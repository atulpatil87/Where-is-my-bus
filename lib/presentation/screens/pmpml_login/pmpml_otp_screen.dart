import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';
import 'package:busindia/core/theme/app_text_styles.dart';
import '../../providers/pmpml_auth_provider.dart';

class PmpmlOtpScreen extends ConsumerStatefulWidget {
  const PmpmlOtpScreen({super.key});

  @override
  ConsumerState<PmpmlOtpScreen> createState() => _PmpmlOtpScreenState();
}

class _PmpmlOtpScreenState extends ConsumerState<PmpmlOtpScreen> {
  final _mobileCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _mobileFocus = FocusNode();
  final _otpFocus = FocusNode();

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _otpCtrl.dispose();
    _mobileFocus.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(pmpmlAuthProvider);

    // Auto-navigate out on success
    ref.listen<PmpmlAuthState>(pmpmlAuthProvider, (_, next) {
      if (next.isAuthenticated && context.mounted) {
        Navigator.of(context).pop(true);
      }
    });

    final isOtpSent = authState.step == PmpmlAuthStep.otpSent ||
        authState.step == PmpmlAuthStep.verifying ||
        authState.step == PmpmlAuthStep.error;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Connect to PMPML'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryOrange.withOpacity(0.12),
                      AppColors.accentBlue.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🚌', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apli PMPML',
                            style: AppTextStyles.subHead.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Login to see live buses, real schedules & directions across Pune.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Step indicator
              _StepIndicator(currentStep: isOtpSent ? 1 : 0),

              const SizedBox(height: AppSpacing.xl),

              if (!isOtpSent) ...[
                // Mobile number input
                Text('Mobile Number',
                    style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange)),
                const SizedBox(height: AppSpacing.sm),
                _buildTextField(
                  controller: _mobileCtrl,
                  focusNode: _mobileFocus,
                  hint: 'Enter 10-digit mobile number',
                  prefix: '+91 ',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildPrimaryButton(
                  label: 'Send OTP',
                  icon: LucideIcons.send,
                  isLoading: authState.step == PmpmlAuthStep.sendingOtp,
                  onPressed: () {
                    final mobile = _mobileCtrl.text.trim();
                    if (mobile.length != 10) {
                      _showSnack('Enter a valid 10-digit mobile number');
                      return;
                    }
                    ref.read(pmpmlAuthProvider.notifier).sendOtp(mobile);
                  },
                ),
              ] else ...[
                // OTP input
                Text(
                  'OTP sent to +91 ${authState.mobile ?? ''}',
                  style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Check your SMS inbox.',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  controller: _otpCtrl,
                  focusNode: _otpFocus,
                  hint: 'Enter 4–6 digit OTP',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildPrimaryButton(
                  label: 'Verify OTP',
                  icon: LucideIcons.checkCircle,
                  isLoading: authState.step == PmpmlAuthStep.verifying,
                  onPressed: () {
                    final otp = _otpCtrl.text.trim();
                    if (otp.length < 4) {
                      _showSnack('Enter a valid OTP');
                      return;
                    }
                    ref.read(pmpmlAuthProvider.notifier).verifyOtp(otp);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: TextButton(
                    onPressed: () {
                      ref.read(pmpmlAuthProvider.notifier).resetToIdle();
                      _otpCtrl.clear();
                    },
                    child: Text(
                      'Change number / Resend OTP',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentBlue),
                    ),
                  ),
                ),
              ],

              // Error message
              if (authState.step == PmpmlAuthStep.error &&
                  authState.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.errorMessage!,
                          style: AppTextStyles.caption
                              .copyWith(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // Privacy note
              Center(
                child: Text(
                  '🔒 Your number is only used to authenticate with PMPML.\nWe do not store it on our servers.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    String? prefix,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (prefix != null)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusMedium),
                  bottomLeft: Radius.circular(AppSpacing.radiusMedium),
                ),
              ),
              child: Text(prefix,
                  style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange)),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon, size: 18),
        label: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep; // 0 = phone, 1 = OTP

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(0, '1', 'Mobile'),
        Expanded(
          child: Container(
            height: 2,
            color: currentStep >= 1
                ? AppColors.primaryOrange
                : AppColors.divider,
          ),
        ),
        _dot(1, '2', 'OTP'),
      ],
    );
  }

  Widget _dot(int step, String label, String title) {
    final active = currentStep >= step;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.primaryOrange : AppColors.divider,
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  color: active ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                )),
          ),
        ),
        const SizedBox(height: 4),
        Text(title,
            style: TextStyle(
              fontSize: 10,
              color: active ? AppColors.primaryOrange : AppColors.textSecondary,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            )),
      ],
    );
  }
}
