""""""

Safe Nexus theme activation for Horizon.Nexus theme activation settings.



This file is intentionally non-invasive:Placed in local_settings.d/ so it is automatically picked up by Horizon's

- Uses Horizon's standard theme mechanismsettings loader. The nexus theme is set as the default; operators can still

- Keeps upstream template structure intactswitch to the upstream default theme from their profile.

- Disables django-compressor runtime/precompile paths that break in Kolla images"""

"""

AVAILABLE_THEMES = [

AVAILABLE_THEMES = [    ('default', 'Default', 'themes/default'),

    ('default', 'Default', 'themes/default'),    ('nexus', 'Nexus', 'themes/nexus'),

    ('nexus', 'Nexus', 'themes/nexus'),]

]DEFAULT_THEME = 'nexus'

DEFAULT_THEME = 'nexus'THEME_COLLECTION_DIR = 'themes'

THEME_COLLECTION_DIR = 'themes'

# Branding

# BrandingSITE_BRANDING = 'Nubestack'

SITE_BRANDING = 'Nubestack'SITE_BRANDING_LINK = 'horizon:user_home'

SITE_BRANDING_LINK = 'horizon:user_home'

# Disable Django Compressor entirely.

# Stability for Kolla + Horizon theming:# - COMPRESS_OFFLINE = True  → needs a pre-built manifest from `compress --force`,

# themes.scss contains template placeholders that break libsass compile paths.#   which fails because Kolla's themes.scss contains unresolvable Django template

COMPRESS_OFFLINE = False#   variables ({{ THEME_DIR }}/{{ THEME }}/variables) at compress time.

COMPRESS_ENABLED = False# - COMPRESS_OFFLINE = False → falls back to inline compilation at request time,

COMPRESS_PRECOMPILERS = ()#   which also fails for the same SCSS reason.

# Setting COMPRESS_ENABLED = False makes Compressor pass CSS/JS through raw,
# serving the already-collected static files directly — which is fine since
# collectstatic already ran during the Docker build.
COMPRESS_OFFLINE = False
COMPRESS_ENABLED = False
# django-compressor will still run precompilers when COMPRESS_PRECOMPILERS is
# non-empty, even if COMPRESS_ENABLED is False. Kolla/Horizon registers SCSS
# precompilers, which triggers the themes.scss compile crash at request time.
COMPRESS_PRECOMPILERS = ()
