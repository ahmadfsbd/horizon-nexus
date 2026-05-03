ARG HORIZON_TAG=antelope
FROM kolla/ubuntu-binary-horizon:${HORIZON_TAG}

USER root

# Copy theme overlays
COPY overlay/themes/nexus \
     /usr/share/openstack-dashboard/themes/nexus

# Copy template overrides into openstack_dashboard templates dir
COPY overlay/themes/nexus/templates \
     /usr/share/openstack-dashboard/openstack_dashboard/templates

# Copy runtime theme settings
COPY overlay/local_settings.d/ \
     /etc/openstack-dashboard/local_settings.d/

# Provide a minimal build-time settings shim so Django can initialise
# without a live database connection during collectstatic
RUN echo "DATABASES = {}\nSECRET_KEY = 'build-only-not-secret'" \
    > /etc/openstack-dashboard/local_settings.d/00_build_shim.py

# Rebuild static assets with nexus theme included
RUN /var/lib/kolla/venv/bin/python \
    /usr/share/openstack-dashboard/manage.py collectstatic \
    --noinput --clear 2>&1 | tail -10

# Remove build shim — runtime config is injected by Kolla at deploy time
RUN rm /etc/openstack-dashboard/local_settings.d/00_build_shim.py

USER horizon
