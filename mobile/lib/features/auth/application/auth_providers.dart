import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/auth/data/auth_service.dart';
import 'package:maxie_mobile/features/auth/data/user_profile_repository.dart';
import 'package:maxie_mobile/features/auth/domain/models/user_profile.dart';

final authServiceProvider = ChangeNotifierProvider<AuthService>(
  (ref) => AuthService(),
);

final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) => UserProfileRepository(),
);

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authServiceProvider).user;
  if (user == null) return const Stream<UserProfile?>.empty();
  return ref.watch(userProfileRepositoryProvider).watchProfile(user.uid);
});
