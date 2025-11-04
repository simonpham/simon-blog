enum Role {
  admin,
  anonymous,
}

class User {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? avatarHash;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Role role;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.avatarHash,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
    this.role = Role.anonymous,
  });
}
