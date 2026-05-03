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
