import 'package:logger/logger.dart';

class LoggingUtil {
  final logger = Logger(
    printer: PrettyPrinter(),
  );

  static void logInfor(String message) {
    Logger().i(message);
  }

  static void logDebug(String message) {
    Logger().d(message);
  }

  static void logWarning(String message) {
    Logger().w(message);
  }

  static void logError(String message) {
    Logger().e(message);
  }
}
