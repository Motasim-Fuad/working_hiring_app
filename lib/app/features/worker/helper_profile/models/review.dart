import 'package:working_hiring/app/features/worker/helper_profile/models/helper_profile_model.dart';
import 'package:working_hiring/app/features/worker/helper_profile/models/customer.dart';

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
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'])
          : null,
      rating: json['rating'],
      review: json['review'],
      createdAt: json['created_at'],
    );
  }
}
