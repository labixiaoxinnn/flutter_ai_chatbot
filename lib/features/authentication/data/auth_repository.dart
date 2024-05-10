import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/auth_error.dart';
import '../domain/auth_hub_event.dart';
import '../domain/auth_session.dart';
import '../domain/user.dart';
import 'auth_repository_fake.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository getAuthRepository(GetAuthRepositoryRef ref) {
  // Replace with actual implementation once API is available
  return AuthRepositoryFake();
}

abstract class AuthRepository {
  TaskEither<AuthError, bool> signInUser(String username, String password);

  TaskEither<AuthError, Map<String, dynamic>> fetchUserAttributes();

  TaskEither<AuthError, Unit> signOutCurrentUser();

  TaskEither<AuthError, Unit> signOutCurrentUserGlobally();

  TaskEither<AuthError, AuthSession> fetchAuthSession();

  TaskEither<AuthError, List<String>> fetchUserGroups();

  TaskEither<AuthError, String> fetchIdToken();

  TaskEither<AuthError, String> fetchAccessToken();

  TaskEither<AuthError, String> fetchRefreshToken();

  TaskEither<AuthError, bool> resetPassword(String username);

  TaskEither<AuthError, Unit> confirmResetPassword(
      String username, String newPassword, String confirmationCode);

  TaskEither<AuthError, Unit> updatePassword({
    required String newPassword,
    required String oldPassword,
  });

  StreamSubscription<AuthHubEvent> getAuthHubEventSubscription({
    void Function(Option<User>)? onSignedIn,
    void Function()? onSignedOut,
    void Function()? onSessionExpired,
    void Function()? onUserDeleted,
  });
}
