import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../authentication/data/auth_repository.dart';
import '../../common/data/api_repository.dart';
import '../domain/chat_message.dart';
import '../domain/chat_thread.dart';
import 'bot_repository_fake.dart';

part 'bot_repository.g.dart';

@riverpod
BotRepository getBotRepository(GetBotRepositoryRef ref) {
  // Replace with actual implementation once API is available
  return BotRepositoryFake(ref.watch(getAuthRepositoryProvider), Dio());
}


abstract class BotRepository extends ApiRepository {
  BotRepository(super.authRepository, super.dio);

  Stream<ChatMessage> getChatResponse(String message);
  Future<List<ChatThread>> getRecentThreads();
}
