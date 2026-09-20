// packages/data/lib/src/providers/firebase_providers.dart
// Manual Riverpod providers — no code-gen, no build_runner needed.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Collection prefix: "dev_" locally, "" in production.
/// Keeps local test data out of production collections.
const dbPrefix = kDebugMode ? 'dev_' : '';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (_) => FirebaseAuth.instance,
);

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  final db = FirebaseFirestore.instance;
  db.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: 40000000,
  );
  return db;
});

final firebaseStorageProvider = Provider<FirebaseStorage>(
  (_) => FirebaseStorage.instance,
);

const _googleWebClientId =
    '715213443351-ufjrg2hbroqpu6lnp0m84e4g1tdjjc87.apps.googleusercontent.com';

final googleSignInProvider = Provider<GoogleSignIn>(
  (_) => GoogleSignIn(
    clientId: _googleWebClientId,
    scopes: ['email', 'profile'],
  ),
);
