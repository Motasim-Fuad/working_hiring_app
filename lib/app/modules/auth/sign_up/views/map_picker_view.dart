import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

class MapPickerView extends StatefulWidget {
  MapPickerView({super.key});

  @override
  State<MapPickerView> createState() => _MapPickerViewState();
}

class _MapPickerViewState extends State<MapPickerView> {
  final String _googleApiKey = dotenv.env['GOOGLE_MAP_API_KEY'] ?? '';

  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(debugLabel: 'map-search');

  final Rx<LatLng> _selectedLocation =
      LatLng(23.758353, 90.374057).obs;
  final RxBool _isLoading = true.obs;
  final RxBool _canShowCurrentLocation = false.obs;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) return;
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return;
      }

      _canShowCurrentLocation.value = true;
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      final current = LatLng(position.latitude, position.longitude);
      _selectedLocation.value = current;
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(current, 16),
      );
    } catch (e) {
      debugPrint('MapPicker current-location error: $e');
    } finally {
      if (mounted) _isLoading.value = false;
    }
  }

  Future<void> _moveToLocation(double lat, double lng) async {
    final location = LatLng(lat, lng);
    _selectedLocation.value = location;
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 16),
    );

    // Do not unfocus here. The Places package can invoke this callback while
    // updating a prediction; removing focus caused the keyboard to disappear.
  }

  void _confirmLocation() {
    _searchFocusNode.unfocus();
    Get.back(result: _selectedLocation.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'.tr),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _confirmLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          Obx(
            () => GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation.value,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                controller.animateCamera(
                  CameraUpdate.newLatLng(_selectedLocation.value),
                );
              },
              onTap: (latLng) {
                _selectedLocation.value = latLng;
                _searchFocusNode.unfocus();
              },
              markers: {
                Marker(
                  markerId: MarkerId('selected_location'),
                  position: _selectedLocation.value,
                ),
              },
              myLocationEnabled: _canShowCurrentLocation.value,
              myLocationButtonEnabled: _canShowCurrentLocation.value,
              padding: EdgeInsets.only(bottom: 120.h, top: 70.h),
            ),
          ),

          Positioned(
            top: 12.h,
            left: 16.w,
            right: 16.w,
            child: SafeArea(
              bottom: false,
              child: Material(
                color: Colors.white,
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
                clipBehavior: Clip.antiAlias,
                child: GooglePlaceAutoCompleteTextField(
                  textEditingController: _searchController,
                  focusNode: _searchFocusNode,
                  googleAPIKey: _googleApiKey,
                  debounceTime: 600,
                  isLatLngRequired: true,
                  isCrossBtnShown: true,
                  keyboardType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.search,
                  inputDecoration: InputDecoration(
                    hintText: 'Search location'.tr,
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 14.h,
                    ),
                  ),
                  itemClick: (prediction) {
                    final description = prediction.description ?? '';
                    _searchController.value = TextEditingValue(
                      text: description,
                      selection: TextSelection.collapsed(
                        offset: description.length,
                      ),
                    );
                  },
                  getPlaceDetailWithLatLng: (prediction) {
                    final lat = double.tryParse(prediction.lat ?? '');
                    final lng = double.tryParse(prediction.lng ?? '');
                    if (lat != null && lng != null) {
                      _moveToLocation(lat, lng);
                    }
                  },
                ),
              ),
            ),
          ),

          Obx(
            () => _isLoading.value
                ? Center(child: CircularProgressIndicator())
                : SizedBox.shrink(),
          ),

          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 14.h,
            child: SafeArea(
              top: false,
              child: ElevatedButton(
                onPressed: _confirmLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6CA34D),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Confirm Location'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
