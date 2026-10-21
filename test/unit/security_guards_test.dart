import 'package:flutter_test/flutter_test.dart';
import 'package:family_legacy/core/security/security_guards.dart';
import 'package:family_legacy/core/errors/app_exception.dart';
import 'package:family_legacy/data/models/membership.dart';
import 'package:family_legacy/data/models/relationship.dart';

void main() {
  group('SecurityGuards Authorization Tests', () {
    final now = DateTime.now();

    final adminMembership = FamilyMembership(
      id: 'mem_admin',
      familyId: 'fam_01',
      userId: 'usr_admin',
      role: MemberRole.primaryAdmin,
      status: MemberStatus.active,
      joinedAt: now,
      updatedAt: now,
    );

    final viewerMembership = FamilyMembership(
      id: 'mem_viewer',
      familyId: 'fam_01',
      userId: 'usr_viewer',
      role: MemberRole.viewer,
      status: MemberStatus.active,
      joinedAt: now,
      updatedAt: now,
    );

    final revokedMembership = FamilyMembership(
      id: 'mem_revoked',
      familyId: 'fam_01',
      userId: 'usr_revoked',
      role: MemberRole.viewer,
      status: MemberStatus.revoked,
      joinedAt: now,
      updatedAt: now,
    );

    test('Primary admin is permitted to perform write operations', () {
      expect(
        () => SecurityGuards.assertPrimaryAdmin(adminMembership, operation: 'add person'),
        returnsNormally,
      );
    });

    test('Approved viewer is strictly denied write permissions', () {
      expect(
        () => SecurityGuards.assertPrimaryAdmin(viewerMembership, operation: 'edit person'),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('Revoked user is blocked from reading or writing', () {
      expect(
        () => SecurityGuards.assertCanRead(revokedMembership),
        throwsA(isA<MembershipRevokedException>()),
      );
      expect(
        () => SecurityGuards.assertPrimaryAdmin(revokedMembership),
        throwsA(isA<MembershipRevokedException>()),
      );
    });

    test('Unauthenticated/null membership is rejected', () {
      expect(
        () => SecurityGuards.assertCanRead(null),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });

  group('Ancestry Cycle Prevention Tests', () {
    final now = DateTime.now();

    test('Self-parenting is immediately blocked', () {
      expect(
        () => SecurityGuards.assertNoAncestryCycle(
          parentId: 'person_A',
          childId: 'person_A',
          existingRelationships: [],
        ),
        throwsA(isA<AncestryCycleException>()),
      );
    });

    test('Direct 2-node cycle is detected and prevented', () {
      // Existing: person_A is parent of person_B
      final existing = [
        Relationship(
          id: 'rel_1',
          familyId: 'fam_01',
          personId: 'person_A',
          relatedPersonId: 'person_B',
          type: RelationshipType.parent,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Attempting to make person_B the parent of person_A
      expect(
        () => SecurityGuards.assertNoAncestryCycle(
          parentId: 'person_B',
          childId: 'person_A',
          existingRelationships: existing,
        ),
        throwsA(isA<AncestryCycleException>()),
      );
    });

    test('Multi-generation indirect cycle (A -> B -> C -> A) is detected and blocked', () {
      // Existing: A parent of B, B parent of C
      final existing = [
        Relationship(
          id: 'rel_1',
          familyId: 'fam_01',
          personId: 'person_A',
          relatedPersonId: 'person_B',
          type: RelationshipType.parent,
          createdAt: now,
          updatedAt: now,
        ),
        Relationship(
          id: 'rel_2',
          familyId: 'fam_01',
          personId: 'person_B',
          relatedPersonId: 'person_C',
          type: RelationshipType.parent,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Attempting to make C parent of A
      expect(
        () => SecurityGuards.assertNoAncestryCycle(
          parentId: 'person_C',
          childId: 'person_A',
          existingRelationships: existing,
        ),
        throwsA(isA<AncestryCycleException>()),
      );
    });

    test('Valid non-cyclical relationship addition succeeds', () {
      final existing = [
        Relationship(
          id: 'rel_1',
          familyId: 'fam_01',
          personId: 'person_A',
          relatedPersonId: 'person_B',
          type: RelationshipType.parent,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Adding A as parent of person_D (sibling to B)
      expect(
        () => SecurityGuards.assertNoAncestryCycle(
          parentId: 'person_A',
          childId: 'person_D',
          existingRelationships: existing,
        ),
        returnsNormally,
      );
    });
  });
}
