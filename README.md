# horizon-nexus

Custom Horizon dashboard theme for [Nubestack](https://nubestack.com), built as a non-invasive overlay on top of [Kolla Horizon](https://quay.io/repository/openstack.kolla/horizon).

---

## What it does

- Replaces logos with Nubestack SVG brand assets
- Applies a modern teal (`#3c7d7d`) UI theme via SCSS
- Customises the login page (teal header, "Powered by OpenStack" tagline, copyright footer)
- Shows the logged-in username in the user dropdown
- Patches quota wheels to render as donuts (d3 innerRadius)
- Sets `DEFAULT_THEME = 'nexus'` and `SITE_BRANDING = 'Nubestack'`

All overrides use safe Horizon extension points — no upstream files are patched.

---

## Repository layout

```
overlay/
  themes/nexus/
    static/
      img/            # logo.svg, favicon.ico, apple-touch-icon.png
      scss/nexus.scss # master theme stylesheet (compiled → css/nexus.css)
      css/nexus.css   # compiled output (committed for Docker build)
    templates/
      base.html                  # injects nexus.css + donut JS patch
      auth/_splash.html          # login logo + tagline
      auth/login.html            # adds copyright footer block
      header/_brand.html         # navbar logo
      header/_user_menu.html     # user dropdown with username header
  global_templates/
    header/_header.html          # moves project selector to right navbar
    header/_brand.html           # navbar brand
  local_settings.d/
    z_nexus_theme.py             # DEFAULT_THEME, SITE_BRANDING, theme list

releases.json   # list of Kolla releases to build (one image each)
Dockerfile      # parameterised via ARG HORIZON_TAG
VERSION         # UI version string (e.g. 1.0.0) — appended to pinned tags
```

---

## Adding or removing a release

Edit **`releases.json`** — the CI pipeline reads it and builds one image per entry:

```json
{
  "_comment": "Kolla Horizon tags: https://quay.io/repository/openstack.kolla/horizon?tab=tags",
  "releases": [
    { "name": "master",  "kolla_tag": "master-ubuntu-noble" },
    { "name": "2025.2",  "kolla_tag": "2025.2-ubuntu-noble" }
  ]
}
```

Each entry produces two Docker Hub tags:

| Tag | Example | Purpose |
|---|---|---|
| `{kolla_tag}-latest` | `master-ubuntu-noble-latest` | Floating — always latest build |
| `{kolla_tag}-{VERSION}` | `master-ubuntu-noble-1.0.0` | Pinned — stable reference |

Auto-deploy to the VM runs only for the `master` release.

---

## Local development

```bash
# Install SCSS compiler
npm ci

# Edit overlay/themes/nexus/static/scss/nexus.scss then compile
npm run build:css

# Smoke check (verifies required files exist and settings are correct)
npm run test:theme

# Build Docker image locally against master Kolla
docker build --build-arg HORIZON_TAG=master-ubuntu-noble -t horizon-nexus:local .
```

### Dev-deploy to VM (bypasses CI)

```bash
bash dev-deploy.sh
```

Builds locally, streams the image via SSH, and redeploys the container on the VM.

---

## CI / CD

Pipeline: `.github/workflows/build.yml`

| Step | What happens |
|---|---|
| `prepare` | Reads `releases.json`, generates a parallel build matrix |
| `build` (matrix) | Builds + pushes both tags for each release |
| `Deploy to VM` | SSH redeploy — fires only for `name == master` |

### Required GitHub Secrets

| Secret | Value |
|---|---|
| `DOCKERHUB_USERNAME` | Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token |
| `DEPLOY_SSH_KEY` | Private key for the VM |
| `DEPLOY_HOST` | VM IP / hostname |
| `DEPLOY_USER` | VM SSH user (e.g. `ubuntu`) |

---

## Upstream references

- [Horizon themes guide](https://docs.openstack.org/horizon/latest/configuration/themes.html)
- [Kolla Horizon guide](https://docs.openstack.org/kolla-ansible/latest/reference/shared-services/horizon-guide.html)
- [Kolla Horizon image tags](https://quay.io/repository/openstack.kolla/horizon?tab=tags)

