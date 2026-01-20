# Security Review: SSH Key Handling

Date: 2026-01-20
Reviewer: Claude (Loki Mode)
Status: PASS with recommendations

## Executive Summary

The SSH key handling implementation follows security best practices with appropriate layered encryption. Private keys are encrypted at rest using AES encryption with per-key salts before storage in the SQLite database. The implementation leverages platform-native secure storage for sensitive settings via flutter_secure_storage.

## Components Reviewed

1. **SshKeyBloc** (`app_bloc/ssh_key/lib/src/bloc.dart`)
2. **SshKeyEncryption Extensions** (`app_bloc/ssh_key/lib/src/ssh_key_extensions.dart`)
3. **AesHelper** (`app_lib/security/lib/src/aes_helper.dart`)
4. **SshKeys Table** (`app_lib/database/lib/src/tables/ssh_keys.dart`)
5. **SecureStorageVaultRepository** (`app_lib/secure_storage/lib/src/secure_storage_vault_repository.dart`)

## Findings

### ✅ GOOD: Encryption at Rest

- Private keys are encrypted using AES before database storage
- Per-key salt is generated and stored alongside encrypted content
- Key derivation uses app name + salt combination

### ✅ GOOD: Secure Storage for Settings

- Terminal settings (including env vars) use flutter_secure_storage
- Platform-native secure storage mechanisms:
  - iOS/macOS: Keychain
  - Android: EncryptedSharedPreferences/Keystore
  - Linux: libsecret
  - Windows: Credential Manager

### ✅ GOOD: Key Material Handling

- `SshKeyData` class properly encapsulates key content and passphrase
- SSHConnector cleans up on authentication failure (socket.close())
- No key material logged in error messages

### ⚠️ MEDIUM: Static IV in AES Encryption

**Location**: `app_lib/security/lib/src/aes_helper.dart:4`
```dart
IV iv = IV.fromUtf8('Best in my World');
```

**Issue**: Using a static IV reduces the security of AES encryption. While the salt provides some differentiation per-key, a unique random IV per encryption would be more secure.

**Recommendation**: Generate a random IV per encryption operation and store it alongside the ciphertext (IVs can be public).

### ⚠️ LOW: Database Not Encrypted

**Location**: SQLite database file

**Issue**: While private keys are encrypted before storage, the database file itself is not encrypted. An attacker with file system access could potentially attempt attacks against the encrypted content.

**Recommendation**: Consider SQLCipher integration for database-level encryption if threat model includes file system access.

### ✅ GOOD: Memory Handling

- Key material passed through function parameters rather than global state
- No persistent caching of decrypted keys observed
- Dart's garbage collection handles memory cleanup

### ✅ GOOD: No Hardcoded Secrets

- No hardcoded passwords or keys found
- Salt is generated per-key
- App name used in key derivation is configurable

## Test Coverage

Verified test coverage exists for:
- `app_lib/security/test/gsmlg_security_test.dart` - Encryption tests
- `app_bloc/ssh_key/test/ssh_key_bloc_test.dart` - BLoC tests
- `app_lib/terminal_hosts/test/ssh_*` - SSH connection tests

## Recommendations

1. **Consider using random IVs** - Generate unique IV per encryption
2. **Add key export confirmation** - Require user confirmation before exporting private keys
3. **Consider SQLCipher** - For enhanced database-level encryption
4. **Add key usage audit logging** - Log when keys are accessed (not the keys themselves)

## Conclusion

The SSH key handling implementation demonstrates good security practices with layered encryption and use of platform-native secure storage. The static IV issue is a medium-priority improvement opportunity but does not represent an immediate vulnerability given the per-key salt usage. The codebase passes security review with the recommendations noted above.
