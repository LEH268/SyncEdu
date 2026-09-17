const MODEL = "gemini-2.5-flash";
const ENDPOINT =
  `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`;

export interface InlineFile {
  mimeType: string;
  /// base64, without a data: prefix.
  data: string;
}

export interface GenerateOptions {
  prompt: string;
  schema: Record<string, unknown>;
  files?: InlineFile[];
  temperature?: number;
}

export interface ToolCallOptions {
  prompt: string;
  /// Gemini `functionDeclarations` entries.
  tools: Record<string, unknown>[];
  temperature?: number;
}

export interface ToolCallResult {
  reply: string;
  toolCall?: { name: string; args: Record<string, unknown> };
}

type Fetcher = (url: string, init: RequestInit) => Promise<Response>;

// deno-lint-ignore no-explicit-any
type GeminiPayload = any;

/// Calls Gemini with structured output or function calling, rotating across
/// keys.
///
/// Rotation is in-memory and per instance, starting at a random index. A
/// coordinated cursor in Postgres was considered and rejected: it adds a round
/// trip and a contention point to every call, and independent rotation spreads
/// load across keys just as well.
export class GeminiClient {
  constructor(
    private readonly keys: string[],
    private readonly fetcher: Fetcher = fetch,
    startIndex: number = Math.floor(Math.random() * Math.max(keys.length, 1)),
  ) {
    if (keys.length === 0) throw new Error("no Gemini keys configured");
    this.cursor = startIndex % keys.length;
  }

  private cursor: number;

  static fromEnvironment(): GeminiClient {
    const keys = [1, 2, 3]
      .map((n) => Deno.env.get(`GEMINI_API_KEY_${n}`))
      .filter((value): value is string => Boolean(value));
    return new GeminiClient(keys);
  }

  async generateJson<T>(options: GenerateOptions): Promise<T> {
    const parts: Array<Record<string, unknown>> = [{ text: options.prompt }];
    for (const file of options.files ?? []) {
      parts.push({ inline_data: { mime_type: file.mimeType, data: file.data } });
    }

    const body = JSON.stringify({
      contents: [{ parts }],
      generationConfig: {
        responseMimeType: "application/json",
        responseSchema: options.schema,
        temperature: options.temperature ?? 0.7,
      },
    });

    const payload = await this.request(body);
    const text = payload?.candidates?.[0]?.content?.parts?.[0]?.text;
    if (typeof text !== "string") {
      throw new Error("Gemini returned no text part");
    }
    return JSON.parse(text) as T;
  }

  /// Declares [tools] to the model and returns either a plain reply or the one
  /// function call it chose. Prose is never asserted on downstream; only the
  /// tool call's structure is.
  async generateToolCall(options: ToolCallOptions): Promise<ToolCallResult> {
    const body = JSON.stringify({
      contents: [{ role: "user", parts: [{ text: options.prompt }] }],
      tools: [{ functionDeclarations: options.tools }],
      generationConfig: { temperature: options.temperature ?? 0.2 },
    });

    const payload = await this.request(body);
    const parts: GeminiPayload[] = payload?.candidates?.[0]?.content?.parts ?? [];
    let reply = "";
    for (const part of parts) {
      if (typeof part?.text === "string") reply += part.text;
      if (part?.functionCall?.name) {
        return {
          reply,
          toolCall: {
            name: part.functionCall.name as string,
            args: (part.functionCall.args ?? {}) as Record<string, unknown>,
          },
        };
      }
    }
    return { reply };
  }

  /// One request, with key rotation. Returns the parsed response payload.
  private async request(body: string): Promise<GeminiPayload> {
    for (let attempt = 0; attempt < this.keys.length; attempt++) {
      const index = (this.cursor + attempt) % this.keys.length;
      let response: Response;
      try {
        response = await this.fetcher(
          `${ENDPOINT}?key=${encodeURIComponent(this.keys[index])}`,
          { method: "POST", headers: { "content-type": "application/json" }, body },
        );
      } catch (_networkError) {
        // A network-level failure (e.g. a thrown TypeError) can carry the
        // key-bearing URL in its message, so it must never be logged or
        // rethrown. Treat it as retryable and move to the next key.
        console.warn(`gemini key index ${index} threw a network error`);
        continue;
      }

      if (response.ok) {
        this.cursor = index;
        return await response.json();
      }

      // Quota and availability are per-key or transient, so another key may
      // work. A 4xx other than 429 is our fault and will fail identically on
      // every key -- rotating would only burn quota.
      const retryable = response.status === 429 || response.status >= 500;
      const detail = await response.text();
      console.warn(
        `gemini key index ${index} returned ${response.status}` +
          (retryable ? " (rotating)" : " (not retryable)"),
      );
      if (!retryable) {
        throw new Error(`Gemini rejected the request (${response.status}): ${detail.slice(0, 300)}`);
      }
    }

    // Deliberately mentions no key and no index in the client-visible message.
    throw new Error(
      "Gemini key rotation exhausted: every configured key failed (rate limit or network error)",
    );
  }
}
