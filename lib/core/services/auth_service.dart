import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

abstract final class AuthService {
  static bool get isConfigured => Firebase.apps.isNotEmpty;

  static User? get currentUser =>
      isConfigured ? FirebaseAuth.instance.currentUser : null;

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (!isConfigured) return;
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!isConfigured) return;
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await credential.user!.updateDisplayName(name);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(credential.user!.uid)
        .set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  static Future<void> signOut() async {
    if (isConfigured) await FirebaseAuth.instance.signOut();
  }

  static Future<void> updateName(String name) async {
    final user = currentUser;
    if (user == null) return;
    final firestore = FirebaseFirestore.instance;
    final memberships = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('households')
        .get();
    final batch = firestore.batch();
    batch.set(firestore.collection('users').doc(user.uid), {
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    for (final membership in memberships.docs) {
      batch.update(
        firestore
            .collection('households')
            .doc(membership.id)
            .collection('members')
            .doc(user.uid),
        {'name': name},
      );
    }
    await batch.commit();
    await user.updateDisplayName(name);
    await user.reload();
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = currentUser;
    final email = user?.email;
    if (user == null || email == null) return;
    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  static Future<void> deleteAccount(String currentPassword) async {
    final user = currentUser;
    final email = user?.email;
    if (user == null || email == null) return;
    final firestore = FirebaseFirestore.instance;
    final memberships = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('households')
        .get();
    if (memberships.docs.any(
      (document) => document.data()['role'] == 'owner',
    )) {
      throw StateError(
        'Debes transferir o eliminar los hogares que administras antes de borrar tu cuenta.',
      );
    }
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: email, password: currentPassword),
    );
    final batch = firestore.batch();
    for (final membership in memberships.docs) {
      final household = firestore.collection('households').doc(membership.id);
      batch.delete(household.collection('members').doc(user.uid));
      batch.update(household, {
        'memberCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.delete(membership.reference);
    }
    batch.delete(firestore.collection('users').doc(user.uid));
    await batch.commit();
    await user.delete();
  }

  static String errorMessage(Object error) {
    if (error is! FirebaseAuthException) {
      return 'No se ha podido completar la operación. Inténtalo de nuevo.';
    }
    return switch (error.code) {
      'invalid-email' => 'El correo electrónico no es válido.',
      'invalid-credential' ||
      'user-not-found' ||
      'wrong-password' => 'El correo o la contraseña no son correctos.',
      'email-already-in-use' => 'Ya existe una cuenta con ese correo.',
      'weak-password' => 'La contraseña debe tener al menos 6 caracteres.',
      'network-request-failed' => 'Comprueba tu conexión a Internet.',
      'requires-recent-login' => 'Vuelve a iniciar sesión antes de continuar.',
      _ => 'No se ha podido completar la operación. Inténtalo de nuevo.',
    };
  }
}
