# Hosting Upload Limitations and Manual Deployment

## Durable Constraint

The agent can authenticate to the hosting FTP service, but data transfers time out. Do not treat a successful login as proof that uploads work, and do not spend recipe-processing time retrying FTP, SFTP, cURL STOR, or alternate encryption modes.

## Verified Deployment Workflow

1. Build and verify the complete replacement archive at `/data/public_html/recetas-kenna-website.zip`.
2. Confirm the archive contains both indexes, every bilingual recipe page, `style.css`, and all favicon assets.
3. Deliver the ZIP through Telegram.
4. The user opens the Hostinger web File Manager, replaces the remote `public_html/` contents with every extracted archive file, and verifies both homepages and the new recipe links.
5. Keep all local files after delivery so a failed or delayed upload can be retried without rebuilding the recipe.

## Security Rules

- Obtain hosting connection details only from Hostinger when the user performs deployment.
- Never put hosting hostnames tied to the account, usernames, passwords, or connection strings in skills, scripts, Git, summaries, or chat.
- GitHub backup and hosting deployment are independent: a successful Git push does not mean the live site was uploaded.

## Asynchronous Operation

Recipe processing must not block on hosting access. Continue accumulating verified recipes and replacement ZIPs locally; the user can deploy batches through the web File Manager when convenient.
