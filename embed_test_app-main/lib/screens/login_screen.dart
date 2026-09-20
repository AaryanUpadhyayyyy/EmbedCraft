import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_ninja/in_app_ninja.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // To access HomeScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;
  
  bool _isLoading = false;
  bool _isLogin = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // 🚩 TRACK: Login Viewed with parity properties
    AppNinja.track('login_viewed', properties: {
      'prev_attempt_failed': false,
      'auth_method_default': 'email'
    });
    
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential;
      final emailDomain = _emailController.text.contains('@') ? _emailController.text.split('@').last : 'invalid';

      if (_isLogin) {
        // 🚩 TRACK: Login Submit with parity
        AppNinja.track('login_submit_clicked', properties: {
          'type': 'login',
          'email_domain': emailDomain,
          'password_length': _passwordController.text.length
        });
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // 🚩 TRACK: Signup Submit with parity
        AppNinja.track('signup_submit_clicked', properties: {
          'type': 'signup',
          'email_domain': emailDomain,
          'phone_provided': _phoneController.text.isNotEmpty
        });
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      final userId = userCredential.user!.uid;
      final name = _nameController.text.isNotEmpty ? _nameController.text : 'BigBasket User';
      final city = _cityController.text.isNotEmpty ? _cityController.text : 'Unknown';
      final phone = _phoneController.text.isNotEmpty ? _phoneController.text : '';
      final gender = _selectedGender ?? 'Unknown';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      await prefs.setString('user_name', name);
      await prefs.setString('user_city', city);

      // 🎯 FIRESTORE PARITY
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'name': name,
          'email': _emailController.text.trim(),
          'city': city,
          'phone': phone,
          'gender': gender,
          'plan': 'bb_star',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore Error: $e');
      }

      // 🎯 DEEP SDK IDENTIFICATION (Full Parity)
      await AppNinja.identify({
        'user_id': userId,
        'name': name,
        'city': city,
        'phone': phone,
        'gender': gender,
        'email': _emailController.text.trim(),
        'plan': 'bb_star', 
        
        'is_anonymous': userCredential.user?.isAnonymous ?? false,
        'email_verified': userCredential.user?.emailVerified ?? false,
        'creation_time': userCredential.user?.metadata.creationTime?.toIso8601String(),
        'last_sign_in_time': userCredential.user?.metadata.lastSignInTime?.toIso8601String(),
        'provider': userCredential.user?.providerData.isNotEmpty == true 
            ? userCredential.user!.providerData.first.providerId 
            : 'password',
        'app_version': '1.0.0+1',
        'platform': Theme.of(context).platform.toString(),
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NinjaApp(child: HomeScreen())),
        );
      }

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication Failed'), 
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF2563EB).withOpacity(0.05),
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  // App Icon
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_cart_rounded, size: 48, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'EmbedShopping',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -1),
                  ),
                  const Text(
                    'Your Premium Shopping Destination',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 48),
                  
                  // Login/Signup Toggle
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLogin = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: _isLogin ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _isLogin ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
                              ),
                              margin: const EdgeInsets.all(4),
                              alignment: Alignment.center,
                              child: Text('Login', style: TextStyle(fontWeight: _isLogin ? FontWeight.bold : FontWeight.w500, color: _isLogin ? const Color(0xFF2563EB) : const Color(0xFF64748B))),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLogin = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: !_isLogin ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: !_isLogin ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
                              ),
                              margin: const EdgeInsets.all(4),
                              alignment: Alignment.center,
                              child: Text('Sign Up', style: TextStyle(fontWeight: !_isLogin ? FontWeight.bold : FontWeight.w500, color: !_isLogin ? const Color(0xFF2563EB) : const Color(0xFF64748B))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildTextField(_emailController, 'Email Address', Icons.email_outlined),
                  const SizedBox(height: 16),
                  _buildTextField(_passwordController, 'Password', Icons.lock_outline, obscure: true),
                  
                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    _buildTextField(_nameController, 'Full Name', Icons.person_outline),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_cityController, 'City', Icons.location_city_outlined)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(border: InputBorder.none, labelText: 'Gender', labelStyle: TextStyle(fontSize: 12)),
                                value: _selectedGender,
                                items: const [
                                  DropdownMenuItem(value: 'Male', child: Text('Male', style: TextStyle(fontSize: 14))),
                                  DropdownMenuItem(value: 'Female', child: Text('Female', style: TextStyle(fontSize: 14))),
                                  DropdownMenuItem(value: 'Other', child: Text('Other', style: TextStyle(fontSize: 14))),
                                ],
                                onChanged: (v) => setState(() => _selectedGender = v),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_phoneController, 'Phone Number', Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                  ],

                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isLogin ? 'Sign In' : 'Get Started', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  
                  const SizedBox(height: 24),
                  if (_isLogin)
                    TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
