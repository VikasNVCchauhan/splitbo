// packages/data/lib/src/dto/user_dto.dart
//
// Firestore ↔ UserEntity marshalling.
// Plain Dart — no code-gen needed; toJson/fromJson are trivial here.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

class UserDto {
  const UserDto({
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

  factory UserDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return UserDto(
      id: doc.id,
      displayName: d['displayName'] as String? ?? '',
      email: d['email'] as String?,
      phoneNumber: d['phoneNumber'] as String?,
      avatarUrl: d['avatarUrl'] as String?,
      defaultCurrency: d['defaultCurrency'] as String? ?? 'INR',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'displayName': displayName,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'defaultCurrency': defaultCurrency,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        displayName: displayName,
        email: email,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        defaultCurrency: defaultCurrency,
        createdAt: createdAt,
      );

  static UserDto fromEntity(UserEntity e) => UserDto(
        id: e.id,
        displayName: e.displayName,
        email: e.email,
        phoneNumber: e.phoneNumber,
        avatarUrl: e.avatarUrl,
        defaultCurrency: e.defaultCurrency,
        createdAt: e.createdAt,
      );
}
