#!/usr/bin/env python3
"""Verify, package, and mirror the bilingual recipe website."""
import argparse
import hashlib
import re
import shutil
import zipfile
from pathlib import Path

CAT_RE = re.compile(r'(<h2>.*?</h2>\s*<ul class="recipes-list">)(.*?)(</ul>)', re.S)
LINK_RE = re.compile(r'<a href="([^"]+)">(.*?)</a>', re.S)


def key(value):
    return re.sub(r"\s+", " ", re.sub(r"<[^>]+>", "", value)).strip().casefold()


def groups(text, spanish=False):
    suffix = "-es.html" if spanish else ".html"
    result = []
    for match in CAT_RE.finditer(text):
        items = LINK_RE.findall(match.group(2))
        result.append((
            [href.removesuffix(suffix) for href, _ in items],
            [key(title) for _, title in items],
        ))
    return result


def verify_indexes(en_text, es_text):
    en_groups, es_groups = groups(en_text), groups(es_text, True)
    assert len(en_groups) == len(es_groups) == 9, "expected nine categories"
    for (en_slugs, en_titles), (es_slugs, _) in zip(en_groups, es_groups):
        assert en_titles == sorted(en_titles), "English category is not alphabetized"
        assert en_slugs == es_slugs, "English and Spanish slug order differs"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--slug", required=True)
    ap.add_argument("--source-url", required=True)
    ap.add_argument("--root", default="/data/public_html")
    ap.add_argument("--backup", default="/data/kenna-recipes-backup/website/public_html")
    ap.add_argument("--zip-name", default="recetas-kenna-website.zip")
    args = ap.parse_args()

    root, backup = Path(args.root), Path(args.backup)
    zip_path = root / args.zip_name
    page_names = [f"{args.slug}.html", f"{args.slug}-es.html"]
    required = [
        "index.html", "index-es.html", "style.css", "favicon.svg",
        "favicon.ico", "apple-touch-icon.png", *page_names,
    ]
    for name in required:
        assert (root / name).is_file() and (root / name).stat().st_size > 0, name

    for name in page_names:
        text = (root / name).read_text(encoding="utf-8")
        assert args.source_url in text, f"canonical source missing from {name}"
        assert '<link rel="stylesheet" href="style.css">' in text
        assert "<style" not in text
        for asset in ["favicon.svg", "favicon.ico", "apple-touch-icon.png"]:
            assert asset in text, f"{asset} missing from {name}"

    en_page = (root / page_names[0]).read_text(encoding="utf-8")
    es_page = (root / page_names[1]).read_text(encoding="utf-8")
    assert page_names[1] in en_page and page_names[0] in es_page

    en_index = (root / "index.html").read_text(encoding="utf-8")
    es_index = (root / "index-es.html").read_text(encoding="utf-8")
    verify_indexes(en_index, es_index)
    assert page_names[0] in en_index and page_names[1] in es_index

    files = sorted(p for p in root.iterdir() if p.is_file() and p.name not in {args.zip_name, "favicon-preview.png"})
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as archive:
        for file in files:
            archive.write(file, file.name)

    with zipfile.ZipFile(zip_path) as archive:
        names = archive.namelist()
        assert len(names) == len(files)
        for name in required:
            assert name in names, f"{name} missing from ZIP"
        zip_en = archive.read("index.html").decode("utf-8")
        zip_es = archive.read("index-es.html").decode("utf-8")
        verify_indexes(zip_en, zip_es)
        assert page_names[0] in zip_en and page_names[1] in zip_es
        for name in page_names:
            assert args.source_url in archive.read(name).decode("utf-8")

    backup.mkdir(parents=True, exist_ok=True)
    source_names = {p.name for p in root.iterdir() if p.is_file() and p.name != "favicon-preview.png"}
    for old in backup.iterdir():
        if old.is_file() and not old.name.startswith(".") and old.name not in source_names:
            old.unlink()
    for file in root.iterdir():
        if file.is_file() and file.name != "favicon-preview.png":
            shutil.copy2(file, backup / file.name)

    digest = hashlib.sha256(zip_path.read_bytes()).hexdigest()
    print(f"VERIFIED zip_entries={len(names)} categories=9 ordering=alphabetical mirrored=True favicon=True bytes={zip_path.stat().st_size} sha256={digest}")

if __name__ == "__main__":
    main()
