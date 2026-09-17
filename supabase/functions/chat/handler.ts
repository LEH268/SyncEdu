import { requireCaller, requireRole } from "../_shared/auth.ts";
import { GeminiClient } from "../_shared/gemini.ts";
import { guarded, HttpError, json } from "../_shared/http.ts";
import { chatToolDeclarations } from "../_shared/schemas.ts";

interface ChapterContext {
  ordinal: number;
  title: string;
  taught: boolean;
}

interface ChatBody {
  utterance: string;
  studentName: string;
  chapters: ChapterContext[];
}

/// Validates the top-level shape only. The chapter list drives the tool
/// enumeration, so it is checked field by field; the utterance and name are
/// prompt material and only need to be non-empty strings.
function validateBody(raw: unknown): ChatBody {
  if (typeof raw !== "object" || raw === null) {
    throw new HttpError(400, "invalid_body");
  }
  const body = raw as Record<string, unknown>;

  if (typeof body.utterance !== "string" || body.utterance.trim().length === 0) {
    throw new HttpError(400, "utterance_required");
  }
  const studentName = typeof body.studentName === "string" && body.studentName.trim().length > 0
    ? body.studentName.trim()
    : "there";

  if (!Array.isArray(body.chapters)) {
    throw new HttpError(400, "chapters_required");
  }
  const chapters: ChapterContext[] = body.chapters.map((item, i) => {
    if (typeof item !== "object" || item === null) {
      throw new HttpError(400, `chapter_${i}_invalid`);
    }
    const c = item as Record<string, unknown>;
    if (typeof c.ordinal !== "number" || typeof c.title !== "string") {
      throw new HttpError(400, `chapter_${i}_invalid`);
    }
    return { ordinal: c.ordinal, title: c.title, taught: Boolean(c.taught) };
  });
  if (chapters.length === 0) {
    throw new HttpError(400, "chapters_required");
  }

  return { utterance: body.utterance.trim(), studentName, chapters };
}

function buildPrompt(input: ChatBody): string {
  const chapterLines = input.chapters
    .map((c) => `  ${c.ordinal}. ${c.title} -- ${c.taught ? "taught (revision)" : "not yet taught (preview)"}`)
    .join("\n");
  return [
    `You are the friendly AI study companion inside a learning app used by`,
    `${input.studentName}. Keep replies to one or two short sentences.`,
    ``,
    `The only chapters that exist are:`,
    chapterLines,
    ``,
    `When the student asks to do something the app supports -- a quiz,`,
    `flashcards, a story, notes, seeing their progress, or picking a chapter`,
    `-- call the matching tool. Never name or route to a chapter ordinal not`,
    `listed above. If they just want to chat or ask a question, reply in`,
    `words and call no tool.`,
    ``,
    `Student said: "${input.utterance}"`,
  ].join("\n");
}

/// Coerces the STRING-enum args the model returns back into the numbers the
/// Dart side expects, and drops any ordinal the student was not offered.
function normaliseToolCall(
  call: { name: string; args: Record<string, unknown> },
  allowed: Set<number>,
): { name: string; args: Record<string, unknown> } {
  const args = { ...call.args };

  if (Array.isArray(args.chapter_ordinals)) {
    args.chapter_ordinals = args.chapter_ordinals
      .map((v) => Number(v))
      .filter((n) => Number.isInteger(n) && allowed.has(n));
  }
  if (args.chapter_ordinal !== undefined) {
    const n = Number(args.chapter_ordinal);
    if (Number.isInteger(n) && allowed.has(n)) {
      args.chapter_ordinal = n;
    } else {
      delete args.chapter_ordinal;
    }
  }
  if (args.question_count !== undefined) {
    const n = Number(args.question_count);
    args.question_count = Number.isFinite(n) ? Math.round(n) : undefined;
  }

  return { name: call.name, args };
}

export const handler = guarded(async (req: Request): Promise<Response> => {
  if (req.method !== "POST") throw new HttpError(405, "method_not_allowed");

  const caller = await requireCaller(req);
  requireRole(caller, "student");

  const raw = await req.json().catch(() => null);
  const input = validateBody(raw);

  const ordinals = input.chapters.map((c) => c.ordinal);
  const gemini = GeminiClient.fromEnvironment();
  const { reply, toolCall } = await gemini.generateToolCall({
    prompt: buildPrompt(input),
    tools: chatToolDeclarations(ordinals),
  });

  if (toolCall) {
    return json({
      reply,
      toolCall: normaliseToolCall(toolCall, new Set(ordinals)),
    });
  }
  return json({ reply: reply.trim().length > 0 ? reply : "I'm here." });
});
