# Instructor guide

How to host the template, test it in your own Learner Lab, run a class session, and recover from the failures Learner Lab most often throws. Read this once in full before a class depends on the lab.

---

## 1. One-time setup: host the template so students can launch it

Students launch the template from **their own** Learner Lab accounts, so it must sit at a public HTTPS URL that CloudFormation can fetch, and the instances must be able to `git clone` the repo at boot. Pick **one** hosting option.

### Option A — public GitHub (simplest)

1. Fork/create this repo under your account and make it **public**.
2. Edit `cfn/student-lab.yaml` → parameter `RepoUrl` default → your fork's HTTPS git URL, e.g. `https://github.com/you/cyber-lab-aws-academy.git`. (This is what the instances clone at boot.)
3. Commit and push. The raw template URL is then:
   ```
   https://raw.githubusercontent.com/you/cyber-lab-aws-academy/main/cfn/student-lab.yaml
   ```
4. Build a **one-click launch link** (URL-encode the raw URL):
   ```
   https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?stackName=cyber-lab&templateURL=https%3A%2F%2Fraw.githubusercontent.com%2Fyou%2Fcyber-lab-aws-academy%2Fmain%2Fcfn%2Fstudent-lab.yaml
   ```
   Give students this link. It opens the Create-stack review screen with the template preloaded; they just fill parameters. (If you teach in us-west-2, change `region=us-east-1` in the link.)

> GitHub raw URLs occasionally rate-limit a whole classroom hitting them at once. If a class of 30 launches simultaneously, prefer Option B.

### Option B — public S3 bucket (robust for a whole class at once)

In **your** account (or any account you control — this is just static hosting, not the students' labs):

```bash
aws s3 mb s3://YOURNAME-cyber-lab --region us-east-1
aws s3 cp cfn/student-lab.yaml s3://YOURNAME-cyber-lab/student-lab.yaml
# make just this object public-readable (adjust if the bucket blocks public ACLs):
aws s3api put-object-acl --bucket YOURNAME-cyber-lab --key student-lab.yaml --acl public-read
```
Template URL: `https://YOURNAME-cyber-lab.s3.amazonaws.com/student-lab.yaml`. Build the one-click link exactly as in Option A with that URL. You still need the repo itself public on GitHub for the boot-time `git clone` (`RepoUrl`).

---

## 2. Test it in YOUR Learner Lab first

Never hand a class an untested stack. In your own Learner Lab:

1. **Start the lab** (AWS Academy → your Learner Lab → **Start Lab**, wait for the dot to go green) and open **AWS Details → AWS CLI** to copy credentials, or click **AWS** to open the console.
2. **Validate the template** (needs your lab credentials loaded locally):
   ```bash
   aws cloudformation validate-template \
     --template-body file://cfn/student-lab.yaml --region us-east-1
   ```
3. **Launch** via the one-click link or:
   ```bash
   aws cloudformation create-stack --stack-name cyber-lab-test \
     --region us-east-1 \
     --template-body file://cfn/student-lab.yaml \
     --parameters \
       ParameterKey=StudentIP,ParameterValue=$(curl -s https://checkip.amazonaws.com)/32 \
       ParameterKey=KasmDesktopPassword,ParameterValue='PickAStrongOne!' \
       ParameterKey=RepoUrl,ParameterValue=https://github.com/you/cyber-lab-aws-academy.git
   ```
   (No `--capabilities` needed — the template creates no IAM.)
4. **Wait for `CREATE_COMPLETE`**, then give the instances **~8–15 min** more for first-boot image pulls and the attacker image build. Watch progress by SSHing to either instance (key via the Learner Lab **vockey**) and `tail -f /var/log/lab-userdata.log`, then `journalctl -u lab-boot -f`.
5. **Read the stack Outputs** (`AttackerDesktopURL`, `TargetPrivateIP`, `TargetAppPorts`, …).
6. **Smoke-test** from the attacker:
   ```bash
   ssh ubuntu@<attacker-public-ip>
   /opt/lab/repo/tools/validate.sh      # TARGET_HOST comes from /opt/lab/lab.env
   ```
7. Open `AttackerDesktopURL` in your browser, accept the self-signed cert, log in as `kasm_user`, open a terminal, run `hexstrike-start`, and confirm you can reach the target apps at `http://<TargetPrivateIP>:<port>`.
8. **Flip egress to Locked** and re-test (see §3), then **delete the test stack**:
   ```bash
   aws cloudformation delete-stack --stack-name cyber-lab-test --region us-east-1
   ```

---

## 3. The egress workflow (important)

The attacker needs the open internet to pull its Kali image and tools on **first boot**, but during the actual attack exercises you want it locked to the lab + the LLM endpoint. Because security-group rules are static, this is a **two-phase** workflow:

1. Deploy with `AttackerEgressMode=Open` (default). Let first boot finish (image build completes, `hexstrike-start` works).
2. **Update the stack** to `AttackerEgressMode=Locked` before students start attacking:
   ```bash
   aws cloudformation update-stack --stack-name cyber-lab \
     --region us-east-1 --template-body file://cfn/student-lab.yaml \
     --parameters ParameterKey=AttackerEgressMode,ParameterValue=Locked \
                  ParameterKey=StudentIP,UsePreviousValue=true \
                  ParameterKey=KasmDesktopPassword,UsePreviousValue=true \
                  ParameterKey=RepoUrl,UsePreviousValue=true
   ```
   In Locked mode the attacker can reach only the lab VPC, DNS, and 443 (for the LLM). `tools/validate.sh` will report egress as BLOCKED. See `docs/safety.md` for narrowing 443 to a true allowlist.

> Teaching tip: the Open→Locked switch is itself a lesson — show students the SG diff and have them confirm with `validate.sh` that exfil paths are gone.

---

## 4. Per-session checklist

**Before class**
- [ ] Your own test stack still deploys clean (re-run §2 after any repo change).
- [ ] One-click link points at the current template; `RepoUrl` points at your public fork.
- [ ] Students know to find their IP (`https://checkip.amazonaws.com`) and set `StudentIP=<ip>/32`.
- [ ] Decide flags on/off (`EnableFlags`, `FlagSecret`) — keep `FlagSecret` identical across students (see `scoreboard/README.md`).

**Start of session**
- [ ] Everyone clicks **Start Lab** and waits for green before launching.
- [ ] Launch via the one-click link; `CREATE_COMPLETE` + ~10 min for boot.
- [ ] Students open `AttackerDesktopURL`, log in, run `hexstrike-start`.
- [ ] Instructor (or students) flip egress to **Locked** (§3).
- [ ] `validate.sh` is green on each workstation.

**End of session (every time)**
- [ ] **STOP both instances** (EC2 → select → Instance state → Stop) — not terminate. Stopped instances keep their disks (and your built image) but stop burning credit.
- [ ] Or just **End Lab** in Learner Lab, which stops everything.
- [ ] Remind students that credit is small and shared across the course.

---

## 5. Troubleshooting (common Learner Lab failures)

| Symptom | Likely cause | Fix |
|--------|--------------|-----|
| Stack `ROLLBACK` immediately, IAM error | Lab blocks IAM; something referenced a role to create | Confirm you're on this template (it creates none). Confirm `LabInstanceProfile` exists: `aws iam list-instance-profiles`. |
| `CREATE_FAILED` on an instance, "instance type not supported" | Size cap in this lab | Set `InstanceType=t3.medium`. |
| Stack ok but desktop never loads after 20 min | First-boot build still running or failed | SSH in; `tail /var/log/lab-userdata.log`; `journalctl -u lab-boot`. Re-run `sudo systemctl restart lab-boot`. |
| `git clone` fails in the log | `RepoUrl` wrong/private, or egress already Locked at first boot | Make the repo public; deploy in **Open** mode first. |
| Kali image pull/build fails | Docker Hub rate limit or image tag gone | Retry (`sudo systemctl restart lab-boot`); or override `KaliDesktopImage` to a tag that pulls; use smaller `KaliToolset=kali-tools-web`. |
| A target app won't come up | One image unavailable/region issue | `cd /opt/lab/repo/tools/target && docker compose logs <svc>`; swap the image tag; the other apps are unaffected. |
| Desktop loads but can't reach target | Egress Locked too early, or wrong IP | Use the **private** `TargetPrivateIP`, not a public IP. Confirm both instances are in the same stack/subnet. |
| Everything was working, now all dead after a break | Session timeout stopped the instances | **Start Lab** again and **Start** the instances; `lab-boot` restores apps automatically (give it a minute). |
| Out of credit / lab won't start | Budget exhausted | Instructor requests a reset via AWS Academy; emphasize stop-when-idle next time. |
| Browser warns about the cert | KasmVNC uses a self-signed cert | Expected — click through. It is only reachable from `StudentIP`. |

---

## 6. What you must verify yourself (cannot be verified outside a live lab)

- `aws cloudformation validate-template` returns clean in your lab.
- `LabRole` / `LabInstanceProfile` exist with those exact names.
- t3.large is permitted (else drop to t3.medium).
- The target images all pull in your region; the Kasm Kali image pulls and builds within your session window.
- HexStrike installs (Kali package or upstream fallback) and `hexstrike-start` reports healthy.
- If you intend to use Bedrock as the LLM: that it's actually enabled in your lab and the model you want is accessible.
