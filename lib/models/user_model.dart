/// ─────────────────────────────────────────────────────────────
///  USER MODEL  –  lib/models/user_model.dart
/// ─────────────────────────────────────────────────────────────
enum UserRole { admin, cashier }

class UserModel {
  final int?     id;
  final String   name;
  final String   username;
  final String   passwordHash;  // store hashed, never plain
  final UserRole role;
  final bool     isActive;
  final DateTime createdAt;

  const UserModel({
    this.id,
    required this.name,
    required this.username,
    required this.passwordHash,
    this.role     = UserRole.cashier,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name':          name,
    'username':      username,
    'password_hash': passwordHash,
    'role':          role.name,
    'is_active':     isActive ? 1 : 0,
    'created_at':    createdAt.toIso8601String(),
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id:           map['id'] as int?,
    name:         map['name'] as String,
    username:     map['username'] as String,
    passwordHash: map['password_hash'] as String,
    role:         UserRole.values.firstWhere(
            (e) => e.name == map['role'], orElse: () => UserRole.cashier),
    isActive:     (map['is_active'] as int) == 1,
    createdAt:    DateTime.parse(map['created_at'] as String),
  );
}