import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../service/api_service.dart';
import '../../../../routes/app_pages.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignupController extends GetxController {
  final AuthRepository _authRepo;

  SignupController(this._authRepo);

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final referralCodeController = TextEditingController();
  final addressLineController = TextEditingController();
  final cityController = TextEditingController();

  final RxBool isLoading = false.obs;

  final RxBool isPasswordHidden = true.obs;
  final RxString passwordStrength = ''.obs;
  final Rx<Color> strengthColor = Colors.grey.obs;

  final RxBool isEmailValid = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void validateEmailRealTime(String value) {
    if (GetUtils.isEmail(value)) {
      isEmailValid.value = true;
    } else {
      isEmailValid.value = false;
    }
  }

  void updatePasswordStrength(String value) {
    if (value.isEmpty) {
      passwordStrength.value = '';
      strengthColor.value = Colors.grey;
    } else if (value.length < 6) {
      passwordStrength.value = 'Very Weak';
      strengthColor.value = Colors.red;
    } else if (value.length < 8) {
      passwordStrength.value = 'Weak';
      strengthColor.value = Colors.orange;
    } else if (value.contains(RegExp(r'[a-zA-Z]')) && value.contains(RegExp(r'[0-9]')) && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      passwordStrength.value = 'Good';
      strengthColor.value = Colors.blue;
    } else if (value.length >= 8 && value.contains(RegExp(r'[A-Z]')) && value.contains(RegExp(r'[a-z]')) && value.contains(RegExp(r'[0-9]')) && value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      passwordStrength.value = 'Strong';
      strengthColor.value = Colors.green;
    } else {
      passwordStrength.value = 'Good';
      strengthColor.value = Colors.blue;
    }
  }

  final RxString lat = "".obs;
  final RxString lng = "".obs;
  final RxString city = "".obs;

  final signupFormKey = GlobalKey<FormState>();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required'.tr;
    if (!GetUtils.isEmail(value)) return 'Enter a valid email'.tr;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required'.tr;
    if (value.length < 6) return 'Password must be at least 8 characters'.tr;
    return null;
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Field is required'.trParams({'field': fieldName.tr});
    }
    return null;
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    lat.value = latitude.toString();
    lng.value = longitude.toString();

    // 1) Google Geocoding API দিয়ে চেষ্টা (নির্ভরযোগ্য)
    final ok = await _reverseGeocodeWithGoogle(latitude, longitude);
    if (ok) return;

    // 2) Fallback: native geocoding
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final c = place.locality ?? place.subAdministrativeArea ?? "";
        city.value = c;
        cityController.text = c;
        addressLineController.text =
        "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
      }
    } catch (e) {
      // 3) তাও fail করলে অন্তত খালি না রাখা
      if (city.value.isEmpty) {
        city.value = "Selected location";
        cityController.text = "Selected location";
      }
    }
  }

  /// Google Geocoding API দিয়ে reverse geocode
  Future<bool> _reverseGeocodeWithGoogle(double latitude, double longitude) async {
    try {
      final key = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
      if (key.isEmpty) return false;

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
            '?latlng=$latitude,$longitude&key=$key',
      );
      final res = await http.get(url);
      if (res.statusCode != 200) return false;

      final body = jsonDecode(res.body);
      if (body['status'] != 'OK') return false;

      final results = body['results'] as List;
      if (results.isEmpty) return false;

      final first = results.first;
      addressLineController.text = first['formatted_address'] ?? '';

      String c = '';
      for (final comp in (first['address_components'] as List)) {
        final types = (comp['types'] as List).cast<String>();
        if (types.contains('locality')) {
          c = comp['long_name'] ?? '';
          break;
        }
        if (c.isEmpty && types.contains('administrative_area_level_2')) {
          c = comp['long_name'] ?? '';
        }
      }
      if (c.isEmpty) c = 'Selected location';

      city.value = c;          // ✅ UI rebuild হবে
      cityController.text = c;  // ✅ signup body-তে যাবে
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> signupUser() async {
    if (!signupFormKey.currentState!.validate()) return;

    if (lat.isEmpty || lng.isEmpty) {
      Get.snackbar("Error".tr, "Please select a location on map".tr);
      return;
    }

    isLoading.value = true;
    try {
      final body = <String, dynamic>{
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'password': passwordController.text,
        'address': {
          'address_line': addressLineController.text.trim(),
          'city': cityController.text.trim(),
          'lat': double.tryParse(lat.value) ?? 0.0,
          'lng': double.tryParse(lng.value) ?? 0.0,
        },
      };

      final refCode = referralCodeController.text.trim();
      if (refCode.isNotEmpty) {
        body['referral_code'] = refCode;
      }

      await _authRepo.signUp(body);
      Get.toNamed(Routes.OTP, arguments: {
        'email': emailController.text.trim(),
        'flowType': 'signup',
      });
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error".tr, "Something went wrong. Please try again.".tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    referralCodeController.dispose();
    addressLineController.dispose();
    cityController.dispose();
    super.onClose();
  }
}
