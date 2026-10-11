import 'package:flutter/material.dart';

import 'package:working_hiring/app/core/widgets/shimmer/app_shimmer.dart';

/// Repeats a page-specific skeleton [itemBuilder] under a single shimmer.
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const ShimmerList({
    super.key,
    required this.itemBuilder,
    this.itemCount = 6,
    this.padding = EdgeInsets.zero,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: spacing),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
