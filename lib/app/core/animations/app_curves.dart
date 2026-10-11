import 'package:flutter/animation.dart';

abstract final class AppCurves {
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve press = Curves.easeOut;
}
