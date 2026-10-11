import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:working_hiring/app/core/constants/app_images.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/onboarding/models/onboarding_model.dart';
export 'package:working_hiring/app/features/onboarding/models/onboarding_model.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  Timer? _timer;

  late final List<OnboardingModel> pages = [
    OnboardingModel(
      image: AppImages.onboarding1,
      title: AppStrings.findTrustedHelp,
      subTitle: AppStrings.onBoardingSubTitle1,
    ),
    OnboardingModel(
      image: AppImages.onboarding2,
      title: AppStrings.postTasks,
      subTitle: AppStrings.onBoardingSubTitle2,
    ),
    OnboardingModel(
      image: AppImages.onboarding3,
      title: AppStrings.chatTrackGet,
      subTitle: AppStrings.onBoardingSubTitle3,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _startAutoPlay();
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (currentPage.value < pages.length - 1) {
        currentPage.value++;
      } else {
        currentPage.value = 0;
      }

      if (pageController.hasClients) {
        pageController.animateToPage(
          currentPage.value,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void createAccount() {
    Get.toNamed('/sign-up');
  }

  void signIn() {
    Get.toNamed('/sign-in');
  }
}
