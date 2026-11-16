// Example function: GET /functions/v1/hello
// Each folder in functions/ is one function; "main" routes requests to them.
// Environment available here: SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY, SUPABASE_DB_URL.

console.log("Hello from Functions!")

Deno.serve(async (req: Request) => {
  let name = "world"
  if (req.method === "POST") {
    try {
      name = (await req.json()).name ?? name
    } catch (_) {
      // no JSON body
    }
  }
  return Response.json({ message: `Hello ${name} from Edge Functions!` })
})
