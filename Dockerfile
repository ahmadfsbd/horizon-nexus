ARG HORIZON_TAG=master-ubuntu-noble
FROM quay.io/openstack.kolla/horizon:${HORIZON_TAG}

USER root

ENV SITE_PACKAGES=/var/lib/kolla/venv/lib/python3/site-packages

# Theme overlay (safe: no global template replacement)
COPY overlay/themes/nexus ${SITE_PACKAGES}/openstack_dashboard/themes/nexus

# Settings overlays for kolla runtime + python local settings
COPY overlay/local_settings.d/ /etc/openstack-dashboard/local_settings.d/
COPY overlay/local_settings.d/ ${SITE_PACKAGES}/openstack_dashboard/local/local_settings.d/

# Kolla start script runs `compress --force`; keep startup alive if it fails
RUN grep -q 'compress --force' /usr/local/bin/kolla_extend_start \
    && sed -i '/compress --force/s/$/ || true/' /usr/local/bin/kolla_extend_start \
    || { echo "ERROR: compress --force line not found in kolla_extend_start"; exit 1; }

# Build-time static collection
RUN echo "build-only-not-a-real-key" > ${SITE_PACKAGES}/openstack_dashboard/local/.secret_key_store \
    && chmod 600 ${SITE_PACKAGES}/openstack_dashboard/local/.secret_key_store \
    && /var/lib/kolla/venv/bin/python /var/lib/kolla/venv/bin/manage.py collectstatic --noinput --clear

# Runtime write permissions for horizon user
RUN chown -R horizon:horizon \
      ${SITE_PACKAGES}/openstack_dashboard/local/ \
      ${SITE_PACKAGES}/static/ \
      /etc/openstack-dashboard/ \
      /var/lib/kolla/

USER horizon
