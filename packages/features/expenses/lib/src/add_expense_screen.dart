import 'dart:convert';
import 'dart:typed_data';

import 'package:data/data.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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

  // OCR state
  Uint8List? _receiptPreview;
  bool _scanning = false;
  String? _scanHint;

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final desc = _descCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    final group = _selectedGroup;
    if (desc.isEmpty || amount <= 0 || group == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to add expenses'),
          backgroundColor: Color(0xFF1E1E1E),
        ),
      );
      return;
    }
    setState(() => _saving = true);

    final splits = group.memberIds
        .map((id) => SplitEntity(userId: id, amount: amount / group.memberIds.length))
        .toList();

    final result = await ref.read(expenseRepositoryProvider).addExpense(
          groupId: group.id,
          description: desc,
          amount: amount,
          currency: group.currency,
          paidBy: user.id,
          splits: splits,
          category: _category,
        );

    if (mounted) {
      setState(() => _saving = false);
      result.fold(
        ok: (_) => Navigator.of(context).pop(),
        err: (err) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.message)),
        ),
      );
    }
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
      if (file.bytes == null) return;
      final ext = (file.extension ?? 'jpg').toLowerCase();
      final mime = ext == 'pdf' ? 'application/pdf' : 'image/jpeg';
      await _runOcr(file.bytes!, mime);
    } catch (_) {
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
        _toastError('Could not read receipt — try a clearer photo.');
        return;
      }

      setState(() {
        _scanHint = 'Receipt scanned ✓';
        if (result.amount != null && _amountCtrl.text.isEmpty) {
          _amountCtrl.text = result.amount!.toStringAsFixed(0);
        }
        if (result.merchant != null && _descCtrl.text.isEmpty) {
          _descCtrl.text = result.merchant!;
        }
        if (result.category != null) {
          _category = result.category!;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFFC3FD00), size: 18),
              SizedBox(width: 8),
              Text('Receipt scanned! Check the details below.'),
            ],
          ),
          backgroundColor: const Color(0xFF1E1E1E),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      _toastError('Scan failed — please fill in manually.');
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  // Uses Gemini 1.5 Flash (multimodal) — understands bill context holistically,
  // not keyword matching. Handles restaurant receipts, utility bills, fuel slips,
  // grocery invoices, PDFs, etc.
  Future<_OcrResult?> _callGeminiVision(Uint8List bytes, String mime) async {
    const apiKey = 'AIzaSyDLWgzUy_UYUcyg0Rp5RBO-lxQMmpM10WU';
    const prompt = r'''
You are a receipt/bill parser. Analyze the image and return ONLY a JSON object (no markdown, no explanation):
{
  "amount": <final total as a number, e.g. 1250.50>,
  "description": "<vendor/merchant name, concise, max 40 chars>",
  "category": "<exactly one of: food, transport, accommodation, entertainment, utilities, shopping, medical, education, other>",
  "notes": "<one short phrase like 'Electricity bill Apr', 'Dinner for 3', 'Fuel refill'>"
}

Category rules (use full context, not just words):
- food: restaurant, cafe, food delivery, grocery store, bakery, dhaba
- transport: fuel/petrol, cab, auto, metro, bus, toll, parking, bike rental
- accommodation: hotel, resort, lodge, homestay, PG, service apartment
- entertainment: movies, OTT, concert, event, game, sport, amusement
- utilities: electricity, water, gas, internet/broadband, mobile recharge, DTH, maintenance
- shopping: clothing, electronics, furniture, appliances, online order (Amazon/Flipkart etc)
- medical: hospital, clinic, pharmacy/chemist, lab test, doctor consultation
- education: school fee, coaching, course, books, stationery

If you cannot read something, use null for that field. Return ONLY the JSON.
''';

    final response = await http
        .post(
          Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                  {
                    'inline_data': {
                      'mime_type': mime,
                      'data': base64Encode(bytes),
                    }
                  },
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.1,
              'maxOutputTokens': 512,
            },
          }),
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;

    final rawText = ((candidates[0]['content']['parts'] as List?)
            ?.firstWhere((p) => p['text'] != null,
                orElse: () => null)?['text'] as String?) ??
        '';

    // Strip markdown code fences if Gemini wrapped the JSON
    final jsonStr = rawText
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    if (jsonStr.isEmpty) return null;

    final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;

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

  void _toastError(String msg) {
    if (!mounted) return;
    setState(() => _scanning = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg), backgroundColor: const Color(0xFF1E1E1E)),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final groupsAsync = ref.watch(watchGroupsProvider);
    final isSignedIn = ref.watch(authStateProvider).valueOrNull != null;
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
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              'Save',
              style: TextStyle(
                color: brandGreen,
                fontWeight: FontWeight.w600,
                fontSize: 16,
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

            // ── Group picker ───────────────────────────────────────
            groupsAsync.when(
              loading: () => isSignedIn
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<GroupEntity>(
                      value: null,
                      hint: const Text('Sign in to see groups'),
                      decoration: const InputDecoration(
                        labelText: 'Group',
                        prefixIcon: Icon(Icons.group_outlined),
                      ),
                      items: const [],
                      onChanged: null,
                    ),
              error: (_, __) => const SizedBox.shrink(),
              data: (groups) => DropdownButtonFormField<GroupEntity>(
                value: _selectedGroup,
                hint: const Text('Select group'),
                decoration: const InputDecoration(
                  labelText: 'Group',
                  prefixIcon: Icon(Icons.group_outlined),
                ),
                items: groups
                    .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g.name),
                        ))
                    .toList(),
                onChanged: (g) => setState(() => _selectedGroup = g),
                dropdownColor: colors.surfaceOverlay,
                style: TextStyle(color: colors.textPrimary, fontSize: 16),
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
            SizedBox(height: spacing.stackXl),

            // ── Split info ─────────────────────────────────────────
            if (_selectedGroup != null)
              Container(
                padding: EdgeInsets.all(spacing.insetMd),
                decoration: BoxDecoration(
                  color: colors.backgroundSubtle,
                  borderRadius: BorderRadius.circular(radius.control),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: colors.textSecondary),
                    SizedBox(width: spacing.inlineSm),
                    Text(
                      'Split equally between ${_selectedGroup!.memberCount} members',
                      style: TextStyle(
                          fontSize: 13, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),

            SizedBox(height: spacing.stackXl),

            // ── Save button ────────────────────────────────────────
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
                    : const Text('Add Expense',
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
                    ? brandGreen.withOpacity(0.6)
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
                          strokeWidth: 2, color: Color(0xFFC3FD00)),
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
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: Color(0xFFC3FD00), size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Receipt scanned',
                                  style: TextStyle(
                                    color: Color(0xFFC3FD00),
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
                            color: Color(0xFFC3FD00), size: 20),
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
                        child: const Icon(Icons.document_scanner_outlined,
                            size: 20, color: brandGreen),
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
  const _ScanSheet({
    required this.onCamera,
    required this.onGallery,
    required this.onFile,
  });

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
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Scan Receipt',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Auto-fill expense details from your receipt',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 20),
          _SheetOption(
            icon: Icons.camera_alt_outlined,
            label: 'Take a Photo',
            subtitle: 'Use your camera',
            onTap: onCamera,
          ),
          _SheetOption(
            icon: Icons.photo_library_outlined,
            label: 'Choose from Gallery',
            subtitle: 'Pick an existing image',
            onTap: onGallery,
          ),
          _SheetOption(
            icon: Icons.attach_file_rounded,
            label: 'Upload File',
            subtitle: 'PDF, JPG, PNG',
            onTap: onFile,
          ),
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
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

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
      trailing: Icon(Icons.chevron_right_rounded,
          color: Colors.grey[600], size: 20),
      onTap: onTap,
    );
  }
}

// ── Category chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onSelected,
  });

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
        color: selected ? colors.brandPrimary : colors.borderDefault,
      ),
      labelStyle: TextStyle(
        color: selected ? colors.brandPrimaryDk : colors.textPrimary,
        fontSize: 13,
      ),
    );
  }
}
