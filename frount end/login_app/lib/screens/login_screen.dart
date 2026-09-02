import 'package:flutter/material.dart';
import '../api_service.dart';
import '../components.dart';
import '../theme.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty) {
      _showSnackBar('Please enter your email or phone');
      return;
    }

    if (password.isEmpty) {
      _showSnackBar('Please enter your password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.login(
        identifier,
        password,
      );
      if (!mounted) return;

      if (res['status'] == 'otp_required') {
        _showSnackBar(res['message'] ?? 'OTP verification required for first login.');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              email: res['email'] ?? identifier,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen(user: res['user'])),
        );
      }
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
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GlassPanel(
                    borderRadius: 28.0,
                    padding: const EdgeInsets.all(36.0),
                    child: Column(
                      children: [
                        // Logo area
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
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.sports_soccer, size: 44, color: AppTheme.primary),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Login to continue your sports journey',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Form
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                              child: Text('Email or Mobile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
                            ),
                            GlassInput(
                              hintText: 'Enter your email or phone',
                              prefixIcon: Icons.person_outline,
                              controller: _identifierController,
                            ),
                            const SizedBox(height: 18),
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                              child: Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
                            ),
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
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text('Forgot Password?', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _isLoading
                                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                                : GlowButton(
                                    text: 'Login',
                                    icon: Icons.arrow_forward_rounded,
                                    onPressed: _login,
                                  ),
                          ],
                        ),

                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(child: Divider(color: AppTheme.onSurfaceVariant.withOpacity(0.2))),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('OR', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant, fontSize: 13)),
                            ),
                            Expanded(child: Divider(color: AppTheme.onSurfaceVariant.withOpacity(0.2))),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Social Login
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.7),
                              side: BorderSide(color: Colors.white.withOpacity(0.8)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.g_mobiledata, size: 32, color: Colors.black),
                                SizedBox(width: 8),
                                Text('Continue with Google', style: TextStyle(color: AppTheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? ", style: TextStyle(color: AppTheme.onSurfaceVariant)),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                              },
                              child: const Text('Sign Up', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                            ),
                          ],
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
