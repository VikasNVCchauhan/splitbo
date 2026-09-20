import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:data/data.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// ── Split mode ────────────────────────────────────────────────────────────────
enum _SplitMode { equal, byAmount, byPercent }

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  GroupEntity? _selectedGroup;
  ExpenseCategory _category = ExpenseCategory.other;
  bool _saving = false;

  // Split state
  _SplitMode _splitMode = _SplitMode.equal;
  final Map<String, TextEditingController> _splitControllers = {};

  // OCR state
  Uint8List? _receiptPreview;
  bool _scanning = false;
  String? _scanHint;

  bool get _isFormValid {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    return _descCtrl.text.trim().isNotEmpty &&
        amount > 0 &&
        _selectedGroup != null;
  }

  bool get _hasAnyValue =>
      _descCtrl.text.isNotEmpty ||
      _amountCtrl.text.isNotEmpty ||
      _selectedGroup != null;

  @override
  void initState() {
    super.initState();
    _descCtrl.addListener(() => setState(() {}));
    _amountCtrl.addListener(() => setState(() {}));
  }

  void _clearForm() {
    for (final c in _splitControllers.values) {
      c.dispose();
    }
    _splitControllers.clear();
    setState(() {
      _descCtrl.clear();
      _amountCtrl.clear();
      _selectedGroup = null;
      _category = ExpenseCategory.other;
      _splitMode = _SplitMode.equal;
      _receiptPreview = null;
      _scanHint = null;
    });
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    for (final c in _splitControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onGroupChanged(GroupEntity? g) {
    for (final c in _splitControllers.values) {
      c.dispose();
    }
    _splitControllers.clear();
    if (g != null) {
      for (final memberId in g.memberIds) {
        _splitControllers[memberId] = TextEditingController();
      }
    }
    setState(() {
      _selectedGroup = g;
      _splitMode = _SplitMode.equal;
    });
  }

  void _prefillSplitControllers() {
    final group = _selectedGroup;
    if (group == null) return;
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    final n = group.memberIds.length;
    if (n == 0) return;
    for (final memberId in group.memberIds) {
      final ctrl = _splitControllers[memberId];
      if (ctrl == null) continue;
      switch (_splitMode) {
        case _SplitMode.equal:
          ctrl.text = '';
        case _SplitMode.byAmount:
          ctrl.text = amount > 0 ? (amount / n).toStringAsFixed(0) : '';
        case _SplitMode.byPercent:
          ctrl.text = (100.0 / n).toStringAsFixed(0);
      }
    }
  }

  List<SplitEntity> _computeSplits(GroupEntity group, double amount) {
    switch (_splitMode) {
      case _SplitMode.equal:
        final share = amount / group.memberIds.length;
        return group.memberIds
            .map((id) => SplitEntity(userId: id, amount: share))
            .toList();
      case _SplitMode.byAmount:
        return group.memberIds.map((id) {
          final v = double.tryParse(
                  _splitControllers[id]?.text.replaceAll(',', '') ?? '0') ??
              0;
          return SplitEntity(userId: id, amount: v);
        }).toList();
      case _SplitMode.byPercent:
        return group.memberIds.map((id) {
          final pct = double.tryParse(_splitControllers[id]?.text ?? '0') ?? 0;
          return SplitEntity(userId: id, amount: amount * pct / 100);
        }).toList();
    }
  }

  Future<void> _save() async {
    final desc = _descCtrl.text.trim();
    final amount =
        double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    if (desc.isEmpty || amount <= 0) {
      _toastError('Please enter a description and amount');
      return;
    }
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) {
      _toastError('Please sign in to add expenses');
      return;
    }

    final group = _selectedGroup;

    // Validate custom splits before saving
    if (group != null) {
      if (_splitMode == _SplitMode.byAmount) {
        final total = _splitControllers.values
            .map((c) =>
                double.tryParse(c.text.replaceAll(',', '')) ?? 0)
            .fold<double>(0, (a, b) => a + b);
        if ((total - amount).abs() > 0.5) {
          _toastError(
              'Split amounts must add up to ₹${amount.toStringAsFixed(0)} (currently ₹${total.toStringAsFixed(0)})');
          return;
        }
      }
      if (_splitMode == _SplitMode.byPercent) {
        final total = _splitControllers.values
            .map((c) => double.tryParse(c.text) ?? 0)
            .fold<double>(0, (a, b) => a + b);
        if ((total - 100).abs() > 0.5) {
          _toastError(
              'Percentages must add up to 100% (currently ${total.toStringAsFixed(0)}%)');
          return;
        }
      }
    }

    setState(() => _saving = true);

    final groupId = group!.id; // group is always non-null: _isFormValid guards this
    final splits = _computeSplits(group, amount);

    final result = await ref.read(expenseRepositoryProvider).addExpense(
          groupId: groupId,
          description: desc,
          amount: amount,
          currency: group?.currency ?? 'INR',
          paidBy: user.id,
          splits: splits,
          category: _category,
        );

    if (mounted) {
      setState(() => _saving = false);
      result.fold(
        ok: (_) => Navigator.of(context).pop(),
        err: (err) => _toastError(err.message),
      );
    }
  }

  // ── Group picker ──────────────────────────────────────────────────────────

  void _showGroupPicker(List<GroupEntity> groups) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _GroupPickerSheet(
        groups: groups,
        selected: _selectedGroup,
        onSelect: (g) {
          Navigator.pop(context);
          _onGroupChanged(g);
        },
      ),
    );
  }

  // ── Receipt scanning ──────────────────────────────────────────────────────

  void _showScanOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScanSheet(
        onCamera: () {
          Navigator.pop(context);
          _pickAndScan(ImageSource.camera);
        },
        onGallery: () {
          Navigator.pop(context);
          _pickAndScan(ImageSource.gallery);
        },
        onFile: () {
          Navigator.pop(context);
          _pickFileAndScan();
        },
      ),
    );
  }

  Future<void> _pickAndScan(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (picked == null) return;
      await _runOcr(await picked.readAsBytes(), 'image/jpeg');
    } catch (_) {
      _toastError('Could not open image.');
    }
  }

  Future<void> _pickFileAndScan() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        _toastError('Could not read file. Try picking again.');
        return;
      }
      final ext = (file.extension ?? 'jpg').toLowerCase();
      final mime = ext == 'pdf' ? 'application/pdf' : 'image/jpeg';
      await _runOcr(bytes, mime);
    } catch (e) {
      _toastError('Could not open file.');
    }
  }

  Future<void> _runOcr(Uint8List bytes, String mime) async {
    setState(() {
      _scanning = true;
      _scanHint = 'Scanning receipt…';
      if (mime.startsWith('image/')) _receiptPreview = bytes;
    });

    try {
      final result = await _callGeminiVision(bytes, mime);
      if (!mounted) return;

      if (result == null) {
        setState(() => _scanHint = 'Could not read receipt');
        _toastError('Could not read receipt — try a clearer photo.');
        return;
      }

      setState(() {
        _scanHint = 'Receipt scanned ✓';
        if (result.amount != null) {
          _amountCtrl.text = result.amount!.toStringAsFixed(0);
        }
        if (result.merchant != null) {
          _descCtrl.text = result.merchant!;
        }
        if (result.category != null) {
          _category = result.category!;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFFC3FD00), size: 18),
              SizedBox(width: 8),
              Text('Receipt scanned!',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
          backgroundColor: Color(0xFF1E1E1E),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('OCR error: $e');
      if (mounted) setState(() => _scanHint = 'Scan failed: ${e.toString().substring(0, e.toString().length.clamp(0, 80))}');
      _toastError('Scan failed — please try again.');
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  // Calls the parseReceipt Cloud Function — key never touches the client.
  Future<_OcrResult?> _callGeminiVision(Uint8List bytes, String mime) async {
    final callable =
        FirebaseFunctions.instance.httpsCallable('parseReceipt');
    final result = await callable.call<Map<Object?, Object?>>({
      'imageBase64': base64Encode(bytes),
      'mimeType': mime,
    });

    final data = Map<String, dynamic>.from(result.data);
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;

    final candidate = (candidates[0] as Map?)?.cast<String, dynamic>();
    final content = (candidate?['content'] as Map?)?.cast<String, dynamic>();
    final parts = content?['parts'] as List?;
    final rawText = parts
            ?.whereType<Map>()
            .where((p) => p['text'] != null)
            .map<String>((p) => p['text'].toString())
            .firstOrNull ??
        '';

    final jsonStr = _extractJson(rawText);
    if (jsonStr == null) return null;

    Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }

    final amount = switch (parsed['amount']) {
      num n => n.toDouble(),
      String s => double.tryParse(s.replaceAll(',', '')),
      _ => null,
    };
    final description = parsed['description'] as String?;
    final categoryStr = parsed['category'] as String?;

    ExpenseCategory? category;
    if (categoryStr != null) {
      try {
        category =
            ExpenseCategory.values.firstWhere((c) => c.name == categoryStr);
      } catch (_) {}
    }

    return _OcrResult(amount: amount, merchant: description, category: category);
  }

  // Extracts a JSON object from a string that may contain markdown fences or extra text.
  static String? _extractJson(String raw) {
    final s = raw
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();
    if (s.startsWith('{')) {
      final end = s.lastIndexOf('}');
      if (end > 0) return s.substring(0, end + 1);
    }
    final match = RegExp(r'\{[\s\S]*\}').firstMatch(s);
    return match?.group(0);
  }

  void _toastError(String msg) {
    if (!mounted) return;
    setState(() => _scanning = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final groupsAsync = ref.watch(watchGroupsProvider);
    const brandGreen = Color(0xFFC3FD00);

    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      appBar: AppBar(
        backgroundColor: colors.backgroundDefault,
        elevation: 0,
        title: const Text('Add Expense',
            style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_hasAnyValue)
            TextButton(
              onPressed: _clearForm,
              child: Text(
                'Clear',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.insetLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Scan Receipt banner ────────────────────────────────
            _ScanReceiptBanner(
              scanning: _scanning,
              scanHint: _scanHint,
              previewBytes: _receiptPreview,
              onTap: _scanning ? null : _showScanOptions,
            ),
            SizedBox(height: spacing.stackMd),

            // ── Amount ─────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(spacing.insetLg),
              decoration: BoxDecoration(
                color: colors.surfaceRaised,
                borderRadius: BorderRadius.circular(radius.card),
                border: Border.all(color: colors.borderDefault),
              ),
              child: Column(
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: spacing.stackXs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _selectedGroup?.currency == 'INR' ||
                                _selectedGroup == null
                            ? '₹'
                            : '\$',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: TextField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[\d,.]')),
                          ],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: colors.textDisabled,
                            ),
                            filled: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.stackMd),

            // ── Description ────────────────────────────────────────
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g. Dinner at Barbeque Nation',
                prefixIcon: Icon(Icons.receipt_long_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: spacing.stackMd),

            // ── Group picker (modern card) ──────────────────────────
            groupsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (groups) => GestureDetector(
                onTap: groups.isEmpty ? null : () => _showGroupPicker(groups),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.surfaceRaised,
                    borderRadius: BorderRadius.circular(radius.control),
                    border: Border.all(color: colors.borderDefault),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.group_outlined,
                          color: colors.textSecondary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _selectedGroup != null
                            ? Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: brandGreen.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _selectedGroup!.name[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: brandGreen,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedGroup!.name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${_selectedGroup!.memberCount} member${_selectedGroup!.memberCount == 1 ? '' : 's'}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: colors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Text(
                                groups.isEmpty
                                    ? 'Create a group first'
                                    : 'Select group',
                                style: TextStyle(
                                    fontSize: 15, color: colors.textSecondary),
                              ),
                      ),
                      Icon(Icons.expand_more_rounded,
                          color: colors.textSecondary, size: 22),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing.stackMd),

            // ── Category ───────────────────────────────────────────
            Text(
              'Category',
              style: TextStyle(
                fontSize: 12,
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: spacing.stackXs),
            Wrap(
              spacing: spacing.inlineSm,
              runSpacing: spacing.inlineSm,
              children: ExpenseCategory.values
                  .map((cat) => _CategoryChip(
                        category: cat,
                        selected: _category == cat,
                        onSelected: (_) => setState(() => _category = cat),
                      ))
                  .toList(),
            ),
            SizedBox(height: spacing.stackMd),

            // ── Dynamic splits (only when group is selected) ────────
            if (_selectedGroup != null) ...[
              _SplitSection(
                group: _selectedGroup!,
                mode: _splitMode,
                controllers: _splitControllers,
                onModeChanged: (mode) {
                  setState(() => _splitMode = mode);
                  _prefillSplitControllers();
                },
              ),
              SizedBox(height: spacing.stackMd),
            ],

            // ── Save button ────────────────────────────────────────
            if (_isFormValid)
              SizedBox(
                height: 54,
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
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.black),
                        )
                      : const Text('Save Expense',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            SizedBox(height: spacing.stackMd),
          ],
        ),
      ),
    );
  }
}

// ── OCR result ────────────────────────────────────────────────────────────────
class _OcrResult {
  final double? amount;
  final String? merchant;
  final ExpenseCategory? category;
  const _OcrResult({this.amount, this.merchant, this.category});
}

// ── Group picker bottom sheet ─────────────────────────────────────────────────
class _GroupPickerSheet extends StatelessWidget {
  const _GroupPickerSheet({
    required this.groups,
    required this.selected,
    required this.onSelect,
  });

  final List<GroupEntity> groups;
  final GroupEntity? selected;
  final ValueChanged<GroupEntity?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Group',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...groups.map((g) {
            final isSelected = g.id == selected?.id;
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFC3FD00).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    g.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFC3FD00),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              title: Text(
                g.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                '${g.memberCount} member${g.memberCount == 1 ? '' : 's'}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle_rounded,
                      color: Color(0xFFC3FD00), size: 22)
                  : null,
              onTap: () => onSelect(g),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Split section ─────────────────────────────────────────────────────────────
class _SplitSection extends StatelessWidget {
  const _SplitSection({
    required this.group,
    required this.mode,
    required this.controllers,
    required this.onModeChanged,
  });

  final GroupEntity group;
  final _SplitMode mode;
  final Map<String, TextEditingController> controllers;
  final ValueChanged<_SplitMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const brandGreen = Color(0xFFC3FD00);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode selector row
          Row(
            children: [
              const Icon(Icons.call_split_rounded,
                  size: 16, color: Color(0xFFC3FD00)),
              const SizedBox(width: 6),
              Text(
                'Split',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              ..._SplitMode.values.map((m) {
                final sel = mode == m;
                return GestureDetector(
                  onTap: () => onModeChanged(m),
                  child: Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: sel ? brandGreen : colors.backgroundSubtle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      switch (m) {
                        _SplitMode.equal => 'Equal',
                        _SplitMode.byAmount => '₹ Amount',
                        _SplitMode.byPercent => '%',
                      },
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.black : colors.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 14),

          if (mode == _SplitMode.equal)
            Text(
              'Split equally between ${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            )
          else
            Column(
              children: group.memberIds.map((memberId) {
                final name =
                    group.memberDisplayNames[memberId] ?? 'Member';
                final ctrl = controllers[memberId];
                if (ctrl == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: brandGreen.withOpacity(0.15),
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            color: brandGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: ctrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[\d,.]')),
                          ],
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            prefixText:
                                mode == _SplitMode.byAmount ? '₹' : '',
                            suffixText:
                                mode == _SplitMode.byPercent ? '%' : '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: colors.borderDefault),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: brandGreen),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: colors.borderDefault),
                            ),
                            filled: true,
                            fillColor: colors.backgroundSubtle,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

// ── Scan Receipt banner ───────────────────────────────────────────────────────
class _ScanReceiptBanner extends StatelessWidget {
  const _ScanReceiptBanner({
    required this.scanning,
    required this.onTap,
    this.previewBytes,
    this.scanHint,
  });

  final bool scanning;
  final Uint8List? previewBytes;
  final String? scanHint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const brandGreen = Color(0xFFC3FD00);
    final hasPreview = previewBytes != null;
    final scanOk = scanHint?.contains('✓') ?? false;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: hasPreview ? 100 : 72,
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: scanning
                ? brandGreen
                : hasPreview
                    ? (scanOk
                        ? brandGreen.withOpacity(0.6)
                        : Colors.orange.withOpacity(0.6))
                    : colors.borderDefault,
            width: scanning ? 2 : 1.5,
          ),
        ),
        child: scanning
            ? const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFC3FD00)),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Scanning receipt…',
                      style: TextStyle(
                        color: Color(0xFFC3FD00),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              )
            : hasPreview
                ? Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(13),
                          bottomLeft: Radius.circular(13),
                        ),
                        child: Image.memory(previewBytes!,
                            width: 100, height: 100, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  scanOk
                                      ? Icons.check_circle_rounded
                                      : Icons.error_outline_rounded,
                                  color:
                                      scanOk ? brandGreen : Colors.orange,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  scanHint ?? 'Receipt attached',
                                  style: TextStyle(
                                    color: scanOk
                                        ? brandGreen
                                        : Colors.orange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to scan again',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 14),
                        child: Icon(Icons.refresh_rounded,
                            color: brandGreen, size: 20),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: brandGreen.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                            Icons.document_scanner_outlined,
                            size: 20,
                            color: brandGreen),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Scan Receipt',
                            style: TextStyle(
                              color: brandGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Auto-fill from photo, PDF or document',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(Icons.chevron_right_rounded,
                            color: Colors.grey[700], size: 20),
                      ),
                    ],
                  ),
      ),
    );
  }
}

// ── Scan options bottom sheet ─────────────────────────────────────────────────
class _ScanSheet extends StatelessWidget {
  const _ScanSheet(
      {required this.onCamera,
      required this.onGallery,
      required this.onFile});

  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text('Scan Receipt',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Auto-fill expense details from your receipt',
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          const SizedBox(height: 20),
          _SheetOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take a Photo',
              subtitle: 'Use your camera',
              onTap: onCamera),
          _SheetOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              subtitle: 'Pick an existing image',
              onTap: onGallery),
          _SheetOption(
              icon: Icons.attach_file_rounded,
              label: 'Upload File',
              subtitle: 'PDF, JPG, PNG',
              onTap: onFile),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: const Color(0xFF2A2A2A),
                shape: const StadiumBorder(),
              ),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption(
      {required this.icon,
      required this.label,
      required this.subtitle,
      required this.onTap});

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFC3FD00).withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFFC3FD00), size: 20),
      ),
      title: Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      trailing:
          Icon(Icons.chevron_right_rounded, color: Colors.grey[600], size: 20),
      onTap: onTap,
    );
  }
}

// ── Category chip ─────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  const _CategoryChip(
      {required this.category,
      required this.selected,
      required this.onSelected});

  final ExpenseCategory category;
  final bool selected;
  final ValueChanged<bool> onSelected;

  static const _icons = <ExpenseCategory, IconData>{
    ExpenseCategory.food: Icons.restaurant_outlined,
    ExpenseCategory.transport: Icons.directions_car_outlined,
    ExpenseCategory.accommodation: Icons.hotel_outlined,
    ExpenseCategory.entertainment: Icons.movie_outlined,
    ExpenseCategory.utilities: Icons.bolt_outlined,
    ExpenseCategory.shopping: Icons.shopping_bag_outlined,
    ExpenseCategory.medical: Icons.medical_services_outlined,
    ExpenseCategory.education: Icons.school_outlined,
    ExpenseCategory.other: Icons.more_horiz,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FilterChip(
      label: Text(category.label),
      avatar: Icon(_icons[category] ?? Icons.receipt_outlined, size: 16),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: colors.surfaceRaised,
      selectedColor: colors.brandPrimaryLt,
      checkmarkColor: colors.brandPrimaryDk,
      side: BorderSide(
          color: selected ? colors.brandPrimary : colors.borderDefault),
      labelStyle: TextStyle(
        color: selected ? colors.brandPrimaryDk : colors.textPrimary,
        fontSize: 13,
      ),
    );
  }
}
