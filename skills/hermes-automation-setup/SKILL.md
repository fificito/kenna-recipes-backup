---
name: hermes-automation-setup
title: Hermes Automation Setup
description: Set up and manage cron jobs, background scripts, and automated workflows in Hermes Agent
---

# Hermes Automation Setup

Configure recurring tasks, background monitoring, and scheduled workflows in Hermes Agent with proper script placement, verification, and error handling.

## Trigger

User needs to:
- Create recurring cron jobs (daily, weekly, custom schedules)
- Set up background monitoring or watchdog scripts
- Schedule one-time reminders (single-run cron jobs)
- Back up data periodically
- Run scripts on a schedule (data collection, pings, health checks)

## Key Concepts

### Cron Jobs vs. Scripts

**Cron Job** (in Hermes):
- Defined with `cronjob(action='create', schedule=..., prompt=..., no_agent=...)`
- Can be LLM-driven (agent runs the prompt each tick) or script-only (no_agent=True)
- Runs in a fresh session with no context from current chat
- Schedules: cron syntax ('0 9 * * *'), human-readable ('every 2h'), or ISO timestamp ('2026-06-01T09:00:00')
- Deliverable: auto-sent back to chat, or silent mode (watchdog pattern)
- Persistence: survives across user sessions

**Script File**:
- Bash (.sh, .bash) or Python (.py) file in ~/scripts/ or project-specific directory
- Executed by cron job or terminal for testing
- Should be self-contained (no external context)
- Output (stdout) becomes the cron job's deliverable

### Script Placement Rules

**Standard location:** `$HERMES_HOME/.hermes/scripts/<script-name>.<ext>` (the `cronjob` tool reports the exact required directory if this differs by installation).
- Pass only the script filename to `cronjob(script=...)`; absolute and home-relative paths are rejected.
- Makes scripts discoverable and organized.

**Relative paths in cronjob:**
- `script='kenna-watchdog.sh'` → Hermes resolves it within its managed cron scripts directory (for example `/data/.hermes/scripts/kenna-watchdog.sh`).
- Works even if the cron job runs in a different working directory.

## Script Design Patterns

### Pattern 1: Watchdog (Silent Monitoring)

**Use when:** You want to monitor something and only report if there's an issue.

```bash
#!/bin/bash
# Health check script — report only on error

STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://example.com)

if [ "$STATUS" -eq 200 ]; then
    # Silent success — no output, no notification
    exit 0
else
    # Error — output to stdout, cron sends notification
    echo "⚠️ Website down! Status: $STATUS"
    exit 1
fi
```

**Cron job config:**
```
no_agent=true  # Skip LLM, just run script
notify_on_complete=false  # Silent on success; errors auto-notify
```

### Pattern 2: Data Collection (For Processing)

**Use when:** Script collects data, then agent processes it.

```bash
#!/bin/bash
# Collect metrics, output as structured data

UPTIME=$(uptime | awk -F'load' '{print $1}')
DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}')
DATE=$(date '+%Y-%m-%d %H:%M:%S')

cat <<EOF
{
  "timestamp": "$DATE",
  "uptime": "$UPTIME",
  "disk_usage": "$DISK_USAGE"
}
EOF
```

**Cron job config:**
```
no_agent=false  # LLM will process the output
script='collect-metrics.sh'  # Script runs first
prompt='Summarize the collected metrics and alert if disk > 80%'
```

### Pattern 3: Idempotent Backup (No-Op if Empty)

**Use when:** Backup only if there are changes.

```bash
#!/bin/bash
# Git backup script — silent if nothing changed

set -e
cd ~/my-repo
git add -A

if git diff --cached --quiet; then
    # No changes — silent exit
    exit 0
fi

git commit -m "Backup: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main

echo "✅ Backup completed at $(date '+%Y-%m-%d %H:%M:%S')"
```

**Cron job config:**
```
no_agent=true
notify_on_complete=false  # Silent unless there was a backup
script='github-backup.sh'
schedule='0 18 * * 5'  # Fridays 6 PM
```

**Output behavior:**
- No changes → empty stdout → no notification sent (silent success)
- Changes exist → script outputs summary → notification sent
- Error → non-zero exit → error alert sent

## Workflow: Creating a Recurring Backup Job

### Step 1: Create Script in ~/scripts/

```bash
#!/bin/bash
# my-backup.sh

set -e
cd ~/my-repo
cp -u /data/sources/* ./backup/
git add -A

if git diff --cached --quiet; then
    exit 0  # Silent — no changes
fi

git commit -m "Weekly backup: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main

echo "✅ Backup completed: $(git log -1 --oneline)"
```

Make executable:
```bash
chmod +x ~/scripts/my-backup.sh
```

### Step 2: Test Script Manually

```bash
bash ~/scripts/my-backup.sh
```

Verify:
- Script runs without errors
- Output looks correct
- Files are backed up to Git
- Commit is pushed

### Step 3: Create Cron Job

```python
cronjob(
    action='create',
    name='weekly-backup',
    schedule='0 18 * * 5',  # Fridays 6 PM
    script='my-backup.sh',
    no_agent=True,  # Script only, no LLM
    notify_on_complete=False,  # Silent unless error or output
)
```

### Step 4: Verify Job

```python
cronjob(action='list')
```

Check:
- job_id is recorded
- schedule is correct
- script parameter is set
- state is 'scheduled'
- enabled is true

### Step 5: Test Manual Run (Before Waiting for Schedule)

```python
cronjob(action='run', job_id='<job_id>')
```

This runs the job immediately, same conditions as scheduled run.

## Common Pitfalls

**Pitfall:** Script file not created before scheduling cron job.

**Solution:** ALWAYS create and test the script manually before creating the cron job. Use `bash ~/scripts/my-script.sh` to test. Fix any errors before scheduling. Verify the script exists at the exact path referenced in cronjob(script=...) by listing: `ls -la ~/scripts/` or `ls -la /data/scripts/`.

**Session Note (Session 26):** Cron job was created with script='github-weekly-backup.sh', but the file `/data/scripts/github-weekly-backup.sh` did not exist. Hermes reported error status on the job. Solution: Created the script file, made it executable, tested manually, then cron job worked. Always verify file existence before relying on scheduled run.

**Impact:** Cron job fails silently or sends error alerts on every run. User has to debug and fix script, then recreate job.

---

**Pitfall:** Forgot to make script executable.

**Solution:** After creating script, run `chmod +x ~/scripts/my-script.sh`. Verify with `ls -la ~/scripts/my-script.sh` (should show 'x' in permissions).

**Impact:** Cron job fails with "permission denied" error on every run.

---

**Pitfall:** Script uses relative paths that don't work from cron context.

**Solution:** Use absolute paths in scripts (`/data/sources` not `./sources`). Test script from a different directory to ensure paths work.

**Impact:** Script works manually but fails in cron. Hard to debug because cron runs without user context.

---

**Pitfall:** Script produces too much output in silent mode.

**Solution:** For watchdog patterns, keep output minimal. Use `echo "error message" >&2` to send errors to stderr (they still trigger alerts). For successful runs, output nothing or just a single status line. Redirect verbose output to /dev/null: `command > /dev/null 2>&1` if you don't want it sent as notification.

**Impact:** User gets spammed with notification messages even when nothing is wrong.

---

**Pitfall:** Cron job created but script references change; job still runs old version.

**Solution:** Job reads script file from disk at runtime, so edits to script take effect immediately. No need to recreate job. But ALWAYS test script changes manually first before relying on cron.

**Impact:** Script bugs persist; job appears broken even though code was updated.

---

**Pitfall:** One-time cron job created with forever repeat.

**Solution:** For single-use reminders or one-time tasks, set `repeat=1`. For recurring jobs, omit repeat (defaults to forever) or set explicit number. Always check the next_run_at time — if it's far in the future, verify the schedule is what you intended.

**Impact:** One-time reminder runs every day. Recurring task becomes one-shot. User gets annoyed with duplicate notifications or missing automation.

**Pitfall:** GitHub authentication is stored in a custom hPanel variable, but unattended `git push` does not automatically consume it.

**Solution:** For the Kenna backup workflow, keep the token only in hPanel as `KENNA_GITHUB_TOKEN`. Use a temporary `GIT_ASKPASS` script that reads the variable at runtime, and delete it with a shell `trap`. Never write the token value into the repository, Git remote URL, logs, skill, or script.

**Impact:** Interactive pushes may work temporarily while scheduled backups fail with `could not read Username` or `Invalid username or token`.

---

**Pitfall:** Checking `git diff --quiet` before `git add -A` misses untracked files, including newly created recipe pages and skill files.

**Solution:** Synchronize all required website, skill, and automation files; run `git add -A`; then check `git diff --cached --quiet`. The staged diff is the authoritative test for whether a backup commit is needed.

**Impact:** A backup job can report no changes even though new files were never committed.

---

## Verification Checklist

Before scheduling any cron job:

- [ ] Script file created in ~/scripts/ (or specified path)
- [ ] Script is executable: `ls -la` shows 'x' permission
- [ ] Script tested manually: `bash ~/scripts/my-script.sh` runs successfully
- [ ] Script uses absolute paths (test from different directory)
- [ ] If silent mode (no_agent=True, notify_on_complete=False): verify output is minimal and only errors/status
- [ ] GitHub or backup destination is ready (if relevant)
- [ ] Schedule is correct cron syntax or human-readable
- [ ] repeat parameter set correctly (1 for one-shot, omit or >1 for recurring)
- [ ] no_agent parameter matches intent (True for scripts-only, False to process output)
- [ ] Job created with cronjob(action='create', ...)
- [ ] Job listed with cronjob(action='list', ...) and state is 'scheduled'
- [ ] (Optional) Test run with cronjob(action='run', job_id=...) before relying on schedule

## Reference

See also:
- `references/github-backup-pattern.md` — Reusable backup script design pattern with troubleshooting
- `references/github-weekly-backup-example.md` — Production example from Kenna recipe site automation
- `scripts/github-weekly-backup.sh` — Ready-to-use GitHub backup script (copy and customize for your repo)
- `hermes-agent` skill for full Hermes configuration
- Hermes documentation: https://hermes-agent.nousresearch.com/docs (cronjob section)
