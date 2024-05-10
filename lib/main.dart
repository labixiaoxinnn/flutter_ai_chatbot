import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'features/chatbot/presentation/ui/chatbot_home_page.dart';
import 'features/ui_theme/ui_theme.dart';

void main() {
  runApp(const ProviderScope(child: ChatbotApp()));
}

class ChatbotApp extends ConsumerWidget {
  const ChatbotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Chatbot',
      theme: theme,
      home: const ChatbotHomePage(),
    );
  }
}
