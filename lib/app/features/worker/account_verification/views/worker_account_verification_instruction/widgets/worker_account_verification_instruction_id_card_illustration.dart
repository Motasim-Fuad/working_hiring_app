import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WorkerAccountVerificationInstructionIdCardIllustration
    extends StatelessWidget {
  const WorkerAccountVerificationInstructionIdCardIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.w.clamp(250.0, 360.0),
      height: 190.h.clamp(158.0, 228.0),
      decoration: BoxDecoration(
        color: Color(0xFF78A8B6),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Text(
              "ID CARD".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
              ),
            ),
          ),

          Positioned(
            top: 60,
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFA6CED7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 15,
                    left: 15,
                    bottom: 15,
                    width: 70,
                    child: Container(
                      color: Color(0xFFF2E7C9),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: 70,
                              height: 30,
                              color: Color(0xFF1A3348),
                            ),
                          ),
                          Positioned(
                            top: 15,
                            child: Container(
                              width: 35,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Color(0xFFF3C774),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            child: Container(
                              width: 40,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Color(0xFF333333),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 20,
                    left: 100,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 6,
                          color: Color(0xFF6B97A3),
                          width: 140,
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              height: 6,
                              color: Color(0xFF6B97A3),
                              width: 60,
                            ),
                            SizedBox(width: 10),
                            Container(
                              height: 6,
                              color: Color(0xFF6B97A3),
                              width: 40,
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Container(
                          height: 6,
                          color: Color(0xFF6B97A3),
                          width: 100,
                        ),
                        SizedBox(height: 12),
                        Container(
                          height: 6,
                          color: Color(0xFF6B97A3),
                          width: 120,
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              height: 6,
                              color: Color(0xFF6B97A3),
                              width: 50,
                            ),
                            SizedBox(width: 10),
                            Container(
                              height: 6,
                              color: Color(0xFF6B97A3),
                              width: 30,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 15,
                    bottom: 15,
                    right: 15,
                    width: 20,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        15,
                        (index) =>
                            Container(height: 2, color: Color(0xFF455A64)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
