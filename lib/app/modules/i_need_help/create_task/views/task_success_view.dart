// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../../core/constants/app_images.dart';
// import '../../../../core/constants/app_strings.dart';
// import '../../../../core/widgets/task_success_view/task_success_view.dart';
// import '../../../../core/widgets/contextual_warning_banner.dart';
// import '../../../../routes/app_pages.dart';
//
// class TaskSuccessView extends StatelessWidget {
//   const TaskSuccessView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(
//         0xFFCBEFB6,
//       ), // Light green background from design
//       body: SafeArea(
//         child: Stack(
//           children: [
//             TaskSuccessCoustomView(
//               imagePath: AppImages.letsGo,
//               title: AppStrings.taskPosted,
//               subTitle1: AppStrings.taskerRequestOffer,
//               subTitleNum1: '1',
//               subTitle2: AppStrings.chatAndGetItDone,
//               subTitleNum2: '2',
//               buttonTitle: AppStrings.goOrder,
//               onTap: () => Get.toNamed(Routes.DASHBOARD),
//             ),
//             const Positioned(
//               top: 16,
//               left: 0,
//               right: 0,
//               child: ContextualWarningBanner(
//                 message: "Wait sometimes for request from your nearest worker.",
//                 backgroundColor: Color(0xFFE8F5E9), // Soft green
//                 textColor: Color(0xFF2E7D32), // Dark green
//                 iconColor: Color(0xFF4CAF50),
//                 icon: Icons.info,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
