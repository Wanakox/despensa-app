class Household {
  const Household({
    required this.id,
    required this.name,
    required this.members,
    this.role = 'owner',
  });

  final String id;
  final String name;
  final int members;
  final String role;

  bool get isOwner => role == 'owner';

  factory Household.fromJson(Map<String, dynamic> json, {String? id}) {
    return Household(
      id: id ?? json['id'] as String? ?? '',
      name: json['name'] as String,
      members: json['members'] as int? ?? 1,
      role: json['role'] as String? ?? 'owner',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'members': members,
    'role': role,
  };
}
