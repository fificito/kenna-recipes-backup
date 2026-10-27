#!/bin/bash
# Weekly complete backup for Kenna Recipes.
# Copies the website, custom skills, and automation scripts, then commits and pushes.

set -euo pipefail

REPO_DIR="/data/kenna-recipes-backup"
WEBSITE_DIR="/data/public_html"
SKILLS_ROOT="/data/skills"
SCRIPT_DIR="/data/scripts"

if [ ! -d "$REPO_DIR/.git" ]; then
    echo "❌ Backup repository not found: $REPO_DIR" >&2
    exit 1
fi

python3 - <<'PY'
from pathlib import Path
import shutil

repo = Path('/data/kenna-recipes-backup')
website = Path('/data/public_html')

# Copy the complete deployable website, excluding the non-deployment preview image.
web_backup = repo / 'website' / 'public_html'
web_backup.mkdir(parents=True, exist_ok=True)
for source in website.rglob('*'):
    if not source.is_file() or source.name == 'favicon-preview.png':
        continue
    target = web_backup / source.relative_to(website)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)

# Back up the user-maintained skills that define this workflow.
skills = {
    Path('/data/skills/content-management/recipe-website-manager'): repo / 'skills' / 'recipe-website-manager',
    Path('/data/skills/productivity/shopping-list-manager'): repo / 'skills' / 'shopping-list-manager',
    Path('/data/skills/software-development/hermes-automation-setup'): repo / 'skills' / 'hermes-automation-setup',
    Path('/data/skills/typesafe-ai'): repo / 'skills' / 'typesafe-ai',
}
for source, target in skills.items():
    if source.is_dir():
        shutil.copytree(source, target, dirs_exist_ok=True)

# Preserve active automation scripts in both the repository root and scripts directory.
for name in ('github-weekly-backup.sh', 'kenna-watchdog.sh'):
    source = Path('/data/scripts') / name
    if source.is_file():
        shutil.copy2(source, repo / name)
        (repo / 'scripts').mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, repo / 'scripts' / name)
PY

cd "$REPO_DIR"
git add -A

if git diff --cached --quiet; then
    exit 0
fi

COMMIT_MSG="Complete backup: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
git commit -m "$COMMIT_MSG"

# The token value stays in hPanel and is never written to disk or committed.
if [ -n "${KENNA_GITHUB_TOKEN:-}" ]; then
    ASKPASS_FILE=$(mktemp "${TMPDIR:-/data/cache/scratch}/kenna-git-askpass.XXXXXX")
    trap 'rm -f "$ASKPASS_FILE"' EXIT
    cat > "$ASKPASS_FILE" <<'ASKPASS'
#!/bin/sh
case "$1" in
  *Username*) printf '%s\n' 'x-access-token' ;;
  *Password*) printf '%s\n' "$KENNA_GITHUB_TOKEN" ;;
  *) exit 1 ;;
esac
ASKPASS
    chmod 700 "$ASKPASS_FILE"
    GIT_ASKPASS="$ASKPASS_FILE" GIT_TERMINAL_PROMPT=0 git push origin main
else
    git push origin main
fi

echo "✅ Complete GitHub backup: $(git rev-parse --short HEAD)"
