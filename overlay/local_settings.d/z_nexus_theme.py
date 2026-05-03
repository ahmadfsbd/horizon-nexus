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

# Kolla/Horizon compressor stability
COMPRESS_OFFLINE = False
COMPRESS_ENABLED = False
COMPRESS_PRECOMPILERS = ()
