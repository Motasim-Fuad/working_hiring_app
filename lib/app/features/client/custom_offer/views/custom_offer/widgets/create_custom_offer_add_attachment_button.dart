import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_hiring/app/features/client/custom_offer/controllers/custom_offer_controller.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/widgets/show_attachment_source_sheet.dart';

class CreateCustomOfferAddAttachmentButton extends StatelessWidget {
  final CustomOfferController fieldController;

  const CreateCustomOfferAddAttachmentButton({
    super.key,
    required this.fieldController,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showAttachmentSourceSheet(fieldController),
      child: Container(
        width: 80.w,
        height: 80.h,
        decoration: BoxDecoration(
          color: Color(0xFF6CA34D).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Color(0xFF6CA34D).withValues(alpha: 0.3)),
        ),
        child: Icon(Icons.add, color: Color(0xFF6CA34D), size: 28.sp),
      ),
    );
  }
}
