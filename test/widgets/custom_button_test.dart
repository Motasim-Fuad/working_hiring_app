import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/core/widgets/custom_button.dart';

Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder: (_, _) => GetMaterialApp(
    translations: AppStrings(),
    locale: const Locale('en', 'US'),
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('shows text and fires onPressed when idle', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(CustomButton(text: 'Submit', onPressed: () => taps++)),
    );

    await tester.tap(find.text('Submit'));
    expect(taps, 1);
  });

  testWidgets('shows "Please wait..." and ignores taps while loading', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        CustomButton(text: 'Submit', isLoading: true, onPressed: () => taps++),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Submit'), findsNothing);
    expect(find.text('Please wait...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    expect(taps, 0);
  });

  testWidgets('outline button also blocks taps while loading', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        CustomButton(
          text: 'Cancel',
          type: ButtonType.outline,
          isLoading: true,
          loadingText: 'Cancelling...',
          onPressed: () => taps++,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Cancelling...'), findsOneWidget);
    await tester.tap(find.byType(OutlinedButton));
    expect(taps, 0);
  });
}
