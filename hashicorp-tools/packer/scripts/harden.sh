#!/bin/bash
# harden.sh – CIS-aligned OS hardening for Amazon Linux 2023
set -euo pipefail

echo "==> Applying OS hardening..."

# Disable unnecessary services
sudo systemctl disable postfix 2>/dev/null || true
sudo systemctl stop postfix 2>/dev/null || true

# SSH hardening
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config

# Kernel parameter hardening
sudo bash -c 'cat > /etc/sysctl.d/99-hardening.conf' <<'EOF'
# Disable IP source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0

# Enable SYN cookies (prevent SYN flood attacks)
net.ipv4.tcp_syncookies = 1

# Enable reverse path filtering
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Disable IPv6 if not needed
net.ipv6.conf.all.disable_ipv6 = 1
EOF

sudo sysctl -p /etc/sysctl.d/99-hardening.conf

# Clean up
sudo dnf clean all
sudo rm -rf /tmp/*

echo "==> OS hardening complete"
