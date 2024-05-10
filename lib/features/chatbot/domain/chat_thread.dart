import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_thread.freezed.dart';
part 'chat_thread.g.dart';

@freezed
class ChatThread with _$ChatThread {
  const factory ChatThread({
    required String threadId,
    required String title,
  }) = _ChatThread;

  factory ChatThread.fromJson(Map<String, dynamic> json) =>
      _$ChatThreadFromJson(json);
}
