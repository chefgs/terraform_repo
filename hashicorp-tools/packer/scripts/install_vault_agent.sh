#!/bin/bash
# install_vault_agent.sh – Install HashiCorp Vault agent (for app tier)
set -euo pipefail

VAULT_VERSION="1.17.2"
VAULT_ZIP="vault_${VAULT_VERSION}_linux_amd64.zip"
VAULT_URL="https://releases.hashicorp.com/vault/${VAULT_VERSION}/${VAULT_ZIP}"

echo "==> Installing Vault agent ${VAULT_VERSION}..."

curl -fsSL -o /tmp/${VAULT_ZIP} ${VAULT_URL}
unzip -o /tmp/${VAULT_ZIP} -d /tmp/
sudo mv /tmp/vault /usr/local/bin/vault
sudo chmod 0755 /usr/local/bin/vault
rm /tmp/${VAULT_ZIP}

# Create vault user/group for agent
sudo useradd --system --home /etc/vault.d --shell /bin/false vault || true

# Create directories
sudo mkdir -p /opt/vault/data
sudo mkdir -p /etc/vault.d
sudo mkdir -p /run/vault
sudo chown -R vault:vault /opt/vault /etc/vault.d /run/vault

# Install systemd service for Vault agent
sudo bash -c 'cat > /etc/systemd/system/vault-agent.service' <<'EOF'
[Unit]
Description=Vault Agent
Documentation=https://www.vaultproject.io/
Requires=network-online.target
After=network-online.target consul.service

[Service]
EnvironmentFile=-/etc/vault.d/vault-agent.env
User=vault
Group=vault
ExecStart=/usr/local/bin/vault agent -config=/etc/vault.d/agent.hcl
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable vault-agent

echo "==> Vault agent ${VAULT_VERSION} installed successfully"
