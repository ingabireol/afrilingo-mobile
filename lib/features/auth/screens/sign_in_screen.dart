import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as Math;

// Internal imports with new feature structure
import 'package:afrilingo/features/auth/services/auth_service.dart';
import 'package:afrilingo/features/auth/services/google_auth_service.dart';
import 'package:afrilingo/core/theme/theme_provider.dart';
import 'package:afrilingo/features/auth/widgets/social_button.dart';
import 'package:afrilingo/features/dashboard/screens/user_dashboard.dart';
import 'package:afrilingo/features/admin/screens/admin_dashboard.dart';
import 'package:afrilingo/features/profile/screens/profile_setup_screen.dart';
import 'package:afrilingo/features/onboarding/screens/aboutus.dart';
import 'package:afrilingo/features/auth/screens/sign_up.dart';

// African-inspired color palette
const Color kPrimaryColor = Color(0xFF8B4513); // Brown
const Color kSecondaryColor = Color(0xFFC78539); // Light brown
const Color kAccentColor = Color(0xFF546CC3); // Blue accent
const Color kBackgroundColor = Color(0xFFF9F5F1); // Cream background
const Color kTextColor = Color(0xFF333333); // Dark text
const Color kLightTextColor = Color(0xFF777777); // Light text
const Color kCardColor = Color(0xFFFFFFFF); // White card background
const Color kDividerColor = Color(0xFFEEEEEE); // Light divider

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _authService = AuthService();
  final _googleAuthService = GoogleAuthServiceNew();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Validation methods
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    // Comprehensive email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutBack),
      ),
    );

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Helper method to handle successful authentication and navigate
  void _handleSuccessfulAuth(Map<String, dynamic> result) async {
    try {
      // First check if the user has a profile
      final profileExists = await _checkUserProfileExists();

      if (!profileExists) {
        // If no profile exists, navigate to profile setup
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileSetupScreen(isNewUser: false)),
          (route) => false,
        );
        return;
      }

      // If profile exists, continue with normal flow
      if (result.containsKey('isAdmin') && result['isAdmin'] == true) {
        // Navigate to admin dashboard if user is admin
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
          (route) => false,
        );
      } else {
        // Navigate to user dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserDashboard()),
          (route) => false,
        );
      }
    } catch (e) {
      print("Error checking profile: $e");
      // If there's an error checking profile, default to profile setup
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => ProfileSetupScreen(isNewUser: false)),
        (route) => false,
      );
    }
  }

  // Check if user has a profile
  Future<bool> _checkUserProfileExists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return false;

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/v1/profile/exists'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Profile check response: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Make sure to check the actual data structure from your API
        final exists = data['data'] ?? false;
        return exists == true;
      }

      // If error or unexpected response, assume no profile exists
      return false;
    } catch (e) {
      print("Error checking profile existence: $e");
      // On error, assume no profile exists to ensure user creates one
      return false;
    }
  }

  void _handleSignIn() async {
    if (_isLoading) return;

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _authService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (result['success'] == true) {
            _handleSuccessfulAuth(result);
          } else {
            _showErrorDialog(result['message']);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showErrorDialog(e.toString());
        }
      }
    }
  }

  void _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      print("Starting Google Sign-In process...");
      final result = await _googleAuthService.signInWithGoogle();
      print("Google Sign-In result: $result");

      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });

        // Check if authentication was successful
        if (result != null && (result['success'] == true)) {
          print("Google Sign-In successful, checking profile");

          // Use the same profile check logic for Google sign-in
          _handleSuccessfulAuth(result);
        } else {
          // Extract error message with fallback
          final errorMessage = result != null && result['message'] != null
              ? result['message']
              : 'Google authentication failed. Please try again.';
          print("Google Sign-In failed: $errorMessage");
          _showErrorDialog(errorMessage);
        }
      }
    } catch (e) {
      print("Google Sign-In exception: $e");
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
        _showErrorDialog("Authentication error: $e");
      }
    }
  }

  void _showErrorDialog(String message) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Create a user-friendly message from technical error
    String userFriendlyMessage = 'Unable to sign in. Please try again.';

    // Handle specific error cases with friendly messages
    if (message.toLowerCase().contains('socket') ||
        message.toLowerCase().contains('connection') ||
        message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('timeout')) {
      userFriendlyMessage =
          'Cannot connect to server. Please check your internet connection and try again.';
    } else if (message.toLowerCase().contains('unauthorized') ||
        message.toLowerCase().contains('invalid credentials') ||
        message.toLowerCase().contains('password') ||
        message.toLowerCase().contains('credentials')) {
      userFriendlyMessage = 'Incorrect email or password. Please try again.';
    } else if (message.toLowerCase().contains('not found') ||
        message.toLowerCase().contains('no account')) {
      userFriendlyMessage =
          'Account not found. Please check your email or create a new account.';
    } else if (message.toLowerCase().contains('google')) {
      userFriendlyMessage =
          'Google sign-in failed. Please try again or use email login.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sign In Failed',
          style: TextStyle(
            color: themeProvider.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(height: 16),
            Text(userFriendlyMessage,
                style: TextStyle(color: themeProvider.textColor, fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: themeProvider.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: themeProvider.isDarkMode
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(scale: _scaleAnimation, child: child),
              ),
            );
          },
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo or icon
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: themeProvider.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.language,
                          size: 60,
                          color: themeProvider.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Header
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sign in to continue your language learning journey',
                      style: TextStyle(
                        fontSize: 16,
                        color: themeProvider.lightTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Form
                    const SizedBox(height: 40),
                    Card(
                      elevation: 4,
                      color: themeProvider.cardColor,
                      shadowColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildInputField(
                                Icons.email_outlined,
                                'Email',
                                controller: _emailController,
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 20),
                              _buildInputField(
                                Icons.lock_outline,
                                'Password',
                                isPassword: true,
                                controller: _passwordController,
                                validator: _validatePassword,
                              ),

                              // Forgot Password
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // Handle forgot password
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: themeProvider.primaryColor,
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              // Sign In Button
                              const SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _handleSignIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeProvider.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                  disabledBackgroundColor: themeProvider
                                      .primaryColor
                                      .withOpacity(0.6),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Divider
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: themeProvider.dividerColor,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              color: themeProvider.lightTextColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: themeProvider.dividerColor,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    // Social Buttons
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          'assets/google_icon.png',
                          onTap: _handleGoogleSignIn,
                        ),
                      ],
                    ),

                    // Sign Up Option
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: TextStyle(color: themeProvider.lightTextColor),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const SignUpScreen(),
                                transitionsBuilder: (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  var begin = const Offset(1.0, 0.0);
                                  var end = Offset.zero;
                                  var curve = Curves.ease;
                                  var tween = Tween(
                                    begin: begin,
                                    end: end,
                                  ).chain(CurveTween(curve: curve));
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: themeProvider.primaryColor,
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Input field builder
  Widget _buildInputField(
    IconData icon,
    String label, {
    bool isPassword = false,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: themeProvider.lightTextColor,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: themeProvider.isDarkMode
                ? themeProvider.cardColor
                : Colors.grey.shade50,
            prefixIcon: Icon(icon, color: themeProvider.lightTextColor),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: themeProvider.lightTextColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeProvider.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeProvider.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 16,
          ),
          validator: validator,
        ),
      ],
    );
  }

  // Social login button
  Widget _buildSocialButton(String iconPath, {required VoidCallback onTap}) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: themeProvider.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: themeProvider.dividerColor, width: 1),
        ),
        child: Center(
          child: _isGoogleLoading && iconPath == 'assets/google_icon.png'
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: themeProvider.primaryColor,
                    strokeWidth: 2,
                  ),
                )
              : Image.asset(
                  iconPath,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}
