import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityEntry {
  const ActivityEntry({
    required this.id,
    required this.actorName,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final String actorName;
  final String description;
  final DateTime createdAt;

  factory ActivityEntry.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) {
    final value = json['createdAt'];
    return ActivityEntry(
      id: id,
      actorName: json['actorName'] as String? ?? 'Alguien',
      description: json['description'] as String? ?? '',
      createdAt: value is Timestamp
          ? value.toDate()
          : DateTime.tryParse(value as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'actorName': actorName,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };
}
