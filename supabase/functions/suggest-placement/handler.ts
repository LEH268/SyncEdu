import { requireCaller, requireRole, serviceClient } from "../_shared/auth.ts";
import { GeminiClient } from "../_shared/gemini.ts";
import { guarded, HttpError, json } from "../_shared/http.ts";
import { placementRationalesSchema } from "../_shared/schemas.ts";

/// One assignment, already computed by `suggestPlacements` in
/// `syncedu_core/placement_engine`. The function composes nothing — it takes
/// the decision and writes the prose. The reference did the reverse; this
/// generalises the spec's "computed deterministically, rationale written by
/// the model, not the reverse".
interface IncomingSuggestion {
  studentId: string;
  studentName: string;
  dominantStyle: string | null;
  suggestedClassId: string | null;
  suggestedClassName: string | null;
  suggestedClassTargetStyle: string | null;
  /// The deterministic reason the engine produced, used verbatim if the model
  /// call fails.
  fallbackRationale: string;
}

function validateBody(raw: unknown): IncomingSuggestion[] {
  if (typeof raw !== "object" || raw === null) throw new HttpError(400, "invalid_body");
  const b = raw as Record<string, unknown>;
  if (!Array.isArray(b.suggestions) || b.suggestions.length === 0) {
    throw new HttpError(400, "suggestions_required");
  }
  return b.suggestions.map((item, i): IncomingSuggestion => {
    if (typeof item !== "object" || item === null) {
      throw new HttpError(400, `suggestion_${i}_invalid`);
    }
    const s = item as Record<string, unknown>;
    if (typeof s.studentId !== "string" || typeof s.fallbackRationale !== "string") {
      throw new HttpError(400, `suggestion_${i}_invalid`);
    }
    return {
      studentId: s.studentId,
      studentName: typeof s.studentName === "string" ? s.studentName : "the student",
      dominantStyle: typeof s.dominantStyle === "string" ? s.dominantStyle : null,
      suggestedClassId: typeof s.suggestedClassId === "string" ? s.suggestedClassId : null,
      suggestedClassName: typeof s.suggestedClassName === "string" ? s.suggestedClassName : null,
      suggestedClassTargetStyle:
        typeof s.suggestedClassTargetStyle === "string" ? s.suggestedClassTargetStyle : null,
      fallbackRationale: s.fallbackRationale,
    };
  });
}

function buildPrompt(suggestions: IncomingSuggestion[]): string {
  return [
    `An administrator is placing new students into classes. Each assignment`,
    `below was decided by a deterministic rule: match the student's dominant`,
    `learning style to a class's target learning style, with class size as`,
    `the tiebreaker. Your job is only to write a one-sentence rationale a`,
    `parent could read for each — do not second-guess the assignment or`,
    `suggest a different class.`,
    ``,
    JSON.stringify(
      suggestions.map((s) => ({
        student_id: s.studentId,
        student: s.studentName,
        dominant_style: s.dominantStyle,
        placed_in: s.suggestedClassName,
        class_target_style: s.suggestedClassTargetStyle,
        unplaced: s.suggestedClassId === null,
      })),
    ),
    ``,
    `Return one rationale per student_id.`,
  ].join("\n");
}

export const handler = guarded(async (req: Request): Promise<Response> => {
  if (req.method !== "POST") throw new HttpError(405, "method_not_allowed");

  const caller = await requireCaller(req);
  requireRole(caller, "admin");

  const suggestions = validateBody(await req.json().catch(() => null));
  const db = serviceClient();

  // Every student must belong to this admin's school.
  const ids = suggestions.map((s) => s.studentId);
  const { data: students } = await db
    .from("students")
    .select("id, school_id")
    .in("id", ids);
  const known = new Set(
    (students ?? []).filter((s) => s.school_id === caller.schoolId).map((s) => s.id),
  );
  if (known.size !== new Set(ids).size) throw new HttpError(403, "forbidden");

  // Model writes prose; on any failure we keep the engine's own rationale.
  const rationaleByStudent = new Map<string, string>(
    suggestions.map((s) => [s.studentId, s.fallbackRationale]),
  );
  let source: "ai" | "rule" = "rule";
  try {
    const gemini = GeminiClient.fromEnvironment();
    const { rationales } = await gemini.generateJson<{
      rationales: { student_id: string; rationale: string }[];
    }>({
      prompt: buildPrompt(suggestions),
      schema: placementRationalesSchema(ids),
      temperature: 0.4,
    });
    for (const r of rationales) {
      if (rationaleByStudent.has(r.student_id) && r.rationale.trim().length > 0) {
        rationaleByStudent.set(r.student_id, r.rationale.trim());
      }
    }
    source = "ai";
  } catch (err) {
    console.warn(`suggest-placement: model call failed, using rule rationale: ${err}`);
  }

  const rows = suggestions.map((s) => ({
    id: crypto.randomUUID(),
    school_id: caller.schoolId,
    student_id: s.studentId,
    suggested_class_id: s.suggestedClassId,
    rationale: rationaleByStudent.get(s.studentId) ?? s.fallbackRationale,
    status: "pending",
  }));
  const { error } = await db.from("placement_suggestions").insert(rows);
  if (error) throw new Error(`placement_suggestions insert failed: ${error.message}`);

  return json({
    source,
    suggestions: rows.map((r) => ({
      id: r.id,
      studentId: r.student_id,
      suggestedClassId: r.suggested_class_id,
      rationale: r.rationale,
      status: r.status,
    })),
  });
});
