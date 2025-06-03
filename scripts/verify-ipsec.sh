#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation

set -euo pipefail

echo "Verifying IPSEC connection..."

# Check connection status
if ! sudo ipsec status github-runner-vpn | grep -q "ESTABLISHED"; then
    echo "IPSEC connection is not established"
    sudo ipsec status
    exit 1
fi

# Check if Security Associations are installed
if ! sudo ipsec status github-runner-vpn | grep -q "INSTALLED"; then
    echo "IPSEC Security Associations are not installed"
    sudo ipsec status
    exit 1
fi

# Verify routing for remote networks
IFS=',' read -ra NETWORKS <<< "$REMOTE_NETWORKS"
for network in "${NETWORKS[@]}"; do
    network=$(echo "$network" | xargs)  # trim whitespace
    echo "Checking route to $network..."
    if ip route show | grep -q "$network"; then
        echo "Route to $network is present"
    else
        echo "Warning: No explicit route found for $network (may be handled by IPSEC policy)"
    fi
done

# Display final status
echo "IPSEC connection verification completed successfully"
sudo ipsec status github-runner-vpn
