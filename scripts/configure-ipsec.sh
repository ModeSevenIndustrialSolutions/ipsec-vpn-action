#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation

set -euo pipefail

echo "Configuring IPSEC connection..."

# Set default peer ID if not provided
PEER_ID=${PEER_ID:-$PEER_IP}

# Create strongSwan configuration
sudo tee /etc/ipsec.conf > /dev/null <<EOF
config setup
    charondebug="all"
    uniqueids=yes

conn github-runner-vpn
    type=tunnel
    auto=add
    keyexchange=ikev${IKE_VERSION}
    left=%defaultroute
    leftid=${LOCAL_ID}
    leftsubnet=0.0.0.0/0
    right=${PEER_IP}
    rightid=${PEER_ID}
    rightsubnet=${REMOTE_NETWORKS}
    ike=${ENCRYPTION_ALGORITHM}-${HASH_ALGORITHM}-modp${DH_GROUP}!
    esp=${ESP_ENCRYPTION}-${ESP_HASH}-modp${PFS_GROUP}!
    ikelifetime=${IKE_LIFETIME}s
    lifetime=${ESP_LIFETIME}s
    authby=secret
    dpdaction=restart
    dpddelay=30s
    dpdtimeout=120s
    compress=no
EOF

# Create secrets file
sudo tee /etc/ipsec.secrets > /dev/null <<EOF
${LOCAL_ID} ${PEER_ID} : PSK "${PSK}"
EOF

# Secure the secrets file
sudo chmod 600 /etc/ipsec.secrets

echo "IPSEC configuration completed"
