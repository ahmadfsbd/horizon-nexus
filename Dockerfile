ARG HORIZON_TAG=2025.1-ubuntu-noble
FROM quay.io/openstack.kolla/horizon:${HORIZON_TAG}

USER root

# Locate the horizon source tree (path contains a version number that varies
# between releases, e.g. /horizon-source/horizon-25.3.3.dev2)
# and export it as HORIZON_SRC for all subsequent RUN steps.
RUN HORIZON_SRC=$(find /horizon-source -maxdepth 1 -mindepth 1 -type d | head -1) \
    && echo "HORIZON_SRC=${HORIZON_SRC}" > /etc/horizon-src.env \
    && echo "Horizon source: ${HORIZON_SRC}"

# Copy nexus theme into the themes directory
COPY overlay/themes/nexus /tmp/nexus-theme/
RUN . /etc/horizon-src.env \
    && mkdir -p "${HORIZON_SRC}/openstack_dashboard/themes/nexus" \
    && cp -r /tmp/nexus-theme/. "${HORIZON_SRC}/openstack_dashboard/themes/nexus/"

# Copy template overrides
RUN . /etc/horizon-src.env \
    && cp -r /tmp/nexus-theme/templates/. "${HORIZON_SRC}/openstack_dashboard/templates/"

# Copy runtime theme settings into BOTH locations:
#   1. /etc/openstack-dashboard/local_settings.d/  — picked up at runtime by Kolla
#   2. <HORIZON_SRC>/openstack_dashboard/local/local_settings.d/ — picked up by
#      manage.py collectstatic at build time (this is where settings.py looks)
COPY overlay/local_settings.d/ /etc/openstack-dashboard/local_settings.d/
RUN . /etc/horizon-src.env \
    && mkdir -p "${HORIZON_SRC}/openstack_dashboard/local/local_settings.d" \
    && cp /etc/openstack-dashboard/local_settings.d/50_nexus_theme.py \
          "${HORIZON_SRC}/openstack_dashboard/local/local_settings.d/50_nexus_theme.py"

# Provide a minimal build-time settings shim so Django can initialise
# without a live database connection during collectstatic
RUN . /etc/horizon-src.env \
    && echo "DATABASES = {}\nSECRET_KEY = 'build-only-not-secret'" \
       > "${HORIZON_SRC}/openstack_dashboard/local/local_settings.d/00_build_shim.py"

# Rebuild static assets with nexus theme included
RUN . /etc/horizon-src.env \
    && cd "${HORIZON_SRC}" \
    && /var/lib/kolla/venv/bin/python manage.py collectstatic \
       --noinput --clear 2>&1 | tail -20

# Remove build shim and temp files — runtime config is injected by Kolla at deploy time
RUN . /etc/horizon-src.env \
    && rm "${HORIZON_SRC}/openstack_dashboard/local/local_settings.d/00_build_shim.py" \
    && rm -rf /tmp/nexus-theme /etc/horizon-src.env

USER horizon
