import 'package:flutter/material.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';

class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = AppResponsive.formMaxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: AppResponsive.horizontalPadding(context),
              ),
          child: child,
        ),
      ),
    );
  }
}
