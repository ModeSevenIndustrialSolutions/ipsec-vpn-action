#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation

set -euo pipefail

echo "Installing IPSEC dependencies..."

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Ubuntu/Debian
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y strongswan strongswan-pki iproute2 iptables
    # RHEL/CentOS/Fedora
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y strongswan iproute iptables
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y strongswan iproute iptables
    else
        echo "Unsupported Linux distribution"
        exit 1
    fi
else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi

# Try to enable strongSwan service if available
if sudo systemctl enable strongswan-starter 2>/dev/null; then
    echo "Enabled strongswan-starter service"
elif sudo systemctl enable strongswan 2>/dev/null; then
    echo "Enabled strongswan service"
else
    echo "Note: Could not enable strongSwan systemd service (this may be normal in some environments)"
fi

echo "IPSEC dependencies installed successfully"
