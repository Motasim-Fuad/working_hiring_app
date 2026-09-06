// lib/modules/i_need_help/saved_helpers/views/saved_helpers_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/modules/i_need_help/helper_list/controllers/helper_list_controller.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../../data/models/saved_helper_model.dart';
import '../../../../data/repositories/helper_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../routes/app_pages.dart';

class SavedHelpersView extends StatefulWidget {
  SavedHelpersView({super.key});

  @override
  State<SavedHelpersView> createState() => _SavedHelpersViewState();
}

class _SavedHelpersViewState extends State<SavedHelpersView> {
  late HelperListController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<HelperRepository>()) {
      Get.put(HelperRepository(Get.find()));
    }
    if (!Get.isRegistered<CategoryRepository>()) {
      Get.put(CategoryRepository(Get.find()));
    }
    if (!Get.isRegistered<HelperListController>()) {
      Get.put(HelperListController(
        Get.find<HelperRepository>(),
        Get.find<CategoryRepository>(),
      ));
    }
    controller = Get.find<HelperListController>();
    controller.loadSavedHelpers();
  }

  // Pull‑to‑refresh callback
  Future<void> _onRefresh() async {
    await controller.loadSavedHelpers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Saved Helpers".tr),
      body: Obx(() {
        if (controller.isLoadingSaved.value) {
          return Center(child: CircularProgressIndicator());
        }

        // Always wrap with RefreshIndicator so pull‑to‑refresh works even when empty.
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: Color(0xFF6CA34D),
          child: controller.savedHelpers.isEmpty
              ? ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 200),
              Center(child: Text('No saved helpers yet.'.tr)),
            ],
          )
              : ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            itemCount: controller.savedHelpers.length,
            itemBuilder: (context, index) {
              final entry = controller.savedHelpers[index];
              return _buildSavedCard(entry);
            },
          ),
        );
      }),
    );
  }

  Widget _buildSavedCard(SavedHelperEntry entry) {
    final helper = entry.helper;
    return GestureDetector(
      onTap: () => controller.navigateToProfile(helper),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26.r,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: helper.avatarUrl.isNotEmpty
                      ? NetworkImage(helper.avatarUrl)
                      : null,
                  child: helper.avatarUrl.isEmpty
                      ? Icon(Icons.person, color: Colors.grey, size: 26.sp)
                      : null,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        helper.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            helper.rating?.toStringAsFixed(1) ?? 'N/A',
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                              'Tasks Count Parenthesized'.trParams({
                                'count': '${helper.totalTasks ?? 0}',
                              }),
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      if (helper.location != null)
                        Text(
                          helper.location!,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 24.sp),
                  onPressed: () {
                    _confirmRemove(entry);
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (helper.categories != null)
              Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: helper.categories!.map((cat) {
                  return Chip(
                    label: Text(cat, style: TextStyle(fontSize: 12.sp)),
                    backgroundColor: Color(0xFFE8F8F5),
                    labelStyle: TextStyle(color: Color(0xFF2E7D32), fontSize: 12.sp),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            if (helper.hourlyRate != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                              'Rate Per Hour'.trParams({
                                'amount': '\$${helper.hourlyRate!.toInt()}',
                              }),
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Color(0xFF6CA34D)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(SavedHelperEntry entry) {
    Get.dialog(
      AlertDialog(
        title: Text('Remove Helper'.tr),
        content: Text(
          'Remove saved helper confirmation'.trParams({
            'name': entry.helper.name,
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await Get.find<HelperRepository>().removeSavedHelper(entry.entryId, profileType: 'customer');
                await controller.loadSavedHelpers();
              } catch (e) {
                Get.snackbar('Error'.tr, 'Could not remove helper.'.tr, snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: Text('Remove'.tr, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
