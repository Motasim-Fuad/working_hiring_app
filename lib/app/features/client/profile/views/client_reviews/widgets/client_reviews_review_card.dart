import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ClientReviewsReviewCard extends StatelessWidget {
  final String providerName;
  final double rating;
  final String reviewText;
  final DateTime? date;

  const ClientReviewsReviewCard({
    super.key,
    required this.providerName,
    required this.rating,
    required this.reviewText,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    final date = this.date;
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26.r,
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(Icons.person, color: Colors.grey),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    providerName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1.h, color: Color(0xFFF0F0F0)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < rating.floor()
                              ? Icons.star
                              : (i < rating
                                    ? Icons.star_half
                                    : Icons.star_border),
                          color: Color(0xFF6CA34D),
                          size: 18.sp,
                        );
                      }),
                    ),
                    if (date != null)
                      Text(
                        DateFormat('MMM d, yyyy').format(date),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                if (reviewText.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    '"$reviewText"',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade800,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
