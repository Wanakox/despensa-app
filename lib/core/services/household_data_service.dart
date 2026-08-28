import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';
import 'local_storage.dart';

abstract final class HouseholdDataService {
  static const _supportedSections = {'inventory', 'cart'};

  static bool _useFirestore(String? householdId) =>
      householdId != null && AuthService.currentUser != null;

  static Stream<List<Map<String, dynamic>>>? watch({
    required String section,
    required String? householdId,
  }) {
    _validateSection(section);
    if (!_useFirestore(householdId)) return null;
    return FirebaseFirestore.instance
        .collection('households')
        .doc(householdId)
        .collection(section)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((document) => {...document.data(), '_id': document.id})
              .toList(),
        );
  }

  static Future<List<Map<String, dynamic>>> load({
    required String section,
    required String householdName,
    required String? householdId,
    required List<Map<String, dynamic>> localDefaults,
  }) async {
    _validateSection(section);
    if (!_useFirestore(householdId)) {
      final key = LocalStorage.householdKey(section, householdName);
      final stored = await LocalStorage.readList(key);
      if (stored != null) return stored;
      final defaults = localDefaults
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      await LocalStorage.writeList(key, defaults);
      return defaults;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('households')
        .doc(householdId)
        .collection(section)
        .get();
    return snapshot.docs
        .map((document) => {...document.data(), '_id': document.id})
        .toList();
  }

  static Future<void> save({
    required String section,
    required String householdName,
    required String? householdId,
    required List<Map<String, dynamic>> data,
  }) async {
    _validateSection(section);
    if (!_useFirestore(householdId)) {
      return LocalStorage.writeList(
        LocalStorage.householdKey(section, householdName),
        data,
      );
    }
    await saveMany(
      householdName: householdName,
      householdId: householdId,
      sections: {section: data},
    );
  }

  static Future<Map<String, dynamic>> upsert({
    required String section,
    required String householdName,
    required String? householdId,
    required Map<String, dynamic> data,
  }) async {
    _validateSection(section);
    final item = Map<String, dynamic>.from(data);
    var id = item['_id'] as String?;
    if (!_useFirestore(householdId)) {
      id ??= DateTime.now().microsecondsSinceEpoch.toString();
      item['_id'] = id;
      final key = LocalStorage.householdKey(section, householdName);
      final stored =
          await LocalStorage.readList(key) ?? <Map<String, dynamic>>[];
      final index = stored.indexWhere((candidate) => candidate['_id'] == id);
      if (index == -1) {
        stored.add(item);
      } else {
        stored[index] = item;
      }
      await LocalStorage.writeList(key, stored);
      return item;
    }

    final collection = FirebaseFirestore.instance
        .collection('households')
        .doc(householdId)
        .collection(section);
    final reference = id == null ? collection.doc() : collection.doc(id);
    id = reference.id;
    item['_id'] = id;
    final firestoreData = Map<String, dynamic>.from(item)..remove('_id');
    await reference.set({
      ...firestoreData,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': AuthService.currentUser!.uid,
      if (data['_id'] == null) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return item;
  }

  static Future<void> deleteItem({
    required String section,
    required String householdName,
    required String? householdId,
    required Map<String, dynamic> data,
  }) async {
    _validateSection(section);
    final id = data['_id'] as String?;
    if (!_useFirestore(householdId)) {
      final key = LocalStorage.householdKey(section, householdName);
      final stored =
          await LocalStorage.readList(key) ?? <Map<String, dynamic>>[];
      stored.removeWhere(
        (candidate) =>
            id != null ? candidate['_id'] == id : _sameItem(candidate, data),
      );
      await LocalStorage.writeList(key, stored);
      return;
    }
    if (id == null) {
      final matches = await FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .collection(section)
          .where('name', isEqualTo: data['name'])
          .get();
      final batch = FirebaseFirestore.instance.batch();
      for (final document in matches.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();
      return;
    }
    await FirebaseFirestore.instance
        .collection('households')
        .doc(householdId)
        .collection(section)
        .doc(id)
        .delete();
  }

  static Future<void> saveMany({
    required String householdName,
    required String? householdId,
    required Map<String, List<Map<String, dynamic>>> sections,
  }) async {
    for (final section in sections.keys) {
      _validateSection(section);
    }
    if (!_useFirestore(householdId)) {
      await Future.wait(
        sections.entries.map(
          (entry) => LocalStorage.writeList(
            LocalStorage.householdKey(entry.key, householdName),
            entry.value,
          ),
        ),
      );
      return;
    }

    final firestore = FirebaseFirestore.instance;
    final household = firestore.collection('households').doc(householdId);
    final snapshots = await Future.wait(
      sections.entries.map((entry) => household.collection(entry.key).get()),
    );
    final batch = firestore.batch();
    final entries = sections.entries.toList();
    for (var sectionIndex = 0; sectionIndex < entries.length; sectionIndex++) {
      final entry = entries[sectionIndex];
      final collection = household.collection(entry.key);
      final existingDocuments = {
        for (final document in snapshots[sectionIndex].docs)
          document.id: document,
      };
      final retainedIds = <String>{};

      for (final item in entry.value) {
        final storedId = item['_id'] as String?;
        final matchingDocument = storedId == null || storedId.isEmpty
            ? existingDocuments.values
                  .cast<QueryDocumentSnapshot<Map<String, dynamic>>?>()
                  .firstWhere(
                    (document) =>
                        document != null &&
                        !retainedIds.contains(document.id) &&
                        _sameItem(document.data(), item),
                    orElse: () => null,
                  )
            : null;
        final reference = storedId != null && storedId.isNotEmpty
            ? collection.doc(storedId)
            : matchingDocument?.reference ?? collection.doc();
        retainedIds.add(reference.id);
        item['_id'] = reference.id;
        final firestoreData = Map<String, dynamic>.from(item)..remove('_id');
        batch.set(reference, {
          ...firestoreData,
          if (!existingDocuments.containsKey(reference.id))
            'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': AuthService.currentUser!.uid,
        }, SetOptions(merge: true));
      }

      for (final document in existingDocuments.values) {
        if (!retainedIds.contains(document.id)) {
          batch.delete(document.reference);
        }
      }
    }
    await batch.commit();
  }

  static bool _sameItem(
    Map<String, dynamic> stored,
    Map<String, dynamic> candidate,
  ) =>
      (stored['name'] as String?)?.trim().toLowerCase() ==
      (candidate['name'] as String?)?.trim().toLowerCase();

  static void _validateSection(String section) {
    if (!_supportedSections.contains(section)) {
      throw ArgumentError.value(section, 'section', 'Sección no compatible');
    }
  }
}
