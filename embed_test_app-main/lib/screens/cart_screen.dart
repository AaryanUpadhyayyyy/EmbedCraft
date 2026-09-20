import 'package:flutter/material.dart';
import 'package:in_app_ninja/in_app_ninja.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Mock Cart Items (Updated with Unsplash images for premium feel)
  final List<Map<String, dynamic>> _cartItems = [
    {'name': 'Alphonso Mango', 'qty': '1 kg', 'price': 120.0, 'image': 'https://images.unsplash.com/photo-1553279768-865429fa0078?auto=format&fit=crop&w=400&q=80'},
    {'name': 'Amul Taaza Milk', 'qty': '500 ml', 'price': 28.0, 'image': ''},
    {'name': 'Baby Corn', 'qty': '250g', 'price': 45.0, 'image': 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?auto=format&fit=crop&w=400&q=80'},
  ];

  @override
  void initState() {
    super.initState();
    // 🚩 TRACK: Cart Viewed with full property parity
    AppNinja.track('cart_viewed', properties: {
      'total_items': _cartItems.length,
      'total_value': _calculateTotal(),
      'currency': 'INR',
      'avg_item_price': _cartItems.isEmpty ? 0 : _calculateTotal() / _cartItems.length,
    });
  }

  double _calculateTotal() {
    return _cartItems.fold(0, (sum, item) => sum + (item['price'] as double));
  }

  void _proceedToCheckout() {
    // 🚩 TRACK: Checkout Started with full property parity
    AppNinja.track('checkout_started', properties: {
      'total_value': _calculateTotal(),
      'item_count': _cartItems.length,
      'currency': 'INR',
      'coupon_applied': false
    });

    Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Shopping Bag', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _cartItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return EmbedWidgetWrapper(
                  id: 'cart_item_row_$index',
                  child: GestureDetector(
                    onTap: () {
                     // 🚩 TRACK: Cart Item Clicked
                     AppNinja.track('cart_item_clicked', properties: {
                       'name': item['name'],
                       'price': item['price'],
                       'qty': item['qty'],
                       'stock_status': 'In Stock',
                       'position_in_cart': index
                     });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: item['image'].isEmpty 
                            ? Container(width: 85, height: 85, color: const Color(0xFFF1F5F9), child: const Icon(Icons.shopping_basket_outlined, color: Color(0xFF94A3B8)))
                            : Image.network(item['image'], width: 85, height: 85, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                              const SizedBox(height: 4),
                              Text(item['qty'], style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text('₹${item['price']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF2563EB)))),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(onPressed: () {}, icon: const Icon(Icons.remove, size: 16), constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                                        const Text('1', style: TextStyle(fontWeight: FontWeight.w900)),
                                        IconButton(onPressed: () {}, icon: const Icon(Icons.add, size: 16), constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                                      ],
                                    ),
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
              );
            },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, -10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                    Text('₹${_calculateTotal()}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  ],
                ),
                const SizedBox(height: 24),
                EmbedWidgetWrapper(
                  id: 'cart_proceed_to_pay_btn', // Parity with ID tracking
                  child: ElevatedButton(
                    onPressed: _proceedToCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                    ),
                    child: const Text('PROCEED TO CHECKOUT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
