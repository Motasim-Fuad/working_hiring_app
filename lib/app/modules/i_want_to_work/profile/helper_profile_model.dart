class HelperProfileResponse {
  bool? status;
  HelperProfileModel? data;

  HelperProfileResponse({this.status, this.data});

  factory HelperProfileResponse.fromJson(Map<String, dynamic> json) {
    return HelperProfileResponse(
      status: json['status'],
      data: json['data'] != null ? HelperProfileModel.fromJson(json['data']) : null,
    );
  }
}

class HelperProfileModel {
  String? companyName;
  String? logo;
  String? details;
  String? hourlyRate;
  String? minBookingHours;
  OfficeLocation? officeLocation;
  int? strikeCount;
  String? accountStatus;
  bool? availabilityStatus;
  bool? isVerified;
  double? completeRate;
  int? totalJobs;
  double? rating;
  List<ServiceCategory>? serviceCategory;
  List<PortfolioItem>? portfolio;
  List<Review>? reviewsAndRatings;

  HelperProfileModel({
    this.companyName,
    this.logo,
    this.details,
    this.hourlyRate,
    this.minBookingHours,
    this.officeLocation,
    this.strikeCount,
    this.accountStatus,
    this.availabilityStatus,
    this.isVerified,
    this.completeRate,
    this.totalJobs,
    this.rating,
    this.serviceCategory,
    this.portfolio,
    this.reviewsAndRatings,
  });

  factory HelperProfileModel.fromJson(Map<String, dynamic> json) {
    return HelperProfileModel(
      companyName: json['company_name'],
      logo: json['logo'],
      details: json['details'],
      hourlyRate: json['hourly_rate']?.toString(),
      minBookingHours: json['min_booking_hours']?.toString(),
      officeLocation: json['office_location'] != null ? OfficeLocation.fromJson(json['office_location']) : null,
      strikeCount: json['strike_count'],
      accountStatus: json['account_status'],
      availabilityStatus: json['availability_status'],
      isVerified: json['is_verified'],
      completeRate: json['complete_rate'] != null ? double.tryParse(json['complete_rate'].toString()) : null,
      totalJobs: json['total_jobs'],
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      serviceCategory: json['service_category'] != null
          ? (json['service_category'] as List).map((i) => ServiceCategory.fromJson(i)).toList()
          : null,
      portfolio: json['portfolio'] != null
          ? (json['portfolio'] as List).map((i) => PortfolioItem.fromJson(i)).toList()
          : null,
      reviewsAndRatings: json['reviews_and_ratings'] != null
          ? (json['reviews_and_ratings'] as List).map((i) => Review.fromJson(i)).toList()
          : null,
    );
  }
}

class OfficeLocation {
  int? id;
  String? addressLine;
  String? city;
  double? lat;
  double? lng;

  OfficeLocation({this.id, this.addressLine, this.city, this.lat, this.lng});

  factory OfficeLocation.fromJson(Map<String, dynamic> json) {
    return OfficeLocation(
      id: json['id'],
      addressLine: json['address_line'],
      city: json['city'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}

class ServiceCategory {
  int? id;
  String? title;

  ServiceCategory({this.id, this.title});

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'],
      title: json['title'],
    );
  }
}

class PortfolioItem {
  int? id;
  String? title;
  String? description;
  String? workingDate;
  String? picture;

  PortfolioItem({this.id, this.title, this.description, this.workingDate, this.picture});

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      workingDate: json['working_date'],
      picture: json['picture'],
    );
  }
}

class Review {
  int? id;
  Customer? customer;
  int? rating;
  String? review;
  String? createdAt;

  Review({this.id, this.customer, this.rating, this.review, this.createdAt});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      rating: json['rating'],
      review: json['review'],
      createdAt: json['created_at'],
    );
  }
}

class Customer {
  int? id;
  String? firstName;
  String? lastName;
  String? photo;

  Customer({this.id, this.firstName, this.lastName, this.photo});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      photo: json['photo'],
    );
  }
}
