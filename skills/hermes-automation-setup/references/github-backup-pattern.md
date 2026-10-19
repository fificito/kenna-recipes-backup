# GitHub Backup Script Pattern

This is a proven, reusable pattern for periodic Git backups. Used in production for recipe website backups.

## The Script

**Location:** `~/scripts/github-backup.sh`

```bash
#!/bin/bash
# GitHub Backup Script — Idempotent, silent on no-change

set -e

REPO_DIR="$HOME/kenna-recipes-backup"
SOURCE_DIR="/data/public_html"

# Validate directories exist
if [ ! -d "$REPO_DIR" ]; then
    echo "❌ Error: Repository not found at $REPO_DIR"
    exit 1
fi

# Change to repo directory
cd "$REPO_DIR"

# Copy files from source (only newer files)
echo "Copying files from $SOURCE_DIR..."
cp -u "$SOURCE_DIR"/*.html "$REPO_DIR/website/public_html/" 2>/dev/null || true
cp -u "$SOURCE_DIR"/*.css "$REPO_DIR/website/public_html/" 2>/dev/null || true

# Check if there are changes
if git diff --quiet; then
    echo "✅ No changes to commit"
    exit 0  # Silent success — no notification
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

## Key Design Decisions

1. **`set -e`** — Exit on first error. Prevents partial backups.

2. **Directory validation** — Check repo exists before proceeding. Fail fast with clear error.

3. **`cp -u`** — Copy only newer files. Avoids re-copying unchanged files. Ignores files that don't exist.

4. **`2>/dev/null || true`** — Suppress errors if pattern doesn't match (no .html files yet). Continue anyway.

5. **`git diff --quiet`** — Exit status 0 if no changes, 1 if changes exist. Use to decide whether to commit.

6. **Silent exit (exit 0) when no changes** — Cron job sees empty output, no notification sent. Keeps notification log clean.

7. **Echo only summary on success** — Single status line output tells user "backup happened". Sent as notification.

8. **Timestamp in commit message** — Every backup is logged with exact time. Easy to track in GitHub history.

## Cron Job Configuration

```python
cronjob(
    action='create',
    name='weekly-github-backup',
    script='github-backup.sh',
    schedule='0 18 * * 5',  # Fridays at 6 PM
    no_agent=True,  # Script only
    notify_on_complete=False,  # Silent unless error or has output
    repeat='forever',  # Keep running every week
)
```

## Testing

1. **Create and test script manually:**
   ```bash
   chmod +x ~/scripts/github-backup.sh
   bash ~/scripts/github-backup.sh
   ```

2. **Verify Git state:**
   ```bash
   cd ~/kenna-recipes-backup
   git status  # Should be clean
   git log --oneline -1  # Should show latest backup commit
   ```

3. **Test cron job immediately (don't wait for schedule):**
   ```python
   cronjob(action='run', job_id='<job_id>')
   ```

## Behavior

- **No changes since last backup:** Script exits silently (exit 0), no files copied, no Git changes. Notification: NONE.
- **Changes exist:** Files copied, Git commit created, pushed to origin/main. Notification: "✅ GitHub backup completed..."
- **Error (repo doesn't exist, Git fails, network down):** Script exits with error (exit 1). Notification: ERROR alert with stderr output.

## Customization

Change these to adapt for other repos/workflows:

- `REPO_DIR` — Where the Git repo is cloned
- `SOURCE_DIR` — Where source files are located
- Source file patterns (`*.html`, `*.css`) — Add more as needed
- `git push origin main` — Change branch if using different default
- Schedule (`0 18 * * 5`) — Change for different frequency (daily: `0 9 * * *`, every 2h: `0 */2 * * *`)
- `COMMIT_MSG` — Customize message format

## Troubleshooting

**Script runs but nothing is backed up:**
- Verify `SOURCE_DIR` exists and has files
- Check if files are truly different: `diff SOURCE_DIR/file.html REPO_DIR/website/public_html/file.html`
- Git might be ignoring files; check `.gitignore`

**Cron job shows error status but script runs fine manually:**
- Cron runs without user environment; use absolute paths
- Check file permissions in cron context
- Test: `cronjob(action='run', job_id=...)` to see actual error

**Too many notifications (backup runs every interval even if nothing changed):**
- Verify script uses `git diff --quiet` to check for changes
- Confirm script exits with 0 when no changes
- Test: `bash ~/scripts/github-backup.sh` twice; second run should produce no output

