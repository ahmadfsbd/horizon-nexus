ARG HORIZON_TAG=master-ubuntu-noble
FROM quay.io/openstack.kolla/horizon:${HORIZON_TAG}

USER root

ENV SITE_PACKAGES=/var/lib/kolla/venv/lib/python3/site-packages

# Theme overlay (safe: no global template replacement)
COPY overlay/themes/nexus ${SITE_PACKAGES}/openstack_dashboard/themes/nexus

# Settings overlays for kolla runtime + python local settings
COPY overlay/local_settings.d/ /etc/openstack-dashboard/local_settings.d/
COPY overlay/local_settings.d/ ${SITE_PACKAGES}/openstack_dashboard/local/local_settings.d/

# Build-time static collection + SCSS compilation
RUN echo "build-only-not-a-real-key" > ${SITE_PACKAGES}/openstack_dashboard/local/.secret_key_store \
    && chmod 600 ${SITE_PACKAGES}/openstack_dashboard/local/.secret_key_store \
    && /var/lib/kolla/venv/bin/python /var/lib/kolla/venv/bin/manage.py collectstatic --noinput --clear \
    && /var/lib/kolla/venv/bin/python /var/lib/kolla/venv/bin/manage.py compress --force

# Runtime write permissions for horizon user
RUN chown -R horizon:horizon \
      ${SITE_PACKAGES}/openstack_dashboard/local/ \
      ${SITE_PACKAGES}/static/ \
      /etc/openstack-dashboard/ \
      /var/lib/kolla/

USER horizon
