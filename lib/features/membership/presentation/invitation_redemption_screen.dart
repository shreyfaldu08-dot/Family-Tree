import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/providers/repository_providers.dart';

class InvitationRedemptionScreen extends ConsumerStatefulWidget {
  const InvitationRedemptionScreen({super.key});

  @override
  ConsumerState<InvitationRedemptionScreen> createState() => _InvitationRedemptionScreenState();
}

class _InvitationRedemptionScreenState extends ConsumerState<InvitationRedemptionScreen> {
  final _codeCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an invitation passcode.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(familyRepositoryProvider);
      await repo.redeemInvitation(
        rawCode: code,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );

      if (mounted) {
        context.go('/pending-approval');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Redemption error: $e'),
            backgroundColor: HeritageColors.statusError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeritageColors.warmIvory,
      appBar: AppBar(
        title: Text('Redeem Passcode', style: HeritageTypography.displaySmall),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: HeritageCurves.cardLarge,
              boxShadow: HeritageShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.vpn_key_outlined,
                  size: 40,
                  color: HeritageColors.forestGreen,
                ),
                const SizedBox(height: 12),
                Text(
                  'Join Shared Family Archive',
                  textAlign: TextAlign.center,
                  style: HeritageTypography.titleMedium.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter the single-use invitation code provided by your family archon. Once entered, your request will be routed for primary admin approval.',
                  textAlign: TextAlign.center,
                  style: HeritageTypography.bodySmall,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Invitation Code',
                    hintText: 'e.g. HL-9X4B7A',
                    prefixIcon: Icon(Icons.password_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Note to Archon (e.g. "I am David\'s daughter")',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _redeem,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Redeem & Request Membership'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
