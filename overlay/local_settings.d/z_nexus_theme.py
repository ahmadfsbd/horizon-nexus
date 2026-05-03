"""
Nexus theme activation settings.

Placed in local_settings.d/ so it is automatically picked up by Horizon's
settings loader. The nexus theme is set as the default; operators can still
switch to the upstream default theme from their profile.
"""

AVAILABLE_THEMES = [
    ('default', 'Default', 'themes/default'),
    ('nexus', 'Nexus', 'themes/nexus'),
]
DEFAULT_THEME = 'nexus'
THEME_COLLECTION_DIR = 'themes'

# Branding
SITE_BRANDING = 'Nubestack'
SITE_BRANDING_LINK = 'horizon:user_home'

# Disable Django Compressor entirely.
# - COMPRESS_OFFLINE = True  → needs a pre-built manifest from `compress --force`,
#   which fails because Kolla's themes.scss contains unresolvable Django template
#   variables ({{ THEME_DIR }}/{{ THEME }}/variables) at compress time.
# - COMPRESS_OFFLINE = False → falls back to inline compilation at request time,
#   which also fails for the same SCSS reason.
# Setting COMPRESS_ENABLED = False makes Compressor pass CSS/JS through raw,
# serving the already-collected static files directly — which is fine since
# collectstatic already ran during the Docker build.
COMPRESS_OFFLINE = False
COMPRESS_ENABLED = False
# django-compressor will still run precompilers when COMPRESS_PRECOMPILERS is
# non-empty, even if COMPRESS_ENABLED is False. Kolla/Horizon registers SCSS
# precompilers, which triggers the themes.scss compile crash at request time.
COMPRESS_PRECOMPILERS = ()
