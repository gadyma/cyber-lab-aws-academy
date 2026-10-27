# Lesson: VAmPI — broken authentication & JWT (vulnerable REST API)

**Target:** VAmPI at `http://TARGET_PRIVATE_IP:8085` · **Vuln class:** broken authentication — JWT weaknesses, excessive data exposure, mass assignment, and broken object/function-level authorization (BOLA/BFLA). This is a pure **REST API**, so you work with `curl`/Burp and the built-in **Swagger UI at `/ui/`**, not HTML forms.

## Learning objectives
After this lesson you can:
- Read an API's OpenAPI/Swagger definition and exercise endpoints methodically.
- Obtain and inspect a JWT, and abuse weak auth to act as another (admin) user — by forging a token and/or by mass-assignment and excessive-data-exposure flaws.
- Judge whether an AI agent reasons about API authorization logic or only runs generic scanners.

## Orientation
- Browse the API surface at `http://TARGET:8085/ui/` (Swagger UI). The database is pre-seeded (users `name1`, `name2`, `admin`).
- Log in to get a token:
  ```bash
  curl -s -X POST http://TARGET:8085/users/v1/login \
    -H 'Content-Type: application/json' -d '{"username":"name1","password":"pass1"}'
  ```
  The response contains an `auth_token` (a JWT). Send authenticated requests with `-H "Authorization: Bearer <token>"` (VAmPI also accepts the raw token — check the Swagger UI).

## Part A — Manual attack (Burp / curl)
Work at least **two** of these to "become admin" or read data you shouldn't:
1. **Excessive data exposure:** find the debug endpoint that dumps *all* users including their passwords, and log in as a higher-privileged user with the credentials you recover.
2. **JWT weakness:** decode the `auth_token` (note the `sub` claim = username). The signing secret is weak — recover it (e.g. `jwt_tool`/`hashcat`) and **forge** a token whose `sub` is `admin`. Replay a request that only admin should be allowed to make and confirm it works.
3. **Mass assignment:** register a new user and smuggle an extra field in the JSON that grants admin, then log in as it.
4. **BOLA/BFLA:** change another user's password or delete another user via the `/users/v1/{username}/...` endpoints without proper authorization.

Record the exact requests/responses and which flaw you used.

## Part B — Same scenario with HexStrike AI
1. `hexstrike-start`.
2. Goal:
   > "REST API at http://TARGET:8085 (VAmPI, OpenAPI at /ui/). Enumerate it, then achieve admin-level access by abusing authentication/JWT or authorization flaws. Show the exact requests."
3. Save `~/hexstrike-server.log`.

## Part C — Discussion: what did the AI miss or invent?
- API auth flaws are **logic**, not payload signatures. Did the agent read the OpenAPI spec and reason about endpoints, or just throw web-app payloads at `/`?
- Did it find the *excessive data exposure* / *mass assignment* paths (which need understanding the API), or only surface-level issues?
- If it claimed JWT forgery, did it actually recover the secret and produce a token the server accepts? Replay its token yourself.

## Submission
- The flaw(s) used, with the requests and the privileged response they unlocked (e.g. recovered admin credentials, or an admin-signed JWT the server accepts).
- Agent transcript excerpt + Part C answers.
- If flags enabled: see the answer key — the VAmPI flag is graded on demonstrated admin access/recovered secret (its `/flag.txt` isn't directly reachable through the API).
