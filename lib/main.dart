import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'app/core/constants/app_strings.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/service/order_event_bus.dart';
import 'app/service/websocket_service.dart';

double _responsiveFontSize(num fontSize, ScreenUtil instance) {
  final width = instance.screenWidth;

  // Preserve the original ScreenUtil behaviour on phones. On wider screens,
  // increase typography only slightly instead of scaling it with full width.
  if (width >= 1024) return fontSize.toDouble() * 1.08;
  if (width >= 600) return fontSize.toDouble() * 1.04;
  return fontSize.toDouble() * instance.scaleWidth;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await dotenv.load(fileName: ".env");
  Get.put(OrderEventBus(), permanent: true);
  Get.put(WebSocketService(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      fontSizeResolver: _responsiveFontSize,
      builder: (context, child) => GetMaterialApp(
        onGenerateTitle: (_) => AppStrings.appName.tr,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        translations: AppStrings(),
        locale: GetStorage().read<String>('lang') == 'zh'
            ? const Locale('zh', 'CN')
            : const Locale('en', 'US'),
        fallbackLocale: const Locale('en', 'US'),
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          final textScale = media.textScaler.scale(1).clamp(0.9, 1.3);
          return MediaQuery(
            data: media.copyWith(textScaler: TextScaler.linear(textScale)),
            child: ResponsiveBreakpoints.builder(
              child: child ?? const SizedBox.shrink(),
              breakpoints: const [
                Breakpoint(start: 0, end: 599, name: MOBILE),
                Breakpoint(start: 600, end: 1023, name: TABLET),
                Breakpoint(start: 1024, end: 1919, name: DESKTOP),
                Breakpoint(start: 1920, end: double.infinity, name: '4K'),
              ],
            ),
          );
        },
      ),
    );
  }
}
