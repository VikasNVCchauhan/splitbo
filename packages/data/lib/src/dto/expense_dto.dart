// packages/data/lib/src/dto/expense_dto.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

class ExpenseDto {
  const ExpenseDto({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.splits,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.currency = 'INR',
    this.category = 'other',
    this.receiptUrl,
    this.notes,
  });

  final String id;
  final String groupId;
  final String description;
  final double amount;
  final String currency;
  final String paidBy;
  final List<Map<String, dynamic>> splits;
  final String category;
  final String? receiptUrl;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ExpenseDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ExpenseDto(
      id: doc.id,
      groupId: d['groupId'] as String? ?? '',
      description: d['description'] as String? ?? '',
      amount: (d['amount'] as num?)?.toDouble() ?? 0.0,
      currency: d['currency'] as String? ?? 'INR',
      paidBy: d['paidBy'] as String? ?? '',
      splits: List<Map<String, dynamic>>.from(d['splits'] as List? ?? []),
      category: d['category'] as String? ?? 'other',
      receiptUrl: d['receiptUrl'] as String?,
      notes: d['notes'] as String?,
      createdBy: d['createdBy'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'groupId': groupId,
        'description': description,
        'amount': amount,
        'currency': currency,
        'paidBy': paidBy,
        'splits': splits,
        'category': category,
        if (receiptUrl != null) 'receiptUrl': receiptUrl,
        if (notes != null) 'notes': notes,
        'createdBy': createdBy,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  ExpenseEntity toEntity() => ExpenseEntity(
        id: id,
        groupId: groupId,
        description: description,
        amount: amount,
        currency: currency,
        paidBy: paidBy,
        splits: splits
            .map((s) => SplitEntity(
                  userId: s['userId'] as String,
                  amount: (s['amount'] as num).toDouble(),
                ))
            .toList(),
        category: ExpenseCategory.values.firstWhere(
          (c) => c.name == category,
          orElse: () => ExpenseCategory.other,
        ),
        receiptUrl: receiptUrl,
        notes: notes,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static ExpenseDto fromEntity(ExpenseEntity e) => ExpenseDto(
        id: e.id,
        groupId: e.groupId,
        description: e.description,
        amount: e.amount,
        currency: e.currency,
        paidBy: e.paidBy,
        splits: e.splits
            .map((s) => {'userId': s.userId, 'amount': s.amount})
            .toList(),
        category: e.category.name,
        receiptUrl: e.receiptUrl,
        notes: e.notes,
        createdBy: e.createdBy,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );
}
