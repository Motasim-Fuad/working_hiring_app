import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:http/http.dart' as http;

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

  final Rx<MapType> _mapType = MapType.normal.obs;
  final RxDouble _currentZoom = 15.0.obs;
  final RxString _addressLabel = ''.obs;
  final RxBool _isResolvingAddress = false.obs;

  final RxBool _streetViewAvailable = false.obs;
  final RxBool _isCheckingStreetView = false.obs;
  final RxInt _streetViewRequestId = 0.obs;

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
      unawaited(_checkStreetViewAvailability(current));
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
      unawaited(_checkStreetViewAvailability(current));
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
    unawaited(_checkStreetViewAvailability(location));
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


  String _streetViewUrl(LatLng loc, {int width = 640, int height = 300}) {
    return 'https://maps.googleapis.com/maps/api/streetview'
        '?size=${width}x$height'
        '&location=${loc.latitude},${loc.longitude}'
        '&fov=80&heading=151.78&pitch=-0.76'
        '&source=outdoor'
        '&key=$_googleApiKey';
  }

  Future<void> _checkStreetViewAvailability(LatLng loc) async {
    if (_googleApiKey.isEmpty) {
      _streetViewAvailable.value = false;
      return;
    }
    _isCheckingStreetView.value = true;
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/streetview/metadata'
            '?location=${loc.latitude},${loc.longitude}'
            '&source=outdoor'
            '&key=$_googleApiKey',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _streetViewAvailable.value = data['status'] == 'OK';
      } else {
        _streetViewAvailable.value = false;
      }
    } catch (e) {
      debugPrint('MapPicker street-view metadata error: $e');
      _streetViewAvailable.value = false;
    } finally {
      _streetViewRequestId.value++;
      _isCheckingStreetView.value = false;
    }
  }

  Future<void> _zoomIn() async {
    await _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    await _mapController?.animateCamera(CameraUpdate.zoomOut());
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
                unawaited(_checkStreetViewAvailability(latLng));
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
                SizedBox(height: 12.h),
                Material(
                  color: Colors.white,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10.r),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Zoom in'.tr,
                        icon: Icon(Icons.add),
                        onPressed: _zoomIn,
                      ),
                      Divider(height: 1, thickness: 1),
                      IconButton(
                        tooltip: 'Zoom out'.tr,
                        icon: Icon(Icons.remove),
                        onPressed: _zoomOut,
                      ),
                    ],
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
                    Obx(() {
                      if (!_streetViewAvailable.value) {
                        return const SizedBox.shrink();
                      }
                      final loc = _selectedLocation.value;
                      final reqId = _streetViewRequestId.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: SizedBox(
                            height: 90.h,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  _streetViewUrl(loc),
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      color: Colors.black12,
                                      child: Center(
                                        child: SizedBox(
                                          width: 18.r,
                                          height: 18.r,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      _streetViewAvailable.value = false;
                                    });
                                    return const SizedBox.shrink();
                                  },
                                ),
                                Positioned(
                                  left: 8.w,
                                  bottom: 6.h,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.55),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.streetview,
                                            size: 14.r, color: Colors.white),
                                        SizedBox(width: 4.w),
                                        Text(
                                          'Street View'.tr,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

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

void unawaited(Future<void> future) {}