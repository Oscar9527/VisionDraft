import 'package:flutter/widgets.dart';

abstract final class AppBreakpoints {
  static const double tablet = 720;
  static const double desktop = 1100;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;
}
