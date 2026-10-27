# Lesson: bWAPP — cross-site scripting (XSS)

**Target:** bWAPP at `http://TARGET_PRIVATE_IP:8083` · **Vuln class:** reflected and stored XSS. **Login:** `bee` / `bug`. Set the **security level to Low**, then choose the XSS bugs from the dropdown.

## Learning objectives
After this lesson you can:
- Explain the difference between reflected and stored XSS and the impact of each.
- Inject and confirm script execution by hand, and craft a payload that does more than `alert(1)` (e.g. steals the session cookie to a listener you control **inside the lab**).
- Judge whether an AI agent confirms real script execution or just flags reflected input.

## Part A — Manual attack (Burp Suite)
1. **Reflected:** choose "XSS - Reflected (GET)". Submit the form, capture in Burp. Inject a script payload into the reflected parameter and confirm it executes in the browser. Then try context variations (inside an attribute, inside an existing tag).
2. **Stored:** choose "XSS - Stored (Blog)". Post an entry containing a script payload. Reload the page and confirm it executes for *every* viewer — that's the stored impact.
3. **Impact demo (in-lab only):** start a simple listener on the attacker (e.g. `python3 -m http.server 8000`) and use a stored payload that sends `document.cookie` to `http://ATTACKER_PRIVATE_IP:8000/`. Confirm the cookie arrives. **Do not** point this at anything outside the lab.
4. Record payloads, the contexts they worked in, and the captured cookie.

## Part B — Same scenario with HexStrike AI
1. `hexstrike-start`.
2. Goal:
   > "App at http://TARGET:8083 (bWAPP, creds bee/bug, security Low). Find reflected and stored XSS, prove execution, and demonstrate cookie theft to a listener on ATTACKER_PRIVATE_IP. Show payloads."
3. Save `~/hexstrike-server.log`.

## Part C — Discussion: what did the AI miss or invent?
- Did the agent confirm **execution**, or did it just report that input was reflected (reflection ≠ XSS if output is encoded)?
- Did it find the **stored** variant, which requires posting then revisiting, or only the easy reflected one?
- Did it invent a working cookie-exfil it never actually verified? Check the listener logs against its claims.

## Submission
- Reflected + stored payloads and evidence of execution; the captured cookie from your in-lab listener.
- Agent transcript excerpt + Part C answers.
- If flags enabled: `/flag.txt` in the bwapp container (`FLAG{bwapp_...}`).
