import 'package:flutter/material.dart';
import '../api_service.dart';
import '../components.dart';
import '../theme.dart';

import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  String? _emailError;
  bool _isEmailValid = false;

  final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );

  void _validateEmail(String value) {
    final trimmed = value.trim();
    setState(() {
      if (trimmed.isEmpty) {
        _emailError = null;
        _isEmailValid = false;
      } else if (!_emailRegex.hasMatch(trimmed)) {
        _emailError = 'Please enter a valid email address (e.g. name@gmail.com)';
        _isEmailValid = false;
      } else {
        _emailError = null;
        _isEmailValid = true;
      }
    });
  }

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      _showSnackBar('Please enter your full name');
      return;
    }

    if (email.isEmpty) {
      _showSnackBar('Please enter your email address');
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
        _isEmailValid = false;
      });
      _showSnackBar('Please enter a valid email address');
      return;
    }

    if (mobile.isEmpty) {
      _showSnackBar('Please enter your mobile number');
      return;
    }

    if (password.isEmpty || password.length < 6) {
      _showSnackBar('Password must be at least 6 characters long');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match!');
      return;
    }

    if (!_agreedToTerms) {
      _showSnackBar('Please agree to the Terms of Service & Privacy Policy');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.register(
        name,
        email,
        mobile,
        password,
      );
      if (!mounted) return;
      
      final notice = res['message'] ?? 'An OTP has been sent to your email address. Please check your Gmail and enter the OTP to verify your account.';
      _showSnackBar(notice);

      // Navigate directly to OTP Verification Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(email: email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return LiquidBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
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
                      child: Icon(Icons.sports_soccer, size: 44, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Create Your Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Join tournaments and connect with players',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),

                  GlassPanel(
                    borderRadius: 28.0,
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Full Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                        const SizedBox(height: 8),
                        GlassInput(hintText: 'John Doe', prefixIcon: Icons.person_outline, controller: _nameController),
                        const SizedBox(height: 18),

                        const Text('Email Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                        const SizedBox(height: 8),
                        GlassInput(
                          hintText: 'john@example.com',
                          prefixIcon: Icons.mail_outline,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: _validateEmail,
                          borderColor: _emailError != null
                              ? Colors.red.withOpacity(0.8)
                              : (_isEmailValid ? Colors.green.withOpacity(0.8) : null),
                          suffixIcon: _emailController.text.isNotEmpty
                              ? (_isEmailValid
                                  ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20)
                                  : (_emailError != null
                                      ? const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20)
                                      : null))
                              : null,
                        ),
                        if (_emailError != null) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, size: 14, color: Colors.red),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _emailError!,
                                    style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),

                        const Text('Mobile Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                        const SizedBox(height: 8),
                        GlassInput(hintText: '+1 (555) 000-0000', prefixIcon: Icons.phone_iphone, controller: _mobileController, keyboardType: TextInputType.phone),
                        const SizedBox(height: 18),

                        const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                        const SizedBox(height: 8),
                        GlassInput(
                          hintText: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          controller: _passwordController,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 18),

                        const Text('Confirm Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                        const SizedBox(height: 8),
                        GlassInput(
                          hintText: '••••••••',
                          prefixIcon: Icons.lock_reset,
                          obscureText: _obscurePassword,
                          controller: _confirmPasswordController,
                        ),
                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreedToTerms,
                                onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                                activeColor: AppTheme.primaryContainer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13),
                                  children: [
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(text: 'Terms of Service', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                    TextSpan(text: ' and '),
                                    TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _isLoading
                            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                            : GlowButton(
                                text: 'Create Account',
                                icon: Icons.arrow_forward_rounded,
                                onPressed: _register,
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Login', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      ),
                    ],
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

