import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.onboardingCompleted = false,
    this.maxieName = 'MAXie',
    this.maxiePersonality = 'Friendly',
    this.bio,
    this.age,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool onboardingCompleted;
  final String maxieName;
  final String maxiePersonality;
  final String? bio;
  final int? age;

  factory UserProfile.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return UserProfile(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: _date(data['createdAt']) ?? DateTime.now(),
      updatedAt: _date(data['updatedAt']) ?? DateTime.now(),
      onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
      maxieName: data['maxieName'] as String? ?? 'MAXie',
      maxiePersonality: data['maxiePersonality'] as String? ?? 'Friendly',
      bio: data['bio'] as String?,
      age: (data['age'] as num?)?.toInt(),
    );
  }

  Map<String, Object?> toFirestore() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'onboardingCompleted': onboardingCompleted,
    'maxieName': maxieName,
    'maxiePersonality': maxiePersonality,
    if (bio != null) 'bio': bio,
    if (age != null) 'age': age,
  };

  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
