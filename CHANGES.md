# Nexus Theme — Change Checklist

Work through these **one at a time**. Deploy and verify each before moving to the next.

---

## ✅ Done

- [x] Fix Horizon 500 SCSS crash (COMPRESS_PRECOMPILERS)
- [x] Nexus theme loads at startup (`DEFAULT_THEME = 'nexus'`)
- [x] `_variables.scss` / `_styles.scss` placed in `static/` so ScssFilter finds them
- [x] Bootstrap variables imported in `_variables.scss` to fix `$modal-sm` error
- [x] Container starts and compress succeeds
- [x] Custom logo SVG (`img/logo.svg`) used in navbar via `{% themable_asset %}`
- [x] "Nubestack" brand text removed from navbar — logo only
- [x] **1. Accent color** — Changed `#c37d7d` → `#3c7d7d` (teal) in `_variables.scss` and `nexus-vars.css`
- [x] **2. Logo visibility** — SVG teal fills replaced with white so logo is fully visible on teal navbar

---

## 🔲 Pending (do one at a time)

- [x] **3. Splash/login page** — `logo-splash.svg` background updated to `#3c7d7d` teal
- [x] **4. Sidebar accent** — Covered automatically via `$brand-primary` → `$component-active-bg`
- [x] **5. Primary buttons** — Covered automatically via `$brand-primary: #3c7d7d`
- [x] **6. Favicon** — `favicon.ico` (32×32) and `apple-touch-icon.png` (180×180) from nubestack-brand-assets
- [x] **7. Page title** — `SITE_BRANDING = 'Nubestack'` already set
- [x] **8. Logo sizing** — Height fixed to 28px, vertical centering improved, dead `.nexus-brand-text` CSS removed

---

## ✅ All items done!

## GitHub Secrets needed for CI auto-deploy
Add these in **Settings → Secrets → Actions** on the repo:

| Secret | Value |
|---|---|
| `DEPLOY_SSH_KEY` | Private SSH key for `ubuntu@192.168.122.39` |
| `DEPLOY_HOST` | `192.168.122.39` |
| `DEPLOY_USER` | `ubuntu` |

---

## Current Accent Color
`#3c7d7d` (teal)

## Dev Deploy
```bash
bash dev-deploy.sh
```
Builds locally and deploys directly to `ubuntu@192.168.122.39` without waiting for CI.
