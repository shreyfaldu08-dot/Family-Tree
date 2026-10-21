import '../errors/app_exception.dart';
import '../../data/models/membership.dart';
import '../../data/models/relationship.dart';

/// Client-side defensive enforcement of authorization and graph integrity.
/// Works in tandem with PostgreSQL RLS policies.
abstract final class SecurityGuards {
  /// Asserts that the current member is the primary admin before any write operation.
  /// Throws [UnauthorizedException] if not primary admin.
  static void assertPrimaryAdmin(FamilyMembership? membership, {String operation = 'perform this action'}) {
    if (membership == null) {
      throw const UnauthorizedException(
        'Authentication and approved family membership are required.',
      );
    }

    if (!membership.status.isActive) {
      throw const MembershipRevokedException(
        'Access denied: Your membership to this family archive has been revoked.',
      );
    }

    if (membership.role != MemberRole.primaryAdmin) {
      throw UnauthorizedException(
        'Strict Authorization: Only the Primary Admin can $operation. All other family members have read-only access.',
      );
    }
  }

  /// Asserts that the current member has active read access to this family archive.
  static void assertCanRead(FamilyMembership? membership) {
    if (membership == null) {
      throw const UnauthorizedException(
        'Please sign in and obtain approved family membership to view this archive.',
      );
    }

    if (!membership.status.isActive) {
      throw const MembershipRevokedException(
        'Your membership has been revoked. Access to this family archive is blocked.',
      );
    }
  }

  /// Detects ancestry cycles client-side before sending relationship inserts to PostgreSQL.
  /// If [parentId] is already a descendant of [childId], adding [parentId] as parent creates a cycle!
  static void assertNoAncestryCycle({
    required String parentId,
    required String childId,
    required List<Relationship> existingRelationships,
  }) {
    if (parentId == childId) {
      throw const AncestryCycleException(
        'Self-parenting is invalid: A person cannot be their own parent.',
      );
    }

    // Build directed adjacency map for parent -> child
    final parentToChildren = <String, Set<String>>{};
    for (final rel in existingRelationships) {
      if (rel.type == RelationshipType.parent) {
        parentToChildren.putIfAbsent(rel.personId, () => {}).add(rel.relatedPersonId);
      } else if (rel.type == RelationshipType.child) {
        parentToChildren.putIfAbsent(rel.relatedPersonId, () => {}).add(rel.personId);
      }
    }

    // Check if parentId is reachable starting from childId (i.e. childId is ancestor of parentId)
    final visited = <String>{};
    final queue = <String>[childId];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (current == parentId) {
        throw const AncestryCycleException(
          'Cycle detected: Making this connection would cause an ancestor loop where a person descends from themselves.',
        );
      }

      final children = parentToChildren[current] ?? const {};
      for (final child in children) {
        if (!visited.contains(child)) {
          visited.add(child);
          queue.add(child);
        }
      }
    }
  }
}
