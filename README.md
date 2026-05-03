# Horizon Nexus

A production-grade OpenStack Horizon rebranding system. Automatically tracks
multiple OpenStack releases, detects upstream Kolla Horizon image changes via
digest comparison, builds a themed container per release, and pushes versioned
images to Docker Hub under **ahmadfsbd/horizon-nexus**.

---

## 1. Architecture Overview

Horizon Nexus is built on the **upstream base + overlay** pattern:

- The base image is always the official `kolla/ubuntu-binary-horizon:<tag>` image. No upstream source files are ever modified.
- All customisation lives exclusively in the `overlay/` directory: SCSS theme files, Django block-inheritance templates, and a `local_settings.d` snippet that activates the theme.
- The `Dockerfile` copies the overlay into the Kolla image, runs `collectstatic` to bake in the compiled assets, and produces a ready-to-deploy image.
- Because we never fork Horizon, every new Kolla base image automatically picks up upstream security patches and feature updates with zero maintenance cost.

```
overlay/
├── themes/nexus/          ← SCSS, SVG logo, template block overrides
└── local_settings.d/      ← runtime settings snippet (theme activation)
```

Template overrides use Django's `{% extends "!base.html" %}` block inheritance
(`!` prefix means "upstream template") so only the changed blocks are declared —
never full template copies.

---

## 2. How Automatic Builds Work

### TRIGGER 1 — Your Overlay Changes (immediate)

Any `git push` to `main` triggers **`build.yml`** and rebuilds all four release
images automatically — no human intervention required.

### TRIGGER 2 — Upstream Kolla Changes (weekly digest check)

Every **Monday at 09:00 UTC**, **`upstream-check.yml`** runs across all releases
listed in `releases.json`. For each release it:

1. Fetches the current Docker Hub image digest for the corresponding Kolla
   Horizon tag via the Docker Hub API.
2. Compares it against the digest stored in `digests/<kolla_tag>.txt`.
3. If the digest changed, it automatically triggers `build.yml` for **that
   release only** and updates the stored digest (committed with `[skip ci]`).

The new image is built, smoke-tested, and pushed to
`ahmadfsbd/horizon-nexus:<release>-latest` without any human intervention.

> **Example:** If Kolla pushes a new `antelope` base image on a Wednesday, the
> pipeline catches it the following Monday and automatically produces
> `ahmadfsbd/horizon-nexus:antelope-latest`.

The weekly cadence is intentional — Horizon upstream does not move fast enough
to warrant daily checks.

> **Known limitation:** If the Docker Hub API returns an empty digest (rate
> limit or API hiccup), the check treats it as no change and skips that release
> until the following Monday. This will not cause a false build or broken image —
> detection is simply delayed by up to one week.

---

## 3. How to Build Locally

Pre-compile SCSS (required — the Kolla base image has no Sass compiler):

```bash
npm install -g sass
sass overlay/themes/nexus/static/scss/nexus.scss \
     overlay/themes/nexus/static/css/nexus.css --no-source-map
```

Then build the image:

```bash
docker build --build-arg HORIZON_TAG=antelope -t horizon-nexus:local .
```

Replace `antelope` with any supported release: `zed`, `antelope`, `2023.2`, `2024.1`.

---

## 4. How to Add a New OpenStack Release

1. Add one entry to `releases.json`:
   ```json
   { "name": "dalmatian", "kolla_tag": "2024.2" }
   ```
2. Create an empty digest file:
   ```bash
   touch digests/2024.2.txt
   git add digests/2024.2.txt releases.json
   git commit -m "feat: add dalmatian release"
   git push
   ```

The pipeline picks it up automatically on the next run. Nothing else changes.

---

## 5. How to Update Theme Colours

1. Edit `overlay/themes/nexus/static/scss/_variables.scss` and/or the `:root`
   block in `nexus.scss`.
2. Bump `VERSION` (e.g. `1.0` → `1.1`).
3. Push to `main`.

All CI builds trigger automatically from the push.

---

## 6. How to Replace the Logo

Replace `overlay/themes/nexus/static/img/logo.svg` with a valid SVG that:
- Works at **32px height** on a teal nav bar background.
- Contains **no text or wordmark** — the logo is a standalone geometric mark.
- Uses only the accent colour (`#3c7d7d`) and white, or your custom palette.

Push to `main` to trigger a rebuild.

---

## 7. Tagging Strategy

| Tag pattern | Description |
|---|---|
| `<release>-<version>` (e.g. `antelope-1.0`) | Pinned, immutable. Safe for production. |
| `<release>-latest` (e.g. `antelope-latest`) | Floating. Updated automatically by the pipeline on upstream change. |
| `latest` | **Manual promotion only.** You decide which release is the stable default. |

> ⚠️ Never use `<release>-latest` in production. Always pin to a specific
> version tag and promote deliberately.

Manual promotion example:
```bash
docker pull ahmadfsbd/horizon-nexus:antelope-1.0
docker tag  ahmadfsbd/horizon-nexus:antelope-1.0 ahmadfsbd/horizon-nexus:latest
docker push ahmadfsbd/horizon-nexus:latest
```

---

## 8. How to Plug into Kolla-Ansible

In `globals.yml` or a Kolla host-vars file:

```yaml
# Floating (picks up weekly upstream rebuilds automatically):
kolla_override_containers:
  horizon:
    image: ahmadfsbd/horizon-nexus:antelope-latest

# Pinned (recommended for production):
kolla_override_containers:
  horizon:
    image: ahmadfsbd/horizon-nexus:antelope-1.0
```

---

## 9. Customising Accent Colour and Logo at Deploy Time (No Rebuild)

Kolla-Ansible's built-in config injection copies files from
`/etc/kolla/config/horizon/` on the deployment host into the running container
at `kolla-ansible deploy` time. **The image is never modified.**

### Overriding the Logo

Place a custom `logo.svg` on the deployment host at:

```
/etc/kolla/config/horizon/themes/nexus/static/img/logo.svg
```

Requirements: valid SVG, works at 32 px height on the accent nav bar, no text.

### Overriding the Accent Colour

All accent colours in the image are defined as CSS custom properties in
`themes/nexus/css/nexus-vars.css`. Place a replacement file on the deployment
host at:

```
/etc/kolla/config/horizon/themes/nexus/static/css/nexus-vars.css
```

Example contents for a purple deployment:

```css
:root {
  --nexus-accent:        #7b3c7d;
  --nexus-accent-dark:   #5f2d5f;
  --nexus-accent-light:  #a35aa3;
  --nexus-accent-subtle: #f4e8f4;
}
```

Because `nexus-vars.css` is loaded **last** in `base.html` (after the compiled
theme CSS), these values override the compiled defaults with no rebuild required.

### Typical Per-Environment Config Directory

```
/etc/kolla/config/horizon/
└── themes/
    └── nexus/
        └── static/
            ├── img/
            │   └── logo.svg          ← customer logo
            └── css/
                └── nexus-vars.css    ← customer accent colours
```

No image rebuild. No pipeline run. Just run `kolla-ansible deploy`.

---

## 10. Known Limitations and Operational Notes

### Collectstatic Build Shim

The Dockerfile injects a minimal Django settings shim (`DATABASES={}`,
dummy `SECRET_KEY`) before running `collectstatic` so Django can initialise
without a live database. This shim is removed after `collectstatic` completes.

In rare cases certain Horizon versions or installed plugins perform database
introspection at startup even before `collectstatic` runs. If the build fails
at this step, inspect the error and extend the shim settings to satisfy the
specific requirement.

### Upstream Digest Check Reliability

The weekly upstream check hits the Docker Hub API directly. If Docker Hub
returns an empty digest (rate limit or API change), the check silently skips
that release until the following Monday. This will not cause a false build or
broken image — it only delays detection by up to one week.

### Smoke Test Depth

The CI smoke test uses `curl` to check for `id="nexus-nav"` in the login page
HTML response. This confirms the element is present but does not verify that
static assets loaded correctly or that the nav is visually functional. The
Playwright test in `tests/smoke/check_ui.py` provides deeper validation and
should be run manually against a full deployment before promoting any image
to production.

### Build Failure Notifications

If a build triggered by the upstream digest check fails the smoke test, a
GitHub issue is automatically opened with a link to the failed run. Monitor
these issues — a failure after an upstream Kolla update typically means a
template block structure changed and one of your overrides needs updating.

### SCSS Compilation

SCSS is compiled in CI before the Docker build using the `sass` npm package.
The Kolla base image does not include a Sass compiler. If you add new SCSS
files, ensure they are imported in `nexus.scss` so they are picked up by
the CI compile step.

---

## 11. Horizon Functionality Note

The overlay changes only visual presentation. Panel visibility, service-based
tab enable/disable, and policy enforcement all remain driven entirely by
upstream Horizon and Kolla's injected runtime settings. No functionality is
modified. If a service is absent from the Keystone catalogue, its tab will
not appear — exactly as it would in stock Horizon.

---

## 12. Never Modify Upstream Files

Never edit any file inside the running container or inside the upstream Kolla
base image directly. Changes made this way are lost on every redeploy and
break reproducibility across nodes. All customisation must live in `overlay/`
and be applied through the pipeline. If you find yourself needing to change
an upstream file, the correct path is to add a block override template in
`overlay/themes/nexus/templates/` instead.
