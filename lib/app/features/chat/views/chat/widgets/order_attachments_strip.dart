import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/widgets/shimmer/app_shimmer.dart';
import 'package:working_hiring/app/core/widgets/shimmer/shimmer_box.dart';

class OrderAttachmentsStrip extends StatelessWidget {
  final List<String> urls;

  const OrderAttachmentsStrip({super.key, required this.urls});

  bool _isPdf(String url) =>
      Uri.tryParse(url)?.path.toLowerCase().endsWith('.pdf') ??
      url.toLowerCase().contains('.pdf');

  void _openImage(String url) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.w),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => SizedBox(
                    height: 240.h,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                  errorWidget: (_, _, _) => _placeholder(
                    Icons.broken_image_outlined,
                    Colors.grey.shade400,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(IconData icon, Color color) => Container(
    width: 68.r,
    height: 68.r,
    color: const Color(0xFFF6F7F9),
    alignment: Alignment.center,
    child: Icon(icon, color: color, size: 26.sp),
  );

  Widget _thumbnail(BuildContext context, String url) {
    final cacheSize = (68.r * MediaQuery.devicePixelRatioOf(context)).round();
    return CachedNetworkImage(
      imageUrl: url,
      width: 68.r,
      height: 68.r,
      fit: BoxFit.cover,
      memCacheWidth: cacheSize,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, _) => AppShimmer(
        child: ShimmerBox(width: 68.r, height: 68.r, radius: 12.r),
      ),
      errorWidget: (_, _, _) =>
          _placeholder(Icons.broken_image_outlined, Colors.grey.shade400),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 68.r,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final url = urls[index];
          final isPdf = _isPdf(url);
          return GestureDetector(
            onTap: isPdf ? null : () => _openImage(url),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE6E8EC)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11.r),
                child: isPdf
                    ? _placeholder(Icons.picture_as_pdf, Colors.red.shade400)
                    : _thumbnail(context, url),
              ),
            ),
          );
        },
      ),
    );
  }
}
