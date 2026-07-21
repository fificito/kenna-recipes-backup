# Deployment Guide

## Quick Deployment to Hosting

### Prerequisites
- Hostinger account with FTP access
- File manager access at https://srv458-files.hstgr.io/

### Step 1: Prepare Files

All website files are in the `website/public_html/` directory:
```
index.html                    # English homepage
index-es.html                 # Spanish homepage
sally-lemon-meringue.html     # Recipe (English)
sally-lemon-meringue-es.html  # Recipe (Spanish)
```

### Step 2: Upload to Hosting

**Option A: Via File Manager (Recommended)**
1. Go to https://srv458-files.hstgr.io/671474cab92cabb7/files/
2. Log in with your hosting credentials
3. Upload each HTML file to the root directory
4. Files overwrite existing versions

**Option B: Via FTP**
```bash
ftp 45.93.101.155
Username: u328513210
Password: Mami!a11

# Upload files
put index.html
put index-es.html
put sally-lemon-meringue.html
put sally-lemon-meringue-es.html
```

### Step 3: Verify

Visit the live site:
- **English:** https://recetasdekenna.com/
- **Spanish:** https://recetasdekenna.com/index-es.html

## Adding New Recipes

### Recipe Extraction Workflow

1. **Send recipe URL** to the AI agent
2. **Agent provides:**
   - `recipe-name.html` (English)
   - `recipe-name-es.html` (Spanish)
   - Updated `index.html`
   - Updated `index-es.html`

3. **Upload all files** to hosting

### Example: Adding a New Recipe

If adding a chocolate cake recipe:
1. Send: `https://example.com/chocolate-cake`
2. Receive:
   - `chocolate-cake.html`
   - `chocolate-cake-es.html`
   - `index.html` (updated with new link)
   - `index-es.html` (updated with new link)
3. Upload all 4 files

## File Structure on Hosting

```
public_html/ (website root)
├── index.html                       # English home
├── index-es.html                    # Spanish home
├── sally-lemon-meringue.html        # Recipe pages...
├── sally-lemon-meringue-es.html
├── chocolate-cake.html              # New recipes go here
├── chocolate-cake-es.html
└── ... (more recipes as added)
```

## Monitoring & Troubleshooting

### Health Check Script

The `kenna-watchdog.sh` script monitors:
- Site HTTP status (must be 200)
- File existence (all recipe files)
- HTML validity (proper HTML tags)

Run manually:
```bash
bash scripts/kenna-watchdog.sh
```

### Common Issues

**Issue: Recipe page returns 404**
- Ensure file is uploaded to root directory
- Check filename matches exactly
- Verify HTML file is valid

**Issue: Language switcher not working**
- Check that both language versions are uploaded
- Verify filenames: `recipe.html` and `recipe-es.html`
- Ensure links in file are correct

**Issue: Styling not displaying**
- CSS is embedded in each HTML file (no external dependencies)
- Check browser cache and hard refresh (Ctrl+Shift+R)
- Verify HTML file didn't get corrupted on upload

## Backups

This repository serves as the complete backup of:
- ✅ All website HTML files
- ✅ All styling and JavaScript
- ✅ All recipes (current & future)
- ✅ Monitoring scripts
- ✅ Documentation

To restore:
```bash
git clone https://github.com/fificito/kenna-recipes-backup.git
cd kenna-recipes-backup/website/public_html
# Upload all files to hosting
```

## Future Enhancements

Planned features:
- Categories/filtering
- Search functionality
- Recipe ratings
- Cook time estimators
- Ingredient scaling
- Print-friendly versions
- Mobile app version

---

**Last Updated:** July 21, 2026
