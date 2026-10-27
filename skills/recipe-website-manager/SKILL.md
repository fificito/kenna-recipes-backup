---
name: recipe-website-manager
title: Recipe Website Manager
description: Use when maintaining Kenna's bilingual recipe website.
version: 1.1.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [recipes, bilingual, website, deployment, github]
    related_skills: [hermes-automation-setup]
---

# Recipe Website Manager

Automates the complete workflow for adding recipes to a bilingual (English/Spanish) recipe website with compact index format, perfect recipe pages, and one-command ZIP file deployment.

## When to Use

Use for any recipe URL, recipe file, recipe-page correction, homepage reordering, replacement ZIP build, hosting handoff, or GitHub backup related to Kenna's bilingual recipe site.

## Trigger Commands

- **`process recipe link [URL]`** — Extract recipe from any public URL, create bilingual HTML files, update homepages, back up to GitHub, generate ZIP file
- **`process recipe file [attachment]`** — Same workflow for user-provided recipe files

## Workflow Steps

### 1. Establish a Clean Baseline and Reject Duplicates
1. Check `git status --short --branch` in `/data/kenna-recipes-backup`; do not build on unexplained changes.
2. Search `/data/public_html` for the source recipe ID, canonical title, canonical source URL, and proposed slug before creating files.
3. If the recipe already exists, reverify the current ZIP and Git state and resend it; do not create duplicate pages.

### 2. Fetch and Extract the Source
1. For NYT Cooking, fetch the tracked URL with compression enabled:
   ```bash
   curl -L --compressed --max-time 45 -A 'Mozilla/5.0 (compatible)' \
     -o /tmp/recipe-source.html -w 'status=%{http_code} bytes=%{size_download}\n' 'URL'
   ```
2. Parse schema.org Recipe JSON-LD from the downloaded HTML with `scripts/extract-jsonld-recipe.py`; it handles both plain and gzip-compressed files.
3. For Pinterest links, extract `resource_response.data.link` from the pin's `resource-response-data` JSON before fetching the recipe; the pin is provenance, not the recipe source.
4. If the canonical recipe page is WAF-blocked, keep that canonical URL and search the exact title plus domain for same-domain recipe-card surfaces such as `/wprm_print/SLUG` or `/print`. Use search snippets only when they expose the complete card, and cross-check title, author, times, yield, ingredients, and directions against another same-domain result; never substitute a similarly titled recipe from another publisher.
5. Extract the canonical title, author, description, yield, prep/cook/total times, ingredients, instructions, category, cuisine, and canonical source URL. Link the canonical article, not a print endpoint or search-result URL.
6. Preserve source quantities and temperatures exactly. Translate them faithfully; metric equivalents may be added but must not silently replace or distort the source.
7. If the source omits prep or cook time, display `Not specified` / `No especificada` and add a short source-timing note. Never invent a split merely to fill metadata fields.

### 3. Create the Bilingual Recipe Pages
- Create English and Spanish files from the approved page structure, using one concise canonical title without promotional qualifiers.
- When a source title leads with a person, publication, or brand attribution, use the standalone dish name as the display title and preserve the attribution in the linked source subtitle instead; this keeps indexes concise without losing provenance.
- Include the reciprocal language switcher, back link, clickable canonical source link, metadata, ingredients, numbered directions, practical tips, category badges, all favicon links, and external `style.css` only.
- Keep tips grounded in the source or ordinary cooking technique; do not add unsupported claims.
- Determine category from the complete dish presentation, not from one keyword in the title.

### 4. Update the Compact Homepages
**Format:**
- Compact list style (NOT grid/cards)
- Arrow indicators (→) before recipe links
- Minimal spacing, clean typography
- Category headers with emoji
- External `style.css` reference
- Language switcher at top

### 5. Verify, Package, and Mirror the Backup
1. Insert the recipe in the affected English category by English display-title order, then insert the Spanish slug at the identical position.
2. Run `scripts/verify-recipe-site.py --slug SLUG --source-url CANONICAL_URL`; this validates both pages and assets, all nine category orders, mirrored EN/ES slug order, ZIP contents, and the backup mirror.
3. Inspect `git status --short` and the staged/unstaged diff immediately after verification. The mirror removes backup files absent from `/data/public_html`; commit those deletions only when they are stale deploy artifacts, not intentional repository documentation or archives.
4. Treat the verifier's ZIP entry count and SHA-256 as the only reportable package totals; never carry counts forward from a previous recipe.

### 6. Commit and Prove the Push
1. Commit the mirrored website with a descriptive recipe-specific message.
2. For this workflow, confirm `KENNA_GITHUB_TOKEN` is visible to the live container by printing only a presence boolean—never its value.
3. Push HTTPS with a temporary `GIT_ASKPASS` helper that reads `KENNA_GITHUB_TOKEN` at runtime; protect it with mode `700` and delete it with a shell `trap`. Never embed a token in a command, remote URL, committed file, tool output, or chat.
4. Compare `git rev-parse HEAD` with `git ls-remote origin refs/heads/main`; require equality and a clean `git status --short --branch` before claiming GitHub success.
5. If authentication blocks the push, keep the verified local commit, report the exact ahead count, and state that GitHub is pending. After credentials are restored, push the entire queued commit chain and repeat the local/remote hash proof.
6. hPanel environment changes require a full application Stop/Start or Redeploy; Telegram `/restart` restarts only the gateway and does not reload container variables.

### 7. Deliver on Telegram
- Send the verified ZIP as `MEDIA:/data/public_html/recetas-kenna-website.zip`.
- Keep the message concise: bilingual completion, category, mirrored ordering, verified ZIP count, GitHub backup, and local/remote synchronization.
- Do not append a full recipe inventory or repeat deployment instructions unless the user asks.

### 8. Homepage Ordering Rules

**Categories (9), in fixed homepage order:**
1. 🍽️ Appetizers
2. 🥞 Breakfast
3. 🥣 Soups
4. 🥗 Salads
5. 🍝 Main Courses
6. 🧂 Sauces & Condiments
7. 🥔 Side Dishes
8. 🍸 Cocktails
9. 🍌 Desserts

**Recipe ordering within categories (Felipe approved):**
- Sort recipes alphabetically by their **English display title** inside every category.
- Mirror that exact recipe sequence on `index-es.html`; do **not** independently alphabetize Spanish titles.
- Whenever a recipe is added or renamed, re-sort its entire category in `index.html`, then reproduce the same slug order in `index-es.html`.
- Before packaging, verify all 9 English categories are alphabetized and that the English/Spanish slug sequences match category by category.

## Working Directory

- Location: `/data/public_html/`
- All recipe HTML files created here
- style.css located here
- Both homepages edited here
- ZIP file generated here

## Design Standards (Felipe Approved)

**Index/Homepage (COMPACT FORMAT):**
- **Compact list style ONLY** (NOT grid/cards — user rejected cards explicitly)
- Arrow indicators (→) before EVERY recipe link
- Minimal spacing, smaller fonts, clean typography
- Emoji category headers
- External style.css reference ONLY (no inline styles)
- Language switcher at top
- Hover effects on links
- Max width 900px, centered container
- This is the ONLY acceptable format — do not deviate

**Recipe Pages (PERFECT FORMAT):**
- Language switcher (English/Español) + back button
- Title + clickable subtitle link to original source (target="_blank")
- Recipe metadata: Prep time, Cook time, Total time, Servings/Yield; mark source-omitted fields as not specified rather than estimating them
- Ingredients section using the approved `<ul class="recipe-list-styled"><li>…</li></ul>` structure; let the shared stylesheet render bullets rather than hand-prefixing bullet characters
- Numbered instruction steps with circular step numbers
- Notes/Tips section with detailed chef's tips
- Category badges
- Warm brown colors: #5d4037 (dark), #795548 (medium), #c49a7f (light)
- External style.css reference (no inline styles)
- Responsive design (mobile/tablet friendly)
- This format is approved and should NOT change

**All ZIP Files (NON-NEGOTIABLE):**
- ALWAYS include style.css
- ALWAYS include both homepages (index.html + index-es.html)
- ALWAYS include all recipe files (both EN and ES versions)
- ALWAYS include favicon.svg, favicon.ico, and apple-touch-icon.png
- Ready for complete site replacement: user can wipe all files on hosting and upload ZIP contents
- ALWAYS verify before sending to user (see references/verification-techniques.md)
- Use `scripts/extract-jsonld-recipe.py` for saved JSON-LD recipe pages and `scripts/verify-recipe-site.py` for the final package gate.

## Dynamic Site State

- Never store recipe totals, ZIP counts, recent additions, or the current Git commit in this skill; they become stale after every update.
- Derive the current state from `/data/public_html`, the freshly built ZIP, and local/remote Git hashes during each run.
- Homepage format remains the approved compact list, and recipe pages remain fully bilingual.

## Verification Gate (CRITICAL)

Before delivering any ZIP:

1. Run `scripts/verify-recipe-site.py --slug SLUG --source-url CANONICAL_URL` successfully.
2. Confirm the reported archive contains both indexes, `style.css`, all three favicon assets, and both new language pages.
3. Confirm all nine English categories are alphabetized and every Spanish category mirrors the English slug sequence.
4. Open the generated archive and assert that both packaged recipe pages contain the canonical source plus one representative ingredient or quantity from each language page; this catches stale or wrong recipe content that structural checks alone cannot detect.
5. Inspect post-mirror `git status` before staging, then commit and attempt the push; prove local `HEAD` equals remote `main` before claiming GitHub synchronization.
6. If package checks fail, fix and rebuild before delivery. If only remote authentication is blocked, deliver the verified ZIP with an explicit `GitHub pending` warning, preserve the local commits, and report the exact ahead count rather than withholding the working site artifact.

## Critical Pitfalls

**Package-content rule:** Inspect the generated archive itself, not only the working directory; a successful page edit does not prove the delivered ZIP contains the link, stylesheet, assets, and both language pages.

**External-style rule:** Keep all homepages and recipe pages on `style.css`; inline styles fragment future design changes across many files.

**Bilingual-index rule:** Update both indexes in the same patch and verify mirrored slug order; updating only one language makes navigation incomplete.

**Homepage-layout rule:** Preserve the approved compact arrow list; substituting cards or grids violates the user's fixed site design.

**Pinterest-source rule:** Pinterest share and feedback URLs may redirect to `/sent/` and hide the original recipe behind client data. Fetch the pin HTML, parse the `<script data-test-id="resource-response-data" type="application/json">` block, and use `resource_response.data.link` as the original source. Confirm the pin's `grid_title`, description, and domain agree before extracting the recipe from that source. Never treat the Pinterest image URL as the canonical recipe source.

**NYT structured-data rule:** Fetch with `curl -L --compressed` and parse every `application/ld+json` block recursively for an object whose `@type` contains `Recipe`; pages can arrive gzip-compressed and the Recipe object may be nested, so a single regex against one script block is brittle. Use `scripts/extract-jsonld-recipe.py` on the saved response.

**Missing-time rule:** Preserve the source's total time while marking omitted prep/cook fields as not specified; guessing a split turns absent source data into false precision.

**Index-edit rule:** Patch around stable href/title context and inspect the diff. If the patch tool reports a non-exact or context-aware match, compare the entire affected category and restore every unrelated title immediately; fuzzy matching can silently rewrite neighboring translated labels even when slug order remains valid.

**Canonical-title rule:** Remove leading person, publication, brand, and promotional attribution from the homepage display title when the dish name stands alone; retain full provenance in the recipe subtitle and source link.

**Push-proof rule:** A local commit is not a GitHub backup. On push failure, preserve the queued commits and label synchronization as pending with the exact ahead count; claim success only after local and remote hashes match.

## Deployment Instructions

1. Download the newly verified ZIP.
2. Extract every file in the archive; never quote a hardcoded count.
3. Delete the old files in the hosting web root.
4. Upload the complete extracted archive contents.
5. Hard-refresh or reopen the site after deployment, especially when favicon changes are involved.

---

## Web Hosting Options

### Option A: Managed Hosting (Recommended for Simplicity)

**Providers:** Hostinger, cPanel, Plesk, GoDaddy, etc.

**Setup:**
1. Sign up for hosting account
2. Point domain A record to hosting IP (usually automated)
3. Use web file manager or FTP to upload files

**Upload Method (Required for this site):**
- Deliver the verified complete-replacement ZIP through Telegram.
- Deploy with the Hostinger web File Manager; automated FTP/SFTP transfers authenticate but time out during data transfer from the agent environment.
- Keep hosting credentials only in Hostinger. Never store them in skills, scripts, Git, summaries, or chat.

See `references/ftp-upload-limitations.md` for the verified asynchronous deployment workflow.

### Option B: VPS with Python HTTP Server

**When to use:** Full control, custom domain, want to run your own server

**Setup:**
```bash
# Copy files to web directory
mkdir -p ~/public_html
cp -r /path/to/recetas-kenna/* ~/public_html/

# Start Python HTTP server
cd ~/public_html
python3 -m http.server --bind 0.0.0.0 8000

# Set up cron watchdog for persistence
hermes cronjob create \
  --name "web-server-watchdog" \
  --schedule "every 5m" \
  --prompt "Check if python3 HTTP server running on 8000; restart if down"
```

**Domain DNS:** Update A record to point to your VPS's public IP
```bash
curl https://api.ipify.org  # Get your public IP
# Update DNS A record to this IP
# Wait 15-30 minutes for propagation
```

**Port Issues:**
- Ports 80/443 need root access but work externally
- Ports 8000+ may be blocked by ISP/VPS firewall
- If blocked, contact VPS provider or use a reverse proxy (Nginx)

### Option C: All-in-One HTML Fallback (When Upload Methods Fail)

When FTP/SFTP/API all fail, consolidate everything into a single `.html` file:

**Structure:**
```html
<!DOCTYPE html>
<html>
<head>
    <style>
        /* All CSS embedded */
    </style>
</head>
<body>
    <!-- Navigation -->
    <button onclick="showPage('home')">Home</button>
    <button onclick="showPage('recipe1')">Recipe 1</button>

    <!-- All pages -->
    <div id="home" class="page active">
        ... homepage content ...
    </div>
    <div id="recipe1" class="page">
        ... recipe 1 content ...
    </div>

    <script>
        function showPage(name) {
            document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
            document.getElementById(name).classList.add('active');
        }
    </script>
</body>
</html>
```

**Advantages:**
- Upload one file only (via browser)
- No external dependencies
- Works even when FTP blocked
- Fast to update

**Disadvantages:**
- One large file (usually 20-50 KB for recipe site)
- All pages load at once (slower for 100+ recipes)
- Not suitable for large media assets


---

## GitHub Backup Automation

Use the `hermes-automation-setup` skill and its maintained `scripts/github-weekly-backup.sh` rather than creating a second recipe-specific backup implementation. The backup must synchronize the complete website, this skill and its support files, related user-maintained skills, and active automation scripts; then stage, commit, push with `KENNA_GITHUB_TOKEN`, and prove local/remote hash equality.

---

## Monitoring & Watchdog

A silent cron watchdog monitors the site every 5 minutes:
- ✅ Checks if index.html and index-es.html exist and are valid HTML
- ✅ Runs silently if everything is healthy
- ❌ Alerts only if files are missing or corrupted

**Location:** Depends on hosting type
- **Managed Hosting:** No watchdog (provider monitors)
- **VPS:** Use cron job (auto-restart if server crashes)


---

## Troubleshooting Uploads

**FTP login succeeds but file transfer hangs**
- Treat authentication success and data-transfer success as separate checks; a working login does not prove uploads will complete.
- Use the Hostinger web File Manager and the verified replacement ZIP instead of retrying automated FTP/SFTP paths.

**Files uploaded but site shows 404**
- **Cause:** Files in wrong directory or permissions wrong
- **Solution:** Verify files are in web root (usually `~/public_html/` or `/home/user/public_html`)

