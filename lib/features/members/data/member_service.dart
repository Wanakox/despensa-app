import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/local_storage.dart';
import '../domain/household_member.dart';

abstract final class MemberService {
  static String _localKey(String householdName) =>
      LocalStorage.householdKey('members', householdName);

  static Stream<List<HouseholdMember>>? watch({required String? householdId}) {
    if (AuthService.currentUser == null || householdId == null) return null;
    return FirebaseFirestore.instance
        .collection('households')
        .doc(householdId)
        .collection('members')
        .snapshots()
        .map((snapshot) {
          final members = snapshot.docs
              .map(
                (document) =>
                    HouseholdMember.fromJson(document.data(), id: document.id),
              )
              .toList();
          members.sort(
            (a, b) => a.isOwner == b.isOwner
                ? a.name.compareTo(b.name)
                : (a.isOwner ? -1 : 1),
          );
          return members;
        });
  }

  static Future<List<HouseholdMember>> load({
    required String householdName,
    required String? householdId,
  }) async {
    final user = AuthService.currentUser;
    if (user == null || householdId == null) {
      final stored = await LocalStorage.readList(_localKey(householdName));
      return stored
              ?.map(
                (data) => HouseholdMember.fromJson(
                  data,
                  id: data['id'] as String? ?? '',
                ),
              )
              .toList() ??
          const [
            HouseholdMember(
              id: 'local-owner',
              name: 'Usuario principal',
              email: '',
              role: 'owner',
            ),
          ];
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('households')
        .doc(householdId)
        .collection('members')
        .get();
    final members = snapshot.docs
        .map(
          (document) =>
              HouseholdMember.fromJson(document.data(), id: document.id),
        )
        .toList();
    members.sort((a, b) {
      if (a.isOwner != b.isOwner) return a.isOwner ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return members;
  }

  static Future<void> invite({
    required String householdName,
    required String? householdId,
    required String email,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (AuthService.currentUser == null || householdId == null) {
      final members = await load(
        householdName: householdName,
        householdId: householdId,
      );
      if (members.any((member) => member.email == normalizedEmail)) return;
      final invited = HouseholdMember(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: normalizedEmail.split('@').first,
        email: normalizedEmail,
        role: 'member',
      );
      await LocalStorage.writeList(
        _localKey(householdName),
        [...members, invited].map((member) => member.toJson()).toList(),
      );
      return;
    }
    final duplicate = await FirebaseFirestore.instance
        .collection('invitations')
        .where('householdId', isEqualTo: householdId)
        .where('email', isEqualTo: normalizedEmail)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    if (duplicate.docs.isNotEmpty) return;
    await FirebaseFirestore.instance.collection('invitations').add({
      'householdId': householdId,
      'householdName': householdName,
      'email': normalizedEmail,
      'status': 'pending',
      'invitedBy': AuthService.currentUser!.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> remove({
    required String householdName,
    required String? householdId,
    required HouseholdMember member,
  }) async {
    if (AuthService.currentUser == null || householdId == null) {
      final members = await load(
        householdName: householdName,
        householdId: householdId,
      );
      await LocalStorage.writeList(
        _localKey(householdName),
        members
            .where((item) => item.id != member.id)
            .map((item) => item.toJson())
            .toList(),
      );
      return;
    }
    final firestore = FirebaseFirestore.instance;
    final household = firestore.collection('households').doc(householdId);
    final batch = firestore.batch();
    batch.delete(household.collection('members').doc(member.id));
    batch.delete(
      firestore
          .collection('users')
          .doc(member.id)
          .collection('households')
          .doc(householdId),
    );
    batch.update(household, {
      'memberCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  static Future<void> transferOwnership({
    required String? householdId,
    required HouseholdMember newOwner,
  }) async {
    final user = AuthService.currentUser;
    if (user == null || householdId == null) return;
    final firestore = FirebaseFirestore.instance;
    final household = firestore.collection('households').doc(householdId);
    final batch = firestore.batch();
    batch.update(household, {
      'ownerId': newOwner.id,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(household.collection('members').doc(user.uid), {
      'role': 'member',
    });
    batch.update(household.collection('members').doc(newOwner.id), {
      'role': 'owner',
    });
    batch.update(
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('households')
          .doc(householdId),
      {'role': 'member'},
    );
    batch.update(
      firestore
          .collection('users')
          .doc(newOwner.id)
          .collection('households')
          .doc(householdId),
      {'role': 'owner'},
    );
    await batch.commit();
  }
}
