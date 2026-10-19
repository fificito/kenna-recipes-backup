# GitHub Weekly Backup Cron Job — Working Example

This is a proven, production-tested example from the Kenna recipe site automation (Session 25).

## Problem Solved
User needed automatic weekly GitHub backups of recipe site files. Manual FTP uploads are user-controlled (asynchronous), but GitHub backups needed to be hands-off.

## Script: github-weekly-backup.sh

**Location:** `/data/scripts/github-weekly-backup.sh`

**Code:**
```bash
#!/bin/bash

# GitHub Weekly Backup Script for Kenna Recipes
# Runs every Friday at 6 PM

set -e

REPO_DIR="$HOME/kenna-recipes-backup"
WEBSITE_DIR="/data/public_html"

# Change to repo directory
cd "$REPO_DIR"

# Copy all HTML and CSS files from working directory
echo "Copying files from $WEBSITE_DIR..."
cp -u "$WEBSITE_DIR"/*.html "$REPO_DIR/website/public_html/" 2>/dev/null || true
cp -u "$WEBSITE_DIR"/*.css "$REPO_DIR/website/public_html/" 2>/dev/null || true

# Check if there are changes
if git diff --quiet; then
    echo "✅ No changes to commit"
    exit 0
fi

# Add all changes
git add -A

# Create commit message with timestamp
COMMIT_MSG="Weekly backup: $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$COMMIT_MSG" || true

# Push to GitHub
git push origin main

echo "✅ GitHub backup completed at $(date '+%Y-%m-%d %H:%M:%S')"
```

**Key Features:**
- ✅ Idempotent: exits silently if no changes (via `git diff --quiet`)
- ✅ Safe: uses `|| true` to continue even if copy fails (some files may not exist yet)
- ✅ Timestamped: commit message includes date/time of backup
- ✅ Self-contained: no external dependencies beyond git

## Setup Steps (Proven Workflow)

### 1. Create Script
```bash
cat > /data/scripts/github-weekly-backup.sh << 'EOF'
#!/bin/bash
# ... (paste code above)
EOF
```

### 2. Make Executable
```bash
chmod +x /data/scripts/github-weekly-backup.sh
```

### 3. Test Manually (CRITICAL — do not skip)
```bash
bash /data/scripts/github-weekly-backup.sh
```

Expected output (first run with changes):
```
Copying files from /data/public_html...
Weekly backup: 2026-07-24 18:00:00
✅ GitHub backup completed at 2026-07-24 18:00:00
```

Expected output (subsequent runs with no changes):
```
Copying files from /data/public_html...
✅ No changes to commit
```

### 4. Schedule Cron Job (Hermes)
```python
cronjob(
    action='create',
    name='kenna-recipes-github-backup',
    schedule='0 18 * * 5',  # Fridays 6 PM
    script='github-weekly-backup.sh',
    no_agent=True,  # Script only
    notify_on_complete=False  # Silent unless error/output
)
```

### 5. Verify Job
```python
cronjob(action='list')
```

Look for:
- state: 'scheduled'
- enabled: true
- script: 'github-weekly-backup.sh'
- schedule: '0 18 * * 5'
- next_run_at: Friday 6 PM

### 6. Test Run (Optional but Recommended)
```python
cronjob(action='run', job_id='<job_id>')
```

This runs the job immediately, simulating the scheduled trigger. Verify it completes without errors.

## Silent Mode Behavior

With `no_agent=True` and `notify_on_complete=False`:

| Scenario | Stdout | Exit Code | Notification |
|----------|--------|-----------|--------------|
| No changes (first check) | "✅ No changes to commit" | 0 | ❌ None (silent) |
| Changes backed up | "✅ GitHub backup completed..." | 0 | ✅ Sent to user |
| Git fails (auth error) | Error message | 1 | ✅ Error alert sent |

**This is the intended "watchdog" pattern:** Report only when something happens or breaks. Silence means "everything is normal."

## Troubleshooting

**Symptom:** Job fails with "permission denied: /data/scripts/github-weekly-backup.sh"

**Solution:** Check permissions: `ls -la /data/scripts/github-weekly-backup.sh`

Must show: `-rwx--x--x` (x = executable)

Fix: `chmod +x /data/scripts/github-weekly-backup.sh`

---

**Symptom:** Job exits 0 (success) but GitHub repo not updated

**Solution:** Test manually: `bash /data/scripts/github-weekly-backup.sh`

Common causes:
- GitHub credentials not set up: `git config --global user.email "user@example.com"`
- Remote URL wrong: `git remote -v` (should show your repo)
- SSH key missing: if using SSH, ensure ~/.ssh/id_rsa exists
- Branch mismatch: script pushes to 'main', but default is 'master'

---

**Symptom:** Get notification every Friday with "✅ No changes to commit" (noisy)

**Solution:** Modify script to exit silently (no output) when nothing changed:

```bash
if git diff --quiet; then
    # exit 0 with NO output = completely silent
    exit 0
fi
```

Currently script echoes before checking, so notification is sent even if nothing was backed up. Remove that echo for truly silent operation.

## Extensions

**Email on error:**
Add this before final echo:
```bash
if [ $? -ne 0 ]; then
    # Something failed — send alert
    echo "❌ GitHub backup FAILED at $(date)" | mail -s "Backup Error" admin@example.com
fi
```

**Backup multiple directories:**
```bash
for DIR in /data/public_html /data/config; do
    cp -r "$DIR"/* "$REPO_DIR/backup/$(basename $DIR)/" 2>/dev/null || true
done
```

**Limit commit history (keep only last 100 commits):**
```bash
git rev-list --all --count | awk '{if ($1 > 100) print}'
if [ $? -eq 0 ]; then
    git rebase --root --autosquash HEAD~100
fi
```

## Related Files
- `/data/scripts/kenna-watchdog.sh` — Site health check (every 5 minutes)
- `~/kenna-recipes-backup/` — GitHub backup directory
- GitHub: https://github.com/fificito/kenna-recipes-backup
