import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../controllers/home_controller.dart';

class HomeBanner extends GetView<HomeController> {
  HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final horizontalMargin = screenWidth >= 600 ? 32.0 : 20.0;
        final titleSize = (screenWidth * 0.065)
            .clamp(20.0, 28.0)
            .toDouble();
        final contentLeft = screenWidth >= 600 ? 28.0 : 20.0;

        return Column(
          children: [
            Center(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 900),
                margin: EdgeInsets.fromLTRB(
                  horizontalMargin,
                  20,
                  horizontalMargin,
                  0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blueGrey.shade100,
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: PageView.builder(
                      controller: controller.bannerPageController,
                      onPageChanged: controller.onBannerPageChanged,
                      itemCount: controller.bannerImages.length,
                      itemBuilder: (context, index) {
                        final imagePath = controller.bannerImages[index];

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (_, error, stackTrace) {
                                debugPrint(
                                  'Banner asset failed: $imagePath — $error',
                                );
                                return Container(
                                  color: Colors.blueGrey.shade100,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.black.withAlpha(200),
                                    Colors.black.withAlpha(0),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: contentLeft,
                              top: 0,
                              bottom: 0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.letLocal.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  Text(
                                    AppStrings.expertsHelp.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  Text(
                                    AppStrings.you.tr,
                                    style: TextStyle(
                                      color: Color(0xFF6CA34D),
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Obx(() {
              final currentIndex = controller.currentBannerIndex.value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.bannerImages.length,
                  (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 3),
                    height: 5,
                    width: currentIndex == index ? 36 : 30,
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? Color(0xFF6CA34D)
                          : Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
