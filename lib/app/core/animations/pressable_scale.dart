import 'package:flutter/material.dart';

import 'package:working_hiring/app/core/animations/app_curves.dart';
import 'package:working_hiring/app/core/animations/app_durations.dart';

part 'pressable_scale_state.dart';

/// Slightly shrinks [child] while pressed for tactile feedback on cards/tiles.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}
