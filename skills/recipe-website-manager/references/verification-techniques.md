# Recipe Website Manager — Verification Techniques

## Verification Checklist (MUST DO BEFORE SENDING ZIP)

This is a MANDATORY quality gate. Do not skip any step.

### Step 1: Verify Recipe Files Exist
```bash
ls -la /data/public_html/recipe-name.html
ls -la /data/public_html/recipe-name-es.html
```

### Step 2: Verify Recipe Link in Homepages (CRITICAL)
```bash
grep -n "recipe-name" /data/public_html/index.html
grep -n "recipe-name" /data/public_html/index-es.html
```

**If grep returns nothing: DO NOT SEND ZIP. The homepage update failed.**

### Step 3: Verify style.css Exists
```bash
ls -la /data/public_html/style.css
```

### Step 4: Verify Index Files Reference External Stylesheet
```bash
grep '<link rel="stylesheet"' /data/public_html/index.html
grep '<link rel="stylesheet"' /data/public_html/index-es.html
```

**Both files must use `<link>` tag. If either has inline `<style>` tags: patch them before creating ZIP.**

### Step 5: Verify style.css is in ZIP (Python)
```python
import zipfile
with zipfile.ZipFile('recetas-kenna-website.zip', 'r') as z:
    if 'style.css' not in z.namelist():
        print("ERROR: style.css missing from ZIP!")
    else:
        print("✅ style.css found in ZIP")
```

### Step 6: Verify Recipe Link in ZIP Contents (Python)
```python
import zipfile
with zipfile.ZipFile('recetas-kenna-website.zip', 'r') as z:
    index_content = z.read('index.html').decode('utf-8')
    if 'recipe-name' in index_content:
        print("✅ Recipe link found in index.html (ZIP)")
    else:
        print("ERROR: Recipe link NOT in index.html (ZIP)!")
    
    index_es_content = z.read('index-es.html').decode('utf-8')
    if 'recipe-name-es' in index_es_content:
        print("✅ Recipe link found in index-es.html (ZIP)")
    else:
        print("ERROR: Recipe link NOT in index-es.html (ZIP)!")
```

### Step 7: Verify ZIP File Count
```python
import zipfile
with zipfile.ZipFile('recetas-kenna-website.zip', 'r') as z:
    print(f"Total files in ZIP: {len(z.filelist)}")
    # Should be 37 + (2 * number of new recipes)
```

### Step 8: Verify GitHub Backup
```bash
cd ~/kenna-recipes-backup
git status  # Should show "working tree clean"
git log --oneline -1  # Show latest commit
```

## Common Verification Failures

### Recipe Link Missing from Homepage
**Symptom:** grep returns nothing for recipe name in index.html/index-es.html

**Cause:** Patch command failed or new category was not created correctly

**Fix:** 
1. Manually check the index file around the correct category
2. Re-run the patch command with correct old_string and new_string
3. Re-verify with grep
4. Only then create ZIP

### style.css Missing from ZIP
**Symptom:** Python zipfile check shows style.css not in namelist

**Cause:** Used shell `zip` command instead of Python; file was not in current directory

**Fix:**
1. Verify `ls -la /data/public_html/style.css` — must exist
2. Re-create ZIP with Python (use the standard script in this repo)
3. Re-verify before sending

### Index Files Have Inline Styles
**Symptom:** grep finds `<style>` tags in index.html/index-es.html

**Cause:** Patch was incomplete; old `<style>` block not fully replaced

**Fix:**
1. Read the file with read_file()
2. Use patch to replace the entire `<style>...</style>` block with `<link rel="stylesheet" href="style.css">`
3. Verify with grep: `grep -c '<style>' /data/public_html/index.html` (should return 0)
4. Then regenerate ZIP

## When to Abort

Do NOT send ZIP if any of these are true:

- [ ] Recipe link not in index.html
- [ ] Recipe link not in index-es.html  
- [ ] style.css missing from filesystem
- [ ] style.css missing from ZIP
- [ ] Index files contain inline `<style>` tags
- [ ] GitHub commit failed or not pushed
- [ ] ZIP file is smaller than 100KB (likely missing files)

## Verification Message to User

Only send ZIP to user with this format:

```
✅ **VERIFIED ZIP FILE - [RECIPE NAME]**

**Verification Summary:**
✅ Recipe files created (English + Spanish)
✅ Both homepages updated with recipe link
✅ style.css included in ZIP
✅ 37 total files verified
✅ GitHub backed up (commit: [HASH])

Download: MEDIA:/data/public_html/recetas-kenna-website.zip
```

Do NOT claim verification if you skipped any step.