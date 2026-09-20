import 'package:flutter/material.dart';
import 'package:in_app_ninja/in_app_ninja.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  String _selectedPaymentMethod = 'credit_card';
  final TextEditingController _promoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 📍 Track page navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNinja.trackPage('checkout', context);
    });
    
    // 🚩 TRACK: Checkout Flow Started with full property parity
    AppNinja.track('checkout_flow_started', properties: {'cart_value': 450.0});
    _trackStep(0, 'address_selection');
  }

  void _trackStep(int step, String name) {
    AppNinja.track('Checkout Step Viewed', properties: {
      'step_number': step + 1,
      'step_name': name
    });
  }

  void _placeOrder() {
    // 🚩 TRACK: Order Placed with full property parity
    AppNinja.track('order_placed', properties: {
      'amount': 420.0,
      'payment_method': _selectedPaymentMethod,
      'promo_applied': _promoController.text.isNotEmpty ? _promoController.text : null
    });

    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 64),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order Successful!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Your items are on their way.', style: TextStyle(color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () { 
                Navigator.of(context).popUntil((route) => route.isFirst);
              }, 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Custom Stepper Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            color: Colors.white,
            child: Row(
              children: [
                _buildStep(0, 'Address', true),
                _buildDivider(true),
                _buildStep(1, 'Payment', _currentStep >= 1),
                _buildDivider(_currentStep >= 1),
                _buildStep(2, 'Review', _currentStep >= 2),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                         Container(
                           padding: const EdgeInsets.all(12),
                           decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(12)),
                           child: const Icon(Icons.location_on, color: Color(0xFF2563EB)),
                         ),
                         const SizedBox(width: 16),
                         const Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text('Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                               Text('123 Modern Heights, Bangalore\nKarnataka - 560001', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                             ],
                           ),
                         ),
                         EmbedWidgetWrapper(
                           id: 'checkout_change_address_btn',
                           child: TextButton(
                             onPressed: () => AppNinja.track('change_address_clicked'), 
                             child: const Text('EDIT', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB)))
                           )
                         )
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPaymentCard('Credit Card', Icons.credit_card_rounded, 'credit_card'),
                      const SizedBox(width: 12),
                      _buildPaymentCard('UPI', Icons.account_balance_wallet_rounded, 'upi'),
                      const SizedBox(width: 12),
                      _buildPaymentCard('Cash', Icons.payments_rounded, 'cash'),
                    ],
                  ),

                  const SizedBox(height: 32),
                  EmbedWidgetWrapper(
                    id: 'checkout_promo_section',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_offer_outlined, color: Color(0xFFF59E0B), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _promoController,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(hintText: 'Apply Promo Code', border: InputBorder.none),
                            ),
                          ),
                          TextButton(
                            onPressed: () => AppNinja.track('promo_applied', properties: {'code': _promoController.text}), 
                            child: const Text('APPLY', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB)))
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        _buildSummaryItem('Subtotal', '₹450'),
                        _buildSummaryItem('Delivery', '₹20'),
                        _buildSummaryItem('Discount', '-₹50', isPromo: true),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text('₹420', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF2563EB))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, -10))],
        ),
        child: EmbedWidgetWrapper(
          id: 'checkout_pay_btn',
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('PLACE ORDER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int index, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive 
              ? const Icon(Icons.check, size: 16, color: Colors.white) 
              : Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? const Color(0xFF1E293B) : const Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildDivider(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 14),
        color: isActive ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildPaymentCard(String label, IconData icon, String value) {
    bool isSelected = _selectedPaymentMethod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedPaymentMethod = value);
          AppNinja.track('payment_method_selected', properties: {'method': value});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B), size: 24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isPromo = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14))),
          Text(value, style: TextStyle(fontWeight: isPromo ? FontWeight.bold : FontWeight.w500, fontSize: 14, color: isPromo ? const Color(0xFF22C55E) : const Color(0xFF1E293B))),
        ],
      ),
    );
  }
}
