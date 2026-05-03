ARG HORIZON_TAG=2025.1-ubuntu-noble
FROM quay.io/openstack.kolla/horizon:${HORIZON_TAG}

USER root

ENV SITE_PACKAGES=/var/lib/kolla/venv/lib/python3/site-packages

# ── Theme overlay ──────────────────────────────────────────────────────────────
COPY overlay/themes/nexus \
     ${SITE_PACKAGES}/openstack_dashboard/themes/nexus

COPY overlay/themes/nexus/templates \
     ${SITE_PACKAGES}/openstack_dashboard/templates/

# /etc/ path: picked up by kolla_set_configs at runtime
COPY overlay/local_settings.d/ \
     /etc/openstack-dashboard/local_settings.d/

# site-packages path: used by manage.py / kolla_extend_start collectstatic
COPY overlay/local_settings.d/ \
     ${SITE_PACKAGES}/openstack_dashboard/local/local_settings.d/

# ── Patch kolla_extend_start ───────────────────────────────────────────────────
# `compress --force` exits 1 because Kolla's own themes.scss contains a Django
# template variable (@import "/{{ THEME_DIR }}/{{ THEME }}/variables") that
# libsass cannot resolve at compress time. With `set -o errexit` active this
# kills the startup script before uwsgi launches.
# Fix: append `|| true` to line 227 (the compress --force line).
RUN sed -i '227s/$/ || true/' /usr/local/bin/kolla_extend_start

# ── Pre-bake static files ──────────────────────────────────────────────────────
# Pre-create .secret_key_store so local_settings.py reads it (not generate)
# then run collectstatic as root at build time to bake assets into the image.
RUN echo "build-only-not-a-real-key" \
        > ${SITE_PACKAGES}/openstack_dashboard/local/.secret_key_store \
    && chmod 600 \
        ${SITE_PACKAGES}/openstack_dashboard/local/.secret_key_store \
    && /var/lib/kolla/venv/bin/python \
        /var/lib/kolla/venv/bin/manage.py collectstatic \
        --noinput --clear 2>&1 | tail -5

# ── Fix ownership ──────────────────────────────────────────────────────────────
# All COPY/RUN steps above ran as root. kolla_extend_start runs as the
# `horizon` user and must be able to write to these paths at startup.
RUN chown -R horizon:horizon \
        ${SITE_PACKAGES}/openstack_dashboard/local/ \
        ${SITE_PACKAGES}/static/ \
        /etc/openstack-dashboard/ \
        /var/lib/kolla/

USER horizon
