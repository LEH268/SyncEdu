import { requireCaller, requireRole } from "../_shared/auth.ts";
import { GeminiClient } from "../_shared/gemini.ts";
import { guarded, HttpError, json } from "../_shared/http.ts";
import { classSummarySchema } from "../_shared/schemas.ts";

interface SummariseClassBody {
  className: string;
  heatmap: Record<string, unknown>[];
  mostMissed: Record<string, unknown>[];
  atRisk: { name: string; reasons: string[] }[];
}

/// Validates only the top-level shape: an array of plain objects for each of
/// `heatmap`, `mostMissed` and `atRisk`, and a non-empty `className`. Nested
/// fields (accuracy, band, errorRate, ...) are not individually checked --
/// they are handed to Gemini verbatim as prose material, never used to drive
/// control flow or a query, so a malformed nested field can only ever produce
/// odd prose, not a wrong or unsafe action.
function validateBody(raw: unknown): SummariseClassBody {
  if (typeof raw !== "object" || raw === null) {
    throw new HttpError(400, "invalid_body");
  }
  const body = raw as Record<string, unknown>;

  if (typeof body.className !== "string" || body.className.trim().length === 0) {
    throw new HttpError(400, "class_name_required");
  }

  const isArrayOfObjects = (value: unknown): value is Record<string, unknown>[] =>
    Array.isArray(value) && value.every((item) => typeof item === "object" && item !== null);

  if (!isArrayOfObjects(body.heatmap)) {
    throw new HttpError(400, "heatmap_required");
  }
  if (!isArrayOfObjects(body.mostMissed)) {
    throw new HttpError(400, "most_missed_required");
  }
  const isAtRiskEntry = (item: unknown): item is { name: string; reasons: string[] } => {
    if (typeof item !== "object" || item === null) return false;
    const entry = item as Record<string, unknown>;
    return (
      typeof entry.name === "string" &&
      Array.isArray(entry.reasons) &&
      entry.reasons.every((r: unknown) => typeof r === "string")
    );
  };
  if (!Array.isArray(body.atRisk) || !body.atRisk.every(isAtRiskEntry)) {
    throw new HttpError(400, "at_risk_required");
  }

  return {
    className: body.className,
    heatmap: body.heatmap,
    mostMissed: body.mostMissed,
    atRisk: body.atRisk as { name: string; reasons: string[] }[],
  };
}

/// Builds a prompt out of exactly the figures the caller supplied, so the
/// summary can only ever describe what is already on the teacher's screen.
/// No table is queried here or anywhere else in this handler.
function buildPrompt(input: SummariseClassBody): string {
  return [
    `You are summarising a class analytics dashboard for a teacher of`,
    `"${input.className}". Describe only the figures given below -- do not`,
    `invent any concept, student, or number that is not listed here. Name`,
    `specific concepts and the class by the labels given.`,
    ``,
    `Mastery heatmap (one entry per chapter):`,
    JSON.stringify(input.heatmap),
    ``,
    `Most-missed concepts, ranked worst first:`,
    JSON.stringify(input.mostMissed),
    ``,
    `Students currently flagged at-risk, with reasons:`,
    JSON.stringify(input.atRisk),
    ``,
    `Write a short prose summary (3-5 sentences) a teacher could read in`,
    `passing: what is going well, the weakest concept(s) by name, and which`,
    `students (if any) need attention and why.`,
  ].join("\n");
}

export const handler = guarded(async (req: Request): Promise<Response> => {
  if (req.method !== "POST") throw new HttpError(405, "method_not_allowed");

  const caller = await requireCaller(req);
  // Only a teacher generates a summary of their own class's figures. Admins
  // are deliberately excluded: this endpoint is scoped to the teacher
  // console per the brief, and an admin-facing summary (if ever needed)
  // should go through a school-scoped endpoint of its own rather than widen
  // this one's role check.
  requireRole(caller, "teacher");

  const raw = await req.json().catch(() => null);
  const input = validateBody(raw);

  const gemini = GeminiClient.fromEnvironment();
  const { summary } = await gemini.generateJson<{ summary: string }>({
    prompt: buildPrompt(input),
    schema: classSummarySchema(),
    temperature: 0.4,
  });

  return json({ summary });
});
