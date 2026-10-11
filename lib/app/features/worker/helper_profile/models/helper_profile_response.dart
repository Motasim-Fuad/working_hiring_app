import 'package:working_hiring/app/features/worker/helper_profile/models/helper_profile_model.dart';

class HelperProfileResponse {
  bool? status;
  HelperProfileModel? data;

  HelperProfileResponse({this.status, this.data});

  factory HelperProfileResponse.fromJson(Map<String, dynamic> json) {
    return HelperProfileResponse(
      status: json['status'],
      data: json['data'] != null
          ? HelperProfileModel.fromJson(json['data'])
          : null,
    );
  }
}
