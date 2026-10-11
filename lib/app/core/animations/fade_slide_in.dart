import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:working_hiring/app/core/animations/app_curves.dart';
import 'package:working_hiring/app/core/animations/app_durations.dart';

part 'fade_slide_in_state.dart';

/// Fades and slides [child] in once when first built.
///
/// Pass [index] for list items to get a staggered entrance; the delay is
/// capped so long lists do not wait noticeably before rendering.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Offset beginOffset;
  final Duration duration;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.beginOffset = const Offset(0, 0.06),
    this.duration = AppDurations.medium,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}
