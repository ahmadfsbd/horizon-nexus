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

# Disable offline compression — the startup `compress --force` fails because
# Kolla's themes.scss contains unresolvable Django template variables at
# compress time. Disabling offline mode makes Django Compressor render CSS
# inline at request time instead of looking up a pre-built manifest.
COMPRESS_OFFLINE = False
