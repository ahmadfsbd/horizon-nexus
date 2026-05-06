"""
Safe Nexus theme activation for Horizon.

This file intentionally uses only safe settings overrides.
"""

AVAILABLE_THEMES = [
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

# Route image uploads through Horizon server instead of direct-to-Glance.
# Direct mode requires CORS on Glance which is typically not configured.
HORIZON_IMAGES_UPLOAD_MODE = 'legacy'
