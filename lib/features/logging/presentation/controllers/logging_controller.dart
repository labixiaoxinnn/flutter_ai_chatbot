import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/request_error.dart';

part 'logging_controller.g.dart';

enum LogLevel {
  all("ALL"),
  finest("FINEST"),
  finer("FINER"),
  fine("FINE"),
  config("CONFIG"),
  info("INFO"),
  warning("WARNING"),
  severe("SEVERE"),
  shout("SHOUT"),
  off("OFF");

  final String code;
  const LogLevel(this.code);
}

enum AnsiColorCode {
  black("30"),
  red("31"),
  green("32"),
  yellow("33"),
  blue("34"),
  magenta("35"),
  cyan("36"),
  white("37"),
  lightBlack("30"),
  lightRed("31"),
  lightGreen("32"),
  lightYellow("33"),
  lightBlue("34"),
  lightMagenta("35"),
  lightCyan("36"),
  lightWhite("37");

  final String code;
  const AnsiColorCode(this.code);

  String paint(String text) => '\x1B[${code}m$text\x1B[0m';
}

enum ColorCode {
  red(Colors.red),
  pink(Colors.pink),
  purple(Colors.purple),
  deepPurple(Colors.deepPurple),
  indigo(Colors.indigo),
  blue(Colors.blue),
  lightBlue(Colors.lightBlue),
  cyan(Colors.cyan),
  teal(Colors.teal),
  green(Colors.green),
  lightGreen(Colors.lightGreen),
  lime(Colors.lime),
  yellow(Colors.yellow),
  amber(Colors.amber),
  orange(Colors.orange),
  deepOrange(Colors.deepOrange),
  brown(Colors.brown),
  blueGrey(Colors.blueGrey);

  final Color color;
  const ColorCode(this.color);

  String paint(String obj) => "\x1B["
      "38:2:${color.red}:${color.green}:${color.blue}"
      "m"
      "${obj.toString()}"
      "\x1B[0m";
}

mixin LogMixin {
  LoggingController get logger => LoggingController(
      runtimeType.toString(), Logger(runtimeType.toString()));
}

@riverpod
LoggingController logController(LogControllerRef ref) =>
    LoggingController('', Logger(''));

class LoggingController with LogMixin {
  LoggingController(this.name, this._logger);
  final String name;
  final Logger _logger;

  Unit fine(Object message) {
    _logger.fine(message);
    return unit;
  }

  Unit config(Object message) {
    _logger.config(message);
    return unit;
  }

  Unit info(Object message) {
    _logger.info(message);
    return unit;
  }

  Unit warn(Object message, Object? error, StackTrace? stackTrace) {
    _logger.warning(message, error, stackTrace);
    return unit;
  }

  Unit severe(Object message, Object error, StackTrace stackTrace) {
    _logger.severe(message, error, stackTrace);
    return unit;
  }

  Unit log(RequestError log) {
    switch (log.logLevel) {
      case LogLevel.finest:
        _logger.finest("$name:${log.message}", log.error, log.stackTrace);
        break;
      case LogLevel.finer:
        _logger.finer("$name:${log.message}", log.error, log.stackTrace);
        break;
      case LogLevel.fine:
        _logger.fine("$name:${log.message}", log.error, log.stackTrace);
        break;
      case LogLevel.config:
        _logger.config("$name:${log.message}", log.error, log.stackTrace);
        break;
      case LogLevel.info:
        _logger.info("$name:${log.message}", log.error, log.stackTrace);
        break;
      case LogLevel.warning:
        _logger.warning("$name:${log.message}", log.error, log.stackTrace);
        break;
      case LogLevel.severe:
        _logger.severe("$name:${log.message}", log.error, log.stackTrace);
        break;
      case LogLevel.shout:
        _logger.shout("$name:${log.message}", log.error, log.stackTrace);
        break;
      default:
        break;
    }
    return unit;
  }

  static final _levelMap = {
    LogLevel.all: Level.ALL,
    LogLevel.finest: Level.FINEST,
    LogLevel.finer: Level.FINER,
    LogLevel.fine: Level.FINE,
    LogLevel.config: Level.CONFIG,
    LogLevel.info: Level.INFO,
    LogLevel.warning: Level.WARNING,
    LogLevel.severe: Level.SEVERE,
    LogLevel.shout: Level.SHOUT,
    LogLevel.off: Level.OFF,
  };

  // static final _levelColorMap = {
  //   lg.Level.ALL.name: ColorCode.blueGrey,
  //   lg.Level.FINEST.name: ColorCode.blueGrey,
  //   lg.Level.FINER.name: ColorCode.blueGrey,
  //   lg.Level.FINE.name: ColorCode.blueGrey,
  //   lg.Level.CONFIG.name: ColorCode.yellow,
  //   lg.Level.INFO.name: ColorCode.blueGrey,
  //   lg.Level.WARNING.name: ColorCode.yellow,
  //   lg.Level.SEVERE.name: ColorCode.red,
  //   lg.Level.SHOUT.name: ColorCode.red,
  //   lg.Level.OFF.name: ColorCode.blueGrey,
  // };

  static final _levelAnsiColorMap = {
    Level.ALL.name: AnsiColorCode.white,
    Level.FINEST.name: AnsiColorCode.cyan,
    Level.FINER.name: AnsiColorCode.cyan,
    Level.FINE.name: AnsiColorCode.magenta,
    Level.CONFIG.name: AnsiColorCode.green,
    Level.INFO.name: AnsiColorCode.green,
    Level.WARNING.name: AnsiColorCode.yellow,
    Level.SEVERE.name: AnsiColorCode.red,
    Level.SHOUT.name: AnsiColorCode.red,
    Level.OFF.name: AnsiColorCode.black,
  };

  // Enable this when you want to use Sentry
  // static final _levelSentryMap = {
  //   lg.Level.FINEST.name: SentryLevel.info,
  //   lg.Level.FINER.name: SentryLevel.info,
  //   lg.Level.FINE.name: SentryLevel.info,
  //   lg.Level.CONFIG.name: SentryLevel.info,
  //   lg.Level.INFO.name: SentryLevel.info,
  //   lg.Level.WARNING.name: SentryLevel.warning,
  //   lg.Level.SEVERE.name: SentryLevel.error,
  //   lg.Level.SHOUT.name: SentryLevel.fatal,
  // };

  static void initialize(LogLevel level) {
    Logger.root.level = _levelMap[level];
    Logger.root.onRecord.listen((LogRecord record) {
      if (kDebugMode) {
        String message =
            '[${record.level.name}]: ${record.time}, name:${record.loggerName}, message:${record.message}';
        if (record.error != null) {
          message += ', error:${record.error}';
        }
        if (record.stackTrace != null) {
          message += '\n${record.stackTrace}';
        }
        print(_levelAnsiColorMap[record.level.name]?.paint(message));
      }
      // Enable this when you want to use Sentry
      // if ([lg.Level.SEVERE, lg.Level.SHOUT].contains(record.level)) {
      //   Sentry.captureException(
      //     record.error,
      //     stackTrace: record.stackTrace,
      //   );
      // } else {
      //   Sentry.captureEvent(
      //     SentryEvent(
      //       level: _levelSentryMap[record.level.name],
      //       message: SentryMessage(
      //         record.message,
      //       ),
      //       throwable: record.error,
      //     ),
      //     stackTrace: record.stackTrace ?? "",
      //   );
      // }
    });
  }

  // Enable this when you want to use Sentry
  // Future<void> setSentryConfigureScope(User user) async {
  //   await Sentry.configureScope(
  //     (scope) => scope.setUser(
  //       SentryUser(
  //         id: user.objectId,
  //         email: user.email,
  //         name: user.name,
  //       ),
  //     ),
  //   );
  // }
}
