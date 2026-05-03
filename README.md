# Horizon Nexus (Clean Safe Baseline)

This repository is rebuilt from scratch to provide a **safe Horizon theme overlay** for Kolla Horizon.

Goals:
- Replace OpenStack logos with your SVG assets
- Modernize visual styling
- Keep Horizon structure/layout/rendering intact (non-invasive)

## Upstream References

- Horizon themes guide: https://docs.openstack.org/horizon/latest/configuration/themes.html
- Kolla Horizon guide: https://docs.openstack.org/kolla-ansible/latest/reference/shared-services/horizon-guide.html

## What is customized

Only safe override points are used:
- `overlay/themes/nexus/static/img/logo.svg`
- `overlay/themes/nexus/static/img/logo-splash.svg`
- `overlay/themes/nexus/templates/base.html` (CSS include only)
- `overlay/themes/nexus/static/scss/*` (visual CSS)
- `overlay/local_settings.d/z_nexus_theme.py` (theme activation)

No invasive replacement of Horizon global templates/layout blocks.

## Replace logos

Replace these files with your own SVGs:

- `overlay/themes/nexus/static/img/logo.svg` (top navbar logo)
- `overlay/themes/nexus/static/img/logo-splash.svg` (login splash logo)

## Build locally

```bash
npm ci
npm run build:css
npm run test:theme

docker build --build-arg HORIZON_TAG=master-ubuntu-noble -t horizon-nexus:local .
```

## Deploy with Kolla (example)

Use image tag from CI:
- `ahmadfsbd/horizon-nexus:master-ubuntu-noble-latest`
- or pinned `ahmadfsbd/horizon-nexus:master-ubuntu-noble-<VERSION>`

For Kolla runtime settings in `/etc/kolla/horizon/_9999-custom-settings.py`, set:

```python
DEFAULT_THEME = 'nexus'
```

## Notes

`z_nexus_theme.py` disables django-compressor runtime paths that are known to fail in Kolla Horizon images due to unresolved SCSS placeholders in `themes.scss`.
