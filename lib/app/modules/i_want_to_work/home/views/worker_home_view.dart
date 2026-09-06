import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:working_hiring/app/modules/i_need_help/home/controllers/home_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/home_header.dart';
import '../controllers/worker_home_controller.dart';
import '../../../../data/repositories/category_repository.dart';   // adjust path
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/repositories/helper_repository.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../core/widgets/responsive_layout.dart';

class WorkerHomeView extends StatefulWidget {
  WorkerHomeView({super.key});

  @override
  State<WorkerHomeView> createState() => _WorkerHomeViewState();
}

class _WorkerHomeViewState extends State<WorkerHomeView> {
  late final WorkerHomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<WorkerHomeController>();

    // ✅ Ensure HomeController is registered and its address is loaded
    _ensureHomeControllerReady();

    // Delay the worker data load to allow the address to be ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          controller.loadInitialData();
        }
      });
    });
  }

  // ----------------------------------------------------------------------
  // Ensure HomeController is available and its address is loaded
  // ----------------------------------------------------------------------
  Future<void> _ensureHomeControllerReady() async {
    // If HomeController is not already registered, put it.
    if (!Get.isRegistered<HomeController>()) {
      // You need to pass its dependencies – adapt to your actual injection.
      // For example:
      final homeController = Get.put(HomeController(
        Get.find<CategoryRepository>(),
        Get.find<UserRepository>(),
        Get.find<HelperRepository>(),
        Get.find<OrderRepository>(),
      ));
      // Load addresses if not already loaded.
      if (homeController.userAddresses.isEmpty) {
        await homeController.loadAddresses();
      }
    } else {
      // Already registered – but if address is empty, load it.
      final homeCtrl = Get.find<HomeController>();
      if (homeCtrl.userAddresses.isEmpty) {
        await homeCtrl.loadAddresses();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(),
            Expanded(
              child: RefreshIndicator(
                color: Color(0xFF6CA34D),
                onRefresh: () => controller.loadInitialData(),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: ResponsiveCenter(
                    maxWidth: AppResponsive.contentMaxWidth,
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        _buildDailyAvailableTime(),
                        SizedBox(height: 20.h),
                        _buildTopFilters(),
                        SizedBox(height: 20.h),
                        _buildCalendarSection(context),
                        SizedBox(height: 20.h),
                        NextJobsSection(),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------------
  //  All helper methods – unchanged
  // ------------------------------------------------------------------------

  Widget _buildTopFilters() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Obx(() {
        final year = controller.selectedYear.value;
        final month = controller.selectedMonth.value;
        final hour = controller.selectedHour.value;
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                value: year,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  isDense: true,
                ),
                dropdownColor: Colors.white,
                style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
                items: [2024, 2025, 2026, 2027]
                    .map((y) => DropdownMenuItem(
                    value: y, child: Text(y.toString(), overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (val) => controller.selectedYear.value = val!,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                value: month,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  isDense: true,
                ),
                dropdownColor: Colors.white,
                style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
                items: List.generate(12, (index) {
                  final m = index + 1;
                  return DropdownMenuItem(
                    value: m,
                    child: Text(DateFormat('MMMM').format(DateTime(2020, m)).tr,
                        overflow: TextOverflow.ellipsis),
                  );
                }),
                onChanged: (val) => controller.selectedMonth.value = val!,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: hour.isEmpty ? null : hour,
                hint: Text('Hour'.tr, style: TextStyle(fontSize: 14.sp), overflow: TextOverflow.ellipsis),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  isDense: true,
                ),
                dropdownColor: Colors.white,
                style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
                items: [
                  DropdownMenuItem(value: '', child: Text('All'.tr)),
                  ...controller.allTimeSlots.map((h) => DropdownMenuItem(
                      value: h,
                      child: Text(h.split(' - ')[0], overflow: TextOverflow.ellipsis)))
                ],
                onChanged: (val) => controller.selectedHour.value = val ?? '',
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCalendarSection(BuildContext context) {
    return Obx(() {
      final year = controller.selectedYear.value;
      final month = controller.selectedMonth.value;

      final firstDayOfMonth = DateTime(year, month, 1);
      final lastDayOfMonth = DateTime(year, month + 1, 0);

      int firstWeekDay = firstDayOfMonth.weekday;
      final daysInMonth = lastDayOfMonth.day;
      final totalSlots = daysInMonth + (firstWeekDay - 1);

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Manage Availability".tr,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Tap a date to open it. Use it to override a single day.".tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Month Year'.trParams({
                          'month': DateFormat('MMMM')
                              .format(firstDayOfMonth)
                              .tr,
                          'year': '$year',
                        }),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Icon(Icons.circle, size: 10.sp, color: Color(0xFF6CA34D)),
                            Text("Available".tr, style: TextStyle(fontSize: 12.sp)),
                            SizedBox(width: 8.w),
                            Icon(Icons.circle, size: 10.sp, color: Color(0xFFEF5350)),
                            Text("Not Available / Booked".tr, style: TextStyle(fontSize: 12.sp)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Days of week header
                  Row(
                    children: [
                      'Mon Short'.tr,
                      'Tue Short'.tr,
                      'Wed Short'.tr,
                      'Thu Short'.tr,
                      'Fri Short'.tr,
                      'Sat Short'.tr,
                      'Sun Short'.tr,
                    ].map((day) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h),

                  // Calendar Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: totalSlots,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      if (index < firstWeekDay - 1) {
                        return SizedBox(); // Empty slots before the 1st
                      }

                      final dayNumber = index - (firstWeekDay - 1) + 1;
                      final currentDate = DateTime(year, month, dayNumber);

                      return Obx(() {
                        final dayColor = controller.colorForDate(currentDate);
                        final isSelected = controller.selectedDate.value == currentDate;

                        Color bgColor = Color(0xFFF5F5F5);
                        Color borderColor = Colors.transparent;
                        Color textColor = Colors.black87;

                        if (dayColor == DayColor.available) {
                          bgColor = Color(0xFFE8F5E9);
                          borderColor = Color(0xFF6CA34D).withValues(alpha: 0.5);
                          textColor = Color(0xFF2E7D32);
                        } else if (dayColor == DayColor.booked) {
                          bgColor = Color(0xFFFFEBEE);
                          borderColor = Color(0xFFEF5350).withValues(alpha: 0.5);
                          textColor = Color(0xFFEF5350);
                        }

                        if (isSelected) {
                          borderColor = dayColor == DayColor.available
                              ? Color(0xFF2E7D32)
                              : (dayColor == DayColor.booked
                              ? Color(0xFFC62828)
                              : Colors.black87);
                        }

                        final isHighlighted = dayColor != DayColor.none || isSelected;

                        return GestureDetector(
                          onTap: () => controller.selectDate(currentDate),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: borderColor,
                                width: isSelected ? 2.5 : 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                dayNumber.toString(),
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            Obx(() {
              return AnimatedSize(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: controller.selectedDate.value == null
                    ? SizedBox(width: double.infinity)
                    : _buildTimeSlotPanel(),
              );
            }),

            SizedBox(height: 24.h),

            // Summary Card
            Obx(() {
              final daysCount = controller.totalAvailableDays;
              final slotsCount = controller.totalAvailableSlots;
              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6CA34D), Color(0xFF4B7B32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4B7B32).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.event_available, color: Color(0xFF4B7B32), size: 32.sp),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Availability Summary".tr,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Available Days Count'.trParams({
                              'count': '$daysCount',
                            }),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Open Slots This Month'.trParams({
                              'count': '$slotsCount',
                            }),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildVerificationBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 32.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            "Your account isn't verified yet.\nTo send work requests and get hired, please\ncomplete your verification.".tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: AppResponsive.height(50, min: 48, max: 56),
            child: ElevatedButton(
              onPressed: () => controller.showVerificationUi(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "Verify now".tr,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotPanel() {
    final date = controller.selectedDate.value!;
    final dateStr = DateFormat('MMM d, yyyy').format(date);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Slots For Date'.trParams({'date': dateStr}),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => controller.selectedDate.value = null,
                child: Icon(Icons.close, size: 20.sp, color: Colors.grey),
              )
            ],
          ),
          SizedBox(height: 12.h),
          // Special date override
          _buildSpecialDateToggle(date),
          SizedBox(height: 16.h),
          Obx(() => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: controller.allTimeSlots.map((slot) {
              final slotState = controller.effectiveSlotState(date, slot);
              final bool isAvailable = slotState == SlotState.available;
              final bool isBooked = slotState == SlotState.booked;
              final bool matchesFilter = controller.selectedHour.value == slot;

              Color bgColor = Color(0xFFF5F5F5);
              Color textColor = AppColors.textPrimary;
              Color borderColor = Colors.transparent;
              const TextDecoration textDecoration = TextDecoration.none;

              if (isAvailable) {
                bgColor = Color(0xFF6CA34D);
                textColor = Colors.white;
                borderColor = Color(0xFF6CA34D);
              } else if (isBooked) {
                bgColor = Color(0xFFEF5350);
                textColor = Colors.white;
                borderColor = Color(0xFFEF5350);
              }

              if (matchesFilter) {
                borderColor = isAvailable ? Colors.white : Colors.blueAccent;
              }

              return GestureDetector(
                onTap: isBooked ? null : () => controller.toggleTimeSlot(slot),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: matchesFilter ? Colors.blueAccent : borderColor,
                      width: matchesFilter ? 2.0 : 1.0,
                    ),
                    boxShadow: matchesFilter
                        ? [
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isAvailable) ...[
                        Icon(Icons.check, color: Colors.white, size: 16.sp),
                        SizedBox(width: 6.w),
                      ],
                      if (isBooked) ...[
                        Icon(Icons.block, color: Colors.white54, size: 16.sp),
                        SizedBox(width: 6.w),
                      ],
                      Text(
                        slot,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: (isAvailable || matchesFilter) ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13.sp,
                          decoration: textDecoration,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildSpecialDateToggle(DateTime date) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, size: 18.sp, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text(
                "Special Date".tr,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            "This applies to this date only. Tap Available to fill in your usual daily hours.".tr,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, height: 1.3),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildDateActionChip(
                label: "Available",
                icon: Icons.check_circle_outline,
                color: Color(0xFF6CA34D),
                onTap: () => controller.setSpecialDate(
                  date,
                  isAvailable: true,
                  startTime: controller.startTime.value,
                  endTime: controller.endTime.value,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "To clear availability for a date, tap the selected time slot.".tr,
            style: TextStyle(color: Colors.redAccent, fontSize: 12.sp, height: 1.3),
          )
        ],
      ),
    );
  }

  Widget _buildDateActionChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 4.w),
            Text(label.tr, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyAvailableTime() {
    final List<String> hoursList = [
      '06:00 AM', '07:00 AM', '08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM',
      '12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM',
      '06:00 PM', '07:00 PM', '08:00 PM', '09:00 PM', '10:00 PM'
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
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
            Text(
              "Set Daily Available Time".tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Applicable to each selected day of every week.".tr,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            Text(
              "Select Days".tr,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            ),
            SizedBox(height: 8.h),
            Obx(() => Wrap(
              spacing: 6,
              runSpacing: 6,
              children: WorkerHomeController.weekDays.map((day) {
                final isSelected = controller.selectedDaysOfWeek.contains(day);
                return GestureDetector(
                  onTap: () => controller.toggleDayOfWeek(day),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF6CA34D) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      day,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                    value: controller.startTime.value,
                    decoration: InputDecoration(
                      labelText: 'Start Time'.tr,
                      labelStyle: TextStyle(fontSize: 12.sp),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      isDense: true,
                    ),
                    items: hoursList
                        .map((h) => DropdownMenuItem(
                        value: h,
                        child: Text(h, style: TextStyle(fontSize: 14.sp))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) controller.startTime.value = val;
                    },
                  )),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                  child: Text("-".tr,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                    value: controller.endTime.value,
                    decoration: InputDecoration(
                      labelText: 'Ending Time'.tr,
                      labelStyle: TextStyle(fontSize: 12.sp),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      isDense: true,
                    ),
                    items: hoursList
                        .map((h) => DropdownMenuItem(
                        value: h,
                        child: Text(h, style: TextStyle(fontSize: 14.sp))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) controller.endTime.value = val;
                    },
                  )),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Obx(() {
              final synced = controller.isPatternSynced;
              final saving = controller.isSavingTime.value;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (synced || saving) ? null : controller.setDailyAvailableTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6CA34D),
                    disabledBackgroundColor: Color(0xFFE8F5E9),
                    elevation: 0,
                    minimumSize: Size(double.infinity, 48.h),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: saving
                      ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text(
                    (synced
                            ? "Already up to date ✓"
                            : "Set Daily Available Time")
                        .tr,
                    style: TextStyle(
                      color: synced ? Color(0xFF2E7D32) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------------
// NextJobsSection (unchanged)
// ------------------------------------------------------------------------
class NextJobsSection extends StatelessWidget {
  NextJobsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkerHomeController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Next job".tr,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Obx(() {
            if (controller.nextJobs.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  "No upcoming jobs".tr,
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.nextJobs.length,
              itemBuilder: (context, index) {
                final job = controller.nextJobs[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.schedule, color: Colors.blue, size: 20.sp),
                  ),
                  title: Text(
                    job.title ?? 'Upcoming job',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    job.workingDate != null
                        ? '${job.workingDate} ${job.workingStartTime ?? ''}'
                        : 'Date TBD',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
