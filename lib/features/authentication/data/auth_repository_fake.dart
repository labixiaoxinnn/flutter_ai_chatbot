import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../domain/auth_error.dart';
import '../domain/auth_hub_event.dart';
import '../domain/auth_session.dart';
import '../domain/user.dart';
import 'auth_repository.dart';



class AuthRepositoryFake implements AuthRepository {
  @override
  TaskEither<AuthError, Unit> confirmResetPassword(
      String username, String newPassword, String confirmationCode) {
    // TODO: implement confirmResetPassword
    throw UnimplementedError();
  }

  @override
  TaskEither<AuthError, String> fetchAccessToken() {
    // TODO: implement fetchAccessToken
    throw UnimplementedError();
  }

  @override
  TaskEither<AuthError, AuthSession> fetchAuthSession() {
    // TODO: implement fetchAuthSession
    throw UnimplementedError();
  }

  @override
  TaskEither<AuthError, String> fetchIdToken() {
    // TODO: implement fetchIdToken
    throw UnimplementedError();
  }

  @override
  TaskEither<AuthError, String> fetchRefreshToken() {
    // TODO: implement fetchRefreshToken
    throw UnimplementedError();
  }

  @override
  TaskEither<AuthError, Map<String, dynamic>> fetchUserAttributes() {
    // TODO: implement fetchUserAttributes
    throw UnimplementedError();
  }

  @override
  TaskEither<AuthError, List<String>> fetchUserGroups() {
    // TODO: implement fetchUserGroups
    throw UnimplementedError();
  }

  @override
  StreamSubscription<AuthHubEvent> getAuthHubEventSubscription(
      {void Function(Option<User> p1)? onSignedIn,
      void Function()? onSignedOut,
      void Function()? onSessionExpired,
      void Function()? onUserDeleted}) {
    // TODO: implement getAuthHubEventSubscription
    throw UnimplementedError();
  }

  @override
  TaskEither<AuthError, bool> resetPassword(String username) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }

  @override
  TaskEither<AuthError, bool> signInUser(String username, String password) {
    // TODO: implement signInUser
    throw UnimplementedError();
  }

  @override
  TaskEither<AuthError, Unit> signOutCurrentUser() {
    // TODO: implement signOutCurrentUser
    throw UnimplementedError();
  }

  @override
  TaskEither<AuthError, Unit> signOutCurrentUserGlobally() {
    // TODO: implement signOutCurrentUserGlobally
    throw UnimplementedError();
  }

  @override
  TaskEither<AuthError, Unit> updatePassword(
      {required String newPassword, required String oldPassword}) {
    // TODO: implement updatePassword
    throw UnimplementedError();
  }
}
