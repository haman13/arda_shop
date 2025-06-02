import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // اطلاعات آدرس و تماس
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _postalCodeController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('کاربر وارد نشده است');
      }

      // ایجاد سفارش جدید
      final orderResponse = await supabase.from('orders').insert({
        'user_id': userId,
        'total_amount': widget.totalAmount,
        'status': 'pending',
        'shipping_address': _addressController.text,
        'phone': _phoneController.text,
        'postal_code': _postalCodeController.text,
      }).select();

      final orderId = orderResponse[0]['id'];

      // ایجاد آیتم‌های سفارش
      for (var item in widget.cartItems) {
        final product = item['products'] as Map<String, dynamic>;
        await supabase.from('order_items').insert({
          'order_id': orderId,
          'product_id': product['id'],
          'quantity': item['quantity'],
          'price': product['final_price'],
        });
      }

      // پاک کردن سبد خرید
      await supabase.from('cart_items').delete().eq('user_id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سفارش شما با موفقیت ثبت شد')),
        );
        Navigator.of(context)
            .pop(true); // برگشت به صفحه قبل با نشان دادن موفقیت
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ثبت سفارش: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نهایی کردن خرید'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // خلاصه سفارش
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'خلاصه سفارش',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('تعداد محصولات: ${widget.cartItems.length}'),
                            Text('مبلغ کل: ${widget.totalAmount} تومان'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // فرم اطلاعات ارسال
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'آدرس کامل',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'لطفاً آدرس را وارد کنید';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'شماره تماس',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'لطفاً شماره تماس را وارد کنید';
                        }
                        if (!RegExp(r'^09\d{9}$').hasMatch(value)) {
                          return 'شماره تماس معتبر نیست';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _postalCodeController,
                      decoration: const InputDecoration(
                        labelText: 'کد پستی',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'لطفاً کد پستی را وارد کنید';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return 'کد پستی باید ۱۰ رقم باشد';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _submitOrder,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'ثبت سفارش',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
