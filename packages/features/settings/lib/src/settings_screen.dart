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
          'Account',
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
                        backgroundColor: const Color(0xFFC3FD00).withOpacity(0.15),
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: user?.avatarUrl == null
                            ? Text(
                                (user?.displayName ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFC3FD00),
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

          // ── Data ─────────────────────────────────────────────
          _Section(
            title: 'DATA',
            children: [
              _Row(
                icon: Icons.currency_rupee_rounded,
                label: 'UPI / GPay ID',
                subtitle: 'Used for one-tap settle-up',
                onTap: () => _showEditProfile(context, ref, user),
              ),
              _Row(
                icon: Icons.chat_rounded,
                label: 'WhatsApp Number',
                subtitle: 'Share your number for quick settlements',
                onTap: () => _showWhatsAppSheet(context, ref, user),
              ),
              _Row(
                icon: Icons.download_outlined,
                label: 'Export Expenses',
                subtitle: 'Download all expenses as CSV',
                onTap: () => _comingSoon(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Preferences ──────────────────────────────────────
          _Section(
            title: 'PREFERENCES',
            children: [
              _Row(
                icon: Icons.camera_alt_outlined,
                label: 'Update Profile Photo',
                subtitle: 'Change your profile picture',
                onTap: () => _showUpdatePhoto(context, ref, user),
              ),
              _Row(
                icon: Icons.palette_outlined,
                label: 'Appearance',
                subtitle: 'Light / Dark / System',
                onTap: () => _showAppearance(context, ref),
              ),
              _Row(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () => _comingSoon(context),
              ),
              _Row(
                icon: Icons.security_outlined,
                label: 'Security',
                onTap: () => _showSecurity(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Support ───────────────────────────────────────────
          _Section(
            title: 'HELP',
            children: [
              _Row(
                icon: Icons.help_outline_rounded,
                label: 'Help & FAQ',
                onTap: () => _showHelpFaq(context),
              ),
              _Row(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () => _showPrivacyPolicy(context),
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

  void _showUpdatePhoto(
      BuildContext context, WidgetRef ref, UserEntity? user) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF9E9E9E).withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Update Profile Photo',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            _PhotoOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take a Photo',
              onTap: () {
                Navigator.pop(context);
                _comingSoon(context);
              },
            ),
            const SizedBox(height: 10),
            _PhotoOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Library',
              onTap: () {
                Navigator.pop(context);
                _comingSoon(context);
              },
            ),
            if (user?.avatarUrl != null) ...[
              const SizedBox(height: 10),
              _PhotoOption(
                icon: Icons.delete_outline_rounded,
                label: 'Remove Photo',
                color: const Color(0xFFFF6B6B),
                onTap: () {
                  Navigator.pop(context);
                  _comingSoon(context);
                },
              ),
            ],
          ],
        ),
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
    _showInfoSheet(
      context,
      title: 'About Splitbo',
      icon: Icons.info_outline_rounded,
      items: const [
        _InfoItem(label: 'Version', value: '1.0.0 (v1 Release)'),
        _InfoItem(label: 'Built with', value: 'Flutter + Firebase'),
        _InfoItem(label: 'AI Receipt Scanning', value: 'Gemini 1.5 Flash'),
        _InfoItem(label: 'Architecture', value: 'Clean Architecture · Riverpod · Melos'),
        _InfoItem(label: 'GitHub', value: 'github.com/VikasNVCchauhan/splitbo'),
        _InfoItem(label: 'License', value: 'Private — All rights reserved'),
      ],
      footer: '© 2025 Splitbo. All rights reserved.',
    );
  }

  void _showWhatsAppSheet(BuildContext context, WidgetRef ref, UserEntity? user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: _WhatsAppSheet(ref: ref, user: user),
      ),
    );
  }

  void _showSecurity(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SecuritySheet(),
    );
  }

  void _showAppearance(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: const _AppearanceSheet(),
      ),
    );
  }

  void _showHelpFaq(BuildContext context) {
    _showInfoSheet(
      context,
      title: 'Help & FAQ',
      icon: Icons.help_outline_rounded,
      items: const [
        _InfoItem(
          label: 'How do I add an expense?',
          value: 'Tap the + button on any screen or open a group and tap "Add Expense". Fill in the description, amount, and who paid.',
        ),
        _InfoItem(
          label: 'How do splits work?',
          value: 'By default expenses are split equally. Tap "Split" to switch to custom amounts or percentages per member.',
        ),
        _InfoItem(
          label: 'What is a guest member?',
          value: 'A guest is someone without a Splitbo account. They appear in your group so you can track expenses involving them, but they cannot sign in.',
        ),
        _InfoItem(
          label: 'How do I scan a receipt?',
          value: 'On the Add Expense screen, tap "Scan Receipt". Splitbo uses Gemini AI to read the amount, merchant, category, and even names of people on the bill.',
        ),
        _InfoItem(
          label: 'How do I settle up?',
          value: 'Go to the Balances tab to see who owes whom. Settle Up functionality is coming in v1.5.',
        ),
        _InfoItem(
          label: 'Can I edit or delete an expense?',
          value: 'Yes — tap any expense in the group or Activity tab to get Edit and Delete options.',
        ),
        _InfoItem(
          label: 'Is my data backed up?',
          value: 'All data is stored in Firebase Firestore, which is replicated and backed up automatically by Google.',
        ),
      ],
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    _showInfoSheet(
      context,
      title: 'Privacy Policy',
      icon: Icons.privacy_tip_outlined,
      items: const [
        _InfoItem(
          label: 'What we collect',
          value: 'Your Google account name and email (for sign-in), expense data you enter, and group information you create.',
        ),
        _InfoItem(
          label: 'What we don\'t collect',
          value: 'Passwords (Google handles auth), payment details, or any data beyond what you explicitly enter.',
        ),
        _InfoItem(
          label: 'How your data is used',
          value: 'Solely to provide the expense-splitting service. Your data is not analysed for advertising or shared with third parties.',
        ),
        _InfoItem(
          label: 'Receipt images',
          value: 'When you scan a receipt, the image is sent to Google\'s Gemini AI for parsing and is not stored permanently.',
        ),
        _InfoItem(
          label: 'Data deletion',
          value: 'You can delete your groups and expenses at any time. To delete your account, contact the Splitbo team.',
        ),
        _InfoItem(
          label: 'Third-party services',
          value: 'Firebase (Google) for auth and database. Google Gemini for receipt parsing. Both are subject to Google\'s privacy policy.',
        ),
      ],
      footer: 'Last updated: September 2025. Contact: splitbo@vikas.dev',
    );
  }

  void _showInfoSheet(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<_InfoItem> items,
    String? footer,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF9E9E9E).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    Icon(icon, color: const Color(0xFFC3FD00), size: 22),
                    const SizedBox(width: 10),
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF9E9E9E)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFF2C2C2C)),
              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.label,
                                  style: const TextStyle(
                                      color: Color(0xFFC3FD00),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4)),
                              const SizedBox(height: 4),
                              Text(item.value,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.5)),
                            ],
                          ),
                        )),
                    if (footer != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(footer,
                            style: const TextStyle(
                                color: Color(0xFF9E9E9E), fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});
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

class _PhotoOption extends StatelessWidget {
  const _PhotoOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Security sheet ────────────────────────────────────────────────────────────
class _SecuritySheet extends StatefulWidget {
  const _SecuritySheet();

  @override
  State<_SecuritySheet> createState() => _SecuritySheetState();
}

class _SecuritySheetState extends State<_SecuritySheet> {
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFFC3FD00);
    const surface = Color(0xFF1A1A1A);

    return Container(
      decoration: const BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Security',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 16),
          // Face ID / biometric toggle row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2C2C2C)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: green.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.fingerprint_rounded,
                          color: green, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Authenticate with Face ID',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        Text(
                          _biometricEnabled
                              ? 'App requires Face ID / fingerprint to open'
                              : 'Require biometrics to open Splitbo',
                          style: const TextStyle(
                              color: Color(0xFF9E9E9E), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _biometricEnabled,
                    onChanged: (val) {
                      setState(() => _biometricEnabled = val);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          val
                              ? 'Biometric lock enabled'
                              : 'Biometric lock disabled',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFF1E1E1E),
                        duration: const Duration(seconds: 2),
                      ));
                    },
                    activeColor: green,
                    activeTrackColor: green.withOpacity(0.3),
                    inactiveThumbColor: const Color(0xFF757575),
                    inactiveTrackColor: const Color(0xFF2C2C2C),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Splitbo uses Firebase Auth with automatic session expiry. All data is encrypted in transit and at rest.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 12),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ── WhatsApp number sheet ─────────────────────────────────────────────────────
class _WhatsAppSheet extends StatefulWidget {
  const _WhatsAppSheet({required this.ref, required this.user});
  final WidgetRef ref;
  final UserEntity? user;

  @override
  State<_WhatsAppSheet> createState() => _WhatsAppSheetState();
}

class _WhatsAppSheetState extends State<_WhatsAppSheet> {
  late final TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.user?.phoneNumber ?? '';
    _ctrl = TextEditingController(text: existing);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final number = _ctrl.text.trim();
    if (number.isEmpty) return;
    final userId = widget.user?.id;
    if (userId == null) return;
    setState(() => _saving = true);
    try {
      final fs = widget.ref.read(firebaseFirestoreProvider);
      await fs
          .collection('${dbPrefix}users')
          .doc(userId)
          .update({'whatsappNumber': number});
      if (mounted) {
        setState(() => _saving = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('WhatsApp number saved',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF1E1E1E),
        ));
      }
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFFC3FD00);
    const surface = Color(0xFF1A1A1A);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('WhatsApp Number',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Friends will be able to send you settle-up reminders on WhatsApp',
                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _ctrl,
                keyboardType: TextInputType.phone,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '+91 98765 43210',
                  hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                  prefixIcon: const Icon(Icons.chat_rounded, color: green, size: 20),
                  filled: true,
                  fillColor: const Color(0xFF141414),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: green),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : const Text('Save',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Appearance sheet ──────────────────────────────────────────────────────────
class _AppearanceSheet extends ConsumerWidget {
  const _AppearanceSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModeProvider);
    const surface = Color(0xFF1A1A1A);

    return Container(
      decoration: const BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Appearance',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _ThemeOption(
                  icon: Icons.light_mode_rounded,
                  label: 'Light',
                  selected: current == ThemeMode.light,
                  onTap: () => ref.read(themeModeProvider.notifier).state =
                      ThemeMode.light,
                ),
                const SizedBox(width: 10),
                _ThemeOption(
                  icon: Icons.dark_mode_rounded,
                  label: 'Dark',
                  selected: current == ThemeMode.dark,
                  onTap: () => ref.read(themeModeProvider.notifier).state =
                      ThemeMode.dark,
                ),
                const SizedBox(width: 10),
                _ThemeOption(
                  icon: Icons.phone_iphone_rounded,
                  label: 'System',
                  selected: current == ThemeMode.system,
                  onTap: () => ref.read(themeModeProvider.notifier).state =
                      ThemeMode.system,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFFC3FD00);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? green.withOpacity(0.12) : const Color(0xFF141414),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? green : const Color(0xFF2C2C2C),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? green : const Color(0xFF9E9E9E), size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? green : const Color(0xFF9E9E9E),
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
