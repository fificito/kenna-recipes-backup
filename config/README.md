# Kenna Recipes — Sanitized Configuration

This directory documents the active workflow without storing credentials or secret values.

## Paths

- Live website workspace: `/data/public_html/`
- Git backup repository: `/data/kenna-recipes-backup/`
- Website backup: `/data/kenna-recipes-backup/website/public_html/`
- Active automation scripts: `/data/scripts/`
- Active Hermes profile: `default`

## GitHub

- Remote repository: `fificito/kenna-recipes-backup`
- Branch: `main`
- Authentication variable: `KENNA_GITHUB_TOKEN`
- The variable is configured in **hPanel → Hermes Agent → Dashboard → Environment**.
- Only the variable name is documented here. Its value must never be committed, written into a remote URL, placed in a script, or sent in chat.
- Automated pushes use a temporary `GIT_ASKPASS` helper that reads the hPanel variable at runtime and deletes itself afterward.

## Backed-Up Skills

- `skills/recipe-website-manager/`
- `skills/shopping-list-manager/`
- `skills/hermes-automation-setup/`

These directories are synchronized from the active `/data/skills/` copies by `github-weekly-backup.sh`.

## Scheduled Automation

- `kenna-recipes-watchdog`
  - Schedule: every 5 minutes
  - Script: `kenna-watchdog.sh`
  - Mode: script-only, silent on success
- `kenna-recipes-github-backup`
  - Schedule: Friday at 18:00 UTC
  - Script: `github-weekly-backup.sh`
  - Mode: script-only

## Website Packaging Rules

- ZIP name: `recetas-kenna-website.zip`
- Includes both homepages, all bilingual recipe pages, `style.css`, and favicon assets.
- English category titles determine alphabetical order.
- Spanish indexes mirror the exact English slug sequence.
- The complete ZIP and website files are stored under `website/public_html/`.

## Hosting

- Deployment is performed with the Hostinger web File Manager.
- FTP authentication works, but data transfers time out from the current network environment.
- Hosting credentials are not stored in this repository.

## Shopping State at This Backup

- Costco: empty
- Super: empty
