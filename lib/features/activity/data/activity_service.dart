import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/local_storage.dart';
import '../domain/activity_entry.dart';

abstract final class ActivityService {
  static String _localKey(String householdName) =>
      LocalStorage.householdKey('activity', householdName);

  static Future<void> record({
    required String householdName,
    required String? householdId,
    required String description,
  }) async {
    final user = AuthService.currentUser;
    final actorName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : user?.email?.split('@').first ?? 'Tú';
    if (user == null || householdId == null) {
      final stored =
          await LocalStorage.readList(_localKey(householdName)) ?? [];
      final entry = ActivityEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        actorName: actorName,
        description: description,
        createdAt: DateTime.now(),
      );
      await LocalStorage.writeList(
        _localKey(householdName),
        [entry.toJson(), ...stored].take(50).toList(),
      );
      return;
    }
    await FirebaseFirestore.instance
        .collection('households')
        .doc(householdId)
        .collection('activity')
        .add({
          'actorId': user.uid,
          'actorName': actorName,
          'description': description,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  static Stream<List<ActivityEntry>>? watch({required String? householdId}) {
    if (AuthService.currentUser == null || householdId == null) return null;
    return FirebaseFirestore.instance
        .collection('households')
        .doc(householdId)
        .collection('activity')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) =>
                    ActivityEntry.fromJson(document.data(), id: document.id),
              )
              .toList(),
        );
  }

  static Future<List<ActivityEntry>> load({
    required String householdName,
    required String? householdId,
  }) async {
    if (AuthService.currentUser == null || householdId == null) {
      final stored =
          await LocalStorage.readList(_localKey(householdName)) ?? [];
      return stored
          .map(
            (data) =>
                ActivityEntry.fromJson(data, id: data['id'] as String? ?? ''),
          )
          .toList();
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('households')
        .doc(householdId)
        .collection('activity')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    return snapshot.docs
        .map(
          (document) =>
              ActivityEntry.fromJson(document.data(), id: document.id),
        )
        .toList();
  }
}
