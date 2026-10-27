# Lesson: DVWA — OS command injection

**Target:** DVWA at `http://TARGET_PRIVATE_IP:8081` · **Vuln class:** OS command injection. **Login:** `admin` / `password`. Set **DVWA Security → Low** first (you'll raise it in the stretch goal).

## Learning objectives
After this lesson you can:
- Explain how user input concatenated into a shell command enables arbitrary command execution.
- Exploit it to read files and identify the service account, using Burp.
- Compare the manual exploit with an AI agent's, and judge the reliability of the agent's findings.

## Part A — Manual attack (Burp Suite)
1. Log in, set security to **Low**, open **Command Injection**. The page pings a host you supply.
2. Send a normal request (`127.0.0.1`) through Burp to **Repeater** and confirm it runs `ping`.
3. The input is passed to a shell. Append a second command using a shell separator so both run. Start by identifying the user, then read a sensitive file.
4. Escalate: list the web root, then read the planted flag file at `/flag.txt`.
5. Record each payload and the output it produced.

## Part B — Same scenario with HexStrike AI
1. `hexstrike-start` in a terminal.
2. Goal for the agent:
   > "Web app at http://TARGET:8081 (DVWA, creds admin/password, security Low). Find a command-injection point, prove code execution, and read /flag.txt. Report exact payloads."
3. Save `~/hexstrike-server.log`.

## Part C — Discussion: what did the AI miss or invent?
- Did the agent log in and set security Low on its own, or did it stall at the auth/CSRF-token step? (DVWA uses a per-session CSRF token — note whether the agent handled it.)
- Did it find the injection and actually demonstrate execution, or claim it without showing output?
- Did it try payloads that don't fit the platform (e.g. Windows syntax against a Linux target)? What does that tell you about trusting AI-chosen payloads blindly?

## Stretch goal
Raise DVWA security to **Medium**, then **High**, and see which payloads survive. Explain what each level filters.

## Submission
- Payloads + outputs for user identification and file read.
- Agent transcript excerpt + Part C answers.
- If flags enabled: `/flag.txt` (`FLAG{dvwa_...}`), obtained via the injection.
