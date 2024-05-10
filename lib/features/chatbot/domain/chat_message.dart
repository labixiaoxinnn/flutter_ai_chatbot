import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum MessageType {
  // production
  requesting("requesting"),
  delegating("delegating"),
  processing("processing"),
  receiving("receiving"),
  validating("validating"),
  response("response"),

  // debug
  system("system"),
  function("function"),
  functionOutput("functionOutput"),
  text("text"),
  error("error");

  final String value;
  const MessageType(this.value);
}

const agentUser = "User";
const agentCeo = "CEO";
const agentSystem = "System";

// The following are used when there is an error
const agentServer = "server";
const agentClient = "client";

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    String? threadId,
    required MessageType msgType,
    required String senderName,
    required String receiverName,
    required String message,
    List<String>? filePaths,
    DateTime? createdAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

Color getAgentDisplayColor(ChatMessage messageOutput) {
  if (messageOutput.msgType == MessageType.function ||
      messageOutput.msgType == MessageType.functionOutput) {
    return Colors.grey;
  }

  if (messageOutput.msgType == MessageType.system) {
    return Colors.red;
  }

  String combinedStr = messageOutput.senderName + messageOutput.receiverName;
  var bytes = utf8.encode(combinedStr);
  var hash = bytes.fold(0, (int prev, int next) => prev * 31 + next);
  var colors = [
    Colors.green,
    Colors.yellow,
    Colors.blue,
    Colors.pink,
    Colors.cyan,
    Colors.white,
  ];
  var colorIndex = hash % colors.length;
  return colors[colorIndex];
}

String getFormattedHeader(ChatMessage messageOutput) {
  if (messageOutput.msgType == MessageType.function) {
    return "${messageOutput.senderName} 🛠️ Executing Function";
  }

  if (messageOutput.msgType == MessageType.functionOutput) {
    return "${messageOutput.senderName} ⚙️Function Output";
  }

  final senderName =
      messageOutput.senderName == agentUser ? "You" : messageOutput.senderName;

  return "$senderName 🗣️ @${messageOutput.receiverName}";
}

String getSenderEmoji(ChatMessage messageOutput) {
  if (messageOutput.msgType == MessageType.system) {
    return "🤖";
  }

  String senderNameLower = messageOutput.senderName.toLowerCase();
  if (messageOutput.msgType == MessageType.functionOutput) {
    senderNameLower = messageOutput.receiverName.toLowerCase();
  }

  if (senderNameLower == "user") {
    return "👤";
  }

  if (senderNameLower == "ceo") {
    return "🤵";
  }

  // Similar hashing approach for emoji selection
  var bytes = utf8.encode(senderNameLower);
  var hash = bytes.fold(0, (int prev, int next) => prev * 31 + next);
  var emojis = [
    "🐶",
    "🐱",
    "🐭",
    "🐹",
    "🐰",
    "🦊",
    "🐻",
    "🐼",
    "🐨",
    "🐯",
    "🦁",
    "🐮",
    "🐷",
    "🐸",
    "🐵",
    "🐔",
    "🐧",
    "🐦",
    "🐤",
  ];

  var emojiIndex = hash % emojis.length;

  return emojis[emojiIndex];
}
