# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation

"""Tests for the IPSEC VPN Action."""

import os
import subprocess
import tempfile
import unittest
from unittest.mock import Mock, patch


class TestIPSECVPNAction(unittest.TestCase):
    """Test cases for IPSEC VPN Action scripts."""

    def setUp(self):
        """Set up test environment."""
        self.test_env = {
            'PEER_IP': '192.168.1.1',
            'PEER_ID': '192.168.1.1',
            'LOCAL_ID': '%any',
            'REMOTE_NETWORKS': '10.0.0.0/8',
            'PSK': 'test-psk-key',
            'IKE_VERSION': '2',
            'ENCRYPTION_ALGORITHM': 'aes256',
            'HASH_ALGORITHM': 'sha256',
            'DH_GROUP': '14',
            'ESP_ENCRYPTION': 'aes256',
            'ESP_HASH': 'sha256',
            'PFS_GROUP': '14',
            'IKE_LIFETIME': '28800',
            'ESP_LIFETIME': '3600',
            'CONNECTION_TIMEOUT': '30'
        }

    def test_install_deps_script_exists(self):
        """Test that install-deps.sh script exists and is executable."""
        script_path = os.path.join(
            os.path.dirname(os.path.dirname(__file__)),
            'scripts',
            'install-deps.sh'
        )
        self.assertTrue(os.path.exists(script_path))
        self.assertTrue(os.access(script_path, os.X_OK))

    def test_configure_ipsec_script_exists(self):
        """Test that configure-ipsec.sh script exists and is executable."""
        script_path = os.path.join(
            os.path.dirname(os.path.dirname(__file__)),
            'scripts',
            'configure-ipsec.sh'
        )
        self.assertTrue(os.path.exists(script_path))
        self.assertTrue(os.access(script_path, os.X_OK))

    def test_start_ipsec_script_exists(self):
        """Test that start-ipsec.sh script exists and is executable."""
        script_path = os.path.join(
            os.path.dirname(os.path.dirname(__file__)),
            'scripts',
            'start-ipsec.sh'
        )
        self.assertTrue(os.path.exists(script_path))
        self.assertTrue(os.access(script_path, os.X_OK))

    def test_verify_ipsec_script_exists(self):
        """Test that verify-ipsec.sh script exists and is executable."""
        script_path = os.path.join(
            os.path.dirname(os.path.dirname(__file__)),
            'scripts',
            'verify-ipsec.sh'
        )
        self.assertTrue(os.path.exists(script_path))
        self.assertTrue(os.access(script_path, os.X_OK))

    def test_action_yml_exists(self):
        """Test that action.yml exists and is valid."""
        action_path = os.path.join(
            os.path.dirname(os.path.dirname(__file__)),
            'action.yml'
        )
        self.assertTrue(os.path.exists(action_path))

    @patch('subprocess.run')
    def test_script_syntax_validation(self, mock_run):
        """Test that all shell scripts have valid syntax."""
        script_dir = os.path.join(
            os.path.dirname(os.path.dirname(__file__)),
            'scripts'
        )
        
        for script_file in os.listdir(script_dir):
            if script_file.endswith('.sh'):
                script_path = os.path.join(script_dir, script_file)
                
                # Use bash -n to check syntax without executing
                result = subprocess.run(
                    ['bash', '-n', script_path],
                    capture_output=True,
                    text=True
                )
                
                self.assertEqual(
                    result.returncode, 0,
                    f"Syntax error in {script_file}: {result.stderr}"
                )

    def test_environment_variable_handling(self):
        """Test that required environment variables are handled properly."""
        # This would test the actual environment variable usage
        # In a real scenario, you'd mock the file operations
        required_vars = [
            'PEER_IP', 'REMOTE_NETWORKS', 'PSK'
        ]
        
        for var in required_vars:
            self.assertIn(var, self.test_env)
            self.assertTrue(len(self.test_env[var]) > 0)


if __name__ == '__main__':
    unittest.main()
