# Lab safety, scope, and acceptable use

This lab exists to teach attack and defense **against deliberately vulnerable targets inside an isolated environment**. The same techniques are harmful if pointed anywhere else. These rules are not optional; they are the condition under which the lab is allowed to run on AWS.

---

## 1. Scope — what you may and may not attack

**In scope (allowed):**
- The **target** EC2 instance in **your own** lab VPC, and only the vulnerable apps running on it.
- Only from the **attacker** instance in the same VPC.

**Out of scope (forbidden):**
- Any other AWS resource — the EC2 metadata/control plane, other instances, S3, IAM, billing, the Learner Lab infrastructure itself.
- **Any other student's** lab or account.
- Any host on the public internet.
- The instructor's scoreboard/CTFd account except through its intended web UI.

If an exercise ever seems to require touching something out of scope, stop and ask the instructor. "I was curious" is not authorization.

## 2. AWS penetration-testing policy (summary)

AWS permits customer-initiated security testing of a specific set of your **own** resources (such as EC2 instances you run) **without prior approval**, and this lab is designed to stay inside that boundary: all traffic is attacker→target within one VPC you own.

AWS **prohibits**, among other things:
- Testing resources you do not own or lack permission to test.
- **DoS / DDoS**, simulated DoS, or any volumetric/stress testing. Do not run flooding, stress, or load-generation "attacks" in this lab.
- Activity that disrupts AWS infrastructure or other customers.

Some activities (e.g. large-scale or network-stress testing) require a separate AWS Simulated Event authorization. We do **none** of those here. When in doubt, the rule for this class is simpler than AWS's: **target VM only, no floods, nothing outside the VPC.** See the current AWS Customer Support Policy for Penetration Testing for the authoritative text.

## 3. Egress controls for the AI agent

The attacker runs HexStrike AI, which drives tools under model guidance. To keep the AI (and the student) from reaching outside the lab:

- The attacker security group supports a **Locked** egress mode (`AttackerEgressMode=Locked`): outbound is limited to the lab VPC (`10.20.0.0/16`), DNS, and 443 for the configured `LLMEndpoint`. Run the attack exercises in Locked mode.
- **Known limitation:** Locked mode still allows 443 to any host (so the LLM endpoint keeps working). A motivated agent could in principle reach other HTTPS hosts. For a tighter lab, narrow the `AttackerEgressLlmLocked` rule from `0.0.0.0/0` to a **prefix list** or specific CIDR of your LLM/Bedrock endpoint, or route LLM calls through a Bedrock VPC **interface endpoint** and drop the 443-to-internet rule entirely. Document which you chose.
- The **target** has no inbound from anywhere except the attacker SG, and only enough egress to pull images on first boot.
- Nothing in the lab should ever need to connect **out** to a student's machine or a third-party service other than the LLM and (first boot only) package/image registries.

## 4. Logging & retention (review the AI agent's actions)

The AI agent can act quickly and at scale, so keep a reviewable record:

- **HexStrike server log:** `~/hexstrike-server.log` on the attacker (the `hexstrike-start` launcher writes here). It captures the API/tool activity the agent requested.
- **Shell history / command log:** encourage students to run exercises from a terminal whose history is retained; for graded work, have them submit the relevant portion.
- **Boot/service logs:** `/var/log/lab-userdata.log` and `journalctl -u lab-boot` on each instance.
- **Retention:** because Learner Lab instances are ephemeral (stop/terminate wipes them eventually), copy any logs you need for review **off the instance before End Lab** — e.g. `scp` them to your machine or paste the relevant section into the student's submission. Suggested retention: keep agent command logs for the duration of the course plus the grading-appeal window.
- Treat anything the agent *outputs* (findings, "vulnerabilities", suggested payloads) as **claims to verify**, not facts — see the per-lesson "what did the AI miss or invent?" discussion.

## 5. If something goes wrong

- You think you touched something out of scope → stop, note the time and what happened, tell the instructor. Early disclosure is always better.
- The agent tried to reach an external host → that's exactly what Locked egress is for; report it as a finding, it's a good teaching moment.
- A real credential or secret appears anywhere → do not use it, report it.

**One-line version:** attack only the target VM in your own VPC, no denial-of-service, keep the agent boxed in, log what it does, and stop the instances when you're done.
