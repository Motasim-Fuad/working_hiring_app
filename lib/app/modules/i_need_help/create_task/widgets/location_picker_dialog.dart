import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';

class LocationPickerDialog extends StatelessWidget {
  final VoidCallback onLocationSelected;

  LocationPickerDialog({
    super.key,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final horizontalInset = (media.size.width * 0.05).clamp(12.0, 40.0);
    final verticalInset = (media.size.height * 0.03).clamp(12.0, 32.0);
    final mapHeight = (media.size.height * 0.32).clamp(180.0, 320.0);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: horizontalInset,
        vertical: verticalInset,
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Map Section
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'http://googleusercontent.com/image_collection/image_retrieval/15724683379604930525_0',
                  height: mapHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: mapHeight,
                      width: double.infinity,
                      color: Color(0xFFEDF1F5),
                      child: Center(
                        child: Icon(Icons.map_outlined, size: 54, color: Color(0xFF9E9E9E)),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              // Search TextField
              TextField(
                decoration: InputDecoration(
                  hintText: "Search location manually...".tr,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              SizedBox(height: 12),

              // Confirm Location Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onLocationSelected,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6CA34D), // Dark leafy green
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppStrings.confirmLocation.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12),

              // My Location Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Mock GPS detection
                    onLocationSelected();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF96D268), // Light green
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppStrings.myLocation.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
