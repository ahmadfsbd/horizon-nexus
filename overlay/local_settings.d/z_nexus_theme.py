"""
Safe Nexus theme activation for Horizon.

This file intentionally uses only safe settings overrides.
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

# Let Kolla's compress --force handle SCSS compilation at container startup.
# Do NOT disable COMPRESS_PRECOMPILERS — that prevents .scss → .css compilation
# and causes browsers to receive raw .scss files (breaks all layouts).
