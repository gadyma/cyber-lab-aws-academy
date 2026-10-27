# Lesson: WebGoat — broken access control / IDOR

**Target:** WebGoat at `http://TARGET_PRIVATE_IP:8082/WebGoat` · **Vuln class:** broken access control, specifically Insecure Direct Object Reference (IDOR). **Setup:** register a user in WebGoat, log in, and open the **Access Control Flaws → IDOR** lesson.

## Learning objectives
After this lesson you can:
- Distinguish authentication from authorization, and explain why a logged-in user can still access data that isn't theirs.
- Enumerate and manipulate object references (IDs) to reach another user's data, using Burp.
- Evaluate whether an AI agent understands *authorization* logic or only pattern-matches on inputs.

## Part A — Manual attack (Burp Suite)
1. In the IDOR lesson, view **your own** profile and capture the request in Burp. Note the object reference (a numeric/string id) and send it to **Repeater**.
2. View your profile via the direct object URL the lesson reveals. Confirm you can retrieve it by id.
3. Change the id to a neighboring value and resend. Observe whether you can read **another** user's profile without authorization.
4. Complete the lesson's "view another profile" and "edit another profile" steps. Record the ids and responses that prove unauthorized access.

## Part B — Same scenario with HexStrike AI
1. `hexstrike-start`.
2. Goal:
   > "Logged-in app at http://TARGET:8082/WebGoat. Access another user's profile you are not authorized to see by manipulating object references. Show the requests."
3. Save `~/hexstrike-server.log`. (Note: WebGoat is a guided, stateful teaching app behind login — see whether the agent copes with that.)

## Part C — Discussion: what did the AI miss or invent?
- IDOR is a **logic** flaw — there's no error message or payload signature. Did the agent recognize that, or did it look for injection/XSS signatures that don't apply?
- Did it maintain the authenticated session WebGoat requires, or fail at login/session handling?
- Did it correctly conclude *authorization* was broken, or mislabel the finding? How would you confirm an IDOR is real and not just a different view of your own data?

## Submission
- The ids/requests proving you read another user's profile.
- Agent transcript excerpt + Part C answers.
- WebGoat tracks lesson completion in its own UI — screenshot the completed lesson as proof (WebGoat has no planted `/flag.txt`).
