import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../user/user_provider.dart';
import '../user/home_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _isLoading = false;

  Future<void> _logout() async {
    setState(() => _isLoading = true);

    try {
      // خروج از حساب کاربری
      await Provider.of<UserProvider>(context, listen: false).logout();

      if (mounted) {
        // بازگشت به صفحه اصلی
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطا در خروج: $e',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.primaryWhite),
            ),
            backgroundColor: AppColors.errorRed,
          ),
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
        backgroundColor: AppColors.appBarBackground,
        title: Text(
          'پروفایل ادمین',
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Padding(
        padding: AppPadding.allMedium,
        child: Column(
          children: [
            // اطلاعات ادمین
            Container(
              width: double.infinity,
              padding: AppPadding.allLarge,
              margin: AppPadding.bottomMedium,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: AppBorderRadius.medium,
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اطلاعات حساب',
                    style: AppTextStyles.heading3,
                  ),
                  AppSizedBox.height16,
                  Row(
                    children: [
                      Icon(Icons.person, color: AppColors.primaryBlue),
                      AppSizedBox.width8,
                      Text(
                        'نام: ادمین سیستم',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  AppSizedBox.height8,
                  Row(
                    children: [
                      Icon(Icons.phone, color: AppColors.primaryBlue),
                      AppSizedBox.width8,
                      Text(
                        'شماره تماس: $adminPhone',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  AppSizedBox.height8,
                  Row(
                    children: [
                      Icon(Icons.admin_panel_settings,
                          color: AppColors.primaryBlue),
                      AppSizedBox.width8,
                      Text(
                        'نقش: مدیر سیستم',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // دکمه خروج از حساب
            Container(
              width: double.infinity,
              padding: AppPadding.allLarge,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: AppBorderRadius.medium,
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عملیات حساب',
                    style: AppTextStyles.heading3,
                  ),
                  AppSizedBox.height16,
                  Text(
                    'با خروج از حساب ادمین، به صفحه اصلی فروشگاه منتقل خواهید شد.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.greyText,
                    ),
                  ),
                  AppSizedBox.height24,

                  // دکمه خروج
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _logout,
                      style: AppButtonStyles.dangerButton,
                      icon: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.primaryWhite,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.logout),
                      label: Text(
                        _isLoading ? 'در حال خروج...' : 'خروج از حساب ادمین',
                        style: AppTextStyles.buttonText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
