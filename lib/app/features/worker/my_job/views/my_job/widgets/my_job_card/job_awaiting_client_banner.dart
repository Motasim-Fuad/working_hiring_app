import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobAwaitingClientBanner extends StatelessWidget {
  const JobAwaitingClientBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_top, size: 16, color: Colors.orange.shade700),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Counter sent — waiting for client response.'.tr,
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
