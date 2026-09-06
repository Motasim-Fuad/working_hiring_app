import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/worker_home_controller.dart';

class ProposalModal extends StatelessWidget {
  ProposalModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.shortBio.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              CustomTextField(
                hintText: AppStrings.tellYourWorkExp.tr,
                maxLines: 4,
              ),

              SizedBox(height: 16),
              Text(
                AppStrings.proposedBudget.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              CustomTextField(
                hintText: '\$90',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  Get.find<WorkerHomeController>().proposedBudget.value = value;
                },
              ),
              SizedBox(height: 4),
              Obx(() {
                final controller = Get.find<WorkerHomeController>();
                final budget = controller.clientPays;
                final fee = controller.serviceFee;
                final revenue = controller.workerRevenue;
                if (budget == 0) {
                  return Text(
                    "+ 20% Platform Fee".tr,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                  'Provider Receives'.trParams({
                    'amount': '\$${revenue.toStringAsFixed(2)}',
                  }),
                      style: TextStyle(
                        color: Color(0xFF7CB342),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                  'Platform Fee Value'.trParams({
                    'amount': '\$${fee.toStringAsFixed(2)}',
                  }),
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                  'Client Pays Total'.trParams({
                    'amount': '\$${budget.toStringAsFixed(2)}',
                  }),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }),

              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: AppStrings.submitRequest.tr,
                  onPressed: () => Get.back(),
                  backgroundColor: Color(0xFF7CB342),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
