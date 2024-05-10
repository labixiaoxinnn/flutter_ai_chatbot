import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'auth_hub_event.freezed.dart';

@freezed
class AuthHubEvent with _$AuthHubEvent {
  const factory AuthHubEvent.signedIn(User user) = SignedIn;
  const factory AuthHubEvent.signedOut() = SignedOut;
  const factory AuthHubEvent.sessionExpired() = SessionExpired;
  const factory AuthHubEvent.userDeleted() = UserDeleted;
}
