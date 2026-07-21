#!/bin/bash
# Silent Watchdog for Kenna's Recipes Site
# Only outputs messages if something is wrong
# Returns empty stdout (silent) if everything is healthy

set -e

WEB_ROOT="$HOME/public_html"
LOG_FILE="$HOME/.hermes/logs/kenna-watchdog.log"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Function to check if required files exist locally
check_files_exist() {
    local missing_files=()
    
    if [ ! -f "$WEB_ROOT/index.html" ]; then
        missing_files+=("index.html")
    fi
    if [ ! -f "$WEB_ROOT/index-es.html" ]; then
        missing_files+=("index-es.html")
    fi
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        echo "❌ MISSING FILES: ${missing_files[@]}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Missing files: ${missing_files[@]}" >> "$LOG_FILE"
        return 1
    fi
    return 0
}

# Function to check if files are readable and valid HTML
check_file_integrity() {
    local errors=()
    
    for file in "$WEB_ROOT"/index.html "$WEB_ROOT"/index-es.html; do
        if [ -f "$file" ]; then
            # Check if file is valid HTML (has opening and closing html tags)
            if ! grep -q "<html" "$file" || ! grep -q "</html>" "$file"; then
                errors+=("$(basename $file): Invalid HTML")
            fi
        fi
    done
    
    if [ ${#errors[@]} -gt 0 ]; then
        echo "❌ FILE INTEGRITY ISSUES: ${errors[@]}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Integrity issues: ${errors[@]}" >> "$LOG_FILE"
        return 1
    fi
    return 0
}

# Run all checks
errors=0

if ! check_files_exist; then
    errors=$((errors + 1))
fi

if ! check_file_integrity; then
    errors=$((errors + 1))
fi

# Only output if there are errors
if [ $errors -gt 0 ]; then
    exit 1
fi

# Silent success - no output
exit 0
