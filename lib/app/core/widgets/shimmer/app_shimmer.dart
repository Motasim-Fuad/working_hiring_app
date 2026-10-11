import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Wraps a skeleton layout built from [ShimmerBox]es with the app's shimmer
/// colors. Each page composes its own skeleton that mirrors its real layout.
class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  static const Color baseColor = Color(0xFFEBEBEB);
  static const Color highlightColor = Color(0xFFF7F7F7);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1300),
      child: child,
    );
  }
}
