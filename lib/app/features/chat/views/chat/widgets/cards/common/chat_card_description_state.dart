part of 'chat_card_description.dart';

class _ChatCardDescriptionState extends State<ChatCardDescription> {
  static const _collapsedLines = 2;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 13.sp,
      height: 1.45,
      color: const Color(0xFF4A4A4A),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChatCardSectionLabel('Job Description'.tr),
        LayoutBuilder(
          builder: (context, constraints) {
            final painter = TextPainter(
              text: TextSpan(text: widget.text, style: style),
              maxLines: _collapsedLines,
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            )..layout(maxWidth: constraints.maxWidth);
            final overflows = painter.didExceedMaxLines;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: Text(
                    widget.text,
                    maxLines: _expanded ? null : _collapsedLines,
                    overflow: _expanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
                if (overflows)
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        _expanded ? 'See less'.tr : 'See more'.tr,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
