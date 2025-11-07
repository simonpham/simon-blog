import 'dart:convert';
import 'dart:typed_data';

import 'package:utils/utils.dart';

const int _keyLen = 32; // AES-256 key
const int _pbkdf2Iterations = 4096; // Recommended iterations
const int _aesGCMNonceSize = 12; // GCM recommended nonce size
const int _unixTimeByteSize = 8; // int64 is 8 bytes

Uint8List _deriveDynamicKey(
  DateTime timestamp,
  String appId,
  Uint8List appVersionRef,
) {
  final DateTime utcTime = timestamp.toUtc();
  final int hour = utcTime.hour;
  final int minute = utcTime.minute;

  final Uint8List dynamicSaltComponent = Uint8List.fromList(
    utf8.encode(
      '${hour.toString().padLeft(2, '0')}${minute.toString().padLeft(2, '0')}',
    ),
  );

  final Uint8List combinedSalt = Uint8List.fromList([
    ...appVersionRef,
    ...dynamicSaltComponent,
  ]);

  final Pbkdf2Parameters pbkdf2Params = Pbkdf2Parameters(
    combinedSalt,
    _pbkdf2Iterations,
    _keyLen,
  );
  final PBKDF2KeyDerivator keyDerivator = PBKDF2KeyDerivator(
    HMac(SHA256Digest(), 64),
  );
  keyDerivator.init(pbkdf2Params);

  return keyDerivator.process(
    Uint8List.fromList(utf8.encode(appId)),
  );
}

String decrypt(Map<String, dynamic> params) {
  final String encodedPayload = params['encodedPayload'];
  final String appId = params['appId'];
  final Uint8List appVersionRef = Uint8List.fromList(
    hex.decode(params['appVersionRef']),
  );

  final Uint8List encryptedPayloadWithMeta = base64Url.decode(encodedPayload);

  const int minExpectedLen =
      1 + _aesGCMNonceSize + _unixTimeByteSize + 16; // 16 is GCM tag size
  if (encryptedPayloadWithMeta.length < minExpectedLen) {
    throw Exception(
      'combined payload too short (minimum $minExpectedLen bytes needed)',
    );
  }

  int offset = 0;

  final int ivLen = encryptedPayloadWithMeta[offset];
  offset++;

  if (ivLen != _aesGCMNonceSize) {
    throw Exception(
      'extracted IV length $ivLen does not match expected GCM nonce size $_aesGCMNonceSize',
    );
  }

  if (encryptedPayloadWithMeta.length < 1 + ivLen + _unixTimeByteSize + 16) {
    throw Exception(
      'combined payload too short after IV length check (needed: ${1 + ivLen + _unixTimeByteSize + 16}, got: ${encryptedPayloadWithMeta.length})',
    );
  }

  final Uint8List iv = encryptedPayloadWithMeta.sublist(offset, offset + ivLen);
  offset += ivLen;

  final Uint8List unixTimestampBytes = encryptedPayloadWithMeta.sublist(
    offset,
    offset + _unixTimeByteSize,
  );
  offset += _unixTimeByteSize;

  final ByteData byteData = ByteData.view(unixTimestampBytes.buffer);
  final int unixTimestamp = byteData.getUint64(0, Endian.big);
  final DateTime encryptionTime = DateTime.fromMillisecondsSinceEpoch(
    unixTimestamp * 1000,
    isUtc: true,
  );

  final Uint8List encryptedContent = encryptedPayloadWithMeta.sublist(offset);

  const int maxAttempts = 3; // Quá tam ba bận.
  Exception? lastException;
  for (int i = 0; i < maxAttempts; i++) {
    try {
      final DateTime currentAttemptTime = encryptionTime.subtract(
        Duration(minutes: i),
      );
      return _decryptWithTimestamp(
        iv,
        encryptedContent,
        currentAttemptTime,
        appId,
        appVersionRef,
      );
    } on Exception catch (e) {
      lastException = e;
      if (i == maxAttempts - 1) {
        rethrow;
      }
      // Continue to the next iteration to try with a reduced time
    }
  }
  // This line should technically be unreachable as the last failed attempt rethrows
  // but included for robustness.
  throw lastException ??
      Exception('Failed to decrypt content after multiple attempts.');
}

String _decryptWithTimestamp(
  Uint8List iv,
  Uint8List encryptedContent,
  DateTime encryptionTime,
  String appId,
  Uint8List appVersionRef,
) {
  final Uint8List dynamicKey = _deriveDynamicKey(
    encryptionTime,
    appId,
    appVersionRef,
  );

  final KeyParameter keyParam = KeyParameter(dynamicKey);
  final AEADParameters params = AEADParameters(
    keyParam,
    128, // GCM tag size is 128 bits (16 bytes)
    iv,
    Uint8List(
      0,
    ), // The Go code does not use additional authenticated data (AAD)
  );

  final GCMBlockCipher gcm = GCMBlockCipher(AESEngine());
  gcm.init(false, params); // false for decrypt

  return utf8.decode(gcm.process(encryptedContent));
}
