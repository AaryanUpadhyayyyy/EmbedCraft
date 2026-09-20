import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_ninja/in_app_ninja.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/screens/login_screen.dart';
import 'package:untitled/screens/cart_screen.dart';
import 'package:untitled/screens/profile_screen.dart';
import 'package:untitled/screens/recipe_detail_screen.dart';
import 'package:untitled/screens/checkout_screen.dart';
import 'package:untitled/screens/membership_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
     await Firebase.initializeApp();
  } catch(e) {
     debugPrint("Firebase Init Failed: $e");
  }

  // When running via 'flutter run' (debug mode) it uses the staging key.
  // When running via 'flutter build apk/ios' (release mode) it uses the live key.
  final String apiKey = kReleaseMode 
      ? 'nk_live_bcecb88d32c3a9353e5e765f45e03055' // Production Key
      : 'nk_live_bcecb88d32c3a9353e5e765f45e03055'; // Using prod key for testing as well

  // Check if local backend is running, otherwise fallback to AWS
  String targetBaseUrl = 'https://api.embedcraft.com';
  try {
    final socket = await Socket.connect('192.168.0.10', 4000, timeout: const Duration(seconds: 2));
    socket.destroy();
    targetBaseUrl = 'http://192.168.0.10:4000';
    debugPrint("✅ Local backend detected. Using $targetBaseUrl");
  } catch (e) {
    debugPrint("⚠️ Local backend not reachable. Falling back to AWS production backend.");
  }

  // 1. Initialize InAppNinja SDK with Live Key & Debug Logs
  AppNinja.debug(true);
  await AppNinja.init(
    apiKey, 
    autoRender: true,
    navigatorKey: navigatorKey,
    baseUrl: targetBaseUrl,
  );

  // 2. Handle "Callback" Actions (formerly Custom) from Dashboard
  NinjaCallbackManager.onEvent.listen((event) {
    if (event.action == NINJA_COMPONENT_CTA_CLICK) {
      final data = event.data;
      final clickType = data['CLICK_TYPE'];
      
      if (clickType == 'custom') {
        final callbackId = data['eventName'];
        debugPrint("🔥 APP CALLBACK RECEIVED: $callbackId");
        
        if (callbackId == 'add_to_cart_promo') {
           ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
             const SnackBar(content: Text('🎉 Promo applied! Added to cart.'), backgroundColor: Colors.green)
           );
        } else if (callbackId == 'open_offers') {
            ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
             const SnackBar(content: Text('🔔 Opening Offers Page...'))
           );
        } else {
           ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
             SnackBar(content: Text('Callback Triggered: $callbackId'))
           );
        }
      }
    }
  });

  runApp(const EmbedShoppingApp());
}

class NinjaRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    AppNinja.clearAllNudges();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    AppNinja.clearAllNudges();
  }
}

final NinjaRouteObserver ninjaRouteObserver = NinjaRouteObserver();

class EmbedShoppingApp extends StatelessWidget {
  const EmbedShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'EmbedShopping',
      navigatorObservers: [ninjaRouteObserver],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFF3B82F6),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
      // 3. IMPORTANT: Wrap with NinjaApp for Screenshot Target Support
      builder: (context, child) {
        return NinjaApp(child: child!);
      },
      initialRoute: '/',
      routes: {
        '/': (context) => StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
               return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData && snapshot.data != null) {
               _restoreIdentity(snapshot.data!);
               return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      },
    );
  }

  Future<void> _restoreIdentity(User user) async {
     try {
       final prefs = await SharedPreferences.getInstance();
       final name = prefs.getString('user_name') ?? 'Shopping Enthusiast';
       final city = prefs.getString('user_city') ?? 'Bangalore';
       
       // 4. Re-identify on Session Restore with Safety
       AppNinja.identify({
          'user_id': user.uid,
          'name': name,
          'city': city,
          'email': user.email,
          'plan': 'bb_star', // Consistent with Dashboard segments
       });
     } catch(e) {
       debugPrint("SDK Identity Restore Failed: $e");
     }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _cartCount = 4;

  @override
  void initState() {
    super.initState();
    // 5. Track Events with 100% Property Parity
    AppNinja.track('screen_viewed', properties: {'screen_name': 'home_feed'});
    AppNinja.track('home_view', properties: {
      'time_of_day': DateTime.now().hour < 12 ? 'morning' : 'afternoon',
      'cart_items_count': _cartCount,
      'user_tier': 'Gold',
    });
  }

  void _openCart() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  void _openProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF2563EB).withOpacity(0.03),
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Action Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu_rounded, color: Color(0xFF1E293B)), 
                          onPressed: () {
                            AppNinja.getInstance().track(event: 'menu_clicked', properties: {
                              'menu_state': 'open', 
                              'active_screen': 'HomeScreen'
                            });
                          }
                        ).appNinjaIdentifier('menu_btn'),
                        Expanded(
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Deliver to', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  Flexible(child: Text('Home, Bangalore', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1E293B)), overflow: TextOverflow.ellipsis)),
                                  SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF2563EB)),
                                ],
                              ),
                            ],
                          ).appNinjaIdentifier('delivery_location_selector'),
                        ),
                        _buildCircleBtn(Icons.shopping_bag_outlined, _openCart, badge: _cartCount).appNinjaIdentifier('cart_btn'),
                        const SizedBox(width: 12),
                        _buildCircleBtn(Icons.card_giftcard_rounded, () {
                          AppNinja.getInstance().track(event: 'rewards_clicked', properties: {
                            'source': 'home_top_bar'
                          });
                        }).appNinjaIdentifier('rewards_btn'),
                        const SizedBox(width: 12),
                        _buildCircleBtn(Icons.person_outline, _openProfile).appNinjaIdentifier('profile_btn'),
                      ],
                    ),
                  ),
                ),
    
                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))],
                      ),
                      child: TextField(
                        onTap: () => AppNinja.getInstance().track(event: 'search_tapped', properties: {
                          'placeholder': 'Search for products...',
                          'previous_searches_count': 0
                        }),
                        decoration: const InputDecoration(
                          hintText: 'Search for "Organic Honey"',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF2563EB), size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ).appNinjaIdentifier('home_search_bar'),
                  ),
                ),
    
                // Ninja Stories (SDK Widget)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: NinjaStories(id: 'home_highlights'),
                  ),
                ),
    
                // Promo Banners
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 170,
                    child: PageView(
                      children: [
                        _buildPromoCard('FRESH DEALS', 'UP TO 50% OFF', 'Daily Greens & Fruits', 'https://images.unsplash.com/photo-1610348725531-843dff563e2c?auto=format&fit=crop&w=800&q=80', const Color(0xFF1E293B)),
                        _buildPromoCard('EAT SMART', 'NEW ARRIVALS', 'Organic superfoods', 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?auto=format&fit=crop&w=800&q=80', const Color(0xFF2563EB)),
                      ],
                    ),
                  ).appNinjaIdentifier('home_banner_list'),
                ),
    
                // Categories Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(child: Text('Browse Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)))),
                        TextButton(onPressed: () {}, child: const Text('See All', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold))).appNinjaIdentifier('see_all_categories_btn'),
                      ],
                    ),
                  ),
                ),
                // Horizontal Categories
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _buildCategoryItem('Fruits', '🍎', const Color(0xFFFEF2F2), 'cat_fruits'),
                        _buildCategoryItem('Veg', '🥦', const Color(0xFFF0FDF4), 'cat_veg'),
                        _buildCategoryItem('Dairy', '🥛', const Color(0xFFEFF6FF), 'cat_dairy'),
                        _buildCategoryItem('Bakery', '🥐', const Color(0xFFFFFBEB), 'cat_bakery'),
                        _buildCategoryItem('Meat', '🥩', const Color(0xFFFEF2F2), 'cat_meat'),
                      ],
                    ),
                  ).appNinjaIdentifier('home_category_list'),
                ),
    
                // Curated Grid
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                    child: Text('Curated For You', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    delegate: SliverChildListDelegate([
                      _buildModernProduct('Golden Honey', '500g', 320, 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=400&q=80', 'prod_honey', tag: 'BEST SELLER'),
                      _buildModernProduct('Blueberries', '250g', 240, 'https://images.unsplash.com/photo-1498557850523-fd3d118b962e?auto=format&fit=crop&w=400&q=80', 'prod_blueberries', tag: 'SUPERFOOD'),
                      _buildModernProduct('Avocado', '2 pcs', 180, 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?auto=format&fit=crop&w=400&q=80', 'prod_avocado'),
                      _buildModernProduct('Greek Yogurt', '200g', 85, 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=400&q=80', 'prod_yogurt', tag: 'NEW'),
                    ]),
                  ),
                ),
    
                // Membership Section (Maps to Container 5/Promo Banner)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)]),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Join bbStar', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                const Text('Free delivery + Extra cashback', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                               AppNinja.track('join_program_clicked', properties: {
                                 'program': 'bbStar',
                                 'referral_source': 'home_banner',
                                 'discount_value': 'Freedel + Cashback'
                               });
                               Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipScreen()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1E293B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('JOIN NOW'),
                          ).appNinjaIdentifier('join_bbstar_btn'),
                        ],
                      ),
                    ).appNinjaIdentifier('promo_banner_container'),
                  ),
                ),
    
                // Recipe Feature Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () {
                          AppNinja.track('featured_recipe_clicked');
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeDetailScreen()));
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          image: const DecorationImage(
                            image: NetworkImage('https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&w=1000&q=80'),
                            fit: BoxFit.cover
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(colors: [Colors.black87, Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter)
                          ),
                          alignment: Alignment.bottomLeft,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Recipe of the Day', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 12)),
                              Text('Hyderabadi Chicken Biryani', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      ),
                    ).appNinjaIdentifier('home_featured_recipe_card'),
                  ),
                ),
    
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -5))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: _buildNavItem(Icons.home_filled, 'Home', true, 'nav_home')),
              Expanded(child: _buildNavItem(Icons.search_rounded, 'Explore', false, 'nav_explore')),
              Expanded(child: _buildNavItem(Icons.local_offer_outlined, 'Offers', false, 'nav_offers')),
              Expanded(child: _buildNavItem(Icons.person_outline, 'Profile', false, 'nav_profile', onTap: _openProfile)),
            ],
          ),
        ).appNinjaIdentifier('home_bottom_nav'),
      ).appNinjaIdentifier('home_screen_scaffold');
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap, {int badge = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF1F5F9))),
            child: Icon(icon, size: 20, color: const Color(0xFF1E293B)),
          ),
          if (badge > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(String label, String title, String sub, String img, Color color) {
    return GestureDetector(
      onTap: () {
          AppNinja.track('banner_clicked', properties: {
            'banner_text': title,
            'banner_type': 'carousel',
            'bg_color_hex': color.value.toRadixString(16)
          });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover, opacity: 0.6),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
          ],
        ),
      ),
    ).appNinjaIdentifier('banner_${label.hashCode}');
  }

  Widget _buildCategoryItem(String name, String emoji, Color bg, String id) {
    return GestureDetector(
      onTap: () {
          AppNinja.track('category_clicked', properties: {
            'category_name': name,
            'section': 'horizontal_list',
            'has_subcategories': true
          });
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          ],
        ),
      ),
    ).appNinjaIdentifier(id);
  }

  Widget _buildModernProduct(String name, String qty, double price, String img, String id, {String? tag}) {
    return GestureDetector(
      onTap: () {
          AppNinja.track('product_clicked', properties: {
            'product_name': name,
            'price': price,
            'currency': 'INR',
            'in_stock': true,
            'category': 'Curated Grid'
          });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    Image.network(img, width: double.infinity, fit: BoxFit.cover),
                    if (tag != null)
                      Positioned(
                        top: 10, left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(6)),
                          child: Text(tag, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1),
                  Text(qty, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹$price', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B))),
                      GestureDetector(
                        onTap: () {
                           AppNinja.track('add_to_cart_clicked', properties: {
                              'product_name': name,
                              'price': price,
                              'quantity': 1,
                              'currency': 'INR'
                            });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ).appNinjaIdentifier('add_${name.replaceAll(' ', '_')}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).appNinjaIdentifier(id);
  }

  Widget _buildNavItem(IconData icon, String label, bool active, String id, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: () {
          const tabs = ['Home', 'Explore', 'Offers', 'Profile'];
          AppNinja.track('nav_tab_clicked', properties: {
              'tab_name': label,
              'tab_index': tabs.indexOf(label),
              'previous_tab': 'Home'
          });
          if (onTap != null) onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFF2563EB) : const Color(0xFF94A3B8), size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.bold : FontWeight.w500, color: active ? const Color(0xFF2563EB) : const Color(0xFF94A3B8))),
        ],
      ),
    ).appNinjaIdentifier(id);
  }
}
