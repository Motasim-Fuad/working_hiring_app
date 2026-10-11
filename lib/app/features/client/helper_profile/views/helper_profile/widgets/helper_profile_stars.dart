import 'package:flutter/material.dart';

class HelperProfileStars extends StatelessWidget {
  final double rating;
  final double size;

  const HelperProfileStars({
    super.key,
    required this.rating,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final position = index + 1;
        final icon = rating >= position
            ? Icons.star_rounded
            : rating >= position - 0.5
            ? Icons.star_half_rounded
            : Icons.star_outline_rounded;
        return Icon(icon, color: Colors.amber.shade700, size: size);
      }),
    );
  }
}
