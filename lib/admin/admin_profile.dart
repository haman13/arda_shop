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
    return OrientationBuilder(
      builder: (context, orientation) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final buttonHeight = _getButtonHeight(context);
        final iconSize = _getResponsiveFontSize(context, 20.0);

        // تعیین فاصله‌گذاری بر اساس سایز صفحه
        final spacing = screenHeight > 600 ? 16.0 : 12.0;
        final padding = screenWidth > 600 ? 16.0 : 12.0;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.appBarBackground,
            title: Text(
              'پروفایل ادمین',
              style: AppTextStyles.heading2.copyWith(
                fontSize: _getResponsiveFontSize(context, 20.0),
              ),
            ),
            centerTitle: true,
            elevation: 0.0,
          ),
          body: orientation == Orientation.landscape
              ? SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      children: [
                        // اطلاعات ادمین
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(padding + 8),
                          margin: EdgeInsets.only(bottom: spacing),
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
                                style: AppTextStyles.heading3.copyWith(
                                  fontSize:
                                      _getResponsiveFontSize(context, 18.0),
                                ),
                              ),
                              SizedBox(height: spacing),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: AppColors.primaryBlue,
                                    size: iconSize,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'نام: ادمین سیستم',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontSize: _getResponsiveFontSize(
                                            context, 14.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: spacing / 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: AppColors.primaryBlue,
                                    size: iconSize,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'شماره تماس: $adminPhone',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontSize: _getResponsiveFontSize(
                                            context, 14.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: spacing / 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings,
                                    color: AppColors.primaryBlue,
                                    size: iconSize,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'نقش: مدیر سیستم',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontSize: _getResponsiveFontSize(
                                            context, 14.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // دکمه خروج از حساب
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(padding + 8),
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
                                style: AppTextStyles.heading3.copyWith(
                                  fontSize:
                                      _getResponsiveFontSize(context, 18.0),
                                ),
                              ),
                              SizedBox(height: spacing),
                              Text(
                                'با خروج از حساب ادمین، به صفحه اصلی فروشگاه منتقل خواهید شد.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.greyText,
                                  fontSize:
                                      _getResponsiveFontSize(context, 14.0),
                                ),
                              ),
                              SizedBox(height: spacing + 8),

                              // دکمه خروج
                              SizedBox(
                                width: double.infinity,
                                height: buttonHeight,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _logout,
                                  style: AppButtonStyles.dangerButton,
                                  icon: _isLoading
                                      ? SizedBox(
                                          width: iconSize,
                                          height: iconSize,
                                          child: CircularProgressIndicator(
                                            color: AppColors.primaryWhite,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Icon(
                                          Icons.logout,
                                          size: iconSize,
                                        ),
                                  label: Text(
                                    _isLoading
                                        ? 'در حال خروج...'
                                        : 'خروج از حساب ادمین',
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
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(padding),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // اطلاعات ادمین
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(padding + 8),
                          margin: EdgeInsets.only(bottom: spacing),
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
                                style: AppTextStyles.heading3.copyWith(
                                  fontSize:
                                      _getResponsiveFontSize(context, 18.0),
                                ),
                              ),
                              SizedBox(height: spacing),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: AppColors.primaryBlue,
                                    size: iconSize,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'نام: ادمین سیستم',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontSize: _getResponsiveFontSize(
                                            context, 14.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: spacing / 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: AppColors.primaryBlue,
                                    size: iconSize,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'شماره تماس: $adminPhone',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontSize: _getResponsiveFontSize(
                                            context, 14.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: spacing / 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings,
                                    color: AppColors.primaryBlue,
                                    size: iconSize,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'نقش: مدیر سیستم',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontSize: _getResponsiveFontSize(
                                            context, 14.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // دکمه خروج از حساب
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(padding + 8),
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
                                style: AppTextStyles.heading3.copyWith(
                                  fontSize:
                                      _getResponsiveFontSize(context, 18.0),
                                ),
                              ),
                              SizedBox(height: spacing),
                              Text(
                                'با خروج از حساب ادمین، به صفحه اصلی فروشگاه منتقل خواهید شد.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.greyText,
                                  fontSize:
                                      _getResponsiveFontSize(context, 14.0),
                                ),
                              ),
                              SizedBox(height: spacing + 8),

                              // دکمه خروج
                              SizedBox(
                                width: double.infinity,
                                height: buttonHeight,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _logout,
                                  style: AppButtonStyles.dangerButton,
                                  icon: _isLoading
                                      ? SizedBox(
                                          width: iconSize,
                                          height: iconSize,
                                          child: CircularProgressIndicator(
                                            color: AppColors.primaryWhite,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Icon(
                                          Icons.logout,
                                          size: iconSize,
                                        ),
                                  label: Text(
                                    _isLoading
                                        ? 'در حال خروج...'
                                        : 'خروج از حساب ادمین',
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
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
