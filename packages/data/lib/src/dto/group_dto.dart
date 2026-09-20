// packages/data/lib/src/dto/group_dto.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

class GroupDto {
  const GroupDto({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.createdBy,
    required this.createdAt,
    this.description = '',
    this.currency = 'INR',
    this.avatarUrl,
    this.totalExpenses = 0.0,
    this.memberDisplayNames = const {},
    this.memberAvatarUrls = const {},
  });

  final String id;
  final String name;
  final String description;
  final List<String> memberIds;
  final Map<String, String> memberDisplayNames;
  final Map<String, String> memberAvatarUrls;
  final String createdBy;
  final DateTime createdAt;
  final String currency;
  final String? avatarUrl;
  final double totalExpenses;

  factory GroupDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return GroupDto(
      id: doc.id,
      name: d['name'] as String? ?? '',
      description: d['description'] as String? ?? '',
      memberIds: List<String>.from(d['memberIds'] as List? ?? []),
      memberDisplayNames: Map<String, String>.from(
          d['memberDisplayNames'] as Map? ?? {}),
      memberAvatarUrls: Map<String, String>.from(
          d['memberAvatarUrls'] as Map? ?? {}),
      createdBy: d['createdBy'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      currency: d['currency'] as String? ?? 'INR',
      avatarUrl: d['avatarUrl'] as String?,
      totalExpenses: (d['totalExpenses'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'description': description,
        'memberIds': memberIds,
        'memberDisplayNames': memberDisplayNames,
        'memberAvatarUrls': memberAvatarUrls,
        'createdBy': createdBy,
        'createdAt': Timestamp.fromDate(createdAt),
        'currency': currency,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'totalExpenses': totalExpenses,
      };

  GroupEntity toEntity() => GroupEntity(
        id: id,
        name: name,
        description: description,
        memberIds: memberIds,
        memberDisplayNames: memberDisplayNames,
        memberAvatarUrls: memberAvatarUrls,
        createdBy: createdBy,
        createdAt: createdAt,
        currency: currency,
        avatarUrl: avatarUrl,
        totalExpenses: totalExpenses,
      );
}
