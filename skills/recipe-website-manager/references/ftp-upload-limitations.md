# FTP Upload Limitations & Manual Deployment Workflow

## Problem
Automated FTP uploads to recetasdekenna.com fail with data transfer timeouts on STOR commands. Network firewall on hosting provider (srv458.hstgr.io) blocks data channel transfers even when authentication succeeds.

## Solution: Manual FileZilla Upload
✅ **PROVEN WORKING** — User has successfully tested and confirmed.

### FileZilla Settings
- **Host:** Obtain from the Hostinger FTP configuration panel
- **Username:** Obtain from the Hostinger FTP configuration panel
- **Password:** Stored only in Hostinger; never put it in skills, scripts, Git, or chat
- **Encryption:** None (plain FTP)
- **Passive Mode:** ENABLED ← Critical for firewall compatibility
- **Port:** 21 (default)

### Deployment Process
1. Agent prepares all files locally in `/data/public_html/`
2. Agent sends complete ZIP file via Telegram to user
3. User downloads ZIP on their local machine
4. User extracts ZIP
5. User opens FileZilla with settings above
6. User deletes ALL files on remote `/public_html/`
7. User uploads ALL extracted files from ZIP
8. User verifies recipes appear on site (HTTP 200 on homepages + recipe links clickable)

### Why This Works
- Plain FTP with passive mode avoids active data channel issues
- User controls upload timing (not time-sensitive, can batch multiple recipes)
- No credential exposure in scripts or cron jobs
- Simple, reliable, repeatable

### Asynchronous Workflow
- Agent can prepare unlimited recipes locally
- ZIP files accumulate in `/data/public_html/` for user to download
- User uploads batches when convenient
- No time pressure, no blocking processes
- Files never deleted locally; persist for retry if upload fails

## Related Issues Tested
- ❌ Automated SFTP upload: timeouts on SSH key exchange + data channel
- ❌ Automated cURL upload: timeouts on STOR command
- ❌ Manual FTP with encryption: timeouts on TLS handshake
- ✅ Manual FileZilla (plain FTP, passive mode): 100% success

## GitHub Backups
Separate from user uploads. Weekly cron job (Fridays 6 PM) automatically backs up all local files to https://github.com/fificito/kenna-recipes-backup. This is NOT blocked by firewall and requires no manual intervention.
