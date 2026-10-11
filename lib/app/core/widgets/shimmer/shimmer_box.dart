import 'package:flutter/material.dart';

/// A solid placeholder block; must be placed inside an [AppShimmer].
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final BoxShape shape;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
    this.shape = BoxShape.rectangle,
  });

  const ShimmerBox.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = 0,
      shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(radius),
      ),
    );
  }
}
