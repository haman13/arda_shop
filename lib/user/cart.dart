import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('کاربر وارد نشده است');
      }

      // دریافت محصولات سبد خرید با اطلاعات کامل محصول
      final response = await supabase.from('cart_items').select('''
            *,
            products:product_id (
              id,
              name,
              price,
              discount,
              final_price,
              image_url
            )
          ''').eq('user_id', userId);

      setState(() {
        _cartItems = List<Map<String, dynamic>>.from(response);
        _calculateTotal();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری سبد خرید: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _calculateTotal() {
    _totalAmount = 0;
    for (var item in _cartItems) {
      final product = item['products'] as Map<String, dynamic>;
      final price = product['final_price'] as double;
      final quantity = item['quantity'] as int;
      _totalAmount += price * quantity;
    }
  }

  Future<void> _updateQuantity(int cartItemId, int newQuantity) async {
    if (newQuantity < 1) return;

    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('cart_items')
          .update({'quantity': newQuantity}).eq('id', cartItemId);

      await _loadCartItems(); // بارگذاری مجدد برای به‌روزرسانی UI
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در به‌روزرسانی تعداد: $e')),
        );
      }
    }
  }

  Future<void> _removeItem(int cartItemId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('cart_items').delete().eq('id', cartItemId);

      await _loadCartItems(); // بارگذاری مجدد برای به‌روزرسانی UI
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در حذف محصول: $e')),
        );
      }
    }
  }

  void _showCheckoutDialog() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          cartItems: _cartItems,
          totalAmount: _totalAmount,
        ),
      ),
    )
        .then((success) {
      if (success == true) {
        _loadCartItems(); // بارگذاری مجدد سبد خرید در صورت موفقیت‌آمیز بودن ثبت سفارش
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cartItems.isEmpty) {
      return const Center(
        child: Text('سبد خرید شما خالی است'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('سبد خرید'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                final product = item['products'] as Map<String, dynamic>;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // تصویر محصول
                        if (product['image_url'] != null)
                          Image.network(
                            product['image_url'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        else
                          Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 40),
                          ),
                        const SizedBox(width: 16),
                        // اطلاعات محصول
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product['final_price']} تومان',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // کنترل‌های تعداد
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => _updateQuantity(
                                item['id'],
                                (item['quantity'] as int) - 1,
                              ),
                            ),
                            Text('${item['quantity']}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _updateQuantity(
                                item['id'],
                                (item['quantity'] as int) + 1,
                              ),
                            ),
                          ],
                        ),
                        // دکمه حذف
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(item['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // بخش جمع کل و دکمه نهایی کردن خرید
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'جمع کل:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_totalAmount.toStringAsFixed(0)} تومان',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showCheckoutDialog,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'نهایی کردن خرید',
                      style: TextStyle(fontSize: 16),
                    ),
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
