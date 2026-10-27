# Lesson: OWASP Mutillidae II — UNION-based SQL injection

**Target:** Mutillidae at `http://TARGET_PRIVATE_IP:8084` · **Vuln class:** classic UNION-based SQL injection with data extraction. Set **Security Level: 0 (low)** from the top toolbar. Use **OWASP Top 10 → Injection → SQLi → "User Info (SQL)"**.

## Learning objectives
After this lesson you can:
- Determine the number and types of columns in a query using `ORDER BY` / `UNION SELECT`.
- Extract data from other tables (user credentials, schema) via a UNION payload.
- Compare manual, methodical extraction with an AI agent's and `sqlmap`'s, and reason about when automation helps vs. misleads.

## Part A — Manual attack (Burp Suite)
1. On "User Info", submit a normal username and capture the request in Burp → **Repeater**.
2. Confirm injectability: a single quote in the username should change the response (error or different output).
3. **Find the column count** by incrementing `ORDER BY N` until it breaks, or by testing `UNION SELECT` with increasing column counts.
4. **Find displayed columns**, then build a `UNION SELECT` that places useful data (database version, current user, then the credentials table) into the visible columns.
5. Extract the username/password table. Record every payload and the rows you recovered.

## Part B — Same scenario with HexStrike AI
1. `hexstrike-start`.
2. Goal:
   > "App at http://TARGET:8084 (Mutillidae, security level 0). Find the SQL injection in User Info, enumerate the database, and extract stored user credentials. Report payloads and findings."
3. Save `~/hexstrike-server.log`. If the agent invokes `sqlmap`, capture that output too.

## Part C — Discussion: what did the AI miss or invent?
- Did the agent reproduce the methodical steps (column count → visible columns → extraction), or jump straight to a tool? Did the tool actually succeed?
- Did it correctly report the **schema/credentials**, or hallucinate table/column names that don't exist in this app? Verify against what you extracted manually.
- When `sqlmap` and the agent disagree with your manual result, which do you trust and why?

## Submission
- Your `ORDER BY`/`UNION` payloads and the extracted credentials.
- Agent (and `sqlmap`) transcript excerpt + Part C answers.
- If flags enabled: `/flag.txt` in the mutillidae container (`FLAG{mutillidae_...}`).
