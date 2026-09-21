// packages/features/balances/lib/src/search_screen.dart
// Global search: groups + friends from cache (instant) + user discovery from Firestore (~20ms).

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _green = Color(0xFFC3FD00);
const _surface = Color(0xFF1A1A1A);
const _border = Color(0xFF2C2C2C);
const _textSecondary = Color(0xFF9E9E9E);

// ── Discovered-user result ────────────────────────────────────────────────────
class _UserResult {
  final String id;
  final String displayName;
  final String? email;
  final String? phone;
  final String? avatarUrl;

  const _UserResult({
    required this.id,
    required this.displayName,
    this.email,
    this.phone,
    this.avatarUrl,
  });

  factory _UserResult.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return _UserResult(
      id: doc.id,
      displayName: d['displayName'] as String? ?? 'Unknown',
      email: d['email'] as String?,
      phone: d['phone'] as String?,
      avatarUrl: d['avatarUrl'] as String?,
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

class _SearchResults {
  final List<GroupEntity> groups;
  final List<_UserResult> users;

  const _SearchResults({required this.groups, required this.users});
  static const empty = _SearchResults(groups: [], users: []);

  bool get isEmpty => groups.isEmpty && users.isEmpty;
}

// ── Screen ────────────────────────────────────────────────────────────────────
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  String _query = '';
  bool _searching = false;
  _SearchResults _results = _SearchResults.empty;

  static const _avatarColors = [
    Color(0xFFC3FD00), Color(0xFF00D4FF), Color(0xFFFF6B9D),
    Color(0xFFFFB347), Color(0xFF9B59B6), Color(0xFF2ECC71),
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _ctrl.addListener(_onInput);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onInput() {
    final q = _ctrl.text.trim();
    if (q == _query) return;
    setState(() {
      _query = q;
      if (q.length < 2) {
        _results = _SearchResults.empty;
        _searching = false;
      } else {
        _searching = true;
      }
    });
    _debounce?.cancel();
    if (q.length >= 2) {
      _debounce = Timer(const Duration(milliseconds: 150), () => _runSearch(q));
    }
  }

  Future<void> _runSearch(String q) async {
    final lower = q.toLowerCase();
    final end = lower.substring(0, lower.length - 1) +
        String.fromCharCode(lower.codeUnitAt(lower.length - 1) + 1);

    // Groups — instant from cached stream
    final allGroups = ref.read(watchGroupsProvider).valueOrNull ?? [];
    final matchedGroups = allGroups
        .where((g) => g.name.toLowerCase().contains(lower))
        .take(8)
        .toList();

    // Users — Firestore prefix scan (~20ms, single b-tree lookup)
    List<_UserResult> matchedUsers = [];
    try {
      final fs = ref.read(firebaseFirestoreProvider);
      final currentUid = ref.read(authStateProvider).valueOrNull?.id;
      final snap = await fs
          .collection('${dbPrefix}users')
          .where('nameLower', isGreaterThanOrEqualTo: lower)
          .where('nameLower', isLessThan: end)
          .limit(10)
          .get();
      matchedUsers = snap.docs
          .where((d) => d.id != currentUid)
          .map(_UserResult.fromDoc)
          .toList();

      // Fallback: also search by email prefix if query contains @
      if (q.contains('@') && matchedUsers.isEmpty) {
        final emailSnap = await fs
            .collection('${dbPrefix}users')
            .where('email', isGreaterThanOrEqualTo: lower)
            .where('email', isLessThan: end)
            .limit(5)
            .get();
        matchedUsers = emailSnap.docs
            .where((d) => d.id != currentUid)
            .map(_UserResult.fromDoc)
            .toList();
      }
    } catch (_) {}

    if (mounted && _query == q) {
      setState(() {
        _results = _SearchResults(groups: matchedGroups, users: matchedUsers);
        _searching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _ctrl,
          focusNode: _focusNode,
          autofocus: true,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          cursorColor: _green,
          decoration: InputDecoration(
            hintText: 'Search groups, people, expenses…',
            hintStyle:
                const TextStyle(color: Color(0xFF555555), fontSize: 15),
            border: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: _textSecondary, size: 18),
                    onPressed: () {
                      _ctrl.clear();
                      _focusNode.requestFocus();
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _query.length < 2
          ? _buildEmpty()
          : _searching
              ? const Center(
                  child: CircularProgressIndicator(
                      color: _green, strokeWidth: 2))
              : _results.isEmpty
                  ? _buildNoResults()
                  : _buildResults(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.search_rounded, color: Color(0xFF333333), size: 56),
          SizedBox(height: 16),
          Text('Search anything',
              style: TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 6),
          Text('Groups, friends, or type an email',
              style: TextStyle(color: Color(0xFF3A3A3A), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, color: _textSecondary, size: 48),
          const SizedBox(height: 14),
          Text('No results for "$_query"',
              style: const TextStyle(color: Colors.white, fontSize: 15)),
          const SizedBox(height: 6),
          const Text('Try a different name or email',
              style: TextStyle(color: _textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      children: [
        if (_results.groups.isNotEmpty) ...[
          _sectionHeader('Groups', _results.groups.length),
          ..._results.groups.map((g) => _GroupTile(
                group: g,
                query: _query,
                onTap: () => context.push('/groups/${g.id}'),
              )),
          const SizedBox(height: 8),
        ],
        if (_results.users.isNotEmpty) ...[
          _sectionHeader('People', _results.users.length),
          ..._results.users.indexed.map((entry) {
            final (i, u) = entry;
            return _UserTile(
              user: u,
              avatarColor: _avatarColors[i % _avatarColors.length],
              query: _query,
            );
          }),
        ],
      ],
    );
  }

  Widget _sectionHeader(String label, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$count',
                style:
                    const TextStyle(color: _textSecondary, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

// ── Group result tile ─────────────────────────────────────────────────────────
class _GroupTile extends StatelessWidget {
  const _GroupTile(
      {required this.group, required this.query, required this.onTap});
  final GroupEntity group;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.group_rounded, color: _green, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightText(
                      text: group.name,
                      query: query,
                      baseStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  Text('${group.memberIds.length} members',
                      style: const TextStyle(
                          color: _textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: _textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── User result tile ──────────────────────────────────────────────────────────
class _UserTile extends StatelessWidget {
  const _UserTile(
      {required this.user,
      required this.avatarColor,
      required this.query});
  final _UserResult user;
  final Color avatarColor;
  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          user.avatarUrl != null
              ? CircleAvatar(
                  radius: 21,
                  backgroundImage: NetworkImage(user.avatarUrl!),
                )
              : CircleAvatar(
                  radius: 21,
                  backgroundColor: avatarColor.withValues(alpha: 0.12),
                  child: Text(user.initials,
                      style: TextStyle(
                          color: avatarColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HighlightText(
                    text: user.displayName,
                    query: query,
                    baseStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                if (user.email != null || user.phone != null)
                  Text(user.email ?? user.phone ?? '',
                      style: const TextStyle(
                          color: _textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Highlight matching text ───────────────────────────────────────────────────
class _HighlightText extends StatelessWidget {
  const _HighlightText(
      {required this.text, required this.query, required this.baseStyle});
  final String text;
  final String query;
  final TextStyle baseStyle;

  @override
  Widget build(BuildContext context) {
    final lower = text.toLowerCase();
    final queryLower = query.toLowerCase();
    final idx = lower.indexOf(queryLower);
    if (idx < 0 || query.isEmpty) {
      return Text(text, style: baseStyle);
    }
    return Text.rich(
      TextSpan(children: [
        if (idx > 0)
          TextSpan(text: text.substring(0, idx), style: baseStyle),
        TextSpan(
          text: text.substring(idx, idx + query.length),
          style: baseStyle.copyWith(
              color: _green, fontWeight: FontWeight.w800),
        ),
        if (idx + query.length < text.length)
          TextSpan(
              text: text.substring(idx + query.length), style: baseStyle),
      ]),
    );
  }
}
