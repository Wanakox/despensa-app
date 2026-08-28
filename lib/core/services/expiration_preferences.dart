import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';
import 'local_storage.dart';

abstract final class ExpirationPreferences {
  static const defaultWarningDays = 3;
  static const _section = 'expiration-warning-days';

  static String _localKey(String householdName) =>
      LocalStorage.householdKey(_section, householdName);

  static Future<int> load({
    required String householdName,
    required String? householdId,
  }) async {
    if (householdId != null && AuthService.currentUser != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .get();
      return _normalize(snapshot.data()?['expirationWarningDays']);
    }
    final stored = await LocalStorage.readList(_localKey(householdName));
    return _normalize(stored?.firstOrNull?['value']);
  }

  static Future<void> save({
    required String householdName,
    required String? householdId,
    required int days,
  }) async {
    final normalized = days.clamp(0, 30);
    if (householdId != null && AuthService.currentUser != null) {
      await FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .update({
            'expirationWarningDays': normalized,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      return;
    }
    await LocalStorage.writeList(_localKey(householdName), [
      {'value': normalized},
    ]);
  }

  static int _normalize(Object? value) =>
      value is num ? value.toInt().clamp(0, 30) : defaultWarningDays;
}
