# Scoreboard (phase 2, optional)

Because every student runs in a **separate** Learner Lab account, the instructor has no cross-account visibility. The scoreboard solves verification without access: each student's target plants **deterministic, per-student flags**, and the instructor can recompute any flag from `(StudentId, app)` alone.

## How it works

```
flag = FLAG{ <app> _ HMAC-SHA256(FlagSecret, "<StudentId>:<app>")[:16] }
```

- `FlagSecret` is a single secret the instructor chooses and keeps **the same for the whole class** (CloudFormation `FlagSecret` parameter, `NoEcho`).
- `StudentId` is the per-student `StudentId` parameter.
- `<app>` ∈ `juiceshop, dvwa, webgoat, bwapp, mutillidae, vampi, flask`.

On the target, `plant-flags.sh` writes each flag to `/flag.txt` inside that app's container at boot (when `EnableFlags=true`). A student who truly solves an app can read its flag and submit it. The instructor recomputes the expected flag with `verify-flag.sh` and checks — **no access to the student's account required**, and students can't guess another student's flag because it's HMAC'd with the shared secret and their own id.

> WebGoat has no planted flag (it tracks completion internally); grade it on evidence. All others get a `/flag.txt`.

## Naming convention
- Always `FLAG{<app>_<16 lowercase hex>}`.
- `<app>` labels are fixed (see list above) so flags sort and map cleanly in CTFd.
- Example: `FLAG{dvwa_9f3c1a7b2e8d4c05}`.

## Verify one submission
```bash
FLAG_SECRET='your-class-secret' ./verify-flag.sh student-017 dvwa
# prints the expected flag; compare to what the student submitted
```

## Pre-generate flags for a roster (to load into CTFd)
```bash
FLAG_SECRET='your-class-secret' ./generate-flags.sh roster.txt > flags.csv
# roster.txt: one StudentId per line
# flags.csv columns: student_id,app,flag
```

## CTFd on the instructor's own machine/account

CTFd runs in **your** environment (local Docker, or an instance in your own non-Learner account) — not in Learner Lab, and not in student accounts. Students just submit flags to it.

```bash
cd scoreboard
docker compose -f docker-compose.ctfd.yml up -d
# open http://localhost:8000 and run the first-time admin setup
```

Then create one challenge per app, and for the flag use a **regex** so any student's valid flag for that app is accepted, while still proving they solved *that app*:

- Challenge "DVWA" → flag type **regex** → `^FLAG\{dvwa_[0-9a-f]{16}\}$`

To attribute a solve to a specific student (not just "someone solved DVWA"), either:
- load each student's exact flags as **case-sensitive static** flags via `flags.csv` (one challenge per student per app, or CTFd's dynamic/user-specific flag plugins), or
- have students submit through an identified account and spot-check with `verify-flag.sh`.

The regex approach is simplest for a live scoreboard; `verify-flag.sh` is the authoritative per-student check at grading time.

## Security notes
- `FlagSecret` is sensitive: anyone with it can compute every flag. Keep it out of the student-facing path and out of git (it's a `NoEcho` CFN parameter and read from the environment by these scripts — **never commit it**).
- Flags are planted at `/flag.txt`; if an image has a read-only FS the planter warns and that app falls back to evidence-based grading.
