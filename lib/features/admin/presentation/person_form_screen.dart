import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/person.dart';
import '../../../data/models/relationship.dart';
import '../../../data/providers/repository_providers.dart';

class PersonFormScreen extends ConsumerStatefulWidget {
  final String? personIdToEdit;
  final String? initialRelationType; // 'parent', 'spouse', 'child', 'sibling'
  final String? initialSourcePersonId;

  const PersonFormScreen({
    super.key,
    this.personIdToEdit,
    this.initialRelationType,
    this.initialSourcePersonId,
  });

  @override
  ConsumerState<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends ConsumerState<PersonFormScreen> {
  int _currentStep = 1;
  final int _totalSteps = 7;

  // Step 1: Basic
  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  final _photoUrlCtrl = TextEditingController();
  Gender _gender = Gender.unknown;

  // Step 2: Birth
  final _birthDateCtrl = TextEditingController();
  final _birthTimeCtrl = TextEditingController();
  final _birthPlaceCtrl = TextEditingController();
  bool _birthDateApprox = false;
  bool _birthDateUnknown = false;

  // Step 3: Family Links
  String? _selectedFatherId;
  String? _selectedMotherId;
  String? _selectedSpouseId;
  String? _selectedChildId;
  String? _selectedSiblingId;

  // Step 4: Life Details
  final _marriageDateCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _currentCityCtrl = TextEditingController();
  final _communityCtrl = TextEditingController();
  String _bloodGroup = 'Unknown';
  final _contactInfoCtrl = TextEditingController();

  // Step 5: Death (only if deceased)
  bool _isDeceased = false;
  final _deathDateCtrl = TextEditingController();
  final _deathPlaceCtrl = TextEditingController();

  // Step 6: Extra
  final _bioCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _extraPhotoCtrl = TextEditingController();

  bool _isSaving = false;
  List<Person> _potentialDuplicates = [];

  final List<String> _bloodGroups = [
    'Unknown',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _initPreselectedLinks();
    if (widget.personIdToEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPersonData();
      });
    }
  }

  void _initPreselectedLinks() {
    if (widget.initialRelationType != null && widget.initialSourcePersonId != null) {
      switch (widget.initialRelationType) {
        case 'parent':
          _selectedChildId = widget.initialSourcePersonId;
          break;
        case 'child':
          _selectedFatherId = widget.initialSourcePersonId;
          break;
        case 'spouse':
          _selectedSpouseId = widget.initialSourcePersonId;
          break;
        case 'sibling':
          _selectedSiblingId = widget.initialSourcePersonId;
          break;
      }
    }
  }

  void _loadPersonData() {
    final persons = ref.read(familyPersonsProvider).valueOrNull ?? [];
    final p = persons.where((x) => x.id == widget.personIdToEdit).firstOrNull;
    if (p != null) {
      _firstNameCtrl.text = p.firstName;
      _middleNameCtrl.text = p.preferredName ?? '';
      _lastNameCtrl.text = p.lastName;
      _nicknameCtrl.text = p.alternateNames.isNotEmpty ? p.alternateNames.first : '';
      _photoUrlCtrl.text = p.portraitUrl ?? '';
      _gender = p.gender;

      if (p.birthDate != null) {
        _birthDateCtrl.text = '${p.birthDate!.day.toString().padLeft(2, '0')}/${p.birthDate!.month.toString().padLeft(2, '0')}/${p.birthDate!.year}';
      } else if (p.birthYear != null) {
        _birthDateCtrl.text = p.birthYear.toString();
      }
      _birthPlaceCtrl.text = p.birthPlace ?? '';
      _birthDateApprox = p.birthDateApprox;

      _isDeceased = !p.isLiving;
      if (p.deathDate != null) {
        _deathDateCtrl.text = '${p.deathDate!.day.toString().padLeft(2, '0')}/${p.deathDate!.month.toString().padLeft(2, '0')}/${p.deathDate!.year}';
      } else if (p.deathYear != null) {
        _deathDateCtrl.text = p.deathYear.toString();
      }
      _deathPlaceCtrl.text = p.deathPlace ?? '';

      _bioCtrl.text = p.bio ?? '';
      _notesCtrl.text = p.lifeStory ?? '';
      setState(() {});
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _nicknameCtrl.dispose();
    _photoUrlCtrl.dispose();
    _birthDateCtrl.dispose();
    _birthTimeCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _marriageDateCtrl.dispose();
    _occupationCtrl.dispose();
    _educationCtrl.dispose();
    _currentCityCtrl.dispose();
    _communityCtrl.dispose();
    _contactInfoCtrl.dispose();
    _deathDateCtrl.dispose();
    _deathPlaceCtrl.dispose();
    _bioCtrl.dispose();
    _notesCtrl.dispose();
    _extraPhotoCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkDuplicates() async {
    final first = _firstNameCtrl.text.trim();
    final last = _lastNameCtrl.text.trim();
    if (first.isEmpty) return;

    final persons = ref.read(familyPersonsProvider).valueOrNull ?? [];
    setState(() {
      _potentialDuplicates = persons.where((p) {
        if (p.id == widget.personIdToEdit) return false;
        final nameMatch = p.firstName.toLowerCase() == first.toLowerCase() ||
            p.lastName.toLowerCase() == last.toLowerCase();
        return nameMatch;
      }).toList();
    });
  }

  void _nextStep() {
    // Only FIRST NAME is required
    if (_currentStep == 1 && _firstNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('First Name is required.'),
          backgroundColor: AppColors.statusError,
        ),
      );
      return;
    }

    if (_currentStep == 1) {
      _checkDuplicates();
    }

    // Step 5 is Death - skip if not deceased
    if (_currentStep == 4 && !_isDeceased) {
      setState(() => _currentStep = 6);
      return;
    }

    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      _savePersonRecord();
    }
  }

  void _previousStep() {
    if (_currentStep == 6 && !_isDeceased) {
      setState(() => _currentStep = 4);
      return;
    }
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  DateTime? _parseDate(String val) {
    if (val.trim().isEmpty) return null;
    final parts = val.trim().split('/');
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null) {
        return DateTime(y, m, d);
      }
    }
    final year = int.tryParse(val.trim());
    if (year != null) {
      return DateTime(year, 1, 1);
    }
    return null;
  }

  int? _parseYear(String val) {
    if (val.trim().isEmpty) return null;
    final parts = val.trim().split('/');
    if (parts.length == 3) {
      return int.tryParse(parts[2]);
    }
    return int.tryParse(val.trim());
  }

  Future<void> _savePersonRecord({bool asDraft = false}) async {
    final first = _firstNameCtrl.text.trim();
    if (first.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('First Name is required to save.'),
          backgroundColor: AppColors.statusError,
        ),
      );
      return;
    }

    final birthDt = _parseDate(_birthDateCtrl.text);
    final deathDt = _parseDate(_deathDateCtrl.text);

    // Validation: death date cannot be before birth date
    if (birthDt != null && deathDt != null && deathDt.isBefore(birthDt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Death date cannot be before birth date.'),
          backgroundColor: AppColors.statusError,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final personRepo = ref.read(personRepositoryProvider);
      final membership = ref.read(currentMembershipProvider).valueOrNull;

      final targetId = widget.personIdToEdit ?? 'per_${DateTime.now().millisecondsSinceEpoch}';

      final person = Person(
        id: targetId,
        familyId: 'fam_kensington_01',
        firstName: first,
        lastName: _lastNameCtrl.text.trim(),
        preferredName: _middleNameCtrl.text.trim().isNotEmpty ? _middleNameCtrl.text.trim() : null,
        maidenName: null,
        alternateNames: _nicknameCtrl.text.trim().isNotEmpty ? [_nicknameCtrl.text.trim()] : const [],
        gender: _gender,
        birthDate: birthDt,
        birthDateApprox: _birthDateApprox,
        birthYearApprox: _birthDateApprox ? _parseYear(_birthDateCtrl.text) : null,
        birthYear: _parseYear(_birthDateCtrl.text),
        birthPlace: _birthPlaceCtrl.text.trim().isNotEmpty ? _birthPlaceCtrl.text.trim() : null,
        deathDate: _isDeceased ? deathDt : null,
        deathDateApprox: false,
        deathYear: _isDeceased ? _parseYear(_deathDateCtrl.text) : null,
        deathPlace: _isDeceased && _deathPlaceCtrl.text.trim().isNotEmpty ? _deathPlaceCtrl.text.trim() : null,
        isLiving: !_isDeceased,
        bio: _bioCtrl.text.trim().isNotEmpty ? _bioCtrl.text.trim() : null,
        lifeStory: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
        portraitUrl: _photoUrlCtrl.text.trim().isNotEmpty ? _photoUrlCtrl.text.trim() : null,
        isVerified: true,
        generationHint: 4,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.personIdToEdit != null) {
        await personRepo.updatePerson(person, membership);
      } else {
        await personRepo.createPerson(person, membership);
      }

      // Link relationships if selected
      final relRepo = ref.read(relationshipRepositoryProvider);
      final now = DateTime.now();

      if (_selectedFatherId != null && _selectedFatherId != targetId) {
        await relRepo.addRelationship(
          Relationship(
            id: 'rel_${now.millisecondsSinceEpoch}_1',
            familyId: 'fam_kensington_01',
            personId: _selectedFatherId!,
            relatedPersonId: targetId,
            type: RelationshipType.parent,
            createdAt: now,
            updatedAt: now,
          ),
          membership,
        );
      }
      if (_selectedMotherId != null && _selectedMotherId != targetId) {
        await relRepo.addRelationship(
          Relationship(
            id: 'rel_${now.millisecondsSinceEpoch}_2',
            familyId: 'fam_kensington_01',
            personId: _selectedMotherId!,
            relatedPersonId: targetId,
            type: RelationshipType.parent,
            createdAt: now,
            updatedAt: now,
          ),
          membership,
        );
      }
      if (_selectedSpouseId != null && _selectedSpouseId != targetId) {
        await relRepo.addRelationship(
          Relationship(
            id: 'rel_${now.millisecondsSinceEpoch}_3',
            familyId: 'fam_kensington_01',
            personId: targetId,
            relatedPersonId: _selectedSpouseId!,
            type: RelationshipType.spouse,
            createdAt: now,
            updatedAt: now,
          ),
          membership,
        );
      }
      if (_selectedChildId != null && _selectedChildId != targetId) {
        await relRepo.addRelationship(
          Relationship(
            id: 'rel_${now.millisecondsSinceEpoch}_4',
            familyId: 'fam_kensington_01',
            personId: targetId,
            relatedPersonId: _selectedChildId!,
            type: RelationshipType.parent,
            createdAt: now,
            updatedAt: now,
          ),
          membership,
        );
      }
      if (_selectedSiblingId != null && _selectedSiblingId != targetId) {
        await relRepo.addRelationship(
          Relationship(
            id: 'rel_${now.millisecondsSinceEpoch}_5',
            familyId: 'fam_kensington_01',
            personId: targetId,
            relatedPersonId: _selectedSiblingId!,
            type: RelationshipType.sibling,
            createdAt: now,
            updatedAt: now,
          ),
          membership,
        );
      }

      ref.invalidate(familyPersonsProvider);
      ref.invalidate(familyRelationshipsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(asDraft ? 'Person draft saved.' : 'Person record saved successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
        // After saving, go to that person's profile
        context.go('/member/$targetId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppColors.statusError),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final persons = ref.watch(familyPersonsProvider).valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.personIdToEdit != null ? 'Edit Person Record' : 'Add Person Record',
          style: HeritageTypography.displaySmall,
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => _savePersonRecord(asDraft: true),
            child: const Text('Save Draft'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 7-Step Progress Indicator Bar
            _buildProgressBar(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: HeritageCurves.cardLarge,
                    boxShadow: HeritageShadows.card,
                  ),
                  child: _buildCurrentStepContent(persons),
                ),
              ),
            ),

            // Bottom Navigation Actions
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Progress Header
  // ---------------------------------------------------------------------------
  Widget _buildProgressBar() {
    final stepTitles = [
      'Basic',
      'Birth',
      'Family Links',
      'Life Details',
      'Death',
      'Extra',
      'Review & Save',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $_currentStep of $_totalSteps: ${stepTitles[_currentStep - 1]}',
                style: HeritageTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${((_currentStep / _totalSteps) * 100).toInt()}%',
                style: HeritageTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: HeritageCurves.pill,
            child: LinearProgressIndicator(
              value: _currentStep / _totalSteps,
              backgroundColor: AppColors.lightSage,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step Switcher
  // ---------------------------------------------------------------------------
  Widget _buildCurrentStepContent(List<Person> allPersons) {
    switch (_currentStep) {
      case 1:
        return _buildStep1Basic();
      case 2:
        return _buildStep2Birth();
      case 3:
        return _buildStep3FamilyLinks(allPersons);
      case 4:
        return _buildStep4LifeDetails();
      case 5:
        return _buildStep5Death();
      case 6:
        return _buildStep6Extra();
      case 7:
        return _buildStep7Review();
      default:
        return const SizedBox.shrink();
    }
  }

  // ---------------------------------------------------------------------------
  // Step 1: Basic Information
  // ---------------------------------------------------------------------------
  Widget _buildStep1Basic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1: Basic Information', style: HeritageTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Only First Name is required. All other fields are optional.', style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 18),

        TextField(
          controller: _firstNameCtrl,
          decoration: const InputDecoration(
            labelText: 'First Name *',
            hintText: 'e.g. Eleanor',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _middleNameCtrl,
          decoration: const InputDecoration(
            labelText: 'Middle Name (Optional)',
            hintText: 'e.g. Vance',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _lastNameCtrl,
          decoration: const InputDecoration(
            labelText: 'Last Name / Surname',
            hintText: 'e.g. Kensington',
            prefixIcon: Icon(Icons.family_restroom_rounded),
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _nicknameCtrl,
          decoration: const InputDecoration(
            labelText: 'Nickname / Alternate Name',
            hintText: 'e.g. Ellie',
            prefixIcon: Icon(Icons.tag_faces_rounded),
          ),
        ),
        const SizedBox(height: 16),

        Text('Gender', style: HeritageTypography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildGenderOption('Male', Gender.male, Icons.male_rounded),
            const SizedBox(width: 8),
            _buildGenderOption('Female', Gender.female, Icons.female_rounded),
            const SizedBox(width: 8),
            _buildGenderOption('Other', Gender.other, Icons.transgender_rounded),
          ],
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _photoUrlCtrl,
          decoration: const InputDecoration(
            labelText: 'Profile Photo URL / Cloud Scan',
            hintText: 'https://...',
            prefixIcon: Icon(Icons.add_photo_alternate_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, Gender val, IconData icon) {
    final isSelected = _gender == val;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _gender = val),
        borderRadius: HeritageCurves.pill,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.lightSage,
            borderRadius: HeritageCurves.pill,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textPrimary),
              const SizedBox(width: 4),
              Text(
                label,
                style: HeritageTypography.labelSmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2: Birth Details
  // ---------------------------------------------------------------------------
  Widget _buildStep2Birth() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2: Birth Details', style: HeritageTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Supports DD/MM/YYYY or partial year format (e.g. 1945).', style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 18),

        if (!_birthDateUnknown) ...[
          TextField(
            controller: _birthDateCtrl,
            decoration: const InputDecoration(
              labelText: 'Date of Birth (DD/MM/YYYY or YYYY)',
              hintText: '14/05/1942',
              prefixIcon: Icon(Icons.calendar_today_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _birthTimeCtrl,
            decoration: const InputDecoration(
              labelText: 'Time of Birth (Optional)',
              hintText: 'e.g. 09:30 AM',
              prefixIcon: Icon(Icons.access_time_rounded),
            ),
          ),
          const SizedBox(height: 12),
        ],

        TextField(
          controller: _birthPlaceCtrl,
          decoration: const InputDecoration(
            labelText: 'Place of Birth',
            hintText: 'e.g. Oxford, Oxfordshire, England',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
        ),
        const SizedBox(height: 14),

        CheckboxListTile(
          value: _birthDateApprox,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          title: Text('Approximate date ("circa")', style: HeritageTypography.bodyMedium),
          onChanged: (v) => setState(() => _birthDateApprox = v ?? false),
        ),

        CheckboxListTile(
          value: _birthDateUnknown,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          title: Text('Date unknown', style: HeritageTypography.bodyMedium),
          onChanged: (v) => setState(() => _birthDateUnknown = v ?? false),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3: Family Links
  // ---------------------------------------------------------------------------
  Widget _buildStep3FamilyLinks(List<Person> allPersons) {
    final available = allPersons.where((p) => p.id != widget.personIdToEdit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: Family Links', style: HeritageTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Connect parents, spouse, or siblings. Relationships update the interactive tree.', style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 18),

        _buildPersonDropdown(
          label: 'Father',
          selectedId: _selectedFatherId,
          persons: available.where((p) => p.gender != Gender.female).toList(),
          onChanged: (v) => setState(() => _selectedFatherId = v),
        ),
        const SizedBox(height: 12),

        _buildPersonDropdown(
          label: 'Mother',
          selectedId: _selectedMotherId,
          persons: available.where((p) => p.gender != Gender.male).toList(),
          onChanged: (v) => setState(() => _selectedMotherId = v),
        ),
        const SizedBox(height: 12),

        _buildPersonDropdown(
          label: 'Spouse / Partner',
          selectedId: _selectedSpouseId,
          persons: available,
          onChanged: (v) => setState(() => _selectedSpouseId = v),
        ),
        const SizedBox(height: 12),

        _buildPersonDropdown(
          label: 'Child',
          selectedId: _selectedChildId,
          persons: available,
          onChanged: (v) => setState(() => _selectedChildId = v),
        ),
        const SizedBox(height: 12),

        _buildPersonDropdown(
          label: 'Sibling',
          selectedId: _selectedSiblingId,
          persons: available,
          onChanged: (v) => setState(() => _selectedSiblingId = v),
        ),
      ],
    );
  }

  Widget _buildPersonDropdown({
    required String label,
    required String? selectedId,
    required List<Person> persons,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: HeritageTypography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: selectedId,
          isExpanded: true,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.people_outline_rounded)),
          hint: Text('Select $label or leave empty', style: HeritageTypography.bodySmall),
          items: [
            const DropdownMenuItem(value: null, child: Text('None / Unknown')),
            ...persons.map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Text('${p.displayName} (${p.lifeDateSpan})', overflow: TextOverflow.ellipsis),
                )),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 4: Life Details
  // ---------------------------------------------------------------------------
  Widget _buildStep4LifeDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 4: Life Details', style: HeritageTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Occupation, education, current city, and community information.', style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 18),

        TextField(
          controller: _occupationCtrl,
          decoration: const InputDecoration(labelText: 'Occupation / Profession', prefixIcon: Icon(Icons.work_outline_rounded)),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _educationCtrl,
          decoration: const InputDecoration(labelText: 'Education', prefixIcon: Icon(Icons.school_outlined)),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _currentCityCtrl,
          decoration: const InputDecoration(labelText: 'Current Residence City', prefixIcon: Icon(Icons.apartment_rounded)),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _communityCtrl,
          decoration: const InputDecoration(labelText: 'Community / Religion (Optional)', prefixIcon: Icon(Icons.church_outlined)),
        ),
        const SizedBox(height: 12),

        Text('Blood Group', style: HeritageTypography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _bloodGroup,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.bloodtype_outlined)),
          items: _bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
          onChanged: (v) => setState(() => _bloodGroup = v ?? 'Unknown'),
        ),
        const SizedBox(height: 14),

        CheckboxListTile(
          value: _isDeceased,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          title: Text('Person is deceased', style: HeritageTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
          subtitle: const Text('Checking this unlocks Step 5 (Death details)'),
          onChanged: (v) => setState(() => _isDeceased = v ?? false),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 5: Death (Shown only if deceased)
  // ---------------------------------------------------------------------------
  Widget _buildStep5Death() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 5: Death Details', style: HeritageTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Record date and place of passing.', style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 18),

        TextField(
          controller: _deathDateCtrl,
          decoration: const InputDecoration(
            labelText: 'Date of Passing (DD/MM/YYYY or YYYY)',
            hintText: 'e.g. 12/10/1998',
            prefixIcon: Icon(Icons.event_busy_rounded),
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _deathPlaceCtrl,
          decoration: const InputDecoration(
            labelText: 'Place of Passing',
            hintText: 'e.g. London, UK',
            prefixIcon: Icon(Icons.location_city_outlined),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 6: Extra Details & Story
  // ---------------------------------------------------------------------------
  Widget _buildStep6Extra() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 6: Life Story & Archive', style: HeritageTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Preserve meaningful memories, life accomplishments, and archival notes.', style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 18),

        TextField(
          controller: _bioCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Short Biography',
            hintText: 'A brief synopsis of their life...',
          ),
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _notesCtrl,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Archival Chronicles & Life Story',
            hintText: 'Detailed stories, anecdotes, and family milestones...',
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 7: Review & Save
  // ---------------------------------------------------------------------------
  Widget _buildStep7Review() {
    final first = _firstNameCtrl.text.trim();
    final last = _lastNameCtrl.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 7: Review & Save', style: HeritageTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Verify the entered information before saving to the family tree.', style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 18),

        if (_potentialDuplicates.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.lightSage,
              borderRadius: HeritageCurves.card,
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Notice: Found ${_potentialDuplicates.length} person(s) with matching names in the database. Ensure this is not an unintentional duplicate.',
                    style: HeritageTypography.bodySmall.copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Summary Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.lightSage.withOpacity(0.5),
            borderRadius: HeritageCurves.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewRow('Full Name', '$first $last'),
              _buildReviewRow('Gender', _gender.name.toUpperCase()),
              _buildReviewRow('Birth', _birthDateCtrl.text.isNotEmpty ? _birthDateCtrl.text : 'Not provided'),
              _buildReviewRow('Place', _birthPlaceCtrl.text.isNotEmpty ? _birthPlaceCtrl.text : 'Not provided'),
              _buildReviewRow('Status', _isDeceased ? 'Deceased (${_deathDateCtrl.text})' : 'Living Relative'),
              _buildReviewRow('Occupation', _occupationCtrl.text.isNotEmpty ? _occupationCtrl.text : 'Not provided'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: HeritageTypography.bodySmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: HeritageTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppColors.surface,
      child: Row(
        children: [
          if (_currentStep > 1) ...[
            OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(90, 48),
                shape: RoundedRectangleBorder(borderRadius: HeritageCurves.pill),
              ),
              child: const Text('Back'),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: HeritageCurves.pill),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_currentStep == _totalSteps ? 'Review & Save Record' : 'Save & Next'),
            ),
          ),
        ],
      ),
    );
  }
}
