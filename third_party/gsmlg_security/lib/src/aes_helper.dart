import 'package:gsmlg_security/encrypt/encrypt.dart';

class AesHelper {
  IV iv = IV.fromUtf8('Best in my World');

  final String appName;
  AesHelper._(this.appName);

  factory AesHelper(String appName) {
    return AesHelper._(appName);
  }

  String salt = 'salt';

  Key get key {
    final ss = '$salt.GSMLG.$appName';
    String s;
    if (ss.length > 32) {
      s = ss.substring(0, 32);
    } else {
      s = ss.padRight(32, '.');
    }
    return Key.fromUtf8(s);
  }

  Encrypter get encrypter {
    return Encrypter(AES(key));
  }

  Encrypted encrypt(String text) {
    return encrypter.encrypt(text, iv: iv);
  }

  String decrypt(Encrypted text) {
    return encrypter.decrypt(text, iv: iv);
  }

  String encrypt64(String text) {
    return encrypt(text).base64;
  }

  String decrypt64(String text) {
    return encrypter.decrypt64(text, iv: iv);
  }

  Key keyWithSalt(String salt) {
    String ss = '$salt.GSMLG.$appName';
    if (ss.length > 32) {
      ss = ss.substring(0, 32);
    } else {
      ss = ss.padRight(32, '.');
    }
    return Key.fromUtf8(ss);
  }

  String encrypt64WithSalt(String text, String salt) {
    return Encrypter(AES(keyWithSalt(salt))).encrypt(text, iv: iv).base64;
  }

  String decrypt64WithSalt(String text, String salt) {
    try {
      final enc = Encrypted.fromBase64(text);
      return Encrypter(AES(keyWithSalt(salt))).decrypt(enc, iv: iv);
    } catch (e) {
      throw Exception(('Invalid encrypt text or salt'));
    }
  }
}
