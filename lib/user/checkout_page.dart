// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import 'user_provider.dart';
import 'payment_page.dart';

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
  bool _isLoadingUserData = true;

  // اطلاعات آدرس و تماس
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _postalCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfileData();
  }

  Future<void> _loadUserProfileData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (!userProvider.isLoggedIn || userProvider.userPhone == null) {
        setState(() => _isLoadingUserData = false);
        return;
      }

      final supabase = Supabase.instance.client;

      // گرفتن اطلاعات کامل کاربر از دیتابیس
      final userData = await supabase
          .from('users')
          .select('name, phone, address, postal_code')
          .eq('phone', userProvider.userPhone!)
          .single();

      setState(() {
        // اگر اطلاعات در پروفایل موجود باشه، اونا رو بار کن
        _phoneController.text =
            userData['phone'] ?? userProvider.userPhone ?? '';
        _addressController.text = userData['address'] ?? '';
        _postalCodeController.text = userData['postal_code'] ?? '';
        _isLoadingUserData = false;
      });
    } catch (e) {
      // اگر خطا بود، حداقل شماره تلفن رو از UserProvider بگیر
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      setState(() {
        _phoneController.text = userProvider.userPhone ?? '';
        _isLoadingUserData = false;
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) return;

    // انتقال به صفحه پرداخت
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          cartItems: widget.cartItems,
          totalAmount: widget.totalAmount,
          shippingAddress: _addressController.text,
          phone: _phoneController.text,
          postalCode: _postalCodeController.text,
        ),
      ),
    );

    // اگر پرداخت موفق بود، برگشت به صفحه قبل
    if (result == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: Text(
          'نهایی کردن خرید',
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
                strokeWidth: AppDimensions.loadingStrokeWidth,
              ),
            )
          : _isLoadingUserData
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
                        'در حال بارگذاری اطلاعات...',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: AppPadding.allMedium,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // اطلاع‌رسانی در صورت وجود اطلاعات از پروفایل
                        if (_addressController.text.isNotEmpty ||
                            _postalCodeController.text.isNotEmpty)
                          Container(
                            padding: AppPadding.allSmall,
                            margin: const EdgeInsets.only(
                                bottom: AppDimensions.paddingMedium),
                            decoration: BoxDecoration(
                              color: AppColors.adminLoadingBackground,
                              borderRadius: AppBorderRadius.small,
                              border: Border.all(
                                color: AppColors.adminLoadingBorder,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.primaryBlue,
                                  size: 20,
                                ),
                                AppSizedBox.width8,
                                Expanded(
                                  child: Text(
                                    'اطلاعات از پروفایل شما بارگذاری شد. در صورت نیاز می‌توانید تغییر دهید.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        AppSizedBox.height16,

                        // فرم اطلاعات ارسال
                        TextFormField(
                          controller: _addressController,
                          decoration:
                              AppInputDecorations.formField('آدرس کامل'),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'لطفاً آدرس را وارد کنید';
                            }
                            return null;
                          },
                        ),
                        AppSizedBox.height16,

                        TextFormField(
                          controller: _phoneController,
                          decoration:
                              AppInputDecorations.formField('شماره تماس'),
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
                        AppSizedBox.height16,

                        TextFormField(
                          controller: _postalCodeController,
                          decoration: AppInputDecorations.formField('کد پستی'),
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
                        AppSizedBox.height24,

                        SizedBox(
                          height: AppDimensions.buttonHeight,
                          child: ElevatedButton(
                            onPressed: _proceedToPayment,
                            style: AppButtonStyles.primaryButton,
                            child: Text(
                              'ادامه و انتخاب روش پرداخت',
                              style: AppTextStyles.buttonText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
