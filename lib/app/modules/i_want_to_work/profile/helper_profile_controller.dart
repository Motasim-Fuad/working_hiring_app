import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:working_hiring/app/data/models/category_model.dart';
import 'package:working_hiring/app/data/repositories/category_repository.dart';
import 'helper_profile_model.dart';
import '../../../data/repositories/helper_repository.dart';
import '../../../service/api_service.dart';
import '../../../routes/app_pages.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class HelperProfileController extends GetxController {
  final HelperRepository _helperRepo;
  final CategoryRepository _categoryRepo;

  HelperProfileController(this._helperRepo, this._categoryRepo);

  // Observables
  Rx<HelperProfileModel?> profileData = Rx<HelperProfileModel?>(null);
  RxBool isLoading = false.obs;
  RxBool isAvailable = false.obs;
  RxBool isLocating = false.obs;

  final Rx<File?> logoFile = Rx<File?>(null);

  // Available categories from backend
  final RxList<CategoryModel> availableCategories = <CategoryModel>[].obs;
  // Selected category IDs
  final RxList<int> selectedCategoryIds = <int>[].obs;

  // Text controllers (serviceCategoryController removed)
  final companyNameController = TextEditingController();
  final hourlyRateController = TextEditingController();
  final minBookingHoursController = TextEditingController();
  final detailsController = TextEditingController();
  final addressLineController = TextEditingController();
  final cityController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    loadCategories(); // load available categories
  }

  @override
  void onClose() {
    // Dispose controllers if needed (but keep them for now)
    super.onClose();
  }

  // Load categories from API
  Future<void> loadCategories() async {
    try {
      final categories = await _categoryRepo.getCategories();
      availableCategories.assignAll(categories);
    } on ApiException catch (e) {
      Get.snackbar('Error'.tr, 'Failed to load categories: ${e.message}');
    } catch (_) {
      Get.snackbar('Error'.tr, 'Failed to load categories'.tr);
    }
  }

  // Toggle selection of a category
  void toggleCategory(int id) {
    if (selectedCategoryIds.contains(id)) {
      selectedCategoryIds.remove(id);
    } else {
      selectedCategoryIds.add(id);
    }
  }

  Future<void> pickLogo() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (picked != null) {
        logoFile.value = File(picked.path);
      }
    } catch (_) {
      Get.snackbar('Error'.tr, 'Could not pick image.'.tr);
    }
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final data = await _helperRepo.getMyHelperProfile();
      profileData.value = HelperProfileModel.fromJson(data);
      populateEditFields();
      if (Get.currentRoute == Routes.CREATE_HELPER_PROFILE) {
        if (profileData.value?.isVerified == true) {
          Get.back();
        } else {
          Get.offNamed(Routes.WORKER_ACCOUNT_VERIFICATION);
        }
        return;
      }
    } on ApiException catch (_) {
      profileData.value = null;
    } catch (_) {
      profileData.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  void populateEditFields() {
    if (profileData.value != null) {
      final profile = profileData.value!;
      companyNameController.text = profile.companyName ?? '';
      hourlyRateController.text = profile.hourlyRate ?? '';
      minBookingHoursController.text = profile.minBookingHours ?? '';
      detailsController.text = profile.details ?? '';
      isAvailable.value = profile.availabilityStatus ?? false;
      // Populate selected IDs from existing profile
      selectedCategoryIds.assignAll(
        profile.serviceCategory?.map((c) => c.id).whereType<int>().toList() ?? [],
      );
      final loc = profile.officeLocation;
      addressLineController.text = loc?.addressLine ?? '';
      cityController.text = loc?.city ?? '';
      latController.text = loc?.lat?.toString() ?? '';
      lngController.text = loc?.lng?.toString() ?? '';

      print("Company: ${profile.companyName}");
      print("Details: ${profile.details}");
      print("Logo: ${profile.logo}");


    }
  }

  Future<void> getCurrentLocation() async {
    try {
      isLocating.value = true;
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
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );
      latController.text = position.latitude.toStringAsFixed(6);
      lngController.text = position.longitude.toStringAsFixed(6);
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          addressLineController.text = place.street ?? '';
          cityController.text = place.locality ?? '';
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('getCurrentLocation error: $e');
    } finally {
      isLocating.value = false;
    }
  }

  /// ✅ MapPickerView থেকে lat/lng পেলে — আসল address বের করে field-এ বসায়।
  /// lat/lng controller-এ আলাদা থাকে (backend-এ ঠিকঠাক যায়),
  /// address field-এ শুধু মানুষের পড়ার মতো address থাকে।
  /// ✅ MapPickerView থেকে lat/lng পেলে — address বের করে field-এ বসায়।
  Future<void> setLocationFromMap(double lat, double lng) async {
    latController.text = lat.toStringAsFixed(6);
    lngController.text = lng.toStringAsFixed(6);

    // 1) আগে Google Geocoding API দিয়ে চেষ্টা (নির্ভরযোগ্য)
    final googleOk = await _reverseGeocodeWithGoogle(lat, lng);
    if (googleOk) return;

    // 2) Google fail করলে native geocoding fallback
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final street = place.street ?? '';
        final sub = place.subLocality ?? '';
        final locality = place.locality ?? '';
        addressLineController.text =
            [street, sub, locality].where((s) => s.isNotEmpty).join(', ');
        cityController.text = locality.isNotEmpty
            ? locality
            : (place.subAdministrativeArea ?? '');
      }
    } catch (_) {}

    // 3) তাও খালি থাকলে fallback (যাতে validation আটকে না যায়)
    if (addressLineController.text.trim().isEmpty) {
      addressLineController.text = 'Selected location';
    }
    if (cityController.text.trim().isEmpty) {
      cityController.text = 'Unknown';
    }
  }

  /// Google Geocoding API দিয়ে reverse geocode
  Future<bool> _reverseGeocodeWithGoogle(double lat, double lng) async {
    try {
      final key = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
      if (key.isEmpty) return false;

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
            '?latlng=$lat,$lng&key=$key',
      );
      final res = await http.get(url);
      if (res.statusCode != 200) return false;

      final body = jsonDecode(res.body);
      if (body['status'] != 'OK') return false;

      final results = body['results'] as List;
      if (results.isEmpty) return false;

      final first = results.first;
      addressLineController.text = first['formatted_address'] ?? '';

      // city বের করা address_components থেকে
      String city = '';
      for (final comp in (first['address_components'] as List)) {
        final types = (comp['types'] as List).cast<String>();
        if (types.contains('locality')) {
          city = comp['long_name'] ?? '';
          break;
        }
        if (city.isEmpty && types.contains('administrative_area_level_2')) {
          city = comp['long_name'] ?? '';
        }
      }
      cityController.text = city;

      return addressLineController.text.trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> createProfile() async {
    if (profileData.value != null) {
      if (profileData.value?.isVerified == true) {
        Get.back();
      } else {
        Get.offNamed(Routes.WORKER_ACCOUNT_VERIFICATION);
      }
      return;
    }

    try {
      isLoading.value = true;

      final lat = double.tryParse(latController.text.trim());
      final lng = double.tryParse(lngController.text.trim());
      if (lat == null || lng == null) {
        Get.snackbar('Error'.tr, 'Office location is required.'.tr);
        return;
      }
      final addressLine = addressLineController.text.trim();
      final city = cityController.text.trim();
      if (addressLine.isEmpty || city.isEmpty) {
        Get.snackbar('Error'.tr, 'Address line and city are required.'.tr);
        return;
      }

      // Use selectedCategoryIds directly (no parsing needed)
      final categoryIds = selectedCategoryIds.toList();

      final data = await _helperRepo.createHelperProfile({
        'company_name': companyNameController.text.trim(),
        'hourly_rate': hourlyRateController.text.trim(),
        'min_booking_hours': minBookingHoursController.text.trim(),
        'details': detailsController.text.trim(),
        'service_category': categoryIds,
      }, logoFile: logoFile.value);
      profileData.value = HelperProfileModel.fromJson(data);

      try {
        final address = await _helperRepo.createAddress({
          'address_line': addressLine,
          'city': city,
          'lat': lat,
          'lng': lng,
        });
        final addressId = address['id'] as int;
        await _helperRepo.setOfficeLocation(addressId);
      } on ApiException catch (e) {
        Get.snackbar('Warning'.tr, 'Profile created but office location failed: ${e.message}');
      } catch (_) {
        Get.snackbar('Warning'.tr, 'Profile created but office location could not be saved.'.tr);
      }

      // Replace only the create-profile route. Main remains underneath, so
      // Back from verification returns to the provider Verify Now gate.
      Get.offNamed(Routes.WORKER_ACCOUNT_VERIFICATION);
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (_) {
      Get.snackbar('Error'.tr, 'An error occurred while creating profile.'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      final lat = double.tryParse(latController.text.trim());
      final lng = double.tryParse(lngController.text.trim());
      if (lat == null || lng == null) {
        Get.snackbar('Error'.tr, 'Office location is required.'.tr);
        return;
      }
      final addressLine = addressLineController.text.trim();
      final city = cityController.text.trim();
      if (addressLine.isEmpty || city.isEmpty) {
        Get.snackbar('Error'.tr, 'Address line and city are required.'.tr);
        return;
      }

      final categoryIds = selectedCategoryIds.toList();

      final data = await _helperRepo.updateHelperProfile({
        'company_name': companyNameController.text.trim(),
        'hourly_rate': hourlyRateController.text.trim(),
        'min_booking_hours': minBookingHoursController.text.trim(),
        'details': detailsController.text.trim(),
        'service_category': categoryIds,
        'availability_status': isAvailable.value,
      }, logoFile: logoFile.value);
      profileData.value = HelperProfileModel.fromJson(data);

      try {
        final address = await _helperRepo.createAddress({
          'address_line': addressLine,
          'city': city,
          'lat': lat,
          'lng': lng,
        });
        final addressId = address['id'] as int;
        await _helperRepo.setOfficeLocation(addressId);
      } on ApiException catch (e) {
        Get.snackbar('Warning'.tr, 'Profile updated but office location failed: ${e.message}');
      } catch (_) {
        Get.snackbar('Warning'.tr, 'Profile updated but office location could not be saved.'.tr);
      }

      Get.back();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (_) {
      Get.snackbar('Error'.tr, 'An error occurred while updating profile.'.tr);
    } finally {
      isLoading.value = false;
    }
  }
}
