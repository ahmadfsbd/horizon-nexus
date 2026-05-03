#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

[ -f "overlay/themes/nexus/static/scss/nexus.scss" ]
[ -f "overlay/themes/nexus/static/css/nexus.css" ]
[ -f "overlay/themes/nexus/static/img/logo.svg" ]
[ -f "overlay/themes/nexus/static/img/logo-splash.svg" ]
[ -f "overlay/local_settings.d/z_nexus_theme.py" ]

grep -q "DEFAULT_THEME = 'nexus'" overlay/local_settings.d/z_nexus_theme.py
grep -q "themes/nexus/css/nexus.css" overlay/themes/nexus/templates/base.html

echo "smoke-theme: ok"
