import 'package:flutter/material.dart';
import 'package:in_app_ninja/in_app_ninja.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  String _selectedPlan = 'gold';
  double _savingsEstimation = 500;
  bool _autoRenew = true;
  bool _newsletter = false;

  @override
  void initState() {
    super.initState();
    // 🚩 TRACK: Page Viewed with parity
    AppNinja.track('membership_page_viewed', properties: {'source': 'profile_tab'});
  }

  void _selectPlan(String plan, double price) {
    setState(() => _selectedPlan = plan);
    // 🚩 TRACK: Plan Selected with full parity properties
    AppNinja.track('membership_plan_selected', properties: {
      'plan_name': plan,
      'plan_price': price,
      'previous_plan': 'none'
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Embed Plus', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Selector Header
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Text('Choose your premium plan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5)),
            ),
            
            SizedBox(
              height: 240,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPlanCard('Silver', '₹299/mo', [const Color(0xFF94A3B8), const Color(0xFF64748B)], 'silver', 299),
                  _buildPlanCard('Gold', '₹499/mo', [const Color(0xFFF59E0B), const Color(0xFFD97706)], 'gold', 499),
                  _buildPlanCard('Platinum', '₹999/mo', [const Color(0xFF1E293B), const Color(0xFF0F172A)], 'platinum', 999),
                ],
              ),
            ),

            const SizedBox(height: 40),
            
            // Savings Calculator (Parity logic)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estimate your savings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 8),
                    Text('Monthly Spend: ₹${_savingsEstimation.toInt()}', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                    EmbedWidgetWrapper(
                      id: 'savings_slider',
                      child: Slider(
                        value: _savingsEstimation,
                        min: 500,
                        max: 20000,
                        divisions: 20,
                        activeColor: const Color(0xFF2563EB),
                        inactiveColor: const Color(0xFFE2E8F0),
                        onChanged: (val) => setState(() => _savingsEstimation = val),
                        onChangeEnd: (val) {
                           // 🚩 TRACK: Calculator used with parity key
                           AppNinja.track('savings_calculator_used', properties: {'input_spend': val});
                        },
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFFF59E0B), size: 20),
                        const SizedBox(width: 8),
                        Flexible(child: Text('You save ₹${(_savingsEstimation * 0.15).toInt()} per month with Gold!', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Benefits with Granular IDs
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('Membership Benefits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ),
            const SizedBox(height: 16),
            EmbedWidgetWrapper(
              id: 'benefits_grid',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildBenefitItem(Icons.local_shipping_outlined, 'Free Delivery', 'On all orders above ₹199', 'benefit_shipping'),
                    _buildBenefitItem(Icons.support_agent_rounded, 'Priority Support', 'Dedicated experts for you', 'benefit_support'),
                    _buildBenefitItem(Icons.percent_rounded, 'Extra 5% Off', 'On every single purchase', 'benefit_discount'),
                    _buildBenefitItem(Icons.flash_on_rounded, 'Early Access', 'Shop new arrivals first', 'benefit_early'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Toggles (Auto-Renew & Newsletter)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    EmbedWidgetWrapper(
                      id: 'autorenew_switch_row',
                      child: _buildToggle('Auto-Renew Subscription', _autoRenew, (val) {
                        setState(() => _autoRenew = val);
                        // 🚩 TRACK: Pref toggled with parity key
                        AppNinja.track('preference_toggled', properties: {'pref': 'auto_renew', 'value': val});
                      }),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(height: 1)),
                    EmbedWidgetWrapper(
                      id: 'newsletter_switch_row',
                      child: _buildToggle('Email Newsletter', _newsletter, (val) {
                        setState(() => _newsletter = val);
                        // 🚩 TRACK: Pref toggled with parity key
                        AppNinja.track('preference_toggled', properties: {'pref': 'newsletter', 'value': val});
                      }),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Hero Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: EmbedWidgetWrapper(
                id: 'activate_membership_btn',
                child: SizedBox(
                   width: double.infinity,
                   height: 60,
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFF1E293B),
                       foregroundColor: Colors.white,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       elevation: 12,
                       shadowColor: const Color(0xFF1E293B).withOpacity(0.4),
                     ),
                     onPressed: () {
                        // 🚩 TRACK: Membership Activated with full parity
                        AppNinja.track('membership_activated', properties: {
                           'plan': _selectedPlan,
                           'term': 'monthly',
                           'auto_renew': _autoRenew,
                           'savings_estimated': (_savingsEstimation * 0.15).toInt()
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome to Embed Plus!'), behavior: SnackBarBehavior.floating));
                        Navigator.pop(context);
                     },
                     child: const Text('ACTIVATE MEMBERSHIP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                   ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(String title, String price, List<Color> colors, String id, double priceVal) {
    bool isSelected = _selectedPlan == id;
    return GestureDetector(
      onTap: () => _selectPlan(id, 299), // Legacy Parity: snippet uses 299 for all tracks
      child: EmbedWidgetWrapper(
        id: 'plan_card_$id',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 160,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected ? [BoxShadow(color: colors.first.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))] : [],
            border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stars_rounded, color: Colors.white.withOpacity(isSelected ? 1.0 : 0.6), size: 32),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              const SizedBox(height: 4),
              Text(price, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
              const Spacer(),
              if (isSelected) const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle, String id) {
    return EmbedWidgetWrapper(
      id: id,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF2563EB), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
          Switch.adaptive(
            value: value, 
            activeColor: const Color(0xFF2563EB),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
