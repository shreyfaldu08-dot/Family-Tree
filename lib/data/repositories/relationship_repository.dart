import '../models/relationship.dart';
import '../models/membership.dart';
import '../services/supabase_service.dart';
import '../../core/security/security_guards.dart';

class RelationshipRepository {
  final SupabaseService _supabase;
  final List<Relationship> _memoryStore = [];

  RelationshipRepository({required SupabaseService supabase}) : _supabase = supabase {
    _initSampleRelationships();
  }

  Future<List<Relationship>> getRelationshipsForFamily(
    String familyId,
    FamilyMembership? membership,
  ) async {
    if (!_supabase.isInitialized) {
      return List.unmodifiable(_memoryStore.where((r) => r.familyId == familyId));
    }

    SecurityGuards.assertCanRead(membership);

    try {
      final res = await _supabase.client
          .from('relationships')
          .select()
          .eq('family_id', familyId);

      final list = (res as List).map((e) => Relationship.fromJson(e as Map<String, dynamic>)).toList();
      if (list.isEmpty && _memoryStore.isNotEmpty) {
        return List.unmodifiable(_memoryStore.where((r) => r.familyId == familyId));
      }
      return list;
    } catch (_) {
      return List.unmodifiable(_memoryStore.where((r) => r.familyId == familyId));
    }
  }

  Future<Relationship> addRelationship(
    Relationship rel,
    FamilyMembership? membership,
  ) async {
    SecurityGuards.assertPrimaryAdmin(membership, operation: 'add family relationships');

    // Run cycle prevention check if relationship is parent or child
    final existing = await getRelationshipsForFamily(rel.familyId, membership);
    if (rel.type == RelationshipType.parent) {
      SecurityGuards.assertNoAncestryCycle(
        parentId: rel.personId,
        childId: rel.relatedPersonId,
        existingRelationships: existing,
      );
    } else if (rel.type == RelationshipType.child) {
      SecurityGuards.assertNoAncestryCycle(
        parentId: rel.relatedPersonId,
        childId: rel.personId,
        existingRelationships: existing,
      );
    }

    if (!_supabase.isInitialized) {
      _memoryStore.add(rel);
      return rel;
    }

    try {
      final res = await _supabase.client
          .from('relationships')
          .insert(rel.toJson())
          .select()
          .single();
      return Relationship.fromJson(res);
    } catch (_) {
      _memoryStore.add(rel);
      return rel;
    }
  }

  Future<void> deleteRelationship(
    String relationshipId,
    FamilyMembership? membership,
  ) async {
    SecurityGuards.assertPrimaryAdmin(membership, operation: 'delete relationships');

    if (!_supabase.isInitialized) {
      _memoryStore.removeWhere((r) => r.id == relationshipId);
      return;
    }

    try {
      await _supabase.client.from('relationships').delete().eq('id', relationshipId);
    } catch (_) {
      _memoryStore.removeWhere((r) => r.id == relationshipId);
    }
  }

  void _initSampleRelationships() {
    const famId = 'fam_kensington_01';
    final now = DateTime.now();

    // Helper to add parent-child relationship (personId is parent, relatedPersonId is child)
    void addParentChild(String parentId, String childId) {
      _memoryStore.add(Relationship(
        id: 'rel_${parentId}_$childId',
        familyId: famId,
        personId: parentId,
        relatedPersonId: childId,
        type: RelationshipType.parent,
        isVerified: true,
        createdAt: now,
        updatedAt: now,
      ));
    }

    void addSpouses(String spouse1, String spouse2) {
      _memoryStore.add(Relationship(
        id: 'rel_sp_${spouse1}_$spouse2',
        familyId: famId,
        personId: spouse1,
        relatedPersonId: spouse2,
        type: RelationshipType.spouse,
        isVerified: true,
        createdAt: now,
        updatedAt: now,
      ));
    }

    // Gen 1 spouses & parents of Gen 2
    addSpouses('p_gen1_archibald', 'p_gen1_margaret');
    addParentChild('p_gen1_archibald', 'p_gen2_hamish');
    addParentChild('p_gen1_margaret', 'p_gen2_hamish');

    // Gen 2 spouses & parents of Gen 3
    addSpouses('p_gen2_hamish', 'p_gen2_isla');
    addParentChild('p_gen2_hamish', 'p_gen3_callum');
    addParentChild('p_gen2_isla', 'p_gen3_callum');

    // Gen 3 spouses & parents of Gen 4
    addSpouses('p_gen3_callum', 'p_gen3_elspeth');
    addParentChild('p_gen3_callum', 'p_gen4_robert');
    addParentChild('p_gen3_elspeth', 'p_gen4_robert');

    // Gen 4 spouses & parents of Gen 5
    addSpouses('p_gen4_robert', 'p_gen4_beatrice');
    addParentChild('p_gen4_robert', 'p_gen5_charles');
    addParentChild('p_gen4_beatrice', 'p_gen5_charles');

    // Gen 5 spouses & parents of Gen 6
    addSpouses('p_gen5_charles', 'p_gen5_clara');
    addParentChild('p_gen5_charles', 'p_gen6_arthur');
    addParentChild('p_gen5_clara', 'p_gen6_arthur');

    // Gen 6 spouses & parents of Gen 7
    addSpouses('p_gen6_arthur', 'p_gen6_evelyn');
    addParentChild('p_gen6_arthur', 'p_gen7_julian');
    addParentChild('p_gen6_evelyn', 'p_gen7_julian');

    // Gen 7 spouses & parents of Gen 8
    addSpouses('p_gen7_julian', 'p_gen7_helena');
    addParentChild('p_gen7_julian', 'p_gen8_david');
    addParentChild('p_gen7_helena', 'p_gen8_david');

    // Gen 8 spouses & parents of Gen 9
    addSpouses('p_gen8_david', 'p_gen8_sophia');
    addParentChild('p_gen8_david', 'p_gen9_lucas');
    addParentChild('p_gen8_sophia', 'p_gen9_lucas');

    // Gen 9 spouses & parents of Gen 10
    addSpouses('p_gen9_lucas', 'p_gen9_elena');
    addParentChild('p_gen9_lucas', 'p_gen10_maya');
    addParentChild('p_gen9_elena', 'p_gen10_maya');
  }
}
