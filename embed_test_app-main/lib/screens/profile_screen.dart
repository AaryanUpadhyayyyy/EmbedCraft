import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_ninja/in_app_ninja.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Loading...';
  String _city = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // 🚩 TRACK: Profile Viewed with full parity properties
    AppNinja.track('profile_viewed', properties: {
      'user_tier': 'bbStar',
      'days_since_signup': 120,
      'notifications_enabled': true
    });
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _name = prefs.getString('user_name') ?? 'User';
      _city = prefs.getString('user_city') ?? 'Unknown';
      _email = user?.email ?? '';
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // 🚩 TRACK: Logout with parity properties
    AppNinja.track('logout_clicked', properties: {
      'session_duration_minutes': 45,
      'reason': 'user_action'
    });
    AppNinja.logout();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return EmbedWidgetWrapper(
      id: 'profile_screen_scaffold',
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: const Color(0xFF2563EB),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 80,
                        child: EmbedWidgetWrapper(
                          id: 'profile_header_section',
                          child: Column(
                            children: [
                              EmbedWidgetWrapper(
                                id: 'profile_pic',
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Color(0xFFF1F5F9),
                                    child: Icon(Icons.person, size: 50, color: Color(0xFF2563EB)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              EmbedWidgetWrapper(
                                id: 'profile_name_text',
                                child: Text(_name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                              EmbedWidgetWrapper(
                                id: 'profile_email_text',
                                child: Text(_email, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Account Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 16),
                    _buildMenuItem(Icons.shopping_bag_outlined, 'My Orders', 'View all your past purchases'),
                    _buildMenuItem(Icons.favorite_border, 'Wishlist', 'Your saved items'),
                    _buildMenuItem(Icons.location_on_outlined, 'My Addresses', 'Manage delivery addresses'),
                    _buildMenuItem(Icons.payment_outlined, 'Payment Methods', 'Manage your cards & accounts'),
                    _buildMenuItem(Icons.notifications_none_rounded, 'Notifications', 'Control your alerts'),
                    _buildMenuItem(Icons.help_outline_rounded, 'Customer Support', 'Get help from our experts'),
                    
                    const SizedBox(height: 32),
                    EmbedWidgetWrapper(
                      id: 'profile_logout_btn',
                      child: GestureDetector(
                        onTap: () {
                           AppNinja.track('logout_clicked'); // Parity: Track without props first
                           _logout();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                              SizedBox(width: 8),
                              Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle) {
    return EmbedWidgetWrapper(
      id: 'profile_menu_${title.replaceAll(' ', '_').toLowerCase()}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 18),
          onTap: () {
             AppNinja.track('profile_menu_clicked', properties: {'menu_item': title});
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Clicked $title')));
          },
        ),
      ),
    );
  }
}
