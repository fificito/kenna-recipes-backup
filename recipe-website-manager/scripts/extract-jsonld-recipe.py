#!/usr/bin/env python3
"""Extract the first schema.org Recipe object from saved HTML."""
import argparse
import gzip
import html
import json
from html.parser import HTMLParser
from pathlib import Path

class JsonLdParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.active = False
        self.buffer = []
        self.blocks = []

    def handle_starttag(self, tag, attrs):
        attrs = {str(k).lower(): str(v).lower() for k, v in attrs}
        if tag.lower() == "script" and attrs.get("type") == "application/ld+json":
            self.active = True
            self.buffer = []

    def handle_data(self, data):
        if self.active:
            self.buffer.append(data)

    def handle_endtag(self, tag):
        if tag.lower() == "script" and self.active:
            self.blocks.append("".join(self.buffer))
            self.active = False


def recipes(value):
    if isinstance(value, dict):
        kind = value.get("@type")
        kinds = kind if isinstance(kind, list) else [kind]
        if "Recipe" in kinds:
            yield value
        for child in value.values():
            yield from recipes(child)
    elif isinstance(value, list):
        for child in value:
            yield from recipes(child)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("html_file")
    ap.add_argument("--all", action="store_true", help="print every Recipe object")
    args = ap.parse_args()

    path = Path(args.html_file)
    raw = path.read_bytes()
    if raw.startswith(b"\x1f\x8b"):
        raw = gzip.decompress(raw)
    parser = JsonLdParser()
    parser.feed(raw.decode("utf-8", errors="replace"))

    found = []
    for block in parser.blocks:
        try:
            found.extend(recipes(json.loads(html.unescape(block))))
        except json.JSONDecodeError:
            continue
    if not found:
        raise SystemExit("No schema.org Recipe object found")

    output = found if args.all else found[0]
    print(json.dumps(output, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()
