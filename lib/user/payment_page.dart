import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import 'user_provider.dart';
import 'home_page.dart';

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;
  final String shippingAddress;
  final String phone;
  final String postalCode;

  const PaymentPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.shippingAddress,
    required this.phone,
    required this.postalCode,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentMethod = 'cash'; // 'cash', 'online', یا 'card_to_card'
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      if (_selectedPaymentMethod == 'cash') {
        await _processCashPayment();
      } else if (_selectedPaymentMethod == 'online') {
        await _processOnlinePayment();
      } else if (_selectedPaymentMethod == 'card_to_card') {
        await _processCardToCardPayment();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطا در پردازش پرداخت: $e',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.primaryWhite),
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _processCashPayment() async {
    // ثبت سفارش با وضعیت "نقدی در محل"
    await _createOrder('cash_on_delivery');

    if (mounted) {
      _showSuccessDialog(
        'سفارش با موفقیت ثبت شد',
        'سفارش شما ثبت شد و پس از تایید ارسال خواهد شد.\nمبلغ را هنگام تحویل پرداخت کنید.',
      );
    }
  }

  Future<void> _processOnlinePayment() async {
    // شبیه‌سازی درگاه پرداخت
    await _showPaymentGatewaySimulation();
  }

  Future<void> _processCardToCardPayment() async {
    // نمایش اطلاعات کارت به کارت
    await _showCardToCardInfo();
  }

  Future<void> _showPaymentGatewaySimulation() async {
    // شبیه‌سازی زمان پردازش درگاه
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // نمایش دیالوگ شبیه‌سازی درگاه
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'درگاه پرداخت (شبیه‌سازی)',
          style: AppTextStyles.heading3,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.credit_card,
              size: 64,
              color: AppColors.primaryBlue,
            ),
            AppSizedBox.height16,
            Text(
              'مبلغ قابل پرداخت: ${AppUtilities.formatPrice(widget.totalAmount.toStringAsFixed(0))}',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.productPrice,
              ),
            ),
            AppSizedBox.height16,
            Text(
              'این یک شبیه‌سازی درگاه پرداخت است.\nانتخاب کنید:',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'پرداخت ناموفق',
              style: AppTextStyles.linkText.copyWith(color: AppColors.errorRed),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: AppButtonStyles.successButton,
            child: Text(
              'پرداخت موفق',
              style: AppTextStyles.buttonText,
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      // پرداخت موفق
      await _createOrder('paid_online');
      if (mounted) {
        _showSuccessDialog(
          'پرداخت موفقیت‌آمیز بود!',
          'سفارش شما ثبت شد و پس از تایید ارسال خواهد شد.',
        );
      }
    } else {
      // پرداخت ناموفق
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'پرداخت ناموفق بود. لطفاً دوباره تلاش کنید.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.primaryWhite),
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _showCardToCardInfo() async {
    if (!mounted) return;

    // نمایش دیالوگ اطلاعات کارت به کارت
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.credit_card_outlined,
              color: AppColors.warningOrange,
              size: 28,
            ),
            AppSizedBox.width8,
            Text(
              'پرداخت کارت به کارت',
              style: AppTextStyles.heading3,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: AppPadding.allMedium,
                decoration: BoxDecoration(
                  color: AppColors.warningOrange.withValues(alpha: 0.1),
                  borderRadius: AppBorderRadius.small,
                  border: Border.all(color: AppColors.warningOrange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مبلغ قابل پرداخت:',
                      style: AppTextStyles.bodyMedium,
                    ),
                    Text(
                      AppUtilities.formatPrice(
                          widget.totalAmount.toStringAsFixed(0)),
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.productPrice,
                      ),
                    ),
                  ],
                ),
              ),
              AppSizedBox.height16,
              Text(
                'اطلاعات کارت:',
                style: AppTextStyles.heading3,
              ),
              AppSizedBox.height8,
              Container(
                padding: AppPadding.allMedium,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: AppBorderRadius.small,
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'شماره کارت:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '6037-9977-1234-5678',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontFamily: 'monospace',
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    AppSizedBox.height8,
                    Text(
                      'نام صاحب حساب:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'فروشگاه آردا',
                      style: AppTextStyles.bodyLarge,
                    ),
                  ],
                ),
              ),
              AppSizedBox.height16,
              Container(
                padding: AppPadding.allSmall,
                decoration: BoxDecoration(
                  color: AppColors.adminLoadingBackground,
                  borderRadius: AppBorderRadius.small,
                  border: Border.all(color: AppColors.adminLoadingBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'راهنمای پرداخت:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    AppSizedBox.height4,
                    Text(
                      '1. مبلغ را به شماره کارت فوق واریز کنید\n'
                      '2. عکس فیش واریزی را ذخیره کنید\n'
                      '3. روی "پرداخت انجام شد" کلیک کنید\n'
                      '4. سفارش شما پس از تأیید پرداخت ارسال می‌شود',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'انصراف',
              style: AppTextStyles.linkText.copyWith(color: AppColors.greyText),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: AppButtonStyles.warningButton,
            child: Text(
              'پرداخت انجام شد',
              style: AppTextStyles.buttonText,
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      // پرداخت کارت به کارت انجام شد
      await _createOrder('paid_card_to_card');
      if (mounted) {
        _showSuccessDialog(
          'سفارش ثبت شد',
          'سفارش شما ثبت شد و پس از تأیید پرداخت توسط ادمین ارسال خواهد شد.\n'
              'لطفاً فیش واریزی را نگه دارید.',
        );
      }
    }
  }

  Future<void> _createOrder(String paymentStatus) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final supabase = Supabase.instance.client;

    // پیدا کردن user_id
    final userData = await supabase
        .from('users')
        .select('id')
        .eq('phone', userProvider.userPhone!)
        .single();

    final userId = userData['id'];

    // تعیین وضعیت سفارش و پرداخت
    String orderStatus = 'pending';
    String finalPaymentStatus = paymentStatus;

    // ایجاد سفارش
    final orderResponse = await supabase.from('orders').insert({
      'user_id': userId,
      'user_phone': userProvider.userPhone,
      'total_amount': widget.totalAmount,
      'status': orderStatus,
      'payment_status': finalPaymentStatus,
      'shipping_address': widget.shippingAddress,
      'contact_phone': widget.phone,
      'postal_code': widget.postalCode,
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
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.successGreen,
              size: 32,
            ),
            AppSizedBox.width8,
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.successGreen,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // بستن دیالوگ و هدایت مستقیم به صفحه اصلی
              Navigator.of(context).pop(); // بستن دیالوگ

              // پاک کردن تمام صفحات و رفتن به HomePage
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            },
            style: AppButtonStyles.primaryButton,
            child: Text(
              'بازگشت به فروشگاه',
              style: AppTextStyles.buttonText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: Text(
          'انتخاب روش پرداخت',
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                    strokeWidth: AppDimensions.loadingStrokeWidth,
                  ),
                  AppSizedBox.height16,
                  Text(
                    'در حال پردازش پرداخت...',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: AppPadding.allMedium,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // خلاصه سفارش
                  Container(
                    decoration: AppDecorations.cartItemShadow,
                    child: Card(
                      elevation: 0,
                      child: Padding(
                        padding: AppPadding.allMedium,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'خلاصه سفارش',
                              style: AppTextStyles.heading3,
                            ),
                            AppSizedBox.height8,
                            Text(
                              'تعداد محصولات: ${widget.cartItems.length}',
                              style: AppTextStyles.bodyMedium,
                            ),
                            AppSizedBox.height4,
                            Text(
                              'مبلغ کل: ${AppUtilities.formatPrice(widget.totalAmount.toStringAsFixed(0))}',
                              style: AppTextStyles.productPrice.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AppSizedBox.height24,

                  // انتخاب روش پرداخت
                  Text(
                    'روش پرداخت را انتخاب کنید:',
                    style: AppTextStyles.heading3,
                  ),
                  AppSizedBox.height16,

                  // گزینه نقدی در محل
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedPaymentMethod == 'cash'
                            ? AppColors.primaryBlue
                            : AppColors.greyText,
                        width: 2,
                      ),
                      borderRadius: AppBorderRadius.medium,
                    ),
                    child: RadioListTile<String>(
                      value: 'cash',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() => _selectedPaymentMethod = value!);
                      },
                      title: Row(
                        children: [
                          Icon(
                            Icons.money,
                            color: AppColors.successGreen,
                          ),
                          AppSizedBox.width8,
                          Text(
                            'پرداخت نقدی در محل',
                            style: AppTextStyles.bodyLarge,
                          ),
                        ],
                      ),
                      subtitle: Text(
                        'مبلغ را هنگام تحویل کالا پرداخت کنید',
                        style: AppTextStyles.greyText,
                      ),
                      activeColor: AppColors.primaryBlue,
                    ),
                  ),
                  AppSizedBox.height16,

                  // گزینه پرداخت آنلاین
                  // Container(
                  //   decoration: BoxDecoration(
                  //     border: Border.all(
                  //       color: _selectedPaymentMethod == 'online'
                  //           ? AppColors.primaryBlue
                  //           : AppColors.greyText,
                  //       width: 2,
                  //     ),
                  //     borderRadius: AppBorderRadius.medium,
                  //   ),
                  //   child: RadioListTile<String>(
                  //     value: 'online',
                  //     groupValue: _selectedPaymentMethod,
                  //     onChanged: (value) {
                  //       setState(() => _selectedPaymentMethod = value!);
                  //     },
                  //     title: Row(
                  //       children: [
                  //         Icon(
                  //           Icons.credit_card,
                  //           color: AppColors.primaryBlue,
                  //         ),
                  //         AppSizedBox.width8,
                  //         Text(
                  //           'پرداخت آنلاین',
                  //           style: AppTextStyles.bodyLarge,
                  //         ),
                  //       ],
                  //     ),
                  //     subtitle: Text(
                  //       'پرداخت از طریق درگاه بانکی (شبیه‌سازی)',
                  //       style: AppTextStyles.greyText,
                  //     ),
                  //     activeColor: AppColors.primaryBlue,
                  //   ),
                  // ),
                  // AppSizedBox.height16,

                  // گزینه پرداخت کارت به کارت
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedPaymentMethod == 'card_to_card'
                            ? AppColors.primaryBlue
                            : AppColors.greyText,
                        width: 2,
                      ),
                      borderRadius: AppBorderRadius.medium,
                    ),
                    child: RadioListTile<String>(
                      value: 'card_to_card',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() => _selectedPaymentMethod = value!);
                      },
                      title: Row(
                        children: [
                          Icon(
                            Icons.credit_card_outlined,
                            color: AppColors.warningOrange,
                          ),
                          AppSizedBox.width8,
                          Text(
                            'پرداخت کارت به کارت',
                            style: AppTextStyles.bodyLarge,
                          ),
                        ],
                      ),
                      subtitle: Text(
                        'واریز مبلغ به شماره کارت فروشگاه',
                        style: AppTextStyles.greyText,
                      ),
                      activeColor: AppColors.primaryBlue,
                    ),
                  ),
                  AppSizedBox.height32,

                  // دکمه تایید پرداخت
                  SizedBox(
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _processPayment,
                      style: _selectedPaymentMethod == 'cash'
                          ? AppButtonStyles.successButton
                          : _selectedPaymentMethod == 'online'
                              ? AppButtonStyles.primaryButton
                              : AppButtonStyles.warningButton,
                      child: Text(
                        _selectedPaymentMethod == 'cash'
                            ? 'ثبت سفارش (پرداخت در محل)'
                            : _selectedPaymentMethod == 'online'
                                ? 'پرداخت آنلاین ${AppUtilities.formatPrice(widget.totalAmount.toStringAsFixed(0))}'
                                : 'پرداخت کارت به کارت ${AppUtilities.formatPrice(widget.totalAmount.toStringAsFixed(0))}',
                        style: AppTextStyles.buttonText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
