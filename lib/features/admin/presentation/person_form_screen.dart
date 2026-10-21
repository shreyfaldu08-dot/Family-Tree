import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/person.dart';
import '../../../data/providers/repository_providers.dart';

class PersonFormScreen extends ConsumerStatefulWidget {
  final String? personIdToEdit;

  const PersonFormScreen({super.key, this.personIdToEdit});

  @override
  ConsumerState<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends ConsumerState<PersonFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _preferredNameCtrl = TextEditingController();
  final _maidenNameCtrl = TextEditingController();
  final _birthYearCtrl = TextEditingController();
  final _birthPlaceCtrl = TextEditingController();
  final _deathYearCtrl = TextEditingController();
  final _deathPlaceCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _lifeStoryCtrl = TextEditingController();

  Gender _gender = Gender.unknown;
  bool _isLiving = true;
  bool _isVerified = true;
  bool _isSaving = false;

  List<Person> _potentialDuplicates = [];

  @override
  void initState() {
    super.initState();
    if (widget.personIdToEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPersonData();
      });
    }
  }

  void _loadPersonData() {
    final persons = ref.read(familyPersonsProvider).valueOrNull ?? [];
    final p = persons.where((x) => x.id == widget.personIdToEdit).firstOrNull;
    if (p != null) {
      _firstNameCtrl.text = p.firstName;
      _lastNameCtrl.text = p.lastName;
      _preferredNameCtrl.text = p.preferredName ?? '';
      _maidenNameCtrl.text = p.maidenName ?? '';
      _birthYearCtrl.text = p.birthDate?.year.toString() ?? p.birthYearApprox?.toString() ?? '';
      _birthPlaceCtrl.text = p.birthPlace ?? '';
      _deathYearCtrl.text = p.deathDate?.year.toString() ?? p.deathYearApprox?.toString() ?? '';
      _deathPlaceCtrl.text = p.deathPlace ?? '';
      _bioCtrl.text = p.bio ?? '';
      _lifeStoryCtrl.text = p.lifeStory ?? '';
      setState(() {
        _gender = p.gender;
        _isLiving = p.isLiving;
        _isVerified = p.isVerified;
      });
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _preferredNameCtrl.dispose();
    _maidenNameCtrl.dispose();
    _birthYearCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _deathYearCtrl.dispose();
    _deathPlaceCtrl.dispose();
    _bioCtrl.dispose();
    _lifeStoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkDuplicates() async {
    final first = _firstNameCtrl.text.trim();
    final last = _lastNameCtrl.text.trim();
    final year = int.tryParse(_birthYearCtrl.text.trim());

    if (first.isNotEmpty && last.isNotEmpty) {
      final repo = ref.read(personRepositoryProvider);
      final membership = ref.read(currentMembershipProvider).valueOrNull;
      final dups = await repo.findPotentialDuplicates(
        familyId: 'fam_kensington_01',
        firstName: first,
        lastName: last,
        birthYear: year,
        excludePersonId: widget.personIdToEdit,
        membership: membership,
      );
      if (mounted) {
        setState(() {
          _potentialDuplicates = dups;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final membership = ref.read(currentMembershipProvider).valueOrNull;
      final repo = ref.read(personRepositoryProvider);

      final birthYear = int.tryParse(_birthYearCtrl.text.trim());
      final deathYear = int.tryParse(_deathYearCtrl.text.trim());

      final person = Person(
        id: widget.personIdToEdit ?? 'p_${DateTime.now().millisecondsSinceEpoch}',
        familyId: 'fam_kensington_01',
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        preferredName: _preferredNameCtrl.text.trim().isEmpty ? null : _preferredNameCtrl.text.trim(),
        maidenName: _maidenNameCtrl.text.trim().isEmpty ? null : _maidenNameCtrl.text.trim(),
        gender: _gender,
        birthDate: birthYear != null ? DateTime(birthYear, 1, 1) : null,
        birthDateApprox: birthYear != null,
        birthYearApprox: birthYear,
        birthPlace: _birthPlaceCtrl.text.trim().isEmpty ? null : _birthPlaceCtrl.text.trim(),
        deathDate: deathYear != null ? DateTime(deathYear, 1, 1) : null,
        deathDateApprox: deathYear != null,
        deathYearApprox: deathYear,
        deathPlace: _deathPlaceCtrl.text.trim().isEmpty ? null : _deathPlaceCtrl.text.trim(),
        isLiving: _isLiving,
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        lifeStory: _lifeStoryCtrl.text.trim().isEmpty ? null : _lifeStoryCtrl.text.trim(),
        isVerified: _isVerified,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.personIdToEdit != null) {
        await repo.updatePerson(person, membership);
      } else {
        await repo.createPerson(person, membership);
      }

      ref.invalidate(familyPersonsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${person.displayName} successfully saved to archive.'),
            backgroundColor: HeritageColors.forestGreen,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: HeritageColors.statusError),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.personIdToEdit != null;

    return Scaffold(
      backgroundColor: HeritageColors.warmIvory,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Family Record' : 'Record New Person', style: HeritageTypography.displaySmall),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Duplicate Warning Banner
            if (_potentialDuplicates.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: HeritageColors.statusWarning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: HeritageColors.statusWarning, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: HeritageColors.statusWarning, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Potential Duplicate Detected',
                          style: HeritageTypography.titleSmall.copyWith(
                            color: HeritageColors.statusWarning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Matching archive records with the same name already exist: ${_potentialDuplicates.map((p) => "${p.displayName} (${p.lifeDateSpan})").join(", ")}.',
                      style: HeritageTypography.bodySmall,
                    ),
                  ],
                ),
              ),

            // Names section
            Text('Names & Identity', style: HeritageTypography.titleMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameCtrl,
                    decoration: const InputDecoration(labelText: 'First Name *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    onChanged: (_) => _checkDuplicates(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameCtrl,
                    decoration: const InputDecoration(labelText: 'Last Name *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    onChanged: (_) => _checkDuplicates(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _preferredNameCtrl,
                    decoration: const InputDecoration(labelText: 'Preferred / Known As'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _maidenNameCtrl,
                    decoration: const InputDecoration(labelText: 'Maiden / Birth Name'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Vital Dates & Places
            Text('Vital Chronology', style: HeritageTypography.titleMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _birthYearCtrl,
                    decoration: const InputDecoration(labelText: 'Birth Year (e.g. 1825)'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _checkDuplicates(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _birthPlaceCtrl,
                    decoration: const InputDecoration(labelText: 'Birthplace'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Living switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Is this family member currently living?', style: HeritageTypography.bodyMedium),
              value: _isLiving,
              activeColor: HeritageColors.forestGreen,
              onChanged: (val) {
                setState(() => _isLiving = val);
              },
            ),

            if (!_isLiving) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _deathYearCtrl,
                      decoration: const InputDecoration(labelText: 'Passing Year (e.g. 1902)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _deathPlaceCtrl,
                      decoration: const InputDecoration(labelText: 'Place of Passing'),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Narrative Story & Bio
            Text('Archival Narrative', style: HeritageTypography.titleMedium),
            const SizedBox(height: 10),
            TextFormField(
              controller: _bioCtrl,
              decoration: const InputDecoration(labelText: 'Biographical Summary (1-2 sentences)'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lifeStoryCtrl,
              decoration: const InputDecoration(labelText: 'Detailed Life Chronicle & Family Memories'),
              maxLines: 5,
            ),

            const SizedBox(height: 16),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Mark as Archival Verified', style: HeritageTypography.bodyMedium),
              subtitle: Text('Confirms supporting primary documents exist.', style: HeritageTypography.bodySmall),
              value: _isVerified,
              activeColor: HeritageColors.forestGreen,
              onChanged: (val) {
                setState(() => _isVerified = val ?? true);
              },
            ),

            const SizedBox(height: 28),

            // Submit Button
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isEditing ? 'Save Changes' : 'Record in Heritage Archive'),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
