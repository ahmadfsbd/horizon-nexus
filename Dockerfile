ARG HORIZON_TAG=master-ubuntu-noble
FROM quay.io/openstack.kolla/horizon:${HORIZON_TAG}

USER root

ENV SITE_PACKAGES=/var/lib/kolla/venv/lib/python3/site-packages

# Theme overlay (safe: no global template replacement)
COPY overlay/themes/nexus ${SITE_PACKAGES}/openstack_dashboard/themes/nexus

# Global template overrides — apply regardless of active theme
COPY overlay/global_templates/ ${SITE_PACKAGES}/openstack_dashboard/templates/

# Settings overlays for kolla runtime + python local settings
COPY overlay/local_settings.d/ /etc/openstack-dashboard/local_settings.d/
COPY overlay/local_settings.d/ ${SITE_PACKAGES}/openstack_dashboard/local/local_settings.d/

# Build-time static collection only.
# compress --force cannot run at build time because themes.scss contains
# Django template variables ({{ THEME_DIR }}/{{ THEME }}) that are only
# resolved at request time. Kolla's kolla_extend_start already runs
# compress --force at container startup when real settings are available.
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
