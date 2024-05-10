import 'dart:convert';

import 'package:dio/dio.dart';

import '../domain/chat_message.dart';
import '../domain/chat_thread.dart';
import 'bot_repository.dart';


class BotRepositoryImpl extends BotRepository {
  BotRepositoryImpl(super.authRepository, super.dio);

  @override
  Stream<ChatMessage> getChatResponse(String message) async* {
    final dioClient = Dio();
    final response = await dioClient.post(
      //! Replace the URL with the actual server URL.
      'http://127.0.0.1:8000/chatbot',
      data: jsonEncode({'message': message}),
      options: Options(
        // followRedirects: false,
        // receiveDataWhenStatusError: true,
        // headers: {
        //   Headers.contentEncodingHeader: [utf8.name],
        // },
        responseType: ResponseType.stream,
      ),
      onReceiveProgress: (received, total) {
        final time = DateTime.now();
        final chunk = received.toString();
        print('$time: $chunk');
      },
    );
    await for (final messageObject in response.data.stream) {
      try {
        yield ChatMessage.fromJson(jsonDecode(utf8.decode(messageObject)));
      } catch (e) {
        final linesStr = utf8.decode(messageObject).trim().split('\n');

        if (linesStr.length <= 1) {
          yield ChatMessage(
            msgType: MessageType.error,
            message: 'Error: $e',
            senderName: agentServer,
            receiverName: agentClient,
          );
        } else {
          yield ChatMessage.fromJson(jsonDecode(linesStr.last));
        }
      }
    }
    // await Future.delayed(const Duration(seconds: 5));
    // yield message;
  }

  @override
  Future<List<ChatThread>> getRecentThreads() async {
    return Future.delayed(
      const Duration(seconds: 2),
      () => List.generate(
        5,
        (index) => ChatThread(
          threadId: index.toString(),
          title: 'Chat $index lorem ipsum dolor sit amet',
        ),
      ),
    );
  }
}
