import 'package:flutter/material.dart';

import 'package:working_hiring/app/core/widgets/responsive_layout.dart';

class ButtonLabel extends StatelessWidget {
  final String text;
  final Color color;

  const ButtonLabel({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: AppResponsive.font(16),
          fontWeight: FontWeight.w600,
          height: 1.0,
        ),
      ),
    );
  }
}
