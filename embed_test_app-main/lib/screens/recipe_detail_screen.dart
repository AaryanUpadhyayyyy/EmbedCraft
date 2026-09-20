import 'package:flutter/material.dart';
import 'package:in_app_ninja/in_app_ninja.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final List<String> _ingredients = [
    '2 cups Premium Basmati Rice',
    '500g Fresh Chicken Thighs',
    '2 Large Onions, caramelized',
    '1 tbsp Pure Ginger-Garlic paste',
    '1 cup Creamy Greek Yogurt',
    'Hand-picked Saffron Strands',
    'Fresh Organic Coriander & Mint'
  ];
  
  final Set<int> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    // 📍 Track page navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNinja.trackPage('recipe_detail', context);
    });
    
    // 🚩 TRACK: Recipe Viewed with full parity
    AppNinja.track('recipe_viewed', properties: {
      'recipe_name': 'Hyderabadi Chicken Biryani',
      'category': 'Main Course',
      'difficulty': 'Medium'
    });
  }

  void _toggleIngredient(int index) {
    setState(() {
      if (_checkedIngredients.contains(index)) {
        _checkedIngredients.remove(index);
      } else {
        _checkedIngredients.add(index);
        // 🚩 TRACK: Ingredient Checked with parity
        AppNinja.track('ingredient_checked', properties: {
          'ingredient': _ingredients[index],
          'total_checked': _checkedIngredients.length + 1
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header with Parallax Hero Image
          SliverAppBar(
            expandedHeight: 350.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF1E293B),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&w=1000&q=80',
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Container
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFDE68A), borderRadius: BorderRadius.circular(6)),
                        child: const Text('BEST SELLER', style: TextStyle(color: Color(0xFF92400E), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Hyderabadi Chicken Biryani', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  const Text('An aromatic, mouth-watering masterpiece of layers of fluffy rice and marinated chicken.', style: TextStyle(color: Color(0xFF64748B), fontSize: 15, height: 1.5)),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                       _buildMeta(Icons.timer_outlined, '45 mins'),
                       _buildMeta(Icons.local_fire_department_outlined, '650 kCal'),
                       _buildMeta(Icons.restaurant_outlined, 'Serves 4'),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  const Text('Ingredients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Ingredients List (Granular IDs)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final isChecked = _checkedIngredients.contains(index);
                return EmbedWidgetWrapper(
                  id: 'ingredient_item_$index',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: GestureDetector(
                      onTap: () => _toggleIngredient(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isChecked ? const Color(0xFFF8FAFC) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isChecked ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              color: isChecked ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _ingredients[index],
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isChecked ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                                  decoration: isChecked ? TextDecoration.lineThrough : null,
                                  fontWeight: isChecked ? FontWeight.normal : FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: _ingredients.length,
            ),
          ),

          // Method / Instructions
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 40, 24, 16),
              child: Text('Method', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final steps = [
                    'Marinate the chicken with spices and yogurt for 2 hours.',
                    'Parboil the rice with whole spices until 70% cooked.',
                    'Layer the marinated chicken and rice in a heavy-bottomed pot.',
                    'Seal the pot and cook on low flame (Dum) for 30 minutes.'
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('0${index + 1}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF2563EB).withOpacity(0.2))),
                        const SizedBox(width: 16),
                        Expanded(child: Text(steps[index], style: const TextStyle(fontSize: 16, color: Color(0xFF475569), height: 1.6))),
                      ],
                    ),
                  );
                },
                childCount: 4,
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: EmbedWidgetWrapper(
        id: 'recipe_fab',
        child: FloatingActionButton.extended(
          onPressed: () {
            // 🚩 TRACK: Cook Now with full parity
            AppNinja.track('cook_now_clicked', properties: {
              'recipe_id': 'biryani_001',
              'timestamp': DateTime.now().toIso8601String()
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Starting Cooking Mode...'), behavior: SnackBarBehavior.floating));
          },
          label: const Text('Start Cooking', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          icon: const Icon(Icons.play_arrow_rounded),
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildMeta(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 12)),
      ],
    );
  }
}
