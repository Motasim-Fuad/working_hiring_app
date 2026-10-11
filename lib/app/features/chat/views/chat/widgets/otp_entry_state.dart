part of 'otp_entry.dart';

class _OtpEntryState extends State<OtpEntry> {
  final _ctrl = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final otp = _ctrl.text.trim();
    if (otp.length != 6) {
      setState(() => _errorText = 'Enter the 6-digit code.'.tr);
      return;
    }
    setState(() {
      _submitting = true;
      _errorText = null;
    });

    final success = await widget.onSubmit(otp);
    // On success the parent replaces this card once the order completes.
    if (!mounted || success) return;

    setState(() {
      _submitting = false;
      _errorText =
          'Incorrect code. Please check with the customer and try again.'.tr;
    });
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14.r),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChatCardNotice(
          title: 'Work started'.tr,
          text:
              'Ask the customer for their 6-digit confirmation code to complete the job.'
                  .tr,
          color: AppColors.primary,
          icon: Icons.key_rounded,
        ),
        SizedBox(height: 12.h),
        TextField(
          controller: _ctrl,
          enabled: !_submitting,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 8,
          ),
          onChanged: (_) {
            if (_errorText != null) setState(() => _errorText = null);
          },
          decoration: InputDecoration(
            counterText: '',
            hintText: 'Enter OTP'.tr,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              letterSpacing: 0,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: const Color(0xFFF6F7F9),
            errorText: _errorText,
            errorMaxLines: 2,
            border: _border(Colors.transparent),
            enabledBorder: _border(
              _errorText != null ? Colors.redAccent : Colors.transparent,
            ),
            focusedBorder: _border(AppColors.primary),
          ),
        ),
        SizedBox(height: 10.h),
        ChatCardButton(
          label: _submitting ? AppStrings.pleaseWait.tr : 'Complete Work'.tr,
          icon: _submitting ? null : Icons.task_alt_rounded,
          color: AppColors.primary,
          onPressed: _submitting ? null : _handleSubmit,
        ),
      ],
    );
  }
}
