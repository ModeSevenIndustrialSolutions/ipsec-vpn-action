<!--
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation
-->

# IPSEC VPN Action

A GitHub composite action that sets up an IPSEC VPN connection from the runner
to a remote endpoint, providing secure access to private networks during
workflow execution.

## Features

- Support for IKEv1 and IKEv2
- Configurable encryption and authentication algorithms
- Automatic routing setup for remote networks
- Compatible with OpenStack VPN services and Linux-based IPSEC daemons
- Secure credential handling via GitHub secrets
- Connection persistence throughout workflow job duration

## Usage

```yaml
- name: Setup IPSEC VPN
  uses: ModeSevenIndustrialSolutions/ipsec-vpn-action@v1
  with:
    peer-ip: '192.168.1.1'
    remote-networks: '10.0.0.0/8,172.16.0.0/12'
    psk: ${{ secrets.IPSEC_PSK }}
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `peer-ip` | Remote IPSEC peer IP address | Yes | - |
| `peer-id` | Remote peer identifier | No | peer-ip value |
| `local-id` | Local identifier | No | `%any` |
| `remote-networks` | Remote network CIDR blocks (comma-separated) | Yes | - |
| `psk` | Pre-shared key for authentication | Yes | - |
| `ike-version` | IKE version (1 or 2) | No | `2` |
| `encryption-algorithm` | Encryption algorithm | No | `aes256` |
| `hash-algorithm` | Hash algorithm | No | `sha256` |
| `dh-group` | Diffie-Hellman group | No | `14` |
| `esp-encryption` | ESP encryption algorithm | No | `aes256` |
| `esp-hash` | ESP hash algorithm | No | `sha256` |
| `pfs-group` | Perfect Forward Secrecy group | No | `14` |
| `ike-lifetime` | IKE SA lifetime in seconds | No | `28800` |
| `esp-lifetime` | ESP SA lifetime in seconds | No | `3600` |
| `connection-timeout` | Connection timeout in seconds | No | `30` |

## Security Considerations

- Always store the pre-shared key (`psk`) as a GitHub secret
- Use strong encryption algorithms (defaults are secure)
- Consider using certificate-based authentication for production environments
- The VPN connection is automatically torn down when the workflow job completes

## Supported Platforms

- Ubuntu (latest, 20.04, 22.04)
- Self-hosted Linux runners with systemd support

## Example Workflows

### Basic Setup

```yaml
name: Deploy with VPN
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup IPSEC VPN
        uses: ModeSevenIndustrialSolutions/ipsec-vpn-action@v1
        with:
          peer-ip: ${{ secrets.VPN_PEER_IP }}
          remote-networks: '10.0.0.0/8'
          psk: ${{ secrets.IPSEC_PSK }}

      - name: Access private resources
        run: |
          # Now you can access resources in the 10.0.0.0/8 network
          curl http://10.0.1.100/api/status
```

### Advanced Configuration

```yaml
- name: Setup IPSEC VPN with custom settings
  uses: ModeSevenIndustrialSolutions/ipsec-vpn-action@v1
  with:
    peer-ip: '198.51.100.1'
    peer-id: 'vpn.example.com'
    local-id: 'github-runner'
    remote-networks: '10.0.0.0/8,172.16.0.0/12'
    psk: ${{ secrets.IPSEC_PSK }}
    ike-version: '2'
    encryption-algorithm: 'aes256'
    hash-algorithm: 'sha384'
    dh-group: '16'
    connection-timeout: '60'
```

## Troubleshooting

The action will fail if:

- The remote peer is unreachable
- Authentication credentials are incorrect
- The connection fails to establish within the timeout period

Check the workflow logs for detailed error messages and IPSEC status information.
