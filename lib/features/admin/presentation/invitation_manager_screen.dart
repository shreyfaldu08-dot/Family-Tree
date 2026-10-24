import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/providers/repository_providers.dart';

class InvitationManagerScreen extends ConsumerStatefulWidget {
  const InvitationManagerScreen({super.key});

  @override
  ConsumerState<InvitationManagerScreen> createState() => _InvitationManagerScreenState();
}

class _InvitationManagerScreenState extends ConsumerState<InvitationManagerScreen> {
  final _emailCtrl = TextEditingController();
  int _validityDays = 7;
  String? _generatedCode;
  bool _isGenerating = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _generateInvite() async {
    setState(() => _isGenerating = true);
    try {
      final repo = ref.read(familyRepositoryProvider);
      final membership = ref.read(currentMembershipProvider).valueOrNull;

      final token = await repo.createInvitation(
        familyId: 'fam_kensington_01',
        recipientEmail: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        validity: Duration(days: _validityDays),
        membership: membership,
      );

      if (mounted) {
        setState(() {
          _generatedCode = token;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: HeritageColors.statusError),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeritageColors.warmIvory,
      appBar: AppBar(
        title: Text('Family Invitations', style: HeritageTypography.displaySmall),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: HeritageCurves.cardLarge,
              boxShadow: HeritageShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Generate Single-Use Passcode', style: HeritageTypography.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Invitations expire automatically. The database stores the SHA-256 hash. Once redeemed, the applicant must still be approved by you.',
                  style: HeritageTypography.bodySmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Recipient Email (Optional)',
                    hintText: 'e.g. cousin.elena@gmail.com',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Validity Period:', style: HeritageTypography.bodyMedium),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: _validityDays,
                      items: const [
                        DropdownMenuItem(value: 3, child: Text('3 Days')),
                        DropdownMenuItem(value: 7, child: Text('7 Days')),
                        DropdownMenuItem(value: 14, child: Text('14 Days')),
                        DropdownMenuItem(value: 30, child: Text('30 Days')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _validityDays = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isGenerating ? null : _generateInvite,
                  child: _isGenerating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Generate Invitation Code'),
                ),
              ],
            ),
          ),

          if (_generatedCode != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.signatureGradient,
                borderRadius: HeritageCurves.cardLarge,
                boxShadow: HeritageShadows.card,
              ),
              child: Column(
                children: [
                  Text(
                    'Active Invitation Code',
                    style: HeritageTypography.labelSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    _generatedCode!,
                    style: HeritageTypography.displayMedium.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                    ),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy to Clipboard'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _generatedCode!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied to clipboard!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
