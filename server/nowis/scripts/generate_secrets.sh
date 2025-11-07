#!/bin/bash

# --- Configuration ---
PASSPHRASE_BYTES=48 # Base64 encoding adds overhead, 48 bytes gives a long, complex string (~64 chars)
SALT_BYTES=32       # 32 bytes = 64 hexadecimal characters

echo "✨ Generating Cryptographically Secure Secrets ✨"
echo "---------------------------------------------------"

# 1. Generate the High-Entropy Passphrase
# Uses openssl to generate random bytes, and base64 encodes it for a mix of characters.
# The resulting passphrase will be long (approx. 64 characters) and complex.
PASSPHRASE=$(openssl rand -base64 $PASSPHRASE_BYTES)

# 2. Generate the Static Encryption Salt
# Uses openssl to generate random bytes, and converts to a hex string for easy config decoding.
# This results in a 64-character (32-byte) hex string.
STATIC_SALT_HEX=$(openssl rand -hex $SALT_BYTES)

# --- Output Results ---
echo
echo "🔒 Your Generated Secrets:"
echo "===================================================================================================="
echo "1. NOWIS_ENCRYPTION_PASSPHRASE (High-Entropy Secret Key for PBKDF2):"
echo "   -> Length: ${#PASSPHRASE} characters"
echo "   -> Value: $PASSPHRASE"
echo
echo "2. NOWIS_ENCRYPTION_STATIC_SALT_HEX (32-byte Hex Salt for PBKDF2):"
echo "   -> Length: ${#STATIC_SALT_HEX} characters (32 bytes)"
echo "   -> Value: $STATIC_SALT_HEX"
echo "===================================================================================================="
echo
echo "⚠️ ACTION REQUIRED:"
echo "1. Securely store the PASSPHRASE in a secrets manager or secure environment variable."
echo "2. Use the STATIC_SALT_HEX in your application's configuration file (e.g., config.NowisEncryptionStaticSaltHex)."
