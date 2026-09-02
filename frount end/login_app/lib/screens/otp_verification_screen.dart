import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api_service.dart';
import '../components.dart';
import '../theme.dart';
import 'dashboard_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _resendCountdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _enteredOtp {
    return _controllers.map((c) => c.text.trim()).join();
  }

  void _verifyOtp() async {
    final otp = _enteredOtp;
    if (otp.length < 6) {
      _showSnackBar('Please enter all 6 digits of your OTP code');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.verifyOtp(widget.email, otp);
      if (!mounted) return;
      
      _showSnackBar('Verification successful! Welcome.');
      
      // Navigate to Dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen(user: res['user'])),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resendOtp() async {
    if (_resendCountdown > 0 || _isResending) return;

    setState(() => _isResending = true);
    try {
      final res = await ApiService.resendOtp(widget.email);
      if (!mounted) return;
      _showSnackBar(res['message'] ?? 'New OTP sent to your email');
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildOtpDigitBox(int index) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focusNodes[index].hasFocus ? AppTheme.primary : Colors.white.withOpacity(0.8),
          width: _focusNodes[index].hasFocus ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
            if (_enteredOtp.length == 6) {
              _verifyOtp();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LiquidBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GlassPanel(
                    borderRadius: 28.0,
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        // Shield Icon
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.2),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.mark_email_read_outlined, size: 44, color: AppTheme.primary),
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'OTP Verification',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'An OTP has been sent to your email address. Please check your Gmail and enter the OTP to verify your account.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.onSurfaceVariant.withOpacity(0.9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryFixedDim.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.email,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // 6 Digit boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) => _buildOtpDigitBox(index)),
                        ),
                        const SizedBox(height: 28),

                        _isLoading
                            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                            : GlowButton(
                                text: 'Verify & Login',
                                icon: Icons.arrow_forward_rounded,
                                onPressed: _verifyOtp,
                              ),
                        const SizedBox(height: 24),

                        // Resend OTP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't receive code? ",
                              style: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.8), fontSize: 13),
                            ),
                            _resendCountdown > 0
                                ? Text(
                                    'Resend in ${_resendCountdown}s',
                                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                  )
                                : GestureDetector(
                                    onTap: _resendOtp,
                                    child: Text(
                                      _isResending ? 'Sending...' : 'Resend OTP',
                                      style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 16, color: AppTheme.onSurfaceVariant),
                          label: const Text('Back to Login', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
