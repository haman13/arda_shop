// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import 'newProduct.dart';
import 'editProduct.dart';
import 'order_management.dart';
import 'user_management.dart';
import 'admin_profile.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int newOrdersCount = 0;
  bool isLoadingOrders = true;

  @override
  void initState() {
    super.initState();
    _loadNewOrdersCount();
  }

  Future<void> _loadNewOrdersCount() async {
    try {
      final response = await Supabase.instance.client
          .from('orders')
          .select('id')
          .eq('status', 'pending'); // فقط سفارشات در انتظار تأیید

      setState(() {
        newOrdersCount = response.length;
        isLoadingOrders = false;
      });
    } catch (e) {
      setState(() {
        isLoadingOrders = false;
      });
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => const NewProductDialog(),
    );
  }

  void _showEditProductPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProductPage()),
    );
  }

  void _showOrderManagementPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrderManagementPage()),
    );
    // بعد از بازگشت از صفحه مدیریت سفارشات، تعداد سفارشات جدید را بروزرسانی کن
    _loadNewOrdersCount();
  }

  void _showUserManagementPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserManagementPage()),
    );
  }

  void _showAdminProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminProfilePage()),
    );
  }

  // تعیین عرض دکمه‌ها بر اساس اندازه دستگاه
  double _getButtonWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    if (screenWidth > 1200) {
      // دسکتاپ: 40% ارتفاع
      return screenHeight * 0.6;
    } else if (screenWidth > 800) {
      // تبلت: 50% ارتفاع
      return screenHeight * 0.65;
    } else if (screenWidth > 600) {
      // تبلت کوچک یا لپ‌تاپ کوچک: 70% عرض
      return screenWidth * 0.7;
    } else {
      // موبایل: 80% عرض
      return screenWidth * 0.8;
    }
  }

  // تعیین اندازه فونت بر اساس سایز صفحه و مقیاس فونت
  double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor;

    // تنظیم فونت بر اساس عرض صفحه
    double scaleFactor = 1.0;
    if (screenWidth > 1200) {
      scaleFactor = 1.2; // دسکتاپ
    } else if (screenWidth > 800) {
      scaleFactor = 1.1; // تبلت
    } else if (screenWidth > 600) {
      scaleFactor = 1.0; // تبلت کوچک
    } else {
      scaleFactor = 0.9; // موبایل
    }

    // اعمال مقیاس فونت سیستم
    return (baseFontSize * scaleFactor * textScale).clamp(12.0, 24.0);
  }

  // تعیین ارتفاع دکمه بر اساس سایز صفحه
  double _getButtonHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    // ارتفاع پایه
    double baseHeight = 48.0;

    // تنظیم بر اساس ارتفاع صفحه
    if (screenHeight > 800) {
      baseHeight = 56.0; // دسکتاپ
    } else if (screenHeight > 600) {
      baseHeight = 52.0; // تبلت
    } else {
      baseHeight = 48.0; // موبایل
    }

    // اعمال مقیاس فونت
    return (baseHeight * textScale).clamp(40.0, 80.0);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final buttonWidth = _getButtonWidth(context);
        final buttonHeight = _getButtonHeight(context);
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // تعیین فاصله‌گذاری بر اساس سایز صفحه
        final spacing = screenHeight > 600 ? 16.0 : 12.0;

        // تعیین اندازه آیکون بر اساس سایز صفحه
        final iconSize = _getResponsiveFontSize(context, 20.0);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.appBarBackground,
            title: Text(
              'داشبورد ادمین',
              style: AppTextStyles.heading2.copyWith(
                fontSize: _getResponsiveFontSize(context, 20.0),
              ),
            ),
            centerTitle: true,
            elevation: 0.0,
            automaticallyImplyLeading: false, // حذف دکمه back
            actions: [
              IconButton(
                onPressed: _showAdminProfilePage,
                icon: Icon(
                  Icons.account_circle,
                  color: AppColors.primaryBlue,
                  size: iconSize + 4,
                ),
                tooltip: 'پروفایل ادمین',
              ),
            ],
          ),
          body: orientation == Orientation.landscape
              ? SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth > 600 ? 16.0 : 12.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: ElevatedButton.icon(
                              onPressed: _showAddProductDialog,
                              style: AppButtonStyles.primaryButton,
                              icon: Icon(
                                Icons.add,
                                size: iconSize,
                              ),
                              label: Text(
                                'افزودن محصول',
                                style: AppTextStyles.buttonText.copyWith(
                                  fontSize:
                                      _getResponsiveFontSize(context, 16.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: spacing),
                          SizedBox(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: ElevatedButton.icon(
                              onPressed: _showEditProductPage,
                              style: AppButtonStyles.successButton,
                              icon: Icon(
                                Icons.edit,
                                size: iconSize,
                              ),
                              label: Text(
                                'ویرایش محصولات',
                                style: AppTextStyles.buttonText.copyWith(
                                  fontSize:
                                      _getResponsiveFontSize(context, 16.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: spacing),
                          SizedBox(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _showOrderManagementPage,
                                    style: AppButtonStyles.secondaryButton,
                                    icon: Icon(
                                      Icons.assignment,
                                      size: iconSize,
                                    ),
                                    label: Text(
                                      'مدیریت سفارشات',
                                      style: AppTextStyles.buttonText.copyWith(
                                        fontSize: _getResponsiveFontSize(
                                            context, 16.0),
                                      ),
                                    ),
                                  ),
                                ),
                                // Badge اعلان
                                if (!isLoadingOrders && newOrdersCount > 0)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: EdgeInsets.all(
                                          screenWidth > 600 ? 6.0 : 4.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.errorRed,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primaryWhite,
                                          width: 2,
                                        ),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth:
                                            screenWidth > 600 ? 24.0 : 20.0,
                                        minHeight:
                                            screenWidth > 600 ? 24.0 : 20.0,
                                      ),
                                      child: Text(
                                        newOrdersCount > 99
                                            ? '99+'
                                            : '$newOrdersCount',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.primaryWhite,
                                          fontWeight: FontWeight.bold,
                                          fontSize: _getResponsiveFontSize(
                                              context, 12.0),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: spacing),
                          SizedBox(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: ElevatedButton.icon(
                              onPressed: _showUserManagementPage,
                              style: AppButtonStyles.warningButton,
                              icon: Icon(
                                Icons.people,
                                size: iconSize,
                              ),
                              label: Text(
                                'مدیریت کاربران',
                                style: AppTextStyles.buttonText.copyWith(
                                  fontSize:
                                      _getResponsiveFontSize(context, 16.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(screenWidth > 600 ? 16.0 : 12.0),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: ElevatedButton.icon(
                              onPressed: _showAddProductDialog,
                              style: AppButtonStyles.primaryButton,
                              icon: Icon(
                                Icons.add,
                                size: iconSize,
                              ),
                              label: Text(
                                'افزودن محصول',
                                style: AppTextStyles.buttonText.copyWith(
                                  fontSize:
                                      _getResponsiveFontSize(context, 16.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: spacing),
                          SizedBox(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: ElevatedButton.icon(
                              onPressed: _showEditProductPage,
                              style: AppButtonStyles.successButton,
                              icon: Icon(
                                Icons.edit,
                                size: iconSize,
                              ),
                              label: Text(
                                'ویرایش محصولات',
                                style: AppTextStyles.buttonText.copyWith(
                                  fontSize:
                                      _getResponsiveFontSize(context, 16.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: spacing),
                          SizedBox(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _showOrderManagementPage,
                                    style: AppButtonStyles.secondaryButton,
                                    icon: Icon(
                                      Icons.assignment,
                                      size: iconSize,
                                    ),
                                    label: Text(
                                      'مدیریت سفارشات',
                                      style: AppTextStyles.buttonText.copyWith(
                                        fontSize: _getResponsiveFontSize(
                                            context, 16.0),
                                      ),
                                    ),
                                  ),
                                ),
                                // Badge اعلان
                                if (!isLoadingOrders && newOrdersCount > 0)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: EdgeInsets.all(
                                          screenWidth > 600 ? 6.0 : 4.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.errorRed,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primaryWhite,
                                          width: 2,
                                        ),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth:
                                            screenWidth > 600 ? 24.0 : 20.0,
                                        minHeight:
                                            screenWidth > 600 ? 24.0 : 20.0,
                                      ),
                                      child: Text(
                                        newOrdersCount > 99
                                            ? '99+'
                                            : '$newOrdersCount',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.primaryWhite,
                                          fontWeight: FontWeight.bold,
                                          fontSize: _getResponsiveFontSize(
                                              context, 12.0),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: spacing),
                          SizedBox(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: ElevatedButton.icon(
                              onPressed: _showUserManagementPage,
                              style: AppButtonStyles.warningButton,
                              icon: Icon(
                                Icons.people,
                                size: iconSize,
                              ),
                              label: Text(
                                'مدیریت کاربران',
                                style: AppTextStyles.buttonText.copyWith(
                                  fontSize:
                                      _getResponsiveFontSize(context, 16.0),
                                ),
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
    );
  }
}
