#!/bin/bash
# install_consul.sh – Install HashiCorp Consul agent
set -euo pipefail

CONSUL_VERSION="1.18.1"
CONSUL_ZIP="consul_${CONSUL_VERSION}_linux_amd64.zip"
CONSUL_URL="https://releases.hashicorp.com/consul/${CONSUL_VERSION}/${CONSUL_ZIP}"

echo "==> Installing Consul ${CONSUL_VERSION}..."

# Download and install
curl -fsSL -o /tmp/${CONSUL_ZIP} ${CONSUL_URL}
unzip -o /tmp/${CONSUL_ZIP} -d /tmp/
sudo mv /tmp/consul /usr/local/bin/consul
sudo chmod 0755 /usr/local/bin/consul
rm /tmp/${CONSUL_ZIP}

# Create consul user/group
sudo useradd --system --home /etc/consul.d --shell /bin/false consul || true

# Create directories
sudo mkdir -p /opt/consul/data
sudo mkdir -p /etc/consul.d
sudo chown -R consul:consul /opt/consul /etc/consul.d

# Install systemd service
sudo bash -c 'cat > /etc/systemd/system/consul.service' <<'EOF'
[Unit]
Description=Consul Agent
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
EnvironmentFile=-/etc/consul.d/consul.env
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable consul

echo "==> Consul ${CONSUL_VERSION} installed successfully"
