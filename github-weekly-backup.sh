#!/bin/bash

# GitHub Weekly Backup Script for Kenna Recipes
# Runs every Friday at 6 PM

set -e

REPO_DIR="$HOME/kenna-recipes-backup"
WEBSITE_DIR="/data/public_html"

# Change to repo directory
cd "$REPO_DIR"

# Copy all HTML and CSS files from working directory
echo "Copying files from $WEBSITE_DIR..."
cp -u "$WEBSITE_DIR"/*.html "$REPO_DIR/website/public_html/" 2>/dev/null || true
cp -u "$WEBSITE_DIR"/*.css "$REPO_DIR/website/public_html/" 2>/dev/null || true

# Check if there are changes
if git diff --quiet; then
    echo "✅ No changes to commit"
    exit 0
fi

# Add all changes
git add -A

# Create commit message with timestamp
COMMIT_MSG="Weekly backup: $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$COMMIT_MSG" || true

# Push to GitHub
git push origin main

echo "✅ GitHub backup completed at $(date '+%Y-%m-%d %H:%M:%S')"
