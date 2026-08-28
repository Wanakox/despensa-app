class HouseholdInvitation {
  const HouseholdInvitation({
    required this.id,
    required this.householdId,
    required this.householdName,
    required this.email,
  });

  final String id;
  final String householdId;
  final String householdName;
  final String email;

  factory HouseholdInvitation.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) => HouseholdInvitation(
    id: id,
    householdId: json['householdId'] as String,
    householdName: json['householdName'] as String,
    email: json['email'] as String,
  );
}
