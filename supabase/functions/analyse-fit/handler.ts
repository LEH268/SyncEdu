import { assertMayActOnStudent, requireCaller, requireRole, serviceClient } from "../_shared/auth.ts";
import { GeminiClient } from "../_shared/gemini.ts";
import { guarded, HttpError, json } from "../_shared/http.ts";
import { fitObservationSchema } from "../_shared/schemas.ts";

/// analyse-fit scores the teacher's observation text and writes a
/// recommendation sentence. It composes nothing: the 40/30/30 arithmetic is
/// Dart's (`composeFitScore` in syncedu_core). On any model failure it returns
/// `teacherPct: null` and no recommendation, and the console falls back to
/// `ruleBasedRecommendation` computed over the reweighted score — so which
/// path ran is always visible.
interface Body {
  studentId: string;
  observationText: string;
  academicPct: number | null;
  studentPct: number | null;
}

function validateBody(raw: unknown): Body {
  if (typeof raw !== "object" || raw === null) throw new HttpError(400, "invalid_body");
  const b = raw as Record<string, unknown>;
  if (typeof b.studentId !== "string") throw new HttpError(400, "student_id_required");
  if (typeof b.observationText !== "string" || b.observationText.trim().length === 0) {
    throw new HttpError(400, "observation_required");
  }
  const num = (v: unknown): number | null => (typeof v === "number" && isFinite(v) ? v : null);
  return {
    studentId: b.studentId,
    observationText: b.observationText.trim(),
    academicPct: num(b.academicPct),
    studentPct: num(b.studentPct),
  };
}

export const handler = guarded(async (req: Request): Promise<Response> => {
  if (req.method !== "POST") throw new HttpError(405, "method_not_allowed");

  const caller = await requireCaller(req);
  requireRole(caller, "teacher", "admin");

  const body = validateBody(await req.json().catch(() => null));
  const db = serviceClient();
  await assertMayActOnStudent(db, caller, body.studentId);

  const prompt = [
    `You are scoring a teacher's written observation of a student for a`,
    `class-fit analysis. Read the observation and rate, from 0 to 100, how`,
    `well this student fits their current class on the evidence in the text`,
    `alone (100 = an excellent fit, 0 = a clear mismatch). Then write one or`,
    `two sentences of recommendation a teacher could act on.`,
    ``,
    `For context only (do not recompute anything): academic result`,
    `${body.academicPct ?? "n/a"} / 100, student self-report`,
    `${body.studentPct ?? "n/a"} / 100. The final fit score is composed`,
    `elsewhere as 40% academic, 30% student, 30% your observation score.`,
    ``,
    `Observation:`,
    body.observationText,
  ].join("\n");

  try {
    const gemini = GeminiClient.fromEnvironment();
    const result = await gemini.generateJson<{ teacher_pct: number; recommendation: string }>({
      prompt,
      schema: fitObservationSchema(),
      temperature: 0.3,
    });
    const teacherPct = Math.max(0, Math.min(100, Number(result.teacher_pct)));
    return json({
      source: "ai",
      teacherPct,
      recommendation: result.recommendation.trim(),
    });
  } catch (err) {
    console.warn(`analyse-fit: model call failed, deferring to the Dart rule: ${err}`);
    return json({ source: "rule", teacherPct: null, recommendation: null });
  }
});
