import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  static const _keyActiveFamilyId = 'active_family_id';
  static const _keyLastFocusPersonId = 'last_focus_person_id';
  static const _keyUserSession = 'user_session_token';

  Future<void> saveActiveFamilyId(String familyId) async {
    await _storage.write(key: _keyActiveFamilyId, value: familyId);
  }

  Future<String?> getActiveFamilyId() async {
    return await _storage.read(key: _keyActiveFamilyId);
  }

  Future<void> saveLastFocusPersonId(String personId) async {
    await _storage.write(key: _keyLastFocusPersonId, value: personId);
  }

  Future<String?> getLastFocusPersonId() async {
    return await _storage.read(key: _keyLastFocusPersonId);
  }

  Future<void> saveUserSession(String sessionData) async {
    await _storage.write(key: _keyUserSession, value: sessionData);
  }

  Future<String?> getUserSession() async {
    return await _storage.read(key: _keyUserSession);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
