import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';

class ProfileMenuItem extends StatelessWidget {
  final dynamic icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = AppResponsive.icon(24);
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      minLeadingWidth: 32,
      minVerticalPadding: 10,
      onTap: onTap,
      leading: SizedBox.square(
        dimension: 32,
        child: Center(
          child: icon is IconData
              ? Icon(icon, color: Colors.black87, size: iconSize)
              : SvgPicture.asset(
                  icon,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    Colors.black87,
                    BlendMode.srcIn,
                  ),
                ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: AppResponsive.font(16),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: AppResponsive.icon(16),
        color: Color(0xFFBDBDBD),
      ),
    );
  }
}
