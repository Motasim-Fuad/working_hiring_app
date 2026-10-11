part of 'saved_helpers_view.dart';

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
      Get.put(
        HelperListController(
          Get.find<HelperRepository>(),
          Get.find<CategoryRepository>(),
        ),
      );
    }
    controller = Get.find<HelperListController>();
    controller.loadSavedHelpers();
  }

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
          return const SavedHelpersShimmer();
        }

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
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  itemCount: controller.savedHelpers.length,
                  itemBuilder: (context, index) {
                    final entry = controller.savedHelpers[index];
                    return SavedHelpersSavedCard(
                      entry: entry,
                      onRemove: _confirmRemove,
                    );
                  },
                ),
        );
      }),
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
          TextButton(onPressed: () => Get.back(), child: Text('Cancel'.tr)),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await Get.find<HelperRepository>().removeSavedHelper(
                  entry.entryId,
                  profileType: 'customer',
                );
                await controller.loadSavedHelpers();
              } catch (e) {
                Get.snackbar(
                  'Error'.tr,
                  'Could not remove helper.'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: Text('Remove'.tr, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
