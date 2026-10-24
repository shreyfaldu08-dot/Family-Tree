import '../models/media_asset.dart';
import '../models/membership.dart';
import '../services/supabase_service.dart';
import '../../core/security/security_guards.dart';

class MediaRepository {
  final SupabaseService _supabase;
  final List<MediaAsset> _memoryStore = [];

  MediaRepository({required SupabaseService supabase}) : _supabase = supabase {
    _initSampleMedia();
  }

  Future<List<MediaAsset>> getMediaForFamily(
    String familyId,
    FamilyMembership? membership, {
    MediaType? typeFilter,
  }) async {
    if (!_supabase.isInitialized) {
      var list = _memoryStore.where((m) => m.familyId == familyId);
      if (typeFilter != null) {
        list = list.where((m) => m.mediaType == typeFilter);
      }
      return List.unmodifiable(list);
    }

    SecurityGuards.assertCanRead(membership);

    try {
      var query = _supabase.client
          .from('media_assets')
          .select()
          .eq('family_id', familyId);

      if (typeFilter != null) {
        query = query.eq('media_type', typeFilter.dbValue);
      }

      final res = await query.order('captured_date', ascending: false);
      final assets = (res as List).map((e) => MediaAsset.fromJson(e as Map<String, dynamic>)).toList();

      if (assets.isEmpty && _memoryStore.isNotEmpty) {
        return List.unmodifiable(_memoryStore.where((m) => m.familyId == familyId));
      }
      return assets;
    } catch (_) {
      return List.unmodifiable(_memoryStore.where((m) => m.familyId == familyId));
    }
  }

  Future<MediaAsset> createMediaAsset(
    MediaAsset asset,
    FamilyMembership? membership,
  ) async {
    SecurityGuards.assertPrimaryAdmin(membership, operation: 'upload family media');

    if (!_supabase.isInitialized) {
      _memoryStore.add(asset);
      return asset;
    }

    try {
      final res = await _supabase.client
          .from('media_assets')
          .insert({
            'family_id': asset.familyId,
            'storage_path': asset.storagePath,
            'storage_bucket': asset.storageBucket,
            'media_type': asset.mediaType.dbValue,
            'title': asset.title,
            'description': asset.description,
            'captured_date': asset.capturedDate?.toIso8601String().split('T').first,
            'captured_date_approx': asset.capturedDateApprox,
            'mime_type': asset.mimeType,
            'file_size_bytes': asset.fileSizeBytes,
            'uploader_id': membership?.userId ?? '',
          })
          .select()
          .single();

      return MediaAsset.fromJson(res);
    } catch (_) {
      _memoryStore.add(asset);
      return asset;
    }
  }

  Future<void> deleteMediaAsset(
    String assetId,
    FamilyMembership? membership,
  ) async {
    SecurityGuards.assertPrimaryAdmin(membership, operation: 'delete media assets');

    if (!_supabase.isInitialized) {
      _memoryStore.removeWhere((m) => m.id == assetId);
      return;
    }

    try {
      await _supabase.client.from('media_assets').delete().eq('id', assetId);
    } catch (_) {
      _memoryStore.removeWhere((m) => m.id == assetId);
    }
  }

  void _initSampleMedia() {
    const famId = 'fam_kensington_01';
    final now = DateTime.now();

    _memoryStore.addAll([
      MediaAsset(
        id: 'med_01',
        familyId: famId,
        storagePath: 'documents/1720_stone_mason_guild_charter.pdf',
        mediaType: MediaType.document,
        title: 'Stone Mason Guild Charter of Edinburgh',
        description: 'Original vellum indenture signed by Archibald Kensington certifying the master craft guild.',
        capturedDate: DateTime(1720, 5, 1),
        capturedDateApprox: false,
        mimeType: 'application/pdf',
        fileSizeBytes: 2450000,
        uploaderId: 'usr_admin_kensington_01',
        createdAt: now,
        updatedAt: now,
      ),
      MediaAsset(
        id: 'med_02',
        familyId: famId,
        storagePath: 'photos/1825_transatlantic_ship_manifest.jpg',
        mediaType: MediaType.photo,
        title: 'Barque Hector Atlantic Manifest',
        description: 'Passenger ledger page showing Callum and Elspeth Kensington arriving in Lower Canada.',
        capturedDate: DateTime(1820, 6, 12),
        capturedDateApprox: true,
        mimeType: 'image/jpeg',
        fileSizeBytes: 3800000,
        uploaderId: 'usr_admin_kensington_01',
        createdAt: now,
        updatedAt: now,
      ),
      MediaAsset(
        id: 'med_03',
        familyId: famId,
        storagePath: 'audio/1965_grandfather_oral_recording.mp3',
        mediaType: MediaType.audio,
        title: 'Arthur Kensington: Recollections of the Great War Hospital',
        description: 'Magnetic reel recording of Arthur describing field surgical stations in Flanders.',
        capturedDate: DateTime(1965, 11, 11),
        capturedDateApprox: false,
        mimeType: 'audio/mpeg',
        fileSizeBytes: 18400000,
        uploaderId: 'usr_admin_kensington_01',
        createdAt: now,
        updatedAt: now,
      ),
      MediaAsset(
        id: 'med_04',
        familyId: famId,
        storagePath: 'photos/1958_julian_helena_wedding.jpg',
        mediaType: MediaType.photo,
        title: 'Julian & Helena Wedding Portrait in Madrid',
        description: 'Silver gelatin print captured outside the cathedral courtyard.',
        capturedDate: DateTime(1958, 6, 20),
        capturedDateApprox: false,
        mimeType: 'image/jpeg',
        fileSizeBytes: 4200000,
        uploaderId: 'usr_admin_kensington_01',
        createdAt: now,
        updatedAt: now,
      ),
    ]);
  }
}
