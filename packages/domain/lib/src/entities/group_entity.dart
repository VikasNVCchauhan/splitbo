// packages/domain/lib/src/entities/group_entity.dart

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class GroupEntity extends Equatable {
  const GroupEntity({
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

  /// Cached display names for member chips — updated by Cloud Functions.
  final Map<String, String> memberDisplayNames;
  final Map<String, String> memberAvatarUrls;

  final String createdBy;
  final DateTime createdAt;
  final String currency;
  final String? avatarUrl;

  /// Total sum of all expense amounts — cached, written by Cloud Functions.
  final double totalExpenses;

  int get memberCount => memberIds.length;

  GroupEntity copyWith({
    String? name,
    String? description,
    List<String>? memberIds,
    Map<String, String>? memberDisplayNames,
    Map<String, String>? memberAvatarUrls,
    String? currency,
    String? avatarUrl,
    double? totalExpenses,
  }) =>
      GroupEntity(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        memberIds: memberIds ?? this.memberIds,
        memberDisplayNames: memberDisplayNames ?? this.memberDisplayNames,
        memberAvatarUrls: memberAvatarUrls ?? this.memberAvatarUrls,
        createdBy: createdBy,
        createdAt: createdAt,
        currency: currency ?? this.currency,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        totalExpenses: totalExpenses ?? this.totalExpenses,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        memberIds,
        memberDisplayNames,
        createdBy,
        createdAt,
        currency,
        avatarUrl,
        totalExpenses,
      ];
}
