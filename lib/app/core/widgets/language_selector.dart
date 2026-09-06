import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import '../constants/app_strings.dart';
import 'responsive_layout.dart';

class LanguageSelector extends StatelessWidget {
  LanguageSelector({super.key, this.isHomeView = false});
  final bool isHomeView;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final iconOnly = isHomeView && constraints.maxWidth < 72;
        return Container(
      padding: EdgeInsets.symmetric(
        horizontal: iconOnly ? 6 : (isHomeView ? 8 : 16),
        vertical: isHomeView ? 8 : 12,
      ),
      decoration: BoxDecoration(
        border: isHomeView ? null : Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(isHomeView ? 25.r : 12.r),
        color: isHomeView ? Color(0xFFF0F0F0) : Colors.transparent,
        boxShadow: isHomeView
            ? [
          BoxShadow(
            color: Colors.black.withAlpha(13), // ~0.05 opacity
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ]
            : null,
      ),
      child: InkWell(
        onTap: () {
          _showLanguageBottomSheet(context);
        },
        child: Row(
          children: [
            ClipOval(
              child: SvgPicture.asset(
                Get.locale?.languageCode == 'zh'
                    ? AppIcons.flagZh
                    : AppIcons.flagEn,
                width: AppResponsive.icon(isHomeView ? 16 : 24),
                height: AppResponsive.icon(isHomeView ? 16 : 24),
                fit: BoxFit.cover, // Ensures the flag fills the 24x24 circle
              ),
            ),
            if (!iconOnly) SizedBox(width: isHomeView ? 6 : 12),
            if (!iconOnly) Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                isHomeView
                    ? SizedBox()
                    : Text(
                  AppStrings.selectLanguage.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  Get.locale?.languageCode == 'zh'
                      ? AppStrings.chinese.tr
                      : AppStrings.english.tr,
                  style: TextStyle(
                    fontSize: AppResponsive.font(isHomeView ? 12 : 16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                ],
              ),
            ),
            if (!iconOnly) SizedBox(width: 2),
            if (!iconOnly) Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
              size: AppResponsive.icon(isHomeView ? 18 : 24),
            ),
          ],
        ),
      ),
        );
      },
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final box = GetStorage();
    Get.bottomSheet(
      Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppResponsive.formMaxWidth),
          child: Container(
        color: Colors.white,
        child: SafeArea(
          bottom: true,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Wrap(
              children: [
                ListTile(
                  leading: SvgPicture.asset(AppIcons.flagEn, width: 24.sp),
                  title: Text(AppStrings.english.tr),
                  onTap: () {
                    Get.updateLocale(Locale('en', 'US'));
                    box.write('lang', 'en');
                    Get.back();
                  },
                ),
                ListTile(
                  leading: SvgPicture.asset(AppIcons.flagZh, width: 24.sp),
                  title: Text('${AppStrings.chinese.tr} (${AppStrings.simplified.tr})'),
                  onTap: () {
                    Get.updateLocale(Locale('zh', 'CN'));
                    box.write('lang', 'zh');
                    Get.back();
                  },
                ),
              ],
            ), // Closes Wrap
          ), // Closes Padding
        ), // Closes SafeArea
          ),
        ),
      ),
    ); // Closes Get.bottomSheet
  }
}
