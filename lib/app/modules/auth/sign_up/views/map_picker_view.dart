import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
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

  // --- new state ---
  final Rx<MapType> _mapType = MapType.normal.obs;
  final RxDouble _currentZoom = 15.0.obs;
  final RxString _addressLabel = ''.obs;
  final RxBool _isResolvingAddress = false.obs;

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
      await _reverseGeocode(current);
    } catch (e) {
      debugPrint('MapPicker current-location error: $e');
    } finally {
      if (mounted) _isLoading.value = false;
    }
  }

  final RxBool _isRecentering = false.obs;

  Future<void> _recenterOnCurrentLocation() async {
    if (_isRecentering.value) return;
    _isRecentering.value = true;
    try {
      if (!_canShowCurrentLocation.value) {
        await _getCurrentLocation();
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final current = LatLng(position.latitude, position.longitude);
      _selectedLocation.value = current;
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(current, 16),
      );
      await _reverseGeocode(current);
    } catch (e) {
      debugPrint('MapPicker recenter error: $e');
    } finally {
      if (mounted) _isRecentering.value = false;
    }
  }

  Future<void> _moveToLocation(double lat, double lng) async {
    final location = LatLng(lat, lng);
    _selectedLocation.value = location;
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 16),
    );
    await _reverseGeocode(location);
  }

  Future<void> _reverseGeocode(LatLng location) async {
    _isResolvingAddress.value = true;
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isEmpty) {
        _addressLabel.value =
        '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}';
        return;
      }

      final p = placemarks.first;

      final parts = <String>[
        if ((p.name ?? '').isNotEmpty && p.name != p.street) p.name!,
        if ((p.subLocality ?? '').isNotEmpty) p.subLocality!,
        if ((p.locality ?? '').isNotEmpty) p.locality!,
        if ((p.locality ?? '').isEmpty && (p.subAdministrativeArea ?? '').isNotEmpty)
          p.subAdministrativeArea!,
        if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea!,
        if ((p.country ?? '').isNotEmpty) p.country!,
      ];

      _addressLabel.value = parts.isNotEmpty
          ? parts.toSet().join(', ')
          : '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}';
    } catch (e) {
      debugPrint('MapPicker reverse-geocode error: $e');
      _addressLabel.value =
      '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}';
    } finally {
      _isResolvingAddress.value = false;
    }
  }

  void _confirmLocation() {
    _searchFocusNode.unfocus();
    Get.back(result: _selectedLocation.value);
  }

  void _cycleMapType() {
    const order = [
      MapType.normal,
      MapType.satellite,
      MapType.hybrid,
      MapType.terrain,
    ];
    final next = order[(order.indexOf(_mapType.value) + 1) % order.length];
    _mapType.value = next;
  }

  String _mapTypeLabel(MapType type) {
    switch (type) {
      case MapType.satellite:
        return 'Satellite'.tr;
      case MapType.hybrid:
        return 'Hybrid'.tr;
      case MapType.terrain:
        return 'Terrain'.tr;
      case MapType.normal:
      default:
        return 'Normal'.tr;
    }
  }

  IconData _mapTypeIcon(MapType type) {
    switch (type) {
      case MapType.satellite:
      case MapType.hybrid:
        return Icons.satellite_alt;
      case MapType.terrain:
        return Icons.terrain;
      case MapType.normal:
      default:
        return Icons.map;
    }
  }

  String _scaleLabel(double zoom, double latitude) {
    final metersPerPixel = 156543.03392 *
        math.cos(latitude * math.pi / 180) /
        math.pow(2, zoom);
    final metersFor100px = metersPerPixel * 100;

    if (metersFor100px >= 1000) {
      return '~${(metersFor100px / 1000).toStringAsFixed(metersFor100px >= 10000 ? 0 : 1)} km';
    }
    return '~${metersFor100px.toStringAsFixed(0)} m';
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
              mapType: _mapType.value,
              initialCameraPosition: CameraPosition(
                target: _selectedLocation.value,
                zoom: _currentZoom.value,
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
                _reverseGeocode(latLng);
              },
              onCameraMove: (position) {
                _currentZoom.value = position.zoom;
              },
              markers: {
                Marker(
                  markerId: MarkerId('selected_location'),
                  position: _selectedLocation.value,
                ),
              },
              myLocationEnabled: _canShowCurrentLocation.value,
              myLocationButtonEnabled: false,
              padding: EdgeInsets.only(bottom: 140.h, top: 70.h),
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

          Positioned(
            right: 16.w,
            bottom: 210.h,
            child: Column(
              children: [
                Obx(
                      () => Material(
                    color: Colors.white,
                    elevation: 4,
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: _mapTypeLabel(_mapType.value),
                      icon: Icon(_mapTypeIcon(_mapType.value)),
                      onPressed: _cycleMapType,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Obx(
                      () => Material(
                    color: Colors.white,
                    elevation: 4,
                    shape: const CircleBorder(),
                    child: _isRecentering.value
                        ? Padding(
                      padding: EdgeInsets.all(12.r),
                      child: SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                        : IconButton(
                      tooltip: 'My location'.tr,
                      icon: Icon(Icons.my_location),
                      onPressed: _recenterOnCurrentLocation,
                    ),
                  ),
                ),
              ],
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
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(
                          () {
                        final zoom = _currentZoom.value;
                        final lat = _selectedLocation.value.latitude;
                        return Material(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10.r),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _isResolvingAddress.value
                                        ? 'Locating...'.tr
                                        : (_addressLabel.value.isEmpty
                                        ? 'Tap map or search a location'.tr
                                        : _addressLabel.value),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  _scaleLabel(zoom, lat),
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10.h),
                    ElevatedButton(
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}