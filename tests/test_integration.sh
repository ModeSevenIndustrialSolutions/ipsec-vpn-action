#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation
# Integration tests for IPSEC VPN Action

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Running integration tests for IPSEC VPN Action..."

# Test 1: Verify all scripts are executable
echo "Test 1: Checking script permissions..."
for script in "$PROJECT_DIR/scripts"/*.sh; do
    if [[ ! -x "$script" ]]; then
        echo "FAIL: Script $script is not executable"
        exit 1
    fi
done
echo "PASS: All scripts are executable"

# Test 2: Verify script syntax
echo "Test 2: Checking script syntax..."
for script in "$PROJECT_DIR/scripts"/*.sh; do
    if ! bash -n "$script"; then
        echo "FAIL: Syntax error in $script"
        exit 1
    fi
done
echo "PASS: All scripts have valid syntax"

# Test 3: Check action.yml structure
echo "Test 3: Validating action.yml..."
if [[ ! -f "$PROJECT_DIR/action.yml" ]]; then
    echo "FAIL: action.yml not found"
    exit 1
fi

# Basic YAML validation (if yq is available)
if command -v yq >/dev/null 2>&1; then
    if ! yq eval '.' "$PROJECT_DIR/action.yml" >/dev/null; then
        echo "FAIL: Invalid YAML in action.yml"
        exit 1
    fi
fi
echo "PASS: action.yml is valid"

# Test 4: Check required inputs are defined
echo "Test 4: Checking required inputs..."
required_inputs=("peer-ip" "remote-networks" "psk")
for input in "${required_inputs[@]}"; do
    if ! grep -q "$input:" "$PROJECT_DIR/action.yml"; then
        echo "FAIL: Required input $input not found in action.yml"
        exit 1
    fi
done
echo "PASS: All required inputs are defined"

echo "All integration tests passed!"
