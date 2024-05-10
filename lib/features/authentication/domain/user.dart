import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum LoginType {
  anonymous("anonymous"),
  emailId("emailId"),
  google("google"),
  cognito("cognito");

  final String value;
  const LoginType(this.value);
}

@freezed
class User with _$User {
  const factory User({
    required LoginType loginType,
    required String objectId,
    required String email,
    String? name,
    String? firstName,
    String? photoUrl,
    String? phone,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

extension UserX on User {
  bool isLoggedIn() => loginType != LoginType.anonymous;
}
