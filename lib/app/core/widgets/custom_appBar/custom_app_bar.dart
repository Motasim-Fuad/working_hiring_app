import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../responsive_layout.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final IconData? icons;
  final VoidCallback? onPressed;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showLeading;
  final double toolbarHeight;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.onPressed,
    this.icons,
    this.bottom,
    this.showLeading = true,
    this.toolbarHeight = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        toolbarHeight: toolbarHeight,
        title: title != null
            ? Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppResponsive.font(18),
                ),
              )
            : null,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: showLeading
            ? IconButton(
                icon: Icon(
                  icons ?? Icons.keyboard_arrow_left,
                  color: AppColors.textPrimary,
                  size: AppResponsive.icon(30),
                ),
                onPressed: onPressed ?? () => Get.back(),
              )
            : null,
        actions: actions,
        bottom: bottom,
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
