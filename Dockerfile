ARG HORIZON_TAG=2025.1-ubuntu-noble
FROM quay.io/openstack.kolla/horizon:${HORIZON_TAG}

USER root

# Runtime paths (used by uwsgi and kolla_extend_start at deploy time)
ENV SITE_PACKAGES=/var/lib/kolla/venv/lib/python3/site-packages

# Copy nexus theme into the installed package themes directory
COPY overlay/themes/nexus \
     ${SITE_PACKAGES}/openstack_dashboard/themes/nexus

# Copy template overrides into the installed package templates directory
COPY overlay/themes/nexus/templates \
     ${SITE_PACKAGES}/openstack_dashboard/templates/

# Copy runtime theme settings to /etc/ (picked up by Kolla at runtime)
COPY overlay/local_settings.d/ \
     /etc/openstack-dashboard/local_settings.d/

# Also copy to the source tree local_settings.d so that the runtime
# kolla_extend_start collectstatic (if triggered) also sees the nexus theme
COPY overlay/local_settings.d/ \
     ${SITE_PACKAGES}/openstack_dashboard/local/local_settings.d/

# Restore ownership so kolla_extend_start (running as the horizon user) can
# write into local/enabled/ and copy policy files into /etc/openstack-dashboard/
RUN chown -R horizon:horizon ${SITE_PACKAGES}/openstack_dashboard/local/ \
    && chown -R horizon:horizon /etc/openstack-dashboard/

# Provide a minimal build-time settings shim and run collectstatic now
# so static assets are pre-baked into the image (faster container startup)
RUN echo "DATABASES = {}\nSECRET_KEY = 'build-only-not-secret'" \
    > ${SITE_PACKAGES}/openstack_dashboard/local/local_settings.d/00_build_shim.py \
    && /var/lib/kolla/venv/bin/python \
       /var/lib/kolla/venv/bin/manage.py collectstatic \
       --noinput --clear 2>&1 | tail -10 \
    && rm ${SITE_PACKAGES}/openstack_dashboard/local/local_settings.d/00_build_shim.py

USER horizon
