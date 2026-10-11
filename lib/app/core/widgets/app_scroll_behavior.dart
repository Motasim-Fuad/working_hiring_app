import 'package:flutter/material.dart';

/// Bouncing scroll physics everywhere for a consistent, smooth feel.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics();
}
