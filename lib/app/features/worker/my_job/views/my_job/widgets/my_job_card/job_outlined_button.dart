import 'package:flutter/material.dart';

class JobOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final double fontSize;

  const JobOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = Colors.redAccent,
    this.fontSize = 16,
  });

  const JobOutlinedButton.green({
    super.key,
    required this.label,
    this.onPressed,
    this.fontSize = 15,
  }) : color = const Color(0xFF6CA34D);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
