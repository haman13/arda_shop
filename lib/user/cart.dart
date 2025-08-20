import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import 'checkout_page.dart';
import 'user_provider.dart';
import 'login_page.dart';

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
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // بررسی لاگین بودن کاربر
      if (!userProvider.isLoggedIn || userProvider.userPhone == null) {
        setState(() {
          _isLoading = false;
          _cartItems = []; // خالی کردن لیست
        });
        return; // فقط return کنیم، هدایت نکنیم
      }

      final supabase = Supabase.instance.client;

      // پیدا کردن user_id از روی شماره تلفن
      final userData = await supabase
          .from('users')
          .select('id')
          .eq('phone', userProvider.userPhone!)
          .single();

      final userId = userData['id'];

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
          SnackBar(
            content: Text(
              'خطا در بارگذاری سبد خرید: $e',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.primaryWhite),
            ),
            backgroundColor: AppColors.errorRed,
          ),
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
          SnackBar(
            content: Text(
              'خطا در به‌روزرسانی تعداد: $e',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.primaryWhite),
            ),
            backgroundColor: AppColors.errorRed,
          ),
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
          SnackBar(
            content: Text(
              'خطا در حذف محصول: $e',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.primaryWhite),
            ),
            backgroundColor: AppColors.errorRed,
          ),
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
    final userProvider = Provider.of<UserProvider>(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appBarBackground,
          title: Text(
            'سبد خرید',
            style: AppTextStyles.heading2,
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryBlue,
            strokeWidth: AppDimensions.loadingStrokeWidth,
          ),
        ),
      );
    }

    if (_cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appBarBackground,
          title: Text(
            'سبد خرید',
            style: AppTextStyles.heading2,
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                userProvider.isLoggedIn
                    ? Icons.shopping_cart_outlined
                    : Icons.login,
                size: 80,
                color: AppColors.greyText,
              ),
              const SizedBox(height: 16),
              Text(
                userProvider.isLoggedIn
                    ? 'سبد خرید شما خالی است'
                    : 'لطفاً ابتدا وارد حساب کاربری خود شوید',
                style:
                    AppTextStyles.heading3.copyWith(color: AppColors.greyText),
                textAlign: TextAlign.center,
              ),
              if (!userProvider.isLoggedIn) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  style: AppButtonStyles.primaryButton,
                  child: Text(
                    'ورود به حساب کاربری',
                    style: AppTextStyles.buttonText,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: Text(
          'سبد خرید',
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: AppPadding.allSmall,
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                final product = item['products'] as Map<String, dynamic>;

                return Container(
                  margin: AppPadding.verticalSmall,
                  decoration: AppDecorations.cartItemShadow,
                  child: Card(
                    elevation: 0,
                    child: Padding(
                      padding: AppPadding.allMedium,
                      child: Row(
                        children: [
                          // تصویر محصول
                          ClipRRect(
                            borderRadius: AppBorderRadius.small,
                            child: product['image_url'] != null
                                ? Image.network(
                                    product['image_url'],
                                    width:
                                        AppDimensions.productImageWidth * 1.6,
                                    height: AppDimensions.productImageHeight,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width:
                                        AppDimensions.productImageWidth * 1.6,
                                    height: AppDimensions.productImageHeight,
                                    color: AppColors.productImagePlaceholder,
                                    child: Icon(
                                      Icons.image,
                                      size: AppDimensions.iconSize * 1.5,
                                      color: AppColors.greyText,
                                    ),
                                  ),
                          ),
                          AppSizedBox.width16,
                          // اطلاعات محصول
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: AppTextStyles.productTitle,
                                ),
                                AppSizedBox.height4,
                                Text(
                                  AppUtilities.formatPrice(
                                      product['final_price']),
                                  style: AppTextStyles.productPrice,
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
                              Text(
                                '${item['quantity']}',
                                style: AppTextStyles.bodyMedium,
                              ),
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
                            icon: Icon(
                              Icons.delete,
                              color: AppColors.cartDeleteButton,
                            ),
                            onPressed: () => _removeItem(item['id']),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // بخش جمع کل و دکمه نهایی کردن خرید
          Container(
            padding: AppPadding.allMedium,
            decoration: BoxDecoration(
              color: AppColors.primaryWhite,
              boxShadow: [
                BoxShadow(
                  color: AppColors.cartShadow,
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
                    Text(
                      'جمع کل:',
                      style: AppTextStyles.heading3,
                    ),
                    Text(
                      AppUtilities.formatPrice(_totalAmount.toStringAsFixed(0)),
                      style: AppTextStyles.heading3
                          .copyWith(color: AppColors.cartTotalPrice),
                    ),
                  ],
                ),
                AppSizedBox.height16,
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _showCheckoutDialog,
                    style: AppButtonStyles.successButton,
                    child: Text(
                      'نهایی کردن خرید',
                      style: AppTextStyles.buttonText,
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
