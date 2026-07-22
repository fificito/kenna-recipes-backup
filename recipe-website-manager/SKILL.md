---
name: recipe-website-manager
title: Recipe Website Manager
description: End-to-end bilingual recipe website management for recetasdekenna.com
---

# Recipe Website Manager

Automates the complete workflow for adding recipes to a bilingual (English/Spanish) recipe website with compact index format, perfect recipe pages, and one-command ZIP file deployment.

## Trigger Commands

- **`process recipe link [URL]`** — Extract recipe from any public URL, create bilingual HTML files, update homepages, back up to GitHub, generate ZIP file
- **`process recipe file [attachment]`** — Same workflow for user-provided recipe files

## Workflow Steps

### 1. Recipe Extraction & Creation
- Curl the recipe URL or read uploaded file
- Extract title, ingredients, instructions, cook times, source
- Create English recipe HTML file (e.g., `bananas-flambe.html`)
- Create Spanish translation (e.g., `bananas-flambe-es.html`)
- Determine appropriate category

### 2. Recipe Page Format (Fixed Template)
**Structure:**
- Language switcher (English/Español)
- Back button to homepage
- Header with title + clickable subtitle link to original source
- Recipe metadata: Prep time, Cook time, Total time, Servings
- Ingredients section with bullet points
- Numbered instruction steps with step numbers in circles
- Notes/Tips section with detailed chef's tips
- Category badges

**Styling:**
- External `style.css` reference (no inline styles)
- Warm brown color scheme: #5d4037, #795548, #c49a7f
- Clean typography, minimal padding
- Responsive design

### 3. Homepage Update (Compact Index Format)
**Format:**
- Compact list style (NOT grid/cards)
- Arrow indicators (→) before recipe links
- Minimal spacing, clean typography
- Category headers with emoji
- External `style.css` reference
- Language switcher at top

**Categories (9):**
- 🍽️ Appetizers
- 🥞 Breakfast
- 🥣 Soups
- 🥗 Salads
- 🍝 Main Courses
- 🧂 Sauces & Condiments
- 🥔 Side Dishes
- 🍌 Desserts

### 4. GitHub Backup
- Copy files to `~/kenna-recipes-backup/website/public_html/`
- Commit with descriptive message
- Push to GitHub

### 5. ZIP File Generation
- Include ALL files: HTML files + style.css
- Create `recetas-kenna-website.zip`
- Verify style.css is included
- Verify both index files have recipe links

### 6. Delivery & Verification
- Send ZIP file to Telegram
- Send summary with complete recipe list
- Include deployment instructions

## Working Directory

- Location: `/data/public_html/`
- All recipe HTML files created here
- style.css located here
- Both homepages edited here
- ZIP file generated here

## Design Standards (Felipe Approved)

**Index/Homepage:**
- Compact list style (NOT grid/cards)
- Arrow indicators before links
- Minimal spacing, smaller fonts
- Emoji category headers
- External style.css reference

**Recipe Pages:**
- Metadata section
- Ingredient lists with bullets
- Numbered steps with circular numbers
- Notes/Tips section
- Warm brown colors
- Language switcher + back button
- Clickable source links

**All ZIP Files:**
- Always include style.css
- Ready for complete site replacement
- Always verify before sending

## Current State

**Active Site:** 17 recipes across 9 categories, fully bilingual
- Total files in ZIP: 37 (36 HTML + 1 CSS)
- Homepage format: Compact list
- Recipe page format: Perfect (approved)

## Verification Checklist

- [ ] Recipe files created (English + Spanish)
- [ ] Both index files updated
- [ ] style.css included in ZIP
- [ ] Both index files reference style.css
- [ ] Recipe link appears in both homepages
- [ ] GitHub commit successful
- [ ] ZIP verified with all files

## Common Pitfalls

**Pitfall:** Forgetting style.css in ZIP
**Solution:** Verify with `ls -la /data/public_html/style.css` before ZIP

**Pitfall:** Index files with inline styles
**Solution:** Use `<link rel="stylesheet" href="style.css">` only

**Pitfall:** Recipe missing from one homepage
**Solution:** Always update BOTH index.html AND index-es.html

**Pitfall:** Not verifying recipe in homepage
**Solution:** Use `grep -n "recipe-name" /data/public_html/index*.html`

**Pitfall:** Using grid/card layout
**Solution:** Keep compact list format with arrow indicators only

## Deployment Instructions

1. Download ZIP file
2. Extract all 37 files
3. Delete ALL files on hosting
4. Upload ALL 37 files
5. Site is live!