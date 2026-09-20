import 'package:data/data.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      appBar: AppBar(
        backgroundColor: colors.backgroundDefault,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Text(
          'Profile',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: colors.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          const SizedBox(height: 16),

          // ── Profile header ────────────────────────────────────
          GestureDetector(
            onTap: () => _showEditProfile(context, ref, user),
            child: Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: colors.brandPrimary,
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: user?.avatarUrl == null
                            ? Text(
                                (user?.displayName ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colors.brandPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: colors.backgroundDefault, width: 2),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              size: 14, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? '—',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '—',
                    style:
                        TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.brandPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: colors.brandPrimary.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.brandPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── Payment methods ───────────────────────────────────
          _Section(
            title: 'PAYMENT',
            children: [
              _Row(
                icon: Icons.currency_rupee_rounded,
                label: 'UPI / GPay ID',
                subtitle: 'Used for one-tap settle-up',
                onTap: () => _showEditProfile(context, ref, user),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Account ───────────────────────────────────────────
          _Section(
            title: 'ACCOUNT',
            children: [
              _Row(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () => _comingSoon(context),
              ),
              _Row(
                icon: Icons.security_outlined,
                label: 'Security',
                onTap: () => _comingSoon(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Support ───────────────────────────────────────────
          _Section(
            title: 'SUPPORT',
            children: [
              _Row(
                icon: Icons.help_outline_rounded,
                label: 'Help & FAQ',
                onTap: () => _comingSoon(context),
              ),
              _Row(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () => _comingSoon(context),
              ),
              _Row(
                icon: Icons.info_outline_rounded,
                label: 'About Splitbo',
                onTap: () => _showAbout(context),
              ),
            ],
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) context.go('/auth/sign-in');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF6B6B),
                side: const BorderSide(color: Color(0xFFFF6B6B), width: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sign Out',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1A1A1A),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Splitbo',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Splitbo. All rights reserved.',
    );
  }

  void _showEditProfile(
      BuildContext context, WidgetRef ref, UserEntity? user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: _EditProfileSheet(user: user),
      ),
    );
  }
}

// ── Edit Profile bottom sheet ─────────────────────────────────────────────────
class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.user});
  final UserEntity? user;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  final _upiCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _upiCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);

    final result = await ref
        .read(authRepositoryProvider)
        .updateProfile(displayName: name);

    final upiId = _upiCtrl.text.trim();
    if (upiId.isNotEmpty && widget.user != null) {
      try {
        await ref
            .read(firebaseFirestoreProvider)
            .collection('${dbPrefix}users')
            .doc(widget.user!.id)
            .update({'upiId': upiId});
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      ok: (_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated ✓',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xFF1E1E1E),
          ),
        );
      },
      err: (err) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.message,
              style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1E1E1E),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFFC3FD00);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text('Edit Profile',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DarkField(
              controller: _nameCtrl,
              label: 'Display Name',
              icon: Icons.person_outline,
              capitalize: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            _DarkField(
              controller: _upiCtrl,
              label: 'UPI ID (optional)',
              hint: 'yourname@upi',
              icon: Icons.currency_rupee_rounded,
              type: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandGreen,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: brandGreen.withOpacity(0.4),
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.black))
                    : const Text('Save Changes',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  const _DarkField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.type,
    this.capitalize = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType? type;
  final TextCapitalization capitalize;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: type,
      textCapitalization: capitalize,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF555555)),
        labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        prefixIcon: Icon(icon, color: const Color(0xFF9E9E9E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC3FD00)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
      ),
    );
  }
}

// ── Section + Row ─────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceRaised,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.borderDefault),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.brandPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colors.brandPrimary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                          color: colors.textSecondary, fontSize: 11),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: colors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
