import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/html_utils.dart';
import '../../../ui_theme/spacing.dart';
import '../../../ui_theme/ui_theme.dart';
import '../../domain/chat_message.dart';
import '../../domain/chat_thread.dart';
import '../controller/file_picker_controller.dart';
import 'attachment_list.dart';
import 'file_picker_widget.dart';

class ChatbotHomePage extends StatelessWidget {
  const ChatbotHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdaptiveLayout(
        topNavigation: SlotLayout(
          config: {
            Breakpoints.smallAndUp: SlotLayout.from(
              key: const Key("smallAndUp"),
              builder: (context) => SizedBox(
                height: 60,
                child: AppBar(
                  iconTheme: const IconThemeData(size: 30),
                  title: const Text(
                    'Welcome to Chatbot',
                  ),
                  actions: [
                    Consumer(
                      builder: (context, ref, child) {
                        final theme = ref.watch(themeProvider);

                        return IconButton(
                          icon: Icon(theme == darkTheme
                              ? Icons.light_mode
                              : Icons.dark_mode),
                          onPressed: () {
                            ref.read(themeProvider.notifier).state =
                                theme == darkTheme ? lightTheme : darkTheme;
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.person),
                      onPressed: () {},
                    )
                  ],
                ),
              ),
            )
          },
        ),
        primaryNavigation: SlotLayout(
          config: {
            Breakpoints.smallAndUp: SlotLayout.from(
              key: const Key("smallAndUp"),
              builder: (context) => const SizedBox(
                width: 220,
                child: Drawer(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 80,
                        child: DrawerHeader(
                          decoration: BoxDecoration(),
                          child: NewChatButton(),
                        ),
                      ),
                      ListTile(
                        title: Text('Recent chats'),
                      ),
                      RecentChatList(),
                    ],
                  ),
                ),
              ),
            ),
          },
        ),
        body: SlotLayout(
          config: {
            Breakpoints.smallAndUp: SlotLayout.from(
              key: const Key("smallAndUp"),
              builder: (context) => const ChatbotBody(),
            ),
          },
        ),
      ),
    );
  }
}

class ScrollableHtmlPart extends HookWidget {
  const ScrollableHtmlPart(
    this.htmlPart, {
    super.key,
  });

  final String htmlPart;

  @override
  Widget build(BuildContext context) {
    final horizontalScrollController = useScrollController();

    String html = htmlPart;
    if (htmlPart.contains("<table>")) {
      String headerBgColor = Theme.of(context)
          .colorScheme
          .onInverseSurface
          .value
          .toRadixString(16)
          .substring(2);

      headerBgColor = "#$headerBgColor";

      String headerTextColor = Theme.of(context)
          .colorScheme
          .inverseSurface
          .value
          .toRadixString(16)
          .substring(2);

      headerTextColor = "#$headerTextColor";

      const borderColor = 'grey';

      html = htmlPart
          .replaceAll("<table>",
              "<table style='border: 1px solid $borderColor; border-collapse: separate;'>")
          .replaceAll("</table>", "</table>")
          .replaceAll(
              "<th>", "<th style='padding: 8px; border: 1px solid $borderColor; border-collapse: separate; background-color: $headerBgColor; color: $headerTextColor;'>")
          .replaceAll("<td>",
              "<td style='padding: 8px; border: 1px solid $borderColor; border-collapse: separate;'>")
          .replaceAll("<td>",
              "<td style='padding: 8px; border: 1px solid $borderColor; border-collapse: separate;'>");
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDoubleSpacing),
      child: Scrollbar(
        thumbVisibility: true,
        controller: horizontalScrollController,
        thickness: 10.0, // Optional: to set the thickness of the scrollbar
        child: SingleChildScrollView(
          controller: horizontalScrollController,
          scrollDirection:
              Axis.horizontal, // Important to make the scroll horizontal
          child: Padding(
            padding: const EdgeInsets.only(bottom: kDoubleSpacing),
            child: SelectionArea(
              child: HtmlWidget(
                html,
                onTapUrl: (url) => launchUrl(Uri(path: url)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecentChatList extends HookConsumerWidget {
  const RecentChatList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatListAsync = ref.watch(getRecentChatThreadsProvider);

    return chatListAsync.when(
      data: (chatList) {
        return Expanded(
          child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              curve: Curves.easeIn,
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: ListView(
                    children: chatList
                        .map((chat) => RecentChatItem(thread: chat))
                        .toList(),
                  ),
                );
              }),
        );
      },
      loading: () => const Align(
          alignment: Alignment.center, child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        return const Center(child: Text('Error loading chats'));
      },
    );
  }
}

class RecentChatItem extends StatelessWidget {
  const RecentChatItem({
    super.key,
    required this.thread,
  });

  final ChatThread thread;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: Padding(
        padding: const EdgeInsets.all(kSingleSpacing),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            thread.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ),
    );
  }
}

final isChatEmptyProvider = Provider.autoDispose<bool>((ref) {
  final chatHistory = ref.watch(chatHistoryProvider);
  return chatHistory.isEmpty;
});

class NewChatButton extends ConsumerWidget {
  const NewChatButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isChatHistoryEmpty = ref.watch(isChatEmptyProvider);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      child: FilledButton(
        key: ValueKey<bool>(!isChatHistoryEmpty),
        onPressed: !isChatHistoryEmpty
            ? () => ref.read(chatHistoryProvider.notifier).clear()
            : null,
        child: Row(
          children: [
            const Icon(Icons.add),
            AppSpacer.singleSpace(),
            const Text('New Chat'),
          ],
        ),
      ),
    );
  }
}

class ChatbotBody extends HookConsumerWidget {
  const ChatbotBody({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();

    final chatHistory = ref.watch(chatHistoryProvider);
    final scrollController = useScrollController();

    ref.listen(chatHistoryProvider, (previous, next) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    });

    final chatEntryHeaderStyle = Theme.of(context).textTheme.bodyMedium;

    return TweenAnimationBuilder(
        duration: const Duration(seconds: 2),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        curve: Curves.easeIn,
        builder: (BuildContext context, dynamic value, Widget? child) {
          return Opacity(
            opacity: value,
            child: Center(
              child: SizedBox(
                width: 1000,
                child: Padding(
                  padding: const EdgeInsets.all(kDoubleSpacing),
                  child: Column(
                    children: [
                      if (chatHistory.isEmpty) ...[
                        const Spacer(),
                        const Text(
                          'Hi, I\'m a <example> chatbot!. How can I help you today?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSpacer.doubleHeight(),
                        const Text(
                          'You can ask me questions about <topic>, or pick a topic below to get started.',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        AppSpacer.quadrupleHeight(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: HelperCard(
                                messageController: messageController,
                                header: "Title 1",
                                helperButtonDetails: const [
                                  (
                                    "Button 1",
                                    "Button 1 question",
                                  ),
                                  ("Button 2", "Button 2 question on title 1"),
                                  ("Button 3", "Button 3 question on title 1"),
                                ],
                              ),
                            ),
                            AppSpacer.singleSpace(),
                            Expanded(
                              child: HelperCard(
                                messageController: messageController,
                                header: "Title 2",
                                helperButtonDetails: const [
                                  ("Button 1", "Button 1 question on title 2"),
                                  ("Button 2", "Button 2 question on title 2"),
                                  ("Button 3", "Button 3 question on title 2"),
                                ],
                              ),
                            ),
                            AppSpacer.singleSpace(),
                            Expanded(
                              child: HelperCard(
                                messageController: messageController,
                                header: "Title 3",
                                helperButtonDetails: const [
                                  ("Button 1", "Button 1 question on title 3"),
                                  ("Button 2", "Button 2 question on title 3"),
                                  ("Button 3", "Button 3 question on title 3"),
                                ],
                              ),
                            )
                          ],
                        ),
                        const Spacer(),
                      ],
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: chatHistory.length + 1,
                          itemBuilder: (context, index) {
                            if (index == chatHistory.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: kDoubleSpacing,
                                ),
                                child: ChatResponseLoading(),
                              );
                            }
                            final chatEntry = chatHistory[index];
                            if (chatEntry.senderName == agentUser) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: kDoubleSpacing,
                                ),
                                child: TweenAnimationBuilder(
                                    duration: const Duration(milliseconds: 500),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    curve: Curves.easeIn,
                                    builder: (BuildContext context,
                                        dynamic value, Widget? child) {
                                      return Opacity(
                                        opacity: value,
                                        child: SelectionArea(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const CircleAvatar(),
                                              AppSpacer.singleSpace(),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        getFormattedHeader(
                                                            chatEntry),
                                                        style:
                                                            chatEntryHeaderStyle),
                                                    Text(chatEntry.message),
                                                    if (chatEntry.filePaths !=
                                                            null &&
                                                        chatEntry.filePaths!
                                                            .isNotEmpty)
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            vertical:
                                                                kSingleSpacing),
                                                        child: Text(
                                                          "Attachments:\n${chatEntry.filePaths!.map((path) => path).join("\n")}",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodySmall
                                                              ?.copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              );
                            }
                            final htmlContent = md.markdownToHtml(
                              chatEntry.message,
                              extensionSet: md.ExtensionSet.gitHubWeb,
                            );

                            final splitHtml =
                                splitHtmlTopLevelScrollableParts(htmlContent);

                            List<Widget> widgets = [];

                            for (var i = 0; i < splitHtml.length; i++) {
                              if (splitHtml[i].contains("<table>") ||
                                  splitHtml[i].contains("<pre>")) {
                                widgets.add(ScrollableHtmlPart(splitHtml[i]));
                                print(splitHtml[i]);
                              } else {
                                print(splitHtml[i]);
                                widgets.add(
                                  HtmlWidget(
                                    splitHtml[i],
                                    onTapUrl: (url) => launchUrl(
                                      Uri.parse(url),
                                      mode: LaunchMode.externalApplication,
                                    ),
                                  ),
                                );
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: kSingleSpacing),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Center(
                                      // child: FaIcon(
                                      //   FontAwesomeIcons
                                      //       .robot, // Replace with desired Font Awesome icon code
                                      // ),
                                      child: Text(
                                        getSenderEmoji(chatEntry),
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              getAgentDisplayColor(chatEntry),
                                        ),
                                      ),
                                    ),
                                  ),
                                  AppSpacer.singleSpace(),
                                  Expanded(
                                    child: TweenAnimationBuilder(
                                      duration:
                                          const Duration(milliseconds: 1000),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      curve: Curves.easeIn,
                                      builder: (BuildContext context,
                                          dynamic value, Widget? child) {
                                        return Opacity(
                                          opacity: value,
                                          child: SelectionArea(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  getFormattedHeader(chatEntry),
                                                  style: chatEntryHeaderStyle
                                                      ?.copyWith(
                                                    color: getAgentDisplayColor(
                                                        chatEntry),
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: widgets,
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      AppSpacer.doubleSpace(),
                      SendMessage(messageController: messageController),
                      AppSpacer.doubleSpace(),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class HelperCard extends StatelessWidget {
  const HelperCard({
    super.key,
    required this.messageController,
    required this.header,
    required this.helperButtonDetails,
  });

  final TextEditingController messageController;
  final String header;
  final List<(String, String)> helperButtonDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kQuadrupleSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              header,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            AppSpacer.doubleHeight(),
            ...helperButtonDetails.map(
              (helperButtonDetail) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: kSingleSpacing),
                  child: HelperButton(
                    messageController: messageController,
                    label: helperButtonDetail.$1,
                    message: helperButtonDetail.$2,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HelperButton extends ConsumerWidget {
  const HelperButton({
    super.key,
    required this.messageController,
    required this.label,
    required this.message,
  });

  final TextEditingController messageController;
  final String label;
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () {
        ref.read((platformFilesProvider.notifier)).state = [];
        messageController.text = message;
      },
      child: Text(label),
    );
  }
}

class SendMessage extends HookConsumerWidget {
  const SendMessage({
    super.key,
    required this.messageController,
  });

  final TextEditingController messageController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platformFiles = ref.watch(platformFilesProvider);
    final enableSendButton = useState(false);
    final enableTextField = useState(true);
    final keyboardListenerFocusNode = useFocusNode();
    final textFieldFocusNode = useFocusNode();

    final isFocused = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        textFieldFocusNode.requestFocus();
      });
      messageController.addListener(() {
        enableSendButton.value = messageController.text.trim().isNotEmpty;
      });
      textFieldFocusNode.addListener(() {
        isFocused.value = textFieldFocusNode.hasFocus;
      });

      return () {
        messageController.removeListener(() {});
        textFieldFocusNode.removeListener(() {});
      };
    }, []);

    ref.listen(chatResponseControllerProvider, (previous, next) {
      if (next is AsyncLoading) {
        messageController.clear();
        // Disable text field while loading to prevent user from sending messages
        enableTextField.value = false;
      } else {
        // Re-enable text field after loading is done
        textFieldFocusNode.requestFocus();
        enableTextField.value = true;
      }
    });

    return ValueListenableBuilder(
        valueListenable: isFocused,
        builder: (context, hasFocus, _) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.all(
                Radius.circular(borderRadius),
              ),
              border: Border.all(
                color: hasFocus
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.primary,
                width: hasFocus ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                if (platformFiles.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(kSingleSpacing),
                    child: Row(
                      children: [
                        AppSpacer.quadrupleWidth(),
                        const Expanded(child: AttachmentList()),
                        AppSpacer.quadrupleWidth(),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    AppSpacer.singleSpace(),
                    const FilePickerWidget(
                      filePickerType: FilePickerType.file,
                      icon: Icons.attach_file,
                    ),
                    AppSpacer.singleSpace(),
                    if (defaultTargetPlatform != TargetPlatform.linux &&
                        defaultTargetPlatform != TargetPlatform.windows &&
                        defaultTargetPlatform != TargetPlatform.macOS)
                      const FilePickerWidget(
                        filePickerType: FilePickerType.photo,
                        icon: Icons.add_a_photo,
                      ),
                    Expanded(
                      child: KeyboardListener(
                        focusNode: keyboardListenerFocusNode,
                        onKeyEvent: (event) {
                          if (HardwareKeyboard.instance
                              .isLogicalKeyPressed(LogicalKeyboardKey.enter)) {
                            if (HardwareKeyboard.instance.isShiftPressed ==
                                    false &&
                                enableSendButton.value) {
                              _sendMessage(ref, messageController);
                              // Without this, the enter key will be inserted into the text field
                              // when the user presses enter.
                              keyboardListenerFocusNode.requestFocus();
                            }
                          }
                        },
                        child: TextField(
                          focusNode: textFieldFocusNode,
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: enableTextField.value
                                ? 'Type your message...'
                                : 'Please wait...',
                            // border: InputBorder.none,
                            // focusedBorder: InputBorder.none,
                            // enabledBorder: InputBorder.none,
                            // isDense: false,
                          ),
                          maxLines:
                              null, // Set maxLines to null for multi-line input
                          readOnly: !enableTextField.value,
                        ),
                      ),
                    ),
                    AppSpacer.singleSpace(),
                    IconButton(
                      onPressed: enableSendButton.value
                          ? () => _sendMessage(ref, messageController)
                          : null,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  void _sendMessage(WidgetRef ref, TextEditingController messageController) {
    final message = messageController.text.trim();

    final filePaths = ref.read(platformFilesProvider.notifier).state;
    ref.read(chatHistoryProvider.notifier).addUserMessage(
          ChatMessage(
            msgType: MessageType.requesting,
            senderName: agentUser,
            receiverName: agentCeo,
            message: message,
            filePaths: filePaths.map((file) => file.path).toList(),
          ),
        );
  }
}

// Animate the loading indicator by switching between '.' and '..' and '...'
class ChatResponseLoading extends HookConsumerWidget {
  const ChatResponseLoading({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responseAsync = ref.watch(chatResponseControllerProvider);
    final dotCount = useState(0);

    useEffect(() {
      Timer? timer;
      if (responseAsync is AsyncLoading) {
        timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
          dotCount.value = (dotCount.value + 1) % 4;
        });
      }
      return () {
        if (timer != null) {
          timer.cancel();
        }
      };
    }, [responseAsync]);

    return responseAsync.when(
      data: (_) => const SizedBox(),
      loading: () {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Opacity(
              opacity: 0.1,
              child: SizedBox(
                width: 40,
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.robot,
                  ),
                ),
              ),
            ),
            AppSpacer.singleSpace(),
            Align(
              alignment: Alignment.centerLeft,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Text(
                  '.' * dotCount.value,
                  key: ValueKey<int>(dotCount.value),
                ),
              ),
            ),
          ],
        );
      },
      error: (error, stackTrace) => const SizedBox(),
    );
  }
}
