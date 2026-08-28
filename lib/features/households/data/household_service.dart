import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/local_storage.dart';
import '../domain/household.dart';
import '../domain/household_invitation.dart';

abstract final class HouseholdService {
  static const _localKey = 'households';

  static Future<List<Household>> load() async {
    final user = AuthService.currentUser;
    if (user == null) {
      final stored = await LocalStorage.readList(_localKey);
      return stored?.map((data) => Household.fromJson(data)).toList() ??
          [
            const Household(id: 'casa-garcia', name: 'Casa García', members: 3),
            const Household(
              id: 'piso-cordoba',
              name: 'Piso Córdoba',
              members: 2,
            ),
          ];
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('households')
        .orderBy('name')
        .get();
    final households = await Future.wait(
      snapshot.docs.map((membership) async {
        final document = await FirebaseFirestore.instance
            .collection('households')
            .doc(membership.id)
            .get();
        final data = document.data();
        return Household(
          id: membership.id,
          name: data?['name'] as String? ?? membership.data()['name'] as String,
          members:
              data?['memberCount'] as int? ??
              membership.data()['members'] as int? ??
              1,
          role: membership.data()['role'] as String? ?? 'member',
        );
      }),
    );
    households.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return households;
  }

  static Future<Household> create(String name) async {
    final user = AuthService.currentUser;
    if (user == null) {
      final households = await load();
      final household = Household(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        members: 1,
      );
      await LocalStorage.writeList(
        _localKey,
        [...households, household].map((item) => item.toJson()).toList(),
      );
      return household;
    }

    final firestore = FirebaseFirestore.instance;
    final householdDocument = firestore.collection('households').doc();
    final batch = firestore.batch();
    batch.set(householdDocument, {
      'name': name,
      'ownerId': user.uid,
      'memberCount': 1,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(householdDocument.collection('members').doc(user.uid), {
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'role': 'owner',
      'joinedAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('households')
          .doc(householdDocument.id),
      {
        'name': name,
        'members': 1,
        'role': 'owner',
        'joinedAt': FieldValue.serverTimestamp(),
      },
    );
    await batch.commit();
    return Household(id: householdDocument.id, name: name, members: 1);
  }

  static Future<List<HouseholdInvitation>> loadInvitations() async {
    final user = AuthService.currentUser;
    final email = user?.email?.trim().toLowerCase();
    if (user == null || email == null || email.isEmpty) return const [];
    final snapshot = await FirebaseFirestore.instance
        .collection('invitations')
        .where('email', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs
        .map(
          (document) =>
              HouseholdInvitation.fromJson(document.data(), id: document.id),
        )
        .toList();
  }

  static Future<void> respondToInvitation(
    HouseholdInvitation invitation, {
    required bool accept,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return;
    final firestore = FirebaseFirestore.instance;
    final invitationReference = firestore
        .collection('invitations')
        .doc(invitation.id);
    if (!accept) {
      await invitationReference.update({
        'status': 'rejected',
        'respondedAt': FieldValue.serverTimestamp(),
      });
      return;
    }
    final household = firestore
        .collection('households')
        .doc(invitation.householdId);
    final existingMembers = await household.collection('members').get();
    final memberCount = existingMembers.docs.length + 1;
    final batch = firestore.batch();
    batch.set(household.collection('members').doc(user.uid), {
      'name': user.displayName ?? user.email?.split('@').first ?? 'Miembro',
      'email': user.email ?? '',
      'role': 'member',
      'invitationId': invitation.id,
      'joinedAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('households')
          .doc(invitation.householdId),
      {
        'name': invitation.householdName,
        'members': memberCount,
        'role': 'member',
        'joinedAt': FieldValue.serverTimestamp(),
      },
    );
    batch.update(household, {
      'memberCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(invitationReference, {
      'status': 'accepted',
      'respondedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  static Future<void> rename(Household household, String name) async {
    if (AuthService.currentUser == null) {
      final households = await load();
      await LocalStorage.writeList(
        _localKey,
        households
            .map(
              (item) =>
                  (item.id == household.id
                          ? Household(
                              id: item.id,
                              name: name,
                              members: item.members,
                              role: item.role,
                            )
                          : item)
                      .toJson(),
            )
            .toList(),
      );
      return;
    }
    final firestore = FirebaseFirestore.instance;
    final householdReference = firestore
        .collection('households')
        .doc(household.id);
    final memberSnapshot = await householdReference.collection('members').get();
    final batch = firestore.batch();
    batch.update(householdReference, {
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    for (final member in memberSnapshot.docs) {
      batch.set(
        firestore
            .collection('users')
            .doc(member.id)
            .collection('households')
            .doc(household.id),
        {'name': name},
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  static Future<void> leave(Household household) async {
    final user = AuthService.currentUser;
    if (user == null) {
      final households = await load();
      await LocalStorage.writeList(
        _localKey,
        households
            .where((item) => item.id != household.id)
            .map((item) => item.toJson())
            .toList(),
      );
      return;
    }
    final firestore = FirebaseFirestore.instance;
    final reference = firestore.collection('households').doc(household.id);
    final batch = firestore.batch();
    batch.delete(reference.collection('members').doc(user.uid));
    batch.delete(
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('households')
          .doc(household.id),
    );
    batch.update(reference, {
      'memberCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  static Future<void> delete(Household household) async {
    if (AuthService.currentUser == null) return leave(household);
    final firestore = FirebaseFirestore.instance;
    final reference = firestore.collection('households').doc(household.id);
    final members = await reference.collection('members').get();
    final batch = firestore.batch();
    for (final member in members.docs) {
      batch.delete(
        firestore
            .collection('users')
            .doc(member.id)
            .collection('households')
            .doc(household.id),
      );
      batch.delete(member.reference);
    }
    batch.delete(reference);
    await batch.commit();
  }
}
