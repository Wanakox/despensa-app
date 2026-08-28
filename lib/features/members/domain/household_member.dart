class HouseholdMember {
  const HouseholdMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final String role;

  bool get isOwner => role == 'owner';

  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    final letters = words.length == 1
        ? words.first.substring(0, 1)
        : '${words.first[0]}${words.last[0]}';
    return letters.toUpperCase();
  }

  factory HouseholdMember.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) => HouseholdMember(
    id: id,
    name: json['name'] as String? ?? 'Miembro',
    email: json['email'] as String? ?? '',
    role: json['role'] as String? ?? 'member',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
  };
}
