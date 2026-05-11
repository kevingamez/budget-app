// Supabase Edge Function: ai-insights
//
// Proxies Anthropic Messages API requests from the Debt Tracker iOS client so
// the ANTHROPIC_API_KEY is never shipped in the IPA. The function is invoked
// via the Supabase API gateway, which verifies the caller's JWT automatically
// when `verify_jwt = true` is set in supabase/config.toml.
//
// Deploy:
//   supabase functions deploy ai-insights
//
// Set the upstream key once (server-side only):
//   supabase secrets set ANTHROPIC_API_KEY=sk-ant-...

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, content-type, x-client-info, apikey",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const jsonHeaders: Record<string, string> = {
  ...corsHeaders,
  "content-type": "application/json",
};

// Defense-in-depth rate limit per JWT subject. The client throttles too, but a
// modified client could bypass that — the server cap is the actual ceiling.
// Stored in an in-memory map keyed on `sub` claim; each Edge Function instance
// keeps its own counter, so this is conservative against a single attacker but
// not strict across regions. Replace with a kv-store or Postgres if you need
// strict per-day caps.
const DAILY_CAP = 50;
const callsToday = new Map<string, { day: string; count: number }>();

function todayKey(): string {
  return new Date().toISOString().slice(0, 10);
}

function decodeJWTSub(authHeader: string | null): string | null {
  if (!authHeader) return null;
  const token = authHeader.replace(/^Bearer\s+/i, "");
  const parts = token.split(".");
  if (parts.length !== 3) return null;
  try {
    // base64url -> base64
    const payload = parts[1].replace(/-/g, "+").replace(/_/g, "/");
    const padded = payload + "=".repeat((4 - payload.length % 4) % 4);
    const decoded = JSON.parse(atob(padded));
    return typeof decoded.sub === "string" ? decoded.sub : null;
  } catch {
    return null;
  }
}

function checkAndIncrement(sub: string): boolean {
  const today = todayKey();
  const entry = callsToday.get(sub);
  if (!entry || entry.day !== today) {
    callsToday.set(sub, { day: today, count: 1 });
    return true;
  }
  if (entry.count >= DAILY_CAP) return false;
  entry.count += 1;
  return true;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "method not allowed" }),
      { status: 405, headers: jsonHeaders },
    );
  }

  const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
  if (!apiKey) {
    return new Response(
      JSON.stringify({ error: "server misconfigured" }),
      { status: 500, headers: jsonHeaders },
    );
  }

  // Parse the body once so we can inspect consent + forward verbatim.
  let parsed: Record<string, unknown>;
  const rawBody = await req.text();
  try {
    parsed = JSON.parse(rawBody);
  } catch {
    return new Response(
      JSON.stringify({ error: "invalid json body" }),
      { status: 400, headers: jsonHeaders },
    );
  }

  // Consent gate: client must explicitly assert the user opted in. This is a
  // server-side check so a modified or sniffed client can't bypass the local
  // toggle. Pair this with a persisted per-user consent row in Postgres if you
  // need legally durable evidence.
  if (parsed.consent !== true) {
    return new Response(
      JSON.stringify({ error: "consent required" }),
      { status: 403, headers: jsonHeaders },
    );
  }

  // Per-user daily cap.
  const sub = decodeJWTSub(req.headers.get("authorization"));
  if (sub && !checkAndIncrement(sub)) {
    return new Response(
      JSON.stringify({ error: "rate limited" }),
      { status: 429, headers: jsonHeaders },
    );
  }

  // Strip non-Anthropic fields before forwarding. `consent` is ours only.
  const { consent: _consent, ...anthropicBody } = parsed;

  let upstream: Response;
  try {
    upstream = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify(anthropicBody),
    });
  } catch (err) {
    return new Response(
      JSON.stringify({ error: "upstream fetch failed", detail: String(err) }),
      { status: 502, headers: jsonHeaders },
    );
  }

  const text = await upstream.text();
  return new Response(text, {
    status: upstream.status,
    headers: jsonHeaders,
  });
});
