
import '../domain/chat_message.dart';
import '../domain/chat_thread.dart';
import 'bot_repository.dart';



const fakeChatMessages = [
  ChatMessage(
      msgType: MessageType.system,
      senderName: agentSystem,
      receiverName: agentUser,
      message:
          "These messages are from fake API. Implement and enable the production API to get real messages."),
  ChatMessage(
      msgType: MessageType.requesting,
      senderName: "Agent1",
      receiverName: "Agent2",
      message:
          "Here is sample chat communication from one agent to another agent."),
  ChatMessage(
      msgType: MessageType.function,
      senderName: "Agent2",
      receiverName: "Agent3",
      message:
          '```json\n{\n  "title": "Sample JSON",\n  "description": "This is a sample JSON request."\n}\n```'),
  ChatMessage(
      msgType: MessageType.functionOutput,
      senderName: "Agent2",
      receiverName: "Agent3",
      message: '''
Sample csv output:

```csv
Name, Age, City
John Doe, 25, New York
Jane Smith, 30, Los Angeles
```

Sample markdown table:

| Name       | Age | City       |
|------------|-----|------------|
| John Doe   | 25  | New York   |
| Jane Smith | 30  | Los Angeles|
'''),
];

class BotRepositoryFake extends BotRepository {
  BotRepositoryFake(super.authRepository, super.dio);

  @override
  Stream<ChatMessage> getChatResponse(String message) async* {
    await Future.delayed(const Duration(seconds: 1));
    for (final chatMessage in fakeChatMessages) {
      await Future.delayed(const Duration(seconds: 1));
      yield chatMessage;
    }
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
