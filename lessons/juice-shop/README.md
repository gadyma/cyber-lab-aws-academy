# Lesson: OWASP Juice Shop — SQL injection → authentication bypass

**Target:** Juice Shop at `http://TARGET_PRIVATE_IP:3000` · **Vuln class:** SQL injection in the login form leading to authentication bypass.

## Learning objectives
After this lesson you can:
- Explain how unparameterized SQL in a login query lets an attacker bypass authentication.
- Craft and test a SQLi payload by hand using Burp Repeater.
- Direct an AI agent at the same goal and critically compare its approach and output to yours.

## Part A — Manual attack (Burp Suite)
1. Browse to the app, open **Account → Login**. Put Burp in the path (intercept on).
2. Submit a dummy login (`test@test.com` / `test`) and send the captured `POST /rest/user/login` request to **Repeater**.
3. The body is JSON like `{"email":"test@test.com","password":"test"}`. The email field is concatenated into a SQL query. Replace the email with a payload that makes the `WHERE` clause always true and comments out the rest, so the query returns the first user (the admin).
4. Iterate in Repeater until the response returns an `authentication` token instead of an error. Decode the returned JWT and note which user you logged in as.
5. Record: the exact payload, the request/response, and which account you landed in.

## Part B — Same scenario with HexStrike AI
1. In a desktop terminal: `hexstrike-start`.
2. From your MCP client (wired to the approved LLM endpoint), give the agent the goal:
   > "There is a web app at http://TARGET:3000. Find and exploit an authentication bypass in the login to log in as an administrator. Report the exact request you used."
3. Let it work. Save `~/hexstrike-server.log`.

## Part C — Discussion: what did the AI miss or invent?
Answer in your submission:
- Did the agent find the SQLi, or did it go down an unrelated path (brute force, a different endpoint)? How many requests did it take vs. your manual attempt?
- Did it **invent** anything — claim a vulnerability it didn't actually demonstrate, cite a payload that didn't work, or report a success the response doesn't support? Quote the log.
- Did it verify its own success (decode the token) or just assert it? What would you have to check before trusting its claim in a real engagement?

## Submission
- Your working payload + the Repeater request/response showing the admin token.
- The agent transcript excerpt and your Part C answers.
- If flags are enabled: the contents of `/flag.txt` in the juice-shop container (`FLAG{juiceshop_...}`), obtained through the app where possible.
