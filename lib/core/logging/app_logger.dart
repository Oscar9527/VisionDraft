import 'package:logger/logger.dart';

class AppLogger {
  AppLogger() : _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  final Logger _logger;

  void info(String message) => _logger.i(message);

  void warn(String message) => _logger.w(message);

  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
