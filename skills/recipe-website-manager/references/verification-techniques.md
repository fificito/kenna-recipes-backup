# Recipe Website Manager — Verification Techniques

Use this reference after both language pages and both homepage entries are complete. The maintained verifier is the primary gate; these checks validate the produced artifact and Git state rather than repeating ad hoc file counts.

## 1. Run the Maintained Verifier

```bash
python3 scripts/verify-recipe-site.py \
  --slug SLUG \
  --source-url 'CANONICAL_SOURCE_URL'
```

Require a successful `VERIFIED` result. Report only the entry count, byte size, and SHA-256 emitted by this fresh run; never reuse totals from an earlier recipe and never assume a fixed count or minimum ZIP size.

## 2. Inspect the ZIP Semantically

Structural presence is not enough: prove that the packaged pages are the new recipe rather than stale files with the right names.

```python
from pathlib import Path
import hashlib
import zipfile

slug = "recipe-slug"
source_marker = "canonical-source-id-or-url-fragment"
en_marker = "representative English ingredient or quantity"
es_marker = "representative Spanish ingredient or quantity"
archive = Path("/data/public_html/recetas-kenna-website.zip")

required = {
    "index.html",
    "index-es.html",
    "style.css",
    "favicon.svg",
    "favicon.ico",
    "apple-touch-icon.png",
    f"{slug}.html",
    f"{slug}-es.html",
}

with zipfile.ZipFile(archive) as z:
    names = set(z.namelist())
    assert required <= names, sorted(required - names)

    index_en = z.read("index.html").decode("utf-8")
    index_es = z.read("index-es.html").decode("utf-8")
    page_en = z.read(f"{slug}.html").decode("utf-8")
    page_es = z.read(f"{slug}-es.html").decode("utf-8")

    assert f'{slug}.html' in index_en
    assert f'{slug}-es.html' in index_es
    assert source_marker in page_en and source_marker in page_es
    assert en_marker in page_en
    assert es_marker in page_es

    print("entries=", len(z.namelist()))
    print("sha256=", hashlib.sha256(archive.read_bytes()).hexdigest())
```

Choose markers that are specific enough to catch the wrong recipe: a source recipe ID and one distinctive quantity in each language work well.

## 3. Review Mirror Side Effects Before Commit

The verifier mirrors `/data/public_html` into the repository and may remove files from `website/public_html` that are absent from the live site.

```bash
cd /data/kenna-recipes-backup
git status --short --branch
git diff --check
git diff --stat
```

Commit deletions only when they are stale deploy artifacts. Preserve repository documentation, archives, or configuration that does not belong to the website mirror. Remember that `git diff --stat` does not list untracked files; `git status --short` is the authoritative inventory before staging.

## 4. Stage, Commit, Push, and Prove Synchronization

```bash
git add website/public_html
git diff --cached --check
git commit -m "Add bilingual RECIPE recipe"
git push origin main

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git ls-remote origin refs/heads/main | cut -f1)
test "$LOCAL" = "$REMOTE"
git status --short --branch
```

Use the workflow's temporary `GIT_ASKPASS` helper when HTTPS authentication comes from `KENNA_GITHUB_TOKEN`; never print or persist the token value.

## Abort and Pending Rules

Do not send the ZIP when any package check fails, including:

- Either language page or homepage link is absent from the archive.
- The canonical source is absent from either packaged page.
- A representative ingredient marker is absent or belongs to another recipe.
- `style.css` or any required favicon asset is missing.
- English ordering or mirrored Spanish slug order fails.
- The ZIP was not rebuilt after the final edit.

A verified ZIP may still be delivered when only the remote push is blocked. Label it **GitHub pending**, preserve the local commit, report the exact ahead count, and retry synchronization when authentication is restored. Never claim GitHub success until local and remote hashes match and the branch is clean.

## User Delivery

Keep the Telegram response concise: bilingual completion, category, mirrored ordering, fresh ZIP entry count and SHA-256, GitHub synchronization state, then the media path. Do not include a hardcoded expected count or a full recipe inventory.
