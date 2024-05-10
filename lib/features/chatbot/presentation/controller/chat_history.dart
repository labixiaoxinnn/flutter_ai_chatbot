import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../logging/presentation/controllers/logging_controller.dart';
import '../../data/bot_repository.dart';
import '../../data/upload_repository.dart';
import '../../domain/chat_message.dart';
import '../../domain/chat_thread.dart';
import 'file_picker_controller.dart';

part 'chat_history.g.dart';

@riverpod
class ChatHistory extends _$ChatHistory {
  @override
  List<ChatMessage> build() {
    return [];
  }

  void addUserMessage(ChatMessage chatMessage) {
    state = [...state, chatMessage];
    final filePaths = chatMessage.filePaths ?? [];

    ref.read(platformFilesProvider.notifier).state = [];
    ref
        .read(chatResponseControllerProvider.notifier)
        .getChatResponse(chatMessage.message, filePaths);
  }

  Future<void> addBotMessage(Stream<ChatMessage> messageObject) async {
    bool isFirstMessage = true;

    await for (final responseMessage in messageObject) {
      if (isFirstMessage) {
        isFirstMessage = false;

        state = [...state, responseMessage];
        continue;
      }

      //! Uncomment the following line to see only the last message from the bot
      // state = [
      //   ...state.sublist(0, state.length - 1),
      //   responseMessage,
      // ];

      //! Comment the following lines to see only the last message from the bot
      if (responseMessage.senderName != agentUser) {
        state = [...state, responseMessage];
      }
    }
  }

  void clear() {
    state = [];
  }
}

@riverpod
class ChatResponseController extends _$ChatResponseController with LogMixin {
  @override
  FutureOr<void> build() {
    //
  }

  Future<void> getChatResponse(String message,
      [List<String> filePaths = const []]) async {
    state = const AsyncValue.loading();

    String userMessage = message;

    if (filePaths.isNotEmpty) {
      if (filePaths.length > 1) {
        userMessage += "\n\nFile names: ";
      } else {
        userMessage += "\n\nFile name: ";
      }
    }

    if (filePaths.isNotEmpty) {
      for (final filePath in filePaths) {
        final result = await ref
            .read(uploadRepositoryProvider)
            .uploadFile(
              filePath,
            )
            .run();

        final isError = result.fold(
          (l) {
            logger.log(l);
            const errorMessage = "Error uploading files";
            //state = AsyncValue.error(errorMessage, StackTrace.current);
            state = const AsyncValue.data(null);
            ref.read(chatHistoryProvider.notifier).addBotMessage(Stream.value(
                const ChatMessage(
                    msgType: MessageType.error,
                    senderName: agentServer,
                    receiverName: agentClient,
                    message: errorMessage)));
            return true;
          },
          (_) {
            userMessage += "\n${filePath.split('/').last}";
            logger.info("File uploaded successfully: $filePath");
            return false;
          },
        );

        if (isError) {
          return;
        }
      }
    }

    // This is to wait for the file upload event to complete before sending the message to the chatbot.
    // This needs to be optimized.
    await Future.delayed(const Duration(seconds: 1));

    final responseMessageObject =
        ref.read(getBotRepositoryProvider).getChatResponse(userMessage);

    await ref
        .read(chatHistoryProvider.notifier)
        .addBotMessage(responseMessageObject);
    state = const AsyncValue.data(null);
  }
}

@riverpod
FutureOr<List<ChatThread>> getRecentChatThreads(
    GetRecentChatThreadsRef ref) async {
  return ref.read(getBotRepositoryProvider).getRecentThreads();
}
