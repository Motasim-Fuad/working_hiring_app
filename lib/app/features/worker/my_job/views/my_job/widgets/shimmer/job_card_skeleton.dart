import 'package:flutter/material.dart';

import 'package:working_hiring/app/core/widgets/shimmer/shimmer_box.dart';

/// Mirrors a job card: title + badge, category, customer, address/schedule
/// with amount on the right, then the action button row.
class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(child: ShimmerBox(height: 16, radius: 6)),
              SizedBox(width: 48),
              ShimmerBox(width: 84, height: 28, radius: 20),
            ],
          ),
          const SizedBox(height: 14),
          const ShimmerBox(width: 110, height: 12, radius: 6),
          const SizedBox(height: 12),
          const ShimmerBox(width: 160, height: 12, radius: 6),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 200, height: 12, radius: 6),
                    SizedBox(height: 12),
                    ShimmerBox(width: 170, height: 12, radius: 6),
                  ],
                ),
              ),
              const ShimmerBox(width: 56, height: 24, radius: 6),
            ],
          ),
          const SizedBox(height: 16),
          const ShimmerBox(height: 46, radius: 12),
        ],
      ),
    );
  }
}
