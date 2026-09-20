// packages/data/lib/src/dto/balance_dto.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

class BalanceDto {
  const BalanceDto({
    required this.groupId,
    required this.userId,
    required this.net,
    required this.details,
    required this.updatedAt,
    this.currency = 'INR',
  });

  final String groupId;
  final String userId;
  final double net;
  final List<Map<String, dynamic>> details;
  final DateTime updatedAt;
  final String currency;

  factory BalanceDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return BalanceDto(
      groupId: d['groupId'] as String? ?? '',
      userId: d['userId'] as String? ?? doc.id,
      net: (d['net'] as num?)?.toDouble() ?? 0.0,
      details: List<Map<String, dynamic>>.from(d['details'] as List? ?? []),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      currency: d['currency'] as String? ?? 'INR',
    );
  }

  BalanceEntity toEntity() => BalanceEntity(
        groupId: groupId,
        userId: userId,
        net: net,
        details: details
            .map((d) => BalanceDetail(
                  fromUserId: d['fromUserId'] as String,
                  toUserId: d['toUserId'] as String,
                  amount: (d['amount'] as num).toDouble(),
                ))
            .toList(),
        updatedAt: updatedAt,
        currency: currency,
      );
}
