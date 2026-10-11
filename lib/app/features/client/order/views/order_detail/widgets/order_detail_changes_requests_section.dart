import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/client/order/views/order_detail/widgets/order_detail_helpers.dart';

class OrderDetailChangesRequestsSection extends StatelessWidget {
  final List<ChangesRequestModel> requests;

  const OrderDetailChangesRequestsSection({super.key, required this.requests});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Change Requests'.tr,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        ...requests.map((req) {
          return Card(
            margin: EdgeInsets.only(bottom: 8.h),
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (req.requestType != null)
                    Text(
                      'Type Value'.trParams({'type': '${req.requestType}'}),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (req.status != null)
                    Text(
                      'Status Value'.trParams({'status': req.status!.tr}),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: getStatusColor(req.status!),
                      ),
                    ),
                  if (req.message != null)
                    Text(
                      'Message Value'.trParams({'message': '${req.message}'}),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  if (req.proposedDate != null)
                    Text(
                      'Proposed Date Value'.trParams({
                        'date': '${req.proposedDate}',
                      }),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  if (req.proposedTime != null)
                    Text(
                      'Proposed Time Value'.trParams({
                        'time': '${req.proposedTime}',
                      }),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  if (req.proposedAmount != null)
                    Text(
                      'Proposed Amount Value'.trParams({
                        'amount': formatCurrency(req.proposedAmount!),
                      }),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
