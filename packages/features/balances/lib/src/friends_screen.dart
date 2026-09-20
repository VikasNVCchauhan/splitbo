import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data/data.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _green = Color(0xFFC3FD00);
const _surface = Color(0xFF1A1A1A);
const _border = Color(0xFF2C2C2C);
const _textSecondary = Color(0xFF9E9E9E);

// ── Provider: watch contacts for current user ─────────────────────────────────
final _contactsProvider = StreamProvider<List<_Contact>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  final fs = ref.watch(firebaseFirestoreProvider);
  return fs
      .collection('${dbPrefix}users')
      .doc(user.id)
      .collection('contacts')
      .orderBy('displayName')
      .snapshots()
      .map((snap) => snap.docs.map((d) => _Contact.fromDoc(d)).toList());
});

class _Contact {
  final String id;
  final String displayName;
  final String? email;
  final String? phone;
  final bool isGuest;
  final double balance;

  const _Contact({
    required this.id,
    required this.displayName,
    this.email,
    this.phone,
    this.isGuest = false,
    this.balance = 0,
  });

  factory _Contact.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return _Contact(
      id: doc.id,
      displayName: d['displayName'] as String? ?? 'Unknown',
      email: d['email'] as String?,
      phone: d['phone'] as String?,
      isGuest: d['isGuest'] as bool? ?? false,
      balance: (d['balance'] as num?)?.toDouble() ?? 0,
    );
  }

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }
}

// ── Filter enum ───────────────────────────────────────────────────────────────
enum _Filter { all, outstanding, settled }

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  _Filter _filter = _Filter.all;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final contactsAsync = ref.watch(_contactsProvider);

    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      appBar: AppBar(
        backgroundColor: colors.backgroundDefault,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Friends',
            style: TextStyle(
                color: colors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, color: _green),
            tooltip: 'Add Friend',
            onPressed: () => _showAddFriendSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Search ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              style: TextStyle(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or email…',
                hintStyle: TextStyle(color: colors.textSecondary, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: colors.textSecondary, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: colors.textSecondary, size: 18),
                        onPressed: () => _searchCtrl.clear(),
                      )
                    : null,
                filled: true,
                fillColor: _surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _green)),
              ),
            ),
          ),
          // ── Filter chips ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: _Filter.values.map((f) {
                final label = switch (f) {
                  _Filter.all => 'All',
                  _Filter.outstanding => 'Outstanding',
                  _Filter.settled => 'Settled',
                };
                final selected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected ? _green : _surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: selected ? _green : _border),
                      ),
                      child: Text(label,
                          style: TextStyle(
                              color: selected ? Colors.black : _textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // ── List ─────────────────────────────────────────────────
          Expanded(
            child: contactsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: _green, strokeWidth: 2)),
              error: (e, _) => Center(
                  child: Text(e.toString(),
                      style: const TextStyle(color: Colors.white))),
              data: (contacts) {
                var filtered = contacts.where((c) {
                  if (_query.isNotEmpty) {
                    final q = _query;
                    if (!c.displayName.toLowerCase().contains(q) &&
                        !(c.email?.toLowerCase().contains(q) ?? false) &&
                        !(c.phone?.contains(q) ?? false)) {
                      return false;
                    }
                  }
                  return switch (_filter) {
                    _Filter.all => true,
                    _Filter.outstanding => c.balance.abs() > 0.5,
                    _Filter.settled => c.balance.abs() <= 0.5,
                  };
                }).toList();

                if (contacts.isEmpty) {
                  return _EmptyState(onAdd: () => _showAddFriendSheet(context));
                }
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No friends match this filter',
                        style: TextStyle(color: _textSecondary)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _FriendTile(
                    contact: filtered[i],
                    onTap: () => _showFriendDetails(context, filtered[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFriendSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: const _AddFriendSheet(),
      ),
    );
  }

  void _showFriendDetails(BuildContext context, _Contact contact) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _FriendDetailSheet(contact: contact),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline_rounded,
                color: _textSecondary, size: 56),
            const SizedBox(height: 16),
            const Text('No friends yet',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Add friends to track shared expenses and settle up easily.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: const StadiumBorder(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: const Text('Add Friend',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Friend tile ───────────────────────────────────────────────────────────────
class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.contact, required this.onTap});
  final _Contact contact;
  final VoidCallback onTap;

  static const _avatarColors = [
    Color(0xFFC3FD00), Color(0xFF00D4FF), Color(0xFFFF6B9D),
    Color(0xFFFFB347), Color(0xFF9B59B6), Color(0xFF2ECC71),
  ];

  @override
  Widget build(BuildContext context) {
    final colorIdx = contact.displayName.codeUnitAt(0) % _avatarColors.length;
    final avatarColor = _avatarColors[colorIdx];
    final balance = contact.balance;
    final hasBalance = balance.abs() > 0.5;
    final isOwed = balance > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: avatarColor.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: avatarColor.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(contact.initials,
                    style: TextStyle(
                        color: avatarColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(contact.displayName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      if (contact.isGuest) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _textSecondary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Guest',
                              style: TextStyle(
                                  color: _textSecondary, fontSize: 10)),
                        ),
                      ],
                    ],
                  ),
                  if (contact.email != null || contact.phone != null)
                    Text(
                      contact.email ?? contact.phone ?? '',
                      style:
                          const TextStyle(color: _textSecondary, fontSize: 12),
                    ),
                ],
              ),
            ),
            if (hasBalance)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isOwed ? 'owes you' : 'you owe',
                    style: TextStyle(
                        color: isOwed ? _green : const Color(0xFFFF6B6B),
                        fontSize: 11),
                  ),
                  Text(
                    '₹${balance.abs().toStringAsFixed(0)}',
                    style: TextStyle(
                        color: isOwed ? _green : const Color(0xFFFF6B6B),
                        fontSize: 15,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              )
            else
              const Text('settled',
                  style: TextStyle(color: _textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ── Add Friend sheet ──────────────────────────────────────────────────────────
class _AddFriendSheet extends ConsumerStatefulWidget {
  const _AddFriendSheet();

  @override
  ConsumerState<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends ConsumerState<_AddFriendSheet> {
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  bool _saving = false;

  bool get _isValid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _contactCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_isValid) return;
    setState(() => _saving = true);

    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final fs = ref.read(firebaseFirestoreProvider);
    final contact = _contactCtrl.text.trim();
    final isEmail = contact.contains('@');

    // Check if a Splitbo user exists with this email/phone
    final existingQuery = await fs
        .collection('${dbPrefix}users')
        .where(isEmail ? 'email' : 'phone', isEqualTo: contact)
        .limit(1)
        .get();

    String friendId;
    if (existingQuery.docs.isNotEmpty) {
      friendId = existingQuery.docs.first.id;
    } else {
      // Create a guest user
      final docRef = fs.collection('${dbPrefix}users').doc();
      await docRef.set({
        'displayName': _nameCtrl.text.trim(),
        isEmail ? 'email' : 'phone': contact,
        'isGuest': true,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      friendId = docRef.id;
    }

    // Add to contacts subcollection
    await fs
        .collection('${dbPrefix}users')
        .doc(user.id)
        .collection('contacts')
        .doc(friendId)
        .set({
      'displayName': _nameCtrl.text.trim(),
      isEmail ? 'email' : 'phone': contact,
      'isGuest': existingQuery.docs.isEmpty,
      'balance': 0,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_nameCtrl.text.trim()} added as a friend',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text('Add Friend',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: _textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DarkField(
              ctrl: _nameCtrl,
              label: 'Full name',
              icon: Icons.person_outline,
              capitalize: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _DarkField(
              ctrl: _contactCtrl,
              label: 'Phone number or email',
              icon: Icons.alternate_email_rounded,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            const Text(
              'If they have a Splitbo account we\'ll link automatically. Otherwise they\'re added as a guest.',
              style: TextStyle(color: _textSecondary, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 20),
            if (_isValid)
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.black))
                      : const Text('Add Friend',
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

// ── Friend detail sheet ───────────────────────────────────────────────────────
class _FriendDetailSheet extends StatelessWidget {
  const _FriendDetailSheet({required this.contact});
  final _Contact contact;

  @override
  Widget build(BuildContext context) {
    final balance = contact.balance;
    final isOwed = balance > 0;
    final hasBalance = balance.abs() > 0.5;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(contact.displayName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: _textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          if (contact.email != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, color: _textSecondary, size: 14),
                  const SizedBox(width: 6),
                  Text(contact.email!,
                      style:
                          const TextStyle(color: _textSecondary, fontSize: 13)),
                ],
              ),
            ),
          if (contact.phone != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, color: _textSecondary, size: 14),
                  const SizedBox(width: 6),
                  Text(contact.phone!,
                      style:
                          const TextStyle(color: _textSecondary, fontSize: 13)),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasBalance
                  ? (isOwed ? _green : const Color(0xFFFF6B6B)).withOpacity(0.08)
                  : const Color(0xFF252525),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  hasBalance
                      ? (isOwed
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded)
                      : Icons.check_circle_outline_rounded,
                  color: hasBalance
                      ? (isOwed ? _green : const Color(0xFFFF6B6B))
                      : _textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasBalance
                        ? (isOwed
                            ? '${contact.displayName} owes you ₹${balance.abs().toStringAsFixed(0)}'
                            : 'You owe ${contact.displayName} ₹${balance.abs().toStringAsFixed(0)}')
                        : 'All settled up',
                    style: TextStyle(
                        color: hasBalance
                            ? (isOwed ? _green : const Color(0xFFFF6B6B))
                            : _textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared input field ────────────────────────────────────────────────────────
class _DarkField extends StatelessWidget {
  const _DarkField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.capitalize = false,
    this.onChanged,
  });
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final bool capitalize;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      textCapitalization:
          capitalize ? TextCapitalization.words : TextCapitalization.none,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textSecondary),
        prefixIcon: Icon(icon, color: _textSecondary, size: 20),
        filled: true,
        fillColor: const Color(0xFF252525),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _green)),
      ),
    );
  }
}
