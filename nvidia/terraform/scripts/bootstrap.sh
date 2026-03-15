#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh
#
# EC2 user_data bootstrap script for the NVIDIA RAG application host.
# Rendered by Terraform's templatefile() function – variables are substituted
# at plan/apply time.
#
# Variables injected by Terraform
# --------------------------------
#   s3_bucket              – S3 bucket for document / index storage
#   app_port               – TCP port for the RAG application
#   nvidia_api_key         – NVIDIA NIM API key (stored in SSM in production)
#   nvidia_nim_model       – LLM model identifier
#   nvidia_embedding_model – Embedding model identifier
# =============================================================================

set -euo pipefail
exec > >(tee /var/log/rag-bootstrap.log) 2>&1

echo "=== NVIDIA RAG Bootstrap Start: $(date) ==="

# ---------------------------------------------------------------------------
# 1. System packages
# ---------------------------------------------------------------------------
yum update -y
yum install -y python3.11 python3.11-pip git amazon-ssm-agent

systemctl enable amazon-ssm-agent
systemctl start  amazon-ssm-agent

# ---------------------------------------------------------------------------
# 2. NVIDIA driver & CUDA (Deep Learning AMI usually pre-installs these;
#    this step is a safety net for base GPU AMIs)
# ---------------------------------------------------------------------------
if ! command -v nvidia-smi &>/dev/null; then
  echo "[bootstrap] Installing NVIDIA drivers…"
  yum install -y kernel-devel-$(uname -r) kernel-headers-$(uname -r)
  # CUDA 12.x toolkit from AWS Deep Learning Toolkit repo
  yum-config-manager --add-repo \
    https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
  yum install -y cuda-toolkit-12-4
fi

nvidia-smi || echo "[bootstrap] WARNING: nvidia-smi not available; continuing."

# ---------------------------------------------------------------------------
# 3. Clone the RAG application from this repository
# ---------------------------------------------------------------------------
RAG_DIR="/opt/rag-app"
mkdir -p "$RAG_DIR"

# If the app code was baked into the AMI or copied via S3, skip the clone.
if [ ! -f "$RAG_DIR/app/main.py" ]; then
  git clone --depth 1 https://github.com/chefgs/terraform_repo.git /tmp/tf_repo
  cp -r /tmp/tf_repo/nvidia/rag-application/app/* "$RAG_DIR/"
fi

# ---------------------------------------------------------------------------
# 4. Python dependencies
# ---------------------------------------------------------------------------
python3.11 -m pip install --upgrade pip
python3.11 -m pip install -r "$RAG_DIR/requirements.txt"

# Use faiss-gpu if CUDA is available
if command -v nvidia-smi &>/dev/null; then
  python3.11 -m pip install faiss-gpu --force-reinstall || true
fi

# ---------------------------------------------------------------------------
# 5. Environment configuration
# ---------------------------------------------------------------------------
cat > /etc/rag-app.env <<EOF
NVIDIA_API_KEY=${nvidia_api_key}
LLM_MODEL=${nvidia_nim_model}
EMBEDDING_MODEL=${nvidia_embedding_model}
LLM_BASE_URL=https://integrate.api.nvidia.com/v1
RAG_S3_BUCKET=${s3_bucket}
APP_PORT=${app_port}
EOF

chmod 600 /etc/rag-app.env

# ---------------------------------------------------------------------------
# 6. Systemd service
# ---------------------------------------------------------------------------
cat > /etc/systemd/system/rag-app.service <<'UNIT'
[Unit]
Description=NVIDIA RAG Document Assistant
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/rag-app
EnvironmentFile=/etc/rag-app.env
# The RAG app is an interactive CLI; the line below is a placeholder that
# logs available options.  Replace with a FastAPI/Flask server command when
# converting the assistant to an API server, for example:
#   ExecStart=/usr/bin/python3.11 -m uvicorn server:app --host 0.0.0.0 --port $APP_PORT
ExecStart=/usr/bin/python3.11 main.py --help
Restart=on-failure
RestartSec=5s
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable rag-app
# Note: the CLI app is interactive; the service definition above is a
# placeholder. Replace ExecStart with a FastAPI/Flask server entrypoint
# when converting the CLI to an API server for production use.

echo "=== NVIDIA RAG Bootstrap Complete: $(date) ==="
