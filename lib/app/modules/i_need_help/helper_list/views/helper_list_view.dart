// lib/modules/i_need_help/helper_list/views/helper_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/helper_repository.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../controllers/helper_list_controller.dart';
import '../../../message/views/chat_view.dart';
import '../../../message/controllers/message_controller.dart';
import '../../custom_offer/views/custom_offer_view.dart';
import '../../../../data/repositories/availability_repository.dart';

class HelperListView extends StatefulWidget {
  HelperListView({super.key});

  @override
  State<HelperListView> createState() => _HelperListViewState();
}

class _HelperListViewState extends State<HelperListView> {
  final HelperListController controller = Get.find<HelperListController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreHelpers();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openChat(helper) async {
    try {
      if (!Get.isRegistered<MessageController>()) {
        if (!Get.isRegistered<AvailabilityRepository>()) {
          Get.put(AvailabilityRepository(Get.find()));
        }
        Get.put(MessageController(
          Get.find<ChatRepository>(),
          Get.find<OrderRepository>(),
          Get.find<AvailabilityRepository>(),
        ));
      }
      final msgCtrl = Get.find<MessageController>();

      final room = await Get.find<ChatRepository>().startChat(helper.id);

      await msgCtrl.loadRooms();
      ChatModel chat;
      try {
        chat = msgCtrl.chats.firstWhere((c) => c.roomUuid == room.uuid);
      } catch (_) {
        chat = ChatModel(
          name: helper.name,
          avatar: helper.avatarUrl,
          lastMessage: '',
          timeAgo: 'Just now'.tr,
          roomUuid: room.uuid,
          roomId: room.id,
        );
        msgCtrl.chats.add(chat);
      }

      Get.to(() => ChatView(chat: chat));
    } catch (e) {
      Get.snackbar('Error'.tr, 'Could not start chat. Please try again.'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: controller.categoryName.value),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildSortSection(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadHelpers,
              color: Color(0xFF6CA34D),
              child: Obx(() {
                if (controller.displayedHelpers.isEmpty) {
                  return Center(
                      child: Text("No helpers match your filter criteria.".tr,
                          style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  itemCount: controller.displayedHelpers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == controller.displayedHelpers.length) {
                      return Obx(() {
                        if (controller.isLoadingMore.value) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF6CA34D))),
                          );
                        }
                        return SizedBox.shrink();
                      });
                    }
                    final helper = controller.displayedHelpers[index];
                    return _buildHelperCard(helper);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 10.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchTextController,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                controller.onSearchChanged(value);
              },
              onSubmitted: (value) {
                controller.searchTextController.text = value.trim();
                controller.searchQuery.value = value.trim();
                controller.loadHelpers();
              },
              decoration: InputDecoration(
                hintText: "Search in this category...".tr,
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    controller.searchTextController.clear();
                    controller.searchQuery.value = '';
                    controller.loadHelpers();
                  },
                )
                    : SizedBox.shrink()),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          OutlinedButton.icon(
            onPressed: () {
              controller.tempMaxDistance.value = controller.maxDistance.value;
              controller.tempMinRating.value = controller.minRating.value;
              controller.tempSelectedCategoryFilter.value =
                  controller.selectedCategoryFilter.value;
              controller.tempSelectedDate.value = controller.selectedDate.value;
              controller.tempSelectedTime.value = controller.selectedTime.value;
              controller.tempLocation.value = controller.location.value;
              controller.tempMinBudget.value = controller.minBudget.value;
              controller.tempMaxBudget.value = controller.maxBudget.value;
              controller.tempShowAvailableOnly.value =
                  controller.showAvailableOnly.value;

              Get.bottomSheet(
                ExtendedFilterBottomSheet(),
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
              );
            },
            icon: Icon(Icons.tune, size: 18.sp),
            label: Text(
              'Filter'.tr,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Color(0xFFE8F8F5),
              foregroundColor: Colors.black87,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              side: BorderSide(color: Color(0xFFA3D5C0), width: 1.2),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => Text(
              'Helpers Found'.trParams({
                'count': '${controller.displayedHelpers.length}',
              }),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  color: Colors.black87),
            )),
          ),
          SizedBox(width: 8.w),
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: PopupMenuButton<String>(
              offset: Offset(0, 35),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              elevation: 4,
              color: Colors.white,
              onSelected: (val) {
                controller.selectedSort.value = val;
                controller.applySort();
              },
              itemBuilder: (context) => [
                _buildSortMenuItem("Rating (High-Low)", Icons.star_rounded),
                _buildSortMenuItem("Price (Low-High)", Icons.attach_money_rounded),
                _buildSortMenuItem("Distance (Nearest)", Icons.location_on_rounded),
              ],
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => Text(
                      controller.selectedSort.value.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Color(0xFF6CA34D),
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp),
                    )),
                    SizedBox(width: 4.w),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF6CA34D), size: 20.sp),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(String value, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Obx(() {
        final isSelected = controller.selectedSort.value == value;
        return Row(
          children: [
            Icon(
                icon,
                size: 18.sp,
                color: isSelected ? Color(0xFF6CA34D) : Colors.grey.shade500),
            SizedBox(width: 10.w),
            Text(
                value.tr,
                style: TextStyle(
                    fontSize: 14.sp,
                    color: isSelected ? Color(0xFF6CA34D) : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
          ],
        );
      }),
    );
  }

  Widget _buildHelperCard(HelperListModel helper) {
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
          children: [
            // Top Section (Category & Availability + Save Button)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    controller.categoryName.value,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Obx(() {
                  final isSaved =
                  controller.savedHelperMap.containsKey(helper.id);
                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? Color(0xFF6CA34D) : Colors.grey,
                      size: 24.sp,
                    ),
                    onPressed: () => controller.toggleSaveHelper(helper),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  );
                }),
              ],
            ),
            SizedBox(height: 16.h),

            // Profile Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            helper.rating!.toStringAsFixed(1),
                            style: TextStyle(
                                fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Tasks Count Parenthesized'.trParams({
                              'count': '${helper.totalTasks}',
                            }),
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.redAccent, size: 14.sp),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              helper.distance != null
                                  ? 'Location With Distance'.trParams({
                                      'location':
                                          helper.location ?? 'N/A'.tr,
                                      'distance': '${helper.distance}',
                                    })
                                  : helper.location ?? 'N/A'.tr,
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (helper.distance != null)
                  Text(
                    'Distance Kilometers'.trParams({
                      'distance': '${helper.distance!.toInt()}',
                    }),
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500),
                  ),
              ],
            ),
            SizedBox(height: 12.h),

            // Details Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 16.sp, color: Colors.grey),
                    SizedBox(width: 6.w),
                    Text(
                        helper.totalTasks != null
                            ? 'Tasks Count'.trParams({
                                'count': '${helper.totalTasks}',
                              })
                            : "No tasks yet".tr,
                        style: TextStyle(
                            fontSize: 12.sp, color: Colors.grey.shade700)),
                    SizedBox(width: 16.w),
                    Icon(Icons.verified, size: 16.sp, color: Colors.green),
                    SizedBox(width: 6.w),
                    Text(
                        (helper.isVerified == true
                                ? "Verified"
                                : "Unverified")
                            .tr,
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: helper.isVerified == true
                                ? Colors.green
                                : Colors.grey.shade700)),
                    Spacer(),
                    Text(
                        helper.hourlyRate != null
                            ? 'Rate Per Hour'.trParams({
                                'amount':
                                    '\$${helper.hourlyRate!.toInt()}',
                              })
                            : "N/A".tr,
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6CA34D))),
                  ],
                ),
                SizedBox(height: 12.h),

                Text(
                  helper.bio ??
                      'Service Provider In'.trParams({
                        'category': controller.categoryName.value,
                      }),
                  style: TextStyle(
                      fontSize: 13.sp, color: Colors.grey.shade600, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "See more".tr,
                    style: TextStyle(
                        fontSize: 13.sp,
                        color: Color(0xFF6CA34D),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Availability Badge
            Obx(() {
              if (controller.requestedDate.value != null) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Color(0xFFCBEFB6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            color: Color(0xFF2E7D32), size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          "Available on your date".tr,
                          style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }),

            SizedBox(height: 4.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _openChat(helper),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      minimumSize: Size(double.infinity, 48.h),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Send Message'.tr,
                      style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(
                            () => CreateCustomOfferView(),
                        arguments: {
                          'workerID': helper.id.toString(),
                          'workerName': helper.name,
                          'workerAvatar': helper.avatarUrl,
                          'categoryID': controller.categoryName.value,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Color(0xFF6CA34D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      minimumSize: Size(double.infinity, 48.h),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Send Request'.tr,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14.sp),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ✅ ExtendedFilterBottomSheet – reused from your original code
// ============================================================
class ExtendedFilterBottomSheet extends StatelessWidget {
  ExtendedFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HelperListController>();
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Detailed Filters".tr,
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close),
                )
              ],
            ),
            SizedBox(height: 24.h),

            // Category
            Text("Category ".tr,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Obx(() => SizedBox(
              height: 40.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.availableCategories.length + 1,
                separatorBuilder: (context, index) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isSelected =
                        controller.tempSelectedCategoryFilter.value ==
                            'All Categories';
                    return ChoiceChip(
                      label: Text('All Categories'.tr),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          controller.tempSelectedCategoryFilter.value =
                          'All Categories';
                          controller.applyFilters();
                        }
                      },
                      selectedColor: Color(0xFF6CA34D),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        side: BorderSide(
                          color: isSelected
                              ? Color(0xFF6CA34D)
                              : Colors.grey.shade300,
                        ),
                      ),
                      showCheckmark: false,
                    );
                  }
                  final category =
                  controller.availableCategories[index - 1];
                  final catName = category.title ?? '';
                  return Obx(() {
                    final isSelected =
                        controller.tempSelectedCategoryFilter.value ==
                            catName;
                    return ChoiceChip(
                      label: Text(catName),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          controller.tempSelectedCategoryFilter.value =
                              catName;
                          controller.applyFilters();
                        } else {
                          controller.tempSelectedCategoryFilter.value = '';
                          controller.applyFilters();
                        }
                      },
                      selectedColor: Color(0xFF6CA34D),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        side: BorderSide(
                          color: isSelected
                              ? Color(0xFF6CA34D)
                              : Colors.grey.shade300,
                        ),
                      ),
                      showCheckmark: false,
                    );
                  });
                },
              ),
            )),

            SizedBox(height: 24.h),
            // Date
            Text("Date".tr,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Obx(() => TextFormField(
              decoration: InputDecoration(
                hintText: controller.tempSelectedDate.value != null
                    ? "${controller.tempSelectedDate.value!.year}-${controller.tempSelectedDate.value!.month.toString().padLeft(2, '0')}-${controller.tempSelectedDate.value!.day.toString().padLeft(2, '0')}"
                    : "Select Date".tr,
                hintStyle: TextStyle(
                    color: controller.tempSelectedDate.value != null
                        ? Colors.black87
                        : Colors.grey),
                prefixIcon: Icon(Icons.calendar_today,
                    size: 18.sp, color: Colors.grey),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                contentPadding:
                EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
              ),
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: controller.tempSelectedDate.value ??
                      DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Color(0xFF6CA34D),
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  controller.tempSelectedDate.value = picked;
                }
              },
            )),
            SizedBox(height: 20.h),

            // Time
            Text("Time".tr,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Obx(() => TextFormField(
              decoration: InputDecoration(
                hintText: controller.tempSelectedTime.value != null
                    ? controller.tempSelectedTime.value!.format(context)
                    : "Select Time".tr,
                hintStyle: TextStyle(
                    color: controller.tempSelectedTime.value != null
                        ? Colors.black87
                        : Colors.grey),
                prefixIcon: Icon(Icons.access_time,
                    size: 18.sp, color: Colors.grey),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                contentPadding:
                EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
              ),
              readOnly: true,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime:
                  controller.tempSelectedTime.value ?? TimeOfDay.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Color(0xFF6CA34D),
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  controller.tempSelectedTime.value = picked;
                }
              },
            )),
            SizedBox(height: 20.h),

            // Location
            Text("Location".tr,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Obx(() => TextFormField(
              key: Key(controller.tempLocation.value),
              initialValue: controller.tempLocation.value,
              onChanged: (val) => controller.tempLocation.value = val,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.location_on,
                    size: 18.sp, color: Colors.redAccent),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                contentPadding:
                EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
              ),
            )),
            SizedBox(height: 8.h),
            Container(
              height: 120.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 40.sp, color: Colors.grey),
                    SizedBox(height: 4.h),
                    Text("Interactive Map Area".tr,
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Budget
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Budget".tr,
                    style:
                    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                Obx(() => Text(
                    "\$${controller.tempMinBudget.value.toInt()} - \$${controller.tempMaxBudget.value.toInt()}+",
                    style: TextStyle(
                        color: Color(0xFF6CA34D), fontWeight: FontWeight.bold))),
              ],
            ),
            SizedBox(height: 8.h),
            Obx(() => RangeSlider(
              values: RangeValues(
                  controller.tempMinBudget.value,
                  controller.tempMaxBudget.value),
              min: 10,
              max: 200,
              activeColor: Color(0xFF6CA34D),
              inactiveColor: Colors.grey.shade200,
              onChanged: (values) {
                controller.tempMinBudget.value = values.start;
                controller.tempMaxBudget.value = values.end;
              },
            )),
            SizedBox(height: 20.h),

            // Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Minimum Rating".tr,
                    style:
                    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                Obx(() => Text(
                    "${controller.tempMinRating.value.toStringAsFixed(1)} ⭐️",
                    style: TextStyle(
                        color: Colors.amber, fontWeight: FontWeight.bold))),
              ],
            ),
            SizedBox(height: 8.h),
            Obx(() => Slider(
              value: controller.tempMinRating.value,
              min: 1.0,
              max: 5.0,
              divisions: 8,
              activeColor: Colors.amber,
              inactiveColor: Colors.grey.shade200,
              onChanged: (value) => controller.tempMinRating.value = value,
            )),
            SizedBox(height: 20.h),

            // Availability Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Show Available Only".tr,
                    style:
                    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                Obx(() => Switch(
                  value: controller.tempShowAvailableOnly.value,
                  onChanged: (val) {
                    controller.tempShowAvailableOnly.value = val;
                  },
                  activeColor: Color(0xFF6CA34D),
                )),
              ],
            ),
            SizedBox(height: 32.h),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.applyFilters();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6CA34D),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
                child: Text("Apply Filters".tr,
                    style:
                    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
