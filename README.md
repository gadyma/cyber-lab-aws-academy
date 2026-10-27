# cyber-lab-aws-academy

Instructor-side teaching lab for **Introduction to Cyber Attack & Defense**, built to run on **AWS Academy Learner Lab**. Each student launches the same CloudFormation template in their **own** Learner Lab account; the instructor cannot reach into student accounts, so everything is a self-service template plus handouts.

> ⚠️ **Scope / ethics.** This lab stands up deliberately vulnerable applications and an attack workstation **inside a single isolated VPC**. All testing must stay inside that VPC. Attacking anything else — other AWS resources, other students, the internet — is out of scope and against the AWS Acceptable Use and pentest policies. See [`docs/safety.md`](docs/safety.md).

## What gets deployed (per student)

```
                 Lab VPC 10.20.0.0/16
   ┌───────────────────────────────────────────────┐
   │  Lab subnet 10.20.1.0/24                        │
   │                                                 │
   │   ATTACKER (t3.large, Ubuntu 22.04)             │
   │     • Kali web desktop (KasmVNC on :6901)       │
   │     • Kali toolset + HexStrike AI MCP server    │
   │     • inbound :6901/:22 only from StudentIP     │
   │              │ attacks (SG-to-SG only)          │
   │              ▼                                   │
   │   TARGET (t3.large, Ubuntu 22.04)               │
   │     • Docker Compose: Juice Shop, DVWA, WebGoat,│
   │       bWAPP, Mutillidae, VAmPI,                 │
   │       Vulnerable Flask — distinct ports         │
   │     • inbound ONLY from the attacker SG         │
   └───────────────────────────────────────────────┘
```

Both instances run an idempotent `tools/lab-boot.sh` via systemd, because Learner Lab **stops** instances on session timeout and they must come back up cleanly.

## Repository layout

| Path | What it is |
|------|------------|
| `cfn/student-lab.yaml` | The CloudFormation template students launch. `LabRole`/`LabInstanceProfile` only; no IAM creation. Validated with cfn-lint. |
| `tools/lab-boot.sh` | Role-aware idempotent boot (systemd `ExecStart`). |
| `tools/target/` | Vulnerable-app `docker-compose.yml`. |
| `tools/attacker/` | Kali-desktop `Dockerfile`, compose, HexStrike launcher. |
| `tools/reset-target.sh` | Clean the target between lessons. |
| `tools/validate.sh` | End-to-end smoke test. |
| `tools/cost-estimate.md` | Hourly / per-semester cost. |
| `docs/instructor-guide.md` | Host the template, test in your own lab, run a session, troubleshoot. |
| `docs/student-quickstart.md` | One-page handout (English + Hebrew). |
| `docs/safety.md` | Scope rules, AWS pentest policy, egress controls, log retention. |
| `lessons/` | One folder per app: objectives, Burp exercise, HexStrike version, discussion. |
| `answer-keys/` | Instructor answer keys (keep OUT of the student-facing path). |
| `scoreboard/` | (Phase 2) CTFd + HMAC per-student flag planter. |

## AWS Academy Learner Lab limits (verify these in YOUR lab — they change)

These constraints shaped the design. **Confirm each one in your own Learner Lab before a class relies on it** — AWS Academy adjusts them per course and over time.

| Limit | Design response |
|-------|-----------------|
| **No IAM role/user creation.** Only the pre-made `LabRole` and `LabInstanceProfile` exist. | Template references `LabInstanceProfile` by name; creates no IAM. |
| **Regions:** typically **us-east-1** and **us-west-2** only. | Template is region-agnostic; AMI resolved via a public SSM alias. Deploy in one of the allowed regions. |
| **Instance sizes capped** (commonly up to t3/t2 "large"-ish; no GPU, no huge types). | `InstanceType` limited to t3.medium/large/xlarge; t3.large default. |
| **Session timeout (~4 h)** stops running instances; budget is small. | systemd + idempotent boot; EBS persists images across stop/start; stop-at-end emphasized everywhere. |
| **Small, shared per-student credit** (a few tens of USD for the course). | Two `t3.large` + EBS; `tools/cost-estimate.md` sizes it; stop-when-idle is the #1 rule. |
| **Marketplace AMIs often unavailable.** | No Marketplace: Ubuntu base + public Docker Hub images; Kali via the Kasm container, not a Marketplace Kali AMI. |
| **Bedrock access NOT guaranteed.** | LLM endpoint is a parameter; Bedrock is optional, documented, never required. |
| **No Elastic IP / NAT guaranteed.** | Single public subnet + the VPC's own IGW; isolation enforced by security groups, not by NAT. |

## Quick start (instructor)

1. Read [`docs/instructor-guide.md`](docs/instructor-guide.md) end to end.
2. Fork this repo publicly and set `RepoUrl` default in `cfn/student-lab.yaml` to your fork (the instances clone it at boot).
3. Test the template in **your own** Learner Lab first (the guide has exact steps).
4. Publish the template and hand students [`docs/student-quickstart.md`](docs/student-quickstart.md).

## Validation status

- `cfn/student-lab.yaml` — **cfn-lint clean** (0 findings).
- all shell scripts — **shellcheck clean** (0 findings).
- `aws cloudformation validate-template` — **passes** (checked with both a standalone account and a live Learner Lab identity).
- **Live Learner Lab inventory (verified 2026-10-27, us-east-1):**
  - `LabRole` and `LabInstanceProfile` exist (profile contains `LabRole`) — the template's IAM assumption holds.
  - `t3.large` is offered in us-east-1.
  - The Ubuntu 22.04 AMI alias resolves (`/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id`).
  - **Bedrock is NOT available** to the `voclabs` role (`bedrock:ListFoundationModels` → AccessDenied). Use an external `LLMEndpoint`; do not rely on Bedrock.
- **Still to do by the instructor:** a live `create-stack` end-to-end run. This needs the repo hosted publicly first (so `RepoUrl` is reachable for the boot-time clone) — see `docs/instructor-guide.md §1`. The stack's resources create independently of the repo; the vulnerable apps and Kali desktop only come up once `RepoUrl` points at a real public fork.
