# Lessons

One folder per vulnerable app on the target. Every lesson follows the same shape so students and graders always know where to look:

1. **Learning objectives** — what the student should be able to do afterward.
2. **Target** — which app/port, and the specific vulnerability class in focus.
3. **Part A — Manual attack (Burp Suite)** — do it by hand first, so the student understands the mechanism.
4. **Part B — Same scenario with HexStrike AI** — drive the AI agent at the same goal and compare.
5. **Part C — Discussion: what did the AI miss or invent?** — the heart of the course: the AI is a tool whose output must be verified.
6. **Submission** — what to hand in (findings, and the flag if `EnableFlags=true`).

> **Before every lesson:** confirm you are attacking only `TargetPrivateIP` inside your own lab, and that the attacker is in **Locked** egress mode. Reset the target between lessons with `sudo /opt/lab/repo/tools/reset-target.sh`.

## Index

| Lesson | App (port) | Vulnerability in focus |
|--------|-----------|------------------------|
| [juice-shop](juice-shop/) | OWASP Juice Shop (3000) | SQL injection → authentication bypass |
| [dvwa](dvwa/) | DVWA (8081) | OS command injection |
| [webgoat](webgoat/) | WebGoat (8082) | Broken access control / IDOR |
| [bwapp](bwapp/) | bWAPP (8083) | Cross-site scripting (stored & reflected) |
| [mutillidae](mutillidae/) | OWASP Mutillidae II (8084) | Classic UNION-based SQL injection |
| [vampi](vampi/) | VAmPI (8085) | Broken authentication / JWT (vulnerable REST API) |
| [vulnerable-flask](vulnerable-flask/) | Vulnerable Flask App (8086) | Server-side template injection (SSTI) |

Instructor answer keys live in [`../answer-keys/`](../answer-keys/) and are **not** part of the student-facing path.

## Using Burp Suite inside the Kali web desktop

Burp is included in the Kali toolset. Launch it from the desktop menu, set the browser's proxy to `127.0.0.1:8080` (the bundled Burp browser is pre-configured), and target `http://TARGET_PRIVATE_IP:<port>`. Use **Proxy → Intercept** to read/modify requests and **Repeater** to iterate on a single request.

## Using HexStrike AI

Start the server from a desktop terminal with `hexstrike-start`, then drive it from your MCP client wired to the approved LLM endpoint. Give it the **same goal** as the manual exercise (e.g. "find and exploit an authentication bypass on http://TARGET:3000"). Keep `~/hexstrike-server.log` — you'll review what it actually did in Part C.
