import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/home_controller.dart';

class AddAddressMapDialog extends GetView<HomeController> {
  AddAddressMapDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.85,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add New Address'.tr,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close)),
            ],
          ),
          SizedBox(height: 16.h),

          // Search Bar Placeholder
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300)
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search location manually...".tr,
                hintStyle: TextStyle(color: Colors.grey),
                icon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Interactive Map Area
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Stack(
                children: [
                  Obx(() {
                    final position = controller.selectedMapLocation.value ?? LatLng(37.7749, -122.4194);
                    return GoogleMap(
                        initialCameraPosition: CameraPosition(target: position, zoom: 14),
                        onMapCreated: controller.onMapCreated,
                        onTap: controller.updateMapPin,
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        markers: {
                          Marker(
                            markerId: MarkerId('selected_pin'),
                            position: position,
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                          )
                        },
                      );
                  }),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Action Buttons
          Row(
            children: [
               Expanded(
                child: OutlinedButton(
                  onPressed: controller.fetchCurrentLocation,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    side: BorderSide(color: Color(0xFF6CA34D), width: 1.5),
                    foregroundColor: Color(0xFF6CA34D),
                  ),
                  child: Text("My Location".tr, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.confirmNewLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6CA34D),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: Text("Confirm Location".tr, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
        ]
      )
    );
  }
}
