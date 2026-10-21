# Reliable GitHub Backup Automation

## Procedure

1. Put the executable script in the exact directory resolved by the cron tool and pass only its filename to the job.
2. Validate every source and destination directory before copying.
3. Copy the complete source tree or an explicit allowlist that includes every deployable asset; narrow `*.html`/`*.css` globs silently omit archives, icons, nested files, and future file types.
4. Copy user-maintained workflow skills with their `references/`, `scripts/`, and `templates/` directories when those skills are part of the recoverable system.
5. Run `git add -A` before deciding whether changes exist. Use `git diff --cached --quiet`; an unstaged diff check misses new untracked files.
6. Exit successfully with empty stdout when there is no staged change.
7. Commit once with a concise timestamped message when staged changes exist.
8. For HTTPS credentials stored in an environment variable, use a temporary `GIT_ASKPASS` helper that reads the variable at runtime. Set mode `700`, remove it with `trap`, and never place the token in a command, URL, repository file, log, or response.
9. Push, compare local `HEAD` with remote branch hash, and require a clean status before reporting success.
10. Run the script a second time; a correct idempotent backup exits 0 with empty stdout.

## Script-Only Cron Configuration

Create the job with a recurring schedule, the script filename, `no_agent=true`, and the intended delivery target. Successful no-change runs stay silent because stdout is empty; non-empty success summaries and failures are delivered.

After creation, list the job and verify its enabled state, schedule, script filename, and next run. Test the script manually before relying on the scheduler.

## Kenna Recipe Site Specialization

Use `scripts/github-weekly-backup.sh`. It synchronizes the complete website, the recipe, shopping-list, and automation skills, plus the active backup and watchdog scripts. Authentication uses the hPanel variable `KENNA_GITHUB_TOKEN`; document only the variable name, never its value.

## Failure Rules

- Preserve local commits when a push fails and report the exact ahead count.
- A local commit is not a remote backup; prove local and remote hashes match.
- Do not rewrite history to purge a previously committed secret without explicit approval. Remove it from the current tree, rotate the credential, and warn that old Git history may retain it.
- A GitHub backup is not a hosting deployment; verify and report them independently.
