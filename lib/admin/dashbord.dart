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

    if (screenWidth > 1200) {
      // دسکتاپ: 40% ارتفاع
      return screenHeight * 0.6;
    } else if (screenWidth > 800) {
      // تبلت: 50% ارتفاع
      return screenHeight * 0.65;
    } else {
      // موبایل: 80% عرض
      return screenWidth * 0.7;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = _getButtonWidth(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: Text(
          'داشبورد ادمین',
          style: AppTextStyles.heading2,
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
              size: 28,
            ),
            tooltip: 'پروفایل ادمین',
          ),
        ],
      ),
      body: Padding(
        padding: AppPadding.allMedium,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: buttonWidth,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _showAddProductDialog,
                  style: AppButtonStyles.primaryButton,
                  icon: Icon(
                    Icons.add,
                    size: AppDimensions.iconSize,
                  ),
                  label: Text(
                    'افزودن محصول',
                    style: AppTextStyles.buttonText,
                  ),
                ),
              ),
              AppSizedBox.height16,
              SizedBox(
                width: buttonWidth,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _showEditProductPage,
                  style: AppButtonStyles.successButton,
                  icon: Icon(
                    Icons.edit,
                    size: AppDimensions.iconSize,
                  ),
                  label: Text(
                    'ویرایش محصولات',
                    style: AppTextStyles.buttonText,
                  ),
                ),
              ),
              AppSizedBox.height16,
              SizedBox(
                width: buttonWidth,
                height: AppDimensions.buttonHeight,
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
                          size: AppDimensions.iconSize,
                        ),
                        label: Text(
                          'مدیریت سفارشات',
                          style: AppTextStyles.buttonText,
                        ),
                      ),
                    ),
                    // Badge اعلان
                    if (!isLoadingOrders && newOrdersCount > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.errorRed,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryWhite,
                              width: 2,
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          child: Text(
                            newOrdersCount > 99 ? '99+' : '$newOrdersCount',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              AppSizedBox.height16,
              SizedBox(
                width: buttonWidth,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _showUserManagementPage,
                  style: AppButtonStyles.warningButton,
                  icon: Icon(
                    Icons.people,
                    size: AppDimensions.iconSize,
                  ),
                  label: Text(
                    'مدیریت کاربران',
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
