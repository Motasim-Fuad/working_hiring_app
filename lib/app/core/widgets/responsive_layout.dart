import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class AppResponsive {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double formMaxWidth = 600;
  static const double contentMaxWidth = 760;
  static const double wideContentMaxWidth = 1200;

  static Size size(BuildContext context) => MediaQuery.sizeOf(context);

  static bool isCompact(BuildContext context) =>
      size(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = size(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      size(context).width >= tabletBreakpoint;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  static double horizontalPadding(BuildContext context) {
    final width = size(context).width;
    if (width >= tabletBreakpoint) return 32;
    if (width >= mobileBreakpoint) return 28;
    return width < 360 ? 16 : 24;
  }

  static double font(double designSize) =>
      designSize.sp.clamp(designSize * 0.88, designSize * 1.18).toDouble();

  static double icon(double designSize) =>
      designSize.sp.clamp(designSize * 0.9, designSize * 1.2).toDouble();

  static double height(double designSize, {double? min, double? max}) {
    final lower = min ?? designSize * 0.82;
    final upper = max ?? designSize * 1.2;
    return designSize.h.clamp(lower, upper).toDouble();
  }

  static double spacing(double designSize) =>
      designSize.h.clamp(designSize * 0.65, designSize * 1.15).toDouble();

  static double availableContentHeight(BuildContext context) {
    final media = MediaQuery.of(context);
    return math.max(
      0,
      media.size.height -
          media.padding.vertical -
          media.viewInsets.bottom,
    );
  }
}

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
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: AppResponsive.horizontalPadding(context),
              ),
          child: child,
        ),
      ),
    );
  }
}
