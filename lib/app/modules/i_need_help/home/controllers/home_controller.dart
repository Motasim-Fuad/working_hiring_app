import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../../app/data/repositories/category_repository.dart';
import '../../../../../app/data/repositories/user_repository.dart';
import '../../../../../app/data/repositories/helper_repository.dart';
import '../../../../../app/data/repositories/order_repository.dart';
import '../../../../../app/data/models/category_model.dart';
import '../../../../../app/data/models/user_model.dart';
import '../../../../../app/data/models/customer_screen_slide_model.dart';
import '../../../../../app/data/models/activity_model.dart';
import '../../../../../app/service/api_service.dart';
import '../../../../../app/service/api_url.dart';
import '../../../../../app/service/shared_prefs_helper.dart';
import '../../../../../app/core/constants/app_images.dart';
import '../../../../../app/core/constants/app_strings.dart';
import '../../../../../app/core/constants/app_constants.dart';
import '../../../main/controllers/main_controller.dart';
import '../views/widgets/location_list_bottom_sheet.dart';
import '../views/widgets/add_address_map_dialog.dart';

class HomeController extends GetxController {
  final CategoryRepository _categoryRepo;
  final UserRepository _userRepo;
  final HelperRepository _helperRepo;
  final OrderRepository _orderRepo;

  HomeController(this._categoryRepo, this._userRepo, this._helperRepo, this._orderRepo);

  final RxString selectedRole = AppStrings.iNeedHelp.obs;
  final RxInt currentBannerIndex = 0.obs;
  late final PageController bannerPageController;
  Timer? _timer;

  // Main address (short, e.g. street name)
  final RxString currentAddress = 'San Francisco'.obs;
  // Full address (street, city) for the sub‑text
  final RxString currentFullAddress = ''.obs;

  final RxList<AddressModel> userAddresses = <AddressModel>[].obs;

  final Rx<LatLng?> selectedMapLocation = Rx<LatLng?>(null);
  Completer<GoogleMapController> mapController = Completer();

  // Local asset banners only. Add more asset constants/paths here.
  final RxList<String> bannerImages = <String>[
   AppImages.homeBanner1,
   AppImages.homeBanner2,
   AppImages.homeBanner3,
   AppImages.homeBanner4,

  ].obs;
  final RxList<CustomerScreenSlide> slides = <CustomerScreenSlide>[].obs;
  final RxBool isLoadingSlides = false.obs;

  final RxList<CategoryModel> servicesCategories = <CategoryModel>[].obs;
  final RxBool isLoadingCategories = false.obs;
  final RxString selectedCategory = ''.obs;

  // Activity
  final Rx<ActivityModel?> activityData = Rx<ActivityModel?>(null);
  final RxBool isLoadingActivity = false.obs;

  // Recommended helpers
  final RxList<HelperListModel> recommendedHelpers = <HelperListModel>[].obs;
  final RxBool isLoadingHelpers = false.obs;

  // More categories (sub-categories)
  final RxList<SubCategoryModel> moreCategories = <SubCategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
    selectedCategory.value = '';
    bannerPageController = PageController(initialPage: 0);
    _startAutoPlay();
  }

  // --------------------------------------------------------------------------
  // Helper to build a full address string from an AddressModel
  // Uses only available fields: addressLine and city.
  // --------------------------------------------------------------------------
  String _buildFullAddress(AddressModel address) {
    final parts = <String>[];
    if (address.addressLine != null && address.addressLine!.isNotEmpty) {
      parts.add(address.addressLine!);
    }
    if (address.city != null && address.city!.isNotEmpty) {
      parts.add(address.city!);
    }
    return parts.join(', ');
  }

  // --------------------------------------------------------------------------
  // Set both the short and full address from an AddressModel
  // --------------------------------------------------------------------------
  void _setCurrentAddress(AddressModel address) {
    currentAddress.value = address.addressLine ?? address.city ?? 'Unknown';
    currentFullAddress.value = _buildFullAddress(address);
  }

  // --------------------------------------------------------------------------
  // Load initial data
  // --------------------------------------------------------------------------
  Future<void> loadInitialData() async {
    // Trigger backend get_or_create for CustomerProfile before any customer API calls.
    try {
      await _userRepo.getCurrentUser(profileType: 'customer');
    } catch (_) {}
    await loadAddresses();
    await Future.wait([
      loadCategories(),
      loadActivity(),
      loadRecommendedHelpers(),
      loadMoreCategories(),
      loadCustomerSlides(),
    ]);
  }

  // --------------------------------------------------------------------------
  // Load addresses from API
  // --------------------------------------------------------------------------
  Future<void> loadAddresses() async {
    try {
      final addresses = await _userRepo.getAddresses(profileType: 'customer');
      userAddresses.value = addresses;
      if (addresses.isNotEmpty) {
        _setCurrentAddress(addresses.first);
      } else {
        // No addresses: reset to static fallback
        currentAddress.value = 'Select an address';
        currentFullAddress.value = '';
      }
    } on ApiException catch (_) {
      Get.snackbar('Error'.tr, 'Could not load your addresses'.tr);
    } catch (_) {
      Get.snackbar('Error'.tr, 'Connection failed. Check your network.'.tr);
    }
  }

  // --------------------------------------------------------------------------
  // Other data loaders (unchanged)
  // --------------------------------------------------------------------------
  Future<void> loadCategories() async {
    isLoadingCategories.value = true;
    try {
      final categories = await _categoryRepo.getCategories(profileType: 'customer');
      servicesCategories.value = categories;
    } on ApiException catch (_) {
      Get.snackbar('Error'.tr, 'Could not load service categories'.tr);
    } catch (_) {
      Get.snackbar('Error'.tr, 'Connection failed. Check your network.'.tr);
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> loadActivity() async {
    isLoadingActivity.value = true;
    try {
      activityData.value = await _orderRepo.getActivity(profileType: 'customer');
    } on ApiException catch (_) {
      Get.snackbar('Error'.tr, 'Could not load activity data'.tr);
    } catch (_) {
      Get.snackbar('Error'.tr, 'Connection failed. Check your network.'.tr);
    } finally {
      isLoadingActivity.value = false;
    }
  }

  Future<void> loadRecommendedHelpers() async {
    isLoadingHelpers.value = true;
    try {
      final addr = userAddresses.isNotEmpty ? userAddresses.first : null;
      recommendedHelpers.value = await _helperRepo.getRecommendedHelpers(
        lat: addr?.lat,
        lng: addr?.lng,
        profileType: 'customer',
      );
    } on ApiException catch (_) {
      Get.snackbar('Error'.tr, 'Could not load recommended helpers'.tr);
    } catch (_) {
      Get.snackbar('Error'.tr, 'Connection failed. Check your network.'.tr);
    } finally {
      isLoadingHelpers.value = false;
    }
  }

  Future<void> loadMoreCategories() async {
    try {
      moreCategories.value = await _categoryRepo.getSubCategories(profileType: 'customer');
    } on ApiException catch (_) {
      Get.snackbar('Error'.tr, 'Could not load sub-categories'.tr);
    } catch (_) {
      Get.snackbar('Error'.tr, 'Connection failed. Check your network.'.tr);
    }
  }

  Future<void> loadCustomerSlides() async {
    // Banner images are bundled assets; no backend/network request is needed.
    bannerImages.assignAll([
      AppImages.homeBanner1,
      AppImages.homeBanner2,
      AppImages.homeBanner3,
      AppImages.homeBanner4,
    ]);
  }

  @override
  void onClose() {
    _timer?.cancel();
    bannerPageController.dispose();
    super.onClose();
  }

  // --------------------------------------------------------------------------
  // Address selection & management
  // --------------------------------------------------------------------------
  void selectAddress(AddressModel address) {
    _setCurrentAddress(address);
    Get.back();
  }

  Future<void> deleteAddress(int index) async {
    if (index >= 0 && index < userAddresses.length) {
      final address = userAddresses[index];
      try {
        if (address.id != null) {
          await _userRepo.deleteAddress(address.id!, profileType: 'customer');
        }
        userAddresses.removeAt(index);
        // If we deleted the currently selected address, pick the first one (or reset)
        if (currentAddress.value == (address.addressLine ?? address.city)) {
          if (userAddresses.isNotEmpty) {
            _setCurrentAddress(userAddresses.first);
          } else {
            currentAddress.value = 'Select an address';
            currentFullAddress.value = '';
          }
        }
      } on ApiException catch (e) {
        Get.snackbar("Error", e.message);
      } catch (_) {
        // Still remove locally on error
        userAddresses.removeAt(index);
      }
    }
  }

  void openLocationList() {
    Get.bottomSheet(
      LocationListBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void openAddNewAddressMap() {
    Get.back();
    selectedMapLocation.value = LatLng(37.7749, -122.4194);
    Get.bottomSheet(
      AddAddressMapDialog(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
    );
  }

  // --------------------------------------------------------------------------
  // Map methods
  // --------------------------------------------------------------------------
  void onMapCreated(GoogleMapController controller) {
    if (!mapController.isCompleted) {
      mapController.complete(controller);
    }
  }

  void updateMapPin(LatLng position) {
    selectedMapLocation.value = position;
  }

  Future<void> fetchCurrentLocation() async {
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


      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final currentLatLng = LatLng(position.latitude, position.longitude);
      selectedMapLocation.value = currentLatLng;

      final GoogleMapController controller = await mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLatLng, zoom: 16),
        ),
      );
    } catch (e) {
      debugPrint('fetchCurrentLocation error: $e');
    }
  }

  Future<void> confirmNewLocation() async {
    if (selectedMapLocation.value == null) {
      Get.snackbar("Error".tr, "Please drop a pin on the map first.".tr);
      return;
    }

    try {
      Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false);

      List<Placemark> placemarks = await placemarkFromCoordinates(
          selectedMapLocation.value!.latitude,
          selectedMapLocation.value!.longitude
      );

      Get.back();

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Build a display address from available placemark fields
        String formattedAddress = "${place.street}, ${place.locality}, ${place.administrativeArea}";

        try {
          final newAddr = await _userRepo.createAddress({
            'address_line': formattedAddress,
            'city': place.locality ?? '',
            'lat': selectedMapLocation.value!.latitude,
            'lng': selectedMapLocation.value!.longitude,
          }, profileType: 'customer');
          userAddresses.add(newAddr);
          _setCurrentAddress(newAddr);
        } on ApiException catch (_) {
          // Fallback: add locally without persisting
          final fallbackAddr = AddressModel(
            addressLine: formattedAddress,
            city: place.locality ?? '',
            lat: selectedMapLocation.value!.latitude,
            lng: selectedMapLocation.value!.longitude,
          );
          userAddresses.add(fallbackAddr);
          _setCurrentAddress(fallbackAddr);
        }

        Get.back(); // close the map bottom sheet
      } else {
        Get.snackbar("Error".tr, "Could not fetch address for this location.".tr);
      }
    } catch (e) {
      Get.back();

      String fallbackAddress = "Custom Location (${selectedMapLocation.value!.latitude.toStringAsFixed(2)}, ${selectedMapLocation.value!.longitude.toStringAsFixed(2)})";
      final fallbackAddr = AddressModel(
        addressLine: fallbackAddress,
        lat: selectedMapLocation.value!.latitude,
        lng: selectedMapLocation.value!.longitude,
      );
      userAddresses.add(fallbackAddr);
      _setCurrentAddress(fallbackAddr);

      Get.back();
    }
  }

  // --------------------------------------------------------------------------
  // Banner auto‑play
  // --------------------------------------------------------------------------
  void _startAutoPlay() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (bannerImages.isEmpty) return;
      if (currentBannerIndex.value < bannerImages.length - 1) {
        currentBannerIndex.value++;
      } else {
        currentBannerIndex.value = 0;
      }
      if (bannerPageController.hasClients) {
        bannerPageController.animateToPage(
          currentBannerIndex.value,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void onBannerPageChanged(int index) {
    currentBannerIndex.value = index;
  }

  // --------------------------------------------------------------------------
  // Role / language / navigation helpers (unchanged)
  // --------------------------------------------------------------------------
  void setRole(String role) {
    selectedRole.value = role;
    final profile = role == AppStrings.iWantToWork ? 'PROVIDER' : 'CUSTOMER';
    SharedPrefsHelper.setString(AppConstants.defaultProfile, profile);
    if (role == AppStrings.iWantToWork) {
      if (Get.isRegistered<MainController>()) {
        Get.find<MainController>().changePhase(2);
      } else {
        Get.offAllNamed('/dashboard');
      }
    } else {
      if (Get.isRegistered<MainController>()) {
        Get.find<MainController>().changePhase(1);
      }
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void changeLanguage(String langCode) {
    if (langCode == 'en') {
      Get.updateLocale(Locale('en', 'US'));
    } else {
      Get.updateLocale(Locale('zh', 'CN'));
    }
  }

  void createAccount() {
    Get.toNamed('/sign-up');
  }

  void proceedToCreateTask() {
    if (selectedCategory.value.isEmpty) {
      Get.toNamed('/create-task');
    } else {
      Get.toNamed(
        '/create-task',
        arguments: {'category': selectedCategory.value},
      );
    }
  }

  void onBannerChanged(int index) {
    currentBannerIndex.value = index;
  }
}
