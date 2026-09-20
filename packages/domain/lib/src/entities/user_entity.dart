// packages/domain/lib/src/entities/user_entity.dart

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.displayName,
    required this.createdAt,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.defaultCurrency = 'INR',
  });

  final String id;
  final String displayName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String defaultCurrency;
  final DateTime createdAt;

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return displayName.substring(0, displayName.length.clamp(0, 2)).toUpperCase();
  }

  UserEntity copyWith({
    String? displayName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? defaultCurrency,
  }) =>
      UserEntity(
        id: id,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        defaultCurrency: defaultCurrency ?? this.defaultCurrency,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        displayName,
        email,
        phoneNumber,
        avatarUrl,
        defaultCurrency,
        createdAt,
      ];
}
