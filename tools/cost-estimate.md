# Cost estimate

Rough, planning-level numbers for **one student** running the default lab (two `t3.large` + EBS) in **us-east-1**. Prices are on-demand list and change over time — treat these as ballpark, confirm against the current AWS price list, and remember Learner Lab credit is **small and shared across the whole course**.

## Unit prices (us-east-1, on-demand, approx.)

| Resource | Price |
|----------|-------|
| `t3.large` | ~$0.0832 / hour |
| `t3.medium` | ~$0.0416 / hour |
| `t3.xlarge` | ~$0.1664 / hour |
| EBS gp3 storage | ~$0.08 / GB-month |
| Data transfer (within one VPC/AZ) | ~$0 |

## Running cost (both instances on)

| Config | Compute / hour | Notes |
|--------|----------------|-------|
| 2 × t3.large (default) | **~$0.166 / hr** | the tested default |
| 2 × t3.medium | ~$0.083 / hr | if t3.large is capped or to save credit |
| 2 × t3.xlarge | ~$0.333 / hr | only if apps are sluggish |

Storage (default 40 GB target + 50 GB attacker = 90 GB gp3): **~$7.2 / month**, i.e. **~$0.01 / hour**, and it is billed **whether the instances are running or stopped** (stopped instances keep their disks).

## Stopped cost (the whole point of "stop when done")

When both instances are **stopped**, you pay **only for EBS** — about **$0.24 / day** for 90 GB, and **$0.00** for compute. That is why the #1 rule is stop-at-end: a stopped lab is ~30× cheaper than a running one and you lose nothing (images and the built Kali desktop persist on disk).

## Per-session and per-semester (one student)

Assume a **3-hour** lab session and students **stop** instances afterward.

| Scenario | Compute | + Storage | Total |
|----------|---------|-----------|-------|
| One 3-hour session | 2×t3.large × 3h ≈ **$0.50** | ~$0.03 | **~$0.53** |
| 14 weekly sessions (42 h) | ≈ **$7.0** | ~$3.4 (storage for the semester) | **~$10.4** |
| Same, but 14 sessions left running an extra 3 h each (forgot to stop) | ≈ **$14** | ~$3.4 | **~$17** |
| Disaster: left running 24/7 for the semester | 2×t3.large × ~2500 h ≈ **$415** | ~$25 | **~$440** |

**Takeaways**
- A disciplined semester for one student is **~$10**. That fits a typical Learner Lab budget with room to spare.
- The gap between "~$10" and "~$440" is **entirely** whether students stop their instances. Hammer this in the handout and at the end of every session.
- If budget is tight, drop to **t3.medium** (halves compute) and/or shrink the EBS volumes toward their 30 GB minimum.
- To save even first-boot build time/credit across many sessions, students should **stop** (not terminate) — terminating forces a full re-pull/rebuild (~10–15 min of compute) next time.
