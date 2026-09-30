import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maxie_mobile/features/auth/domain/models/user_profile.dart';

void main() {
  test('UserProfile serializes authenticated identity and preferences', () {
    final created = DateTime.utc(2026, 9, 17);
    final profile = UserProfile(
      uid: 'user-123',
      email: 'raj@example.com',
      displayName: 'Raj',
      createdAt: created,
      updatedAt: created,
      maxieName: 'MAXie',
      maxiePersonality: 'Curious',
    );

    final data = profile.toFirestore();

    expect(data['uid'], 'user-123');
    expect(data['email'], 'raj@example.com');
    expect(data['displayName'], 'Raj');
    expect(data['createdAt'], Timestamp.fromDate(created));
    expect(data['maxiePersonality'], 'Curious');
  });
}
