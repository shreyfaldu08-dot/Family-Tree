import 'package:flutter_test/flutter_test.dart';
import 'package:family_legacy/data/services/supabase_service.dart';
import 'package:family_legacy/data/models/invitation.dart';

void main() {
  group('Invitation Hashing & Verification Tests', () {
    test('Invitation hashing normalizes case and trims whitespace', () {
      const code1 = 'HL-7K2X9P';
      const code2 = '  hl-7k2x9p  ';

      final hash1 = SupabaseService.hashInvitationCode(code1);
      final hash2 = SupabaseService.hashInvitationCode(code2);

      expect(hash1, equals(hash2));
      expect(hash1.length, equals(64)); // SHA-256 hex string length
    });

    test('Different invitation codes produce distinct hashes', () {
      final hashA = SupabaseService.hashInvitationCode('HL-AAAAAA');
      final hashB = SupabaseService.hashInvitationCode('HL-BBBBBB');

      expect(hashA, isNot(equals(hashB)));
    });

    test('Invitation model correctly identifies expiration and revocation states', () {
      final now = DateTime.now();

      final validInvite = Invitation(
        id: 'inv_1',
        familyId: 'fam_1',
        codeHash: 'hash_1',
        createdBy: 'usr_1',
        expiresAt: now.add(const Duration(days: 7)),
        isRevoked: false,
        createdAt: now,
      );

      final expiredInvite = Invitation(
        id: 'inv_2',
        familyId: 'fam_1',
        codeHash: 'hash_2',
        createdBy: 'usr_1',
        expiresAt: now.subtract(const Duration(hours: 1)),
        isRevoked: false,
        createdAt: now.subtract(const Duration(days: 8)),
      );

      final revokedInvite = Invitation(
        id: 'inv_3',
        familyId: 'fam_1',
        codeHash: 'hash_3',
        createdBy: 'usr_1',
        expiresAt: now.add(const Duration(days: 7)),
        isRevoked: true,
        createdAt: now,
      );

      expect(validInvite.isValid, isTrue);
      expect(expiredInvite.isValid, isFalse);
      expect(expiredInvite.isExpired, isTrue);
      expect(revokedInvite.isValid, isFalse);
    });
  });
}
