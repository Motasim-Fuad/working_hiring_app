import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactHeight = constraints.maxHeight < 620;
            final showBadges = constraints.maxHeight >= 520;
            return ResponsiveCenter(
              maxWidth: AppResponsive.contentMaxWidth,
              padding: EdgeInsets.symmetric(
                horizontal: AppResponsive.horizontalPadding(context),
              ),
              child: Column(
                children: [
                  SizedBox(height: compactHeight ? 8 : 20),

            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.pages.length,
                  (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    height: 4,
                    width: constraints.maxWidth < 360 ? 30 : 40,
                    decoration: BoxDecoration(
                      color: controller.currentPage.value == index
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ),
            ),
                  SizedBox(height: compactHeight ? 12 : 24),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          controller.pages[index].title.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppResponsive.font(20),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: compactHeight ? 8 : 16,
                        ),
                        child: Text(
                          controller.pages[index].subTitle.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppResponsive.font(12),
                            // fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(height: compactHeight ? 8 : 20),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.r),
                            image: DecorationImage(
                              image: AssetImage(controller.pages[index].image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

                  if (showBadges) ...[
                    SizedBox(height: compactHeight ? 8 : 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTrustBadge(Icons.verified_user,
                              AppStrings.tenKVerified.tr, AppStrings.helpers.tr),
                        ),
                        Expanded(
                          child: _buildTrustBadge(Icons.shield, AppStrings.oneHundredPercent.tr,
                              AppStrings.securePayBadge.tr),
                        ),
                        Expanded(
                          child: _buildTrustBadge(Icons.star, AppStrings.ninetyNinePercent.tr,
                              AppStrings.successRate.tr),
                        ),
                      ],
                    ),
                  ],

            // Bottom Area
                  SizedBox(height: compactHeight ? 8 : 16),
                  Padding(
                    padding: EdgeInsets.only(bottom: compactHeight ? 8 : 20),
                    child: CustomButton(
                      text: AppStrings.getStarted.tr,
                      onPressed: controller.createAccount,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF6CA34D), size: AppResponsive.icon(28)),
        SizedBox(height: 4),
        Text(title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppResponsive.font(14))),
        Text(subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey, fontSize: AppResponsive.font(12))),
      ],
    );
  }
}
