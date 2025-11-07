package util

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/binary"
	"encoding/hex"
	"fmt"
	"io"
	"nowis/pkg/configs"
	"time"

	"golang.org/x/crypto/pbkdf2"
)

const (
	keyLen          = 32   // AES-256 key
	pbkdf2Iterations = 4096 // Recommended iterations
	aesGCMNonceSize = 12   // GCM recommended nonce size
	unixTimeByteSize = 8    // int64 is 8 bytes
)

var (
	staticEncryptionSalt []byte
)

func init() {
	var err error
	config := configs.GetConfig()
	staticEncryptionSalt, err = hex.DecodeString(config.NowisEncryptionStaticSaltHex)
	if err != nil {
		panic(fmt.Sprintf("Failed to decode encryption static salt hex: %v", err))
	}
}

// deriveDynamicKey generates an AES key using PBKDF2, incorporating the static passphrase,
// static salt, and the hour/minute from the provided timestamp (in UTC).
func deriveDynamicKey(timestamp time.Time) []byte {
	utcTime := timestamp.UTC()
	hour := utcTime.Hour()
	minute := utcTime.Minute()

	dynamicSaltComponent := fmt.Appendf(nil, "%02d%02d", hour, minute)

	combinedSalt := make([]byte, len(staticEncryptionSalt)+len(dynamicSaltComponent))
	copy(combinedSalt, staticEncryptionSalt)
	copy(combinedSalt[len(staticEncryptionSalt):], dynamicSaltComponent)

	config := configs.GetConfig()
	return pbkdf2.Key([]byte(config.NowisEncryptionPassphrase), combinedSalt, pbkdf2Iterations, keyLen, sha256.New)
}

// EncryptContent encrypts the plaintext content (string) using AES-GCM with a key
// derived from the current UTC time. It returns a Base64-encoded string that combines
// the IV length, IV, encryption timestamp, and the actual encrypted content.
// This combined string is what should be sent to the client.
func EncryptContent(plaintext string) (encodedPayload string, err error) {
	encryptionTime := time.Now().UTC()
	dynamicKey := deriveDynamicKey(encryptionTime)

	block, err := aes.NewCipher(dynamicKey)
	if err != nil {
		return "", fmt.Errorf("util: could not create AES cipher: %w", err)
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", fmt.Errorf("util: could not create GCM: %w", err)
	}

	if gcm.NonceSize() != aesGCMNonceSize {
		return "", fmt.Errorf("util: unexpected GCM nonce size: %d, expected %d", gcm.NonceSize(), aesGCMNonceSize)
	}

	iv := make([]byte, gcm.NonceSize())
	if _, err = io.ReadFull(rand.Reader, iv); err != nil {
		return "", fmt.Errorf("util: could not generate IV: %w", err)
	}

	encryptedContent := gcm.Seal(nil, iv, []byte(plaintext), nil)

	if len(iv) > 255 {
		return "", fmt.Errorf("util: IV size %d exceeds 255 bytes, cannot store length in 1 byte", len(iv))
	}
	ivLenByte := byte(len(iv))

	unixTimestamp := encryptionTime.Unix()
	unixTimestampBytes := make([]byte, unixTimeByteSize)
	binary.BigEndian.PutUint64(unixTimestampBytes, uint64(unixTimestamp))

	totalSize := 1 + len(iv) + unixTimeByteSize + len(encryptedContent)
	encryptedPayloadWithMeta := make([]byte, totalSize)

	offset := 0
	encryptedPayloadWithMeta[offset] = ivLenByte
	offset++

	copy(encryptedPayloadWithMeta[offset:offset+len(iv)], iv)
	offset += len(iv)

	copy(encryptedPayloadWithMeta[offset:offset+unixTimeByteSize], unixTimestampBytes)
	offset += unixTimeByteSize

	copy(encryptedPayloadWithMeta[offset:], encryptedContent)

	encodedPayload = base64.URLEncoding.EncodeToString(encryptedPayloadWithMeta)
	return encodedPayload, nil
}

// ExtractAndDecryptContent extracts the IV, encryption timestamp, and actual
// encrypted content from the combined Base64-encoded string, derives the key, and decrypts.
// This function is useful for testing the server-side encryption or if you
// ever needed to decrypt on the server. For the client, a similar parsing
// and decryption logic would be implemented in their respective language.
func ExtractAndDecryptContent(encodedPayload string) (plaintext string, err error) {
	encryptedPayloadWithMeta, err := base64.URLEncoding.DecodeString(encodedPayload)
	if err != nil {
		return "", fmt.Errorf("util: failed to decode base64 payload: %w", err)
	}

	minExpectedLen := 1 + aesGCMNonceSize + unixTimeByteSize + 16 // 16 is GCM tag size
	if len(encryptedPayloadWithMeta) < minExpectedLen {
		return "", fmt.Errorf("util: combined payload too short (minimum %d bytes needed)", minExpectedLen)
	}

	offset := 0

	ivLen := int(encryptedPayloadWithMeta[offset])
	offset++

	if ivLen != aesGCMNonceSize {
		return "", fmt.Errorf("util: extracted IV length %d does not match expected GCM nonce size %d", ivLen, aesGCMNonceSize)
	}

	if len(encryptedPayloadWithMeta) < 1+ivLen+unixTimeByteSize+16 {
		return "", fmt.Errorf("util: combined payload too short after IV length check (needed: %d, got: %d)", 1+ivLen+unixTimeByteSize+16, len(encryptedPayloadWithMeta))
	}

	iv := encryptedPayloadWithMeta[offset : offset+ivLen]
	offset += ivLen

	unixTimestampBytes := encryptedPayloadWithMeta[offset : offset+unixTimeByteSize]
	offset += unixTimeByteSize
	unixTimestamp := int64(binary.BigEndian.Uint64(unixTimestampBytes))
	encryptionTime := time.Unix(unixTimestamp, 0).UTC()

	encryptedContent := encryptedPayloadWithMeta[offset:]

	dynamicKey := deriveDynamicKey(encryptionTime)

	block, err := aes.NewCipher(dynamicKey)
	if err != nil {
		return "", fmt.Errorf("util: could not create AES cipher: %w", err)
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", fmt.Errorf("util: could not create GCM: %w", err)
	}

	decryptedBytes, err := gcm.Open(nil, iv, encryptedContent, nil)
	if err != nil {
		return "", fmt.Errorf("util: could not decrypt content: %w", err)
	}

	return string(decryptedBytes), nil
}
