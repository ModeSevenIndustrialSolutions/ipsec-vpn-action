#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation

set -euo pipefail

echo "Starting IPSEC connection..."

# Try different methods to start strongSwan
if sudo systemctl is-active --quiet strongswan-starter; then
    echo "strongswan-starter service is already running"
elif sudo systemctl start strongswan-starter 2>/dev/null; then
    echo "Started strongswan-starter service via systemctl"
    sleep 3
elif sudo ipsec start 2>/dev/null; then
    echo "Started strongSwan via ipsec start command"
    sleep 3
else
    echo "Warning: Could not start strongSwan service, but continuing..."
    echo "This might work if strongSwan is already configured to start automatically"
fi

# Check if strongSwan daemon is running
if ! sudo ipsec status >/dev/null 2>&1; then
    echo "strongSwan daemon does not appear to be running, attempting to start manually..."
    sudo ipsec start || echo "Warning: Could not start strongSwan daemon"
    sleep 2
fi

# Start the connection
sudo ipsec up github-runner-vpn

# Wait for connection establishment with timeout
echo "Waiting for IPSEC connection to establish..."
timeout="${CONNECTION_TIMEOUT}"
while [ "$timeout" -gt 0 ]; do
    if sudo ipsec status github-runner-vpn | grep -q "ESTABLISHED"; then
        echo "IPSEC connection established successfully"
        break
    fi
    sleep 2
    ((timeout-=2))
done

if [ "$timeout" -le 0 ]; then
    echo "IPSEC connection failed to establish within ${CONNECTION_TIMEOUT} seconds"
    sudo ipsec status
    exit 1
fi

echo "IPSEC connection started successfully"
