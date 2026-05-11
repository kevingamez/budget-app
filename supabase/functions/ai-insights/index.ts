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

  const body = await req.text();

  let upstream: Response;
  try {
    upstream = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body,
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
