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
- [ ] **4. Sidebar accent** — Check sidebar active/hover states pick up the new teal color
- [ ] **5. Primary buttons** — Verify `.btn-primary` uses teal (`$brand-primary`)
- [ ] **6. Favicon** — Replace with Nubestack favicon if desired
- [ ] **7. Page title** — Confirm browser tab shows "Nubestack" (via `SITE_BRANDING`)
- [ ] **8. Logo sizing** — Fine-tune logo height/padding in navbar if needed
- [ ] **9. CI → auto deploy** — Wire `dev-deploy.sh` into workflow or add deploy step

---

## Current Accent Color
`#c37d7d` (rose/mauve) — to be changed to `#3c7d7d` (teal) in item 1

## Dev Deploy
```bash
bash dev-deploy.sh
```
Builds locally and deploys directly to `ubuntu@192.168.122.39` without waiting for CI.
