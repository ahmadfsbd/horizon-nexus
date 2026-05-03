#!/usr/bin/env bash
# dev-deploy.sh — build locally, stream to VM, redeploy
# Usage: ./dev-deploy.sh
set -euo pipefail

VM=ubuntu@192.168.122.39
IMAGE=horizon-nexus:dev

echo "==> Building image..."
sudo docker build --build-arg HORIZON_TAG=master-ubuntu-noble -t "$IMAGE" .

echo "==> Streaming image to VM..."
sudo docker save "$IMAGE" | ssh "$VM" "sudo docker load"

echo "==> Redeploying on VM..."
ssh "$VM" "sudo docker stop horizon 2>/dev/null || true; sudo docker rm horizon 2>/dev/null || true; sudo docker run -d --name horizon --network host -e KOLLA_CONFIG_STRATEGY=COPY_ALWAYS -v /etc/kolla/horizon/:/var/lib/kolla/config_files/:ro -v /etc/localtime:/etc/localtime:ro -v /var/log/kolla/horizon:/var/log/kolla/horizon horizon-nexus:dev"

echo "==> Waiting 25s for startup..."
sleep 25

echo "==> Container status:"
ssh "$VM" "sudo docker ps -a | grep horizon"

echo "==> Logs:"
ssh "$VM" "sudo docker logs horizon 2>&1 | grep -E 'Error|CommandError|Compressing|uwsgi|started' | tail -20"

echo "==> Dashboard: http://192.168.122.100"
