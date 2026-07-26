class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLogin;
  final int totalLoginDays;
  final bool isPremium;
  final String? fcmToken;

  UserModel({
    required this.id,
    this.name = 'Friend',
    this.email = '',
    this.photoUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
    this.totalLoginDays = 0,
    this.isPremium = false,
    this.fcmToken,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastLogin = lastLogin ?? DateTime.now();

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
    int? totalLoginDays,
    bool? isPremium,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      totalLoginDays: totalLoginDays ?? this.totalLoginDays,
      isPremium: isPremium ?? this.isPremium,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'createdAt': createdAt.toIso8601String(),
        'lastLogin': lastLogin.toIso8601String(),
        'totalLoginDays': totalLoginDays,
        'isPremium': isPremium,
        'fcmToken': fcmToken,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] ?? '',
        name: map['name'] ?? 'Friend',
        email: map['email'] ?? '',
        photoUrl: map['photoUrl'],
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        lastLogin: DateTime.tryParse(map['lastLogin'] ?? '') ?? DateTime.now(),
        totalLoginDays: map['totalLoginDays'] ?? 0,
        isPremium: map['isPremium'] ?? false,
        fcmToken: map['fcmToken'],
      );
}