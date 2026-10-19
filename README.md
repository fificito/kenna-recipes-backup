# Kenna's Recipes - Bilingual Website Backup

🥘 A beautiful, fully bilingual (English & Spanish) recipe website for Kenna's personal recipe collection.

**Live Site:** https://recetasdekenna.com/

## 📁 Repository Structure

```
kenna-recipes-backup/
├── website/                          # Website files
│   └── public_html/
│       ├── index.html               # English homepage
│       ├── index-es.html            # Spanish homepage
│       ├── sally-lemon-meringue.html        # Sally's recipe (English)
│       ├── sally-lemon-meringue-es.html     # Sally's recipe (Spanish)
│       ├── all-in-one.html          # All-in-one recipe page
│       ├── style.css                # Stylesheet
│       ├── recipes/                 # Recipe subdirectories
│       │   ├── main-course/
│       │   │   ├── canard-a-la-capsicum.html
│       │   │   └── mushroom-risotto.html
│       │   └── Desserts/
│       │       └── classic-lemon-meringue-pie.html
│       └── TRANSLATION-WORKFLOW.md  # Translation workflow guide
├── scripts/                          # Monitoring & automation
│   ├── kenna-watchdog.sh            # Silent health monitoring script
│   └── github-weekly-backup.sh      # Complete website/skills GitHub backup
├── skills/                           # User-maintained Hermes skills
│   ├── recipe-website-manager/
│   ├── shopping-list-manager/
│   └── hermes-automation-setup/
├── config/                           # Sanitized configuration documentation
├── docs/                             # Documentation
│   ├── SETUP.md                     # Setup instructions
│   ├── WORKFLOW.md                  # Translation workflow
│   └── DEPLOYMENT.md                # Deployment guide
└── README.md                         # This file
```

## 🌐 Features

✅ **Fully Bilingual**
- English & Spanish versions of all pages
- Language switcher on every page
- One-click toggle between English ↔ Español

✅ **Professional Translations**
- Native Spanish translations (not machine-generated)
- Cultural food terminology adaptation
- Cooking methods clearly explained in both languages

✅ **Beautiful Design**
- Brown & cream color scheme
- Responsive layout
- Easy navigation between recipes

✅ **Current Recipes**
- Duck with Orange and Capsicum (Pato con Naranja y Capsicum)
- Mushroom Risotto (Risotto de Hongos)
- Classic Lemon Meringue Pie (Tarta Clásica de Merengue de Limón)
- Sally's Lemon Meringue Pie Version (Tarta de Merengue de Limón - Versión Sally)

## 🛡️ Monitoring

**Silent Watchdog:** The site is monitored every 5 minutes via `kenna-watchdog.sh`
- Checks site health (HTTP 200)
- Verifies all recipe files exist
- Confirms file integrity
- **Silent if everything is fine** → Only alerts on errors

## 🚀 Quick Start

### Local Setup
```bash
# Clone the repository
git clone https://github.com/fificito/kenna-recipes-backup.git
cd kenna-recipes-backup

# Copy website files to your hosting
cp -r website/public_html/* /path/to/your/webroot/
```

### Adding New Recipes

1. **Send recipe link to the AI agent**
2. **Receives:**
   - English version: `recipe-name.html`
   - Spanish version: `recipe-name-es.html`
3. **Update both homepages:**
   - `index.html`
   - `index-es.html`
4. **Upload all files to hosting**

See `TRANSLATION-WORKFLOW.md` for detailed workflow.

## 📊 File Organization

### Spanish Recipe Categories
- **Platos Principales** = Main Courses
- **Postres** = Desserts
- **Bebidas** = Beverages
- **Entradas** = Appetizers
- **Ensaladas** = Salads
- **Sopas** = Soups
- **Panes y Repostería** = Breads & Baking
- **Salsas y Aderezos** = Sauces & Dressings

### File Naming Convention
- English: `recipe-name.html`
- Spanish: `recipe-name-es.html`

Example:
- `duck-with-orange.html` (English)
- `duck-with-orange-es.html` (Spanish)

## 🔧 Deployment

**Hosting Provider:** Hostinger with LiteSpeed

**Upload Method:** Hostinger web File Manager. FTP authentication may work, but data transfers time out in the current network environment.

Credentials are stored only in the appropriate hosting control panel or hPanel environment. They are never committed to this repository.

## 📋 Maintenance

### Regular Updates
1. New recipe links are sent to the AI agent
2. Agent extracts & translates to Spanish
3. Both versions created with proper formatting
4. Both homepages updated
5. Files uploaded to hosting

### Monitoring
- Watchdog runs every 5 minutes
- Checks site accessibility
- Verifies file integrity
- Reports errors immediately

## 🌍 Language Support

Currently supported:
- **English** - Full site in English
- **Español** - Full site in Spanish

Both versions are complete with:
- Full recipe content
- Ingredient lists
- Step-by-step instructions
- Professional translations
- Cultural adaptations

## 🔐 Security

- All credentials stored securely
- GitHub uses the hPanel environment variable `KENNA_GITHUB_TOKEN`; its value is never written to disk or committed
- FTP credentials encrypted in hosting provider
- No sensitive data in repository

## 📞 Support

For issues or new recipes:
- Contact Felipe Maurer (fificito)
- Email: felipe@maurer.com.mx
- GitHub: @fificito

## 📄 License

This is a personal recipe collection for Kenna. All rights reserved.

---

**Last Updated:** October 19, 2026
**Website Status:** ✅ Live & Active
**Bilingual Status:** ✅ Complete (English & Spanish)
**Monitoring:** ✅ Active (Silent Watchdog)
