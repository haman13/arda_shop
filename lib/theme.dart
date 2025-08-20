// ignore_for_file: provide_deprecation_message

import 'package:flutter/material.dart';

// ============= Admin Credentials =============
const String adminPhone = '09123456789';
const String adminPassword = '123456';

// ============= Supabase Configuration =============
const String supabaseUrl = 'https://qkjlatswbxyjkdyxrsjr.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFramxhdHN3Ynh5amtkeXhyc2pyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2NjM2MzYsImV4cCI6MjA2MzIzOTYzNn0.EU2DBkoSskYat1IkAmho6UQj1JdsZAHb5W8-wK8__Pk';

// ============= App Colors =============
class AppColors {
  // Modern Primary Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBlueDark = Color(0xFF1976D2);
  static const Color primaryBlueLight = Color(0xFF64B5F6);
  static const Color primaryRed = Color(0xFFE53935);
  static const Color primaryGreen = Color(0xFF43A047);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color primaryBlack = Color(0xFF212121);

  // Modern Gradient Colors
  static const Color gradientStart = Color(0xFF667eea);
  static const Color gradientEnd = Color(0xFF764ba2);
  static const Color cardGradientStart = Color(0xFFf093fb);
  static const Color cardGradientEnd = Color(0xFFf5576c);
  static const Color blueGradientStart = Color(0xFF4fc3f7);
  static const Color blueGradientEnd = Color(0xFF29b6f6);

  // Modern Tab Colors
  static const Color tabActiveBackground = Color(0xFF2196F3);
  static const Color tabInactiveBackground = Color(0xFFE3F2FD);
  static const Color tabActiveText = Color(0xFFFFFFFF);
  static const Color tabInactiveText = Color(0xFF1976D2);
  static const Color tabIndicator = Color(0xFF2196F3);

  // Enhanced Product Colors
  static const Color productCardShadow = Color(0x15000000);
  static const Color productHoverShadow = Color(0x25000000);
  static const Color discountBadge = Color(0xFFFF5722);
  static const Color discountBadgeText = Color(0xFFFFFFFF);

  // App Bar Colors
  static const Color appBarBackground =
      softGreenBackground; // استفاده در: پس‌زمینه AppBar تمام صفحات، دکمه ورود در صفحه اصلی
  static const Color appBarIcon = Colors
      .red; // استفاده در: آیکون‌های AppBar، آیکون سبد خرید، دکمه ورود/ثبت‌نام

  // Authentication Colors
  static const Color loginRegisterText =
      Colors.red; // استفاده در: متن دکمه ورود/ثبت‌نام در صفحه اصلی
  static const Color authLoadingIndicator =
      Colors.white; // رنگ نشانگر بارگذاری در صفحات احراز هویت

  // Product Colors
  static const Color productPrice = Colors
      .green; // استفاده در: قیمت محصولات در کارت‌ها، صفحه پرداخت، سبد خرید، تاریخچه سفارشات
  static const Color productOldPrice =
      Colors.grey; // استفاده در: قیمت قدیمی محصولات (با خط خورده)
  static const Color productImagePlaceholder =
      Color(0xFFE0E0E0); // استفاده در: جایگزین تصاویر محصولات وقتی لود نمی‌شوند
  static const Color imagePlaceholder =
      Color(0xFFE0E0E0); // استفاده در: جایگزین تصاویر کلی

  // Cart Colors
  static const Color cartDeleteButton =
      Colors.red; // رنگ دکمه حذف در سبد خرید (فعلاً مستقیماً استفاده نمی‌شود)
  static const Color cartTotalPrice =
      Colors.green; // رنگ قیمت کل در سبد خرید (فعلاً مستقیماً استفاده نمی‌شود)
  static const Color cartShadow =
      Color(0x1A000000); // استفاده در: سایه کارت‌های محصول و آیتم‌های سبد خرید

  // Status Colors
  static const Color successGreen = Colors
      .green; // استفاده در: پیام‌های موفقیت، وضعیت‌های مثبت سفارشات، دکمه‌های مثبت در ادمین
  static const Color errorRed = Colors
      .red; // استفاده در: پیام‌های خطا، دکمه‌های حذف، وضعیت‌های منفی، دکمه خروج
  static const Color warningOrange = Colors
      .orange; // استفاده در: هشدارها، وضعیت در انتظار، آیکون‌های نامشخص در پروفایل

  // Form Colors
  static const Color formFieldEnabled =
      Colors.blue; // رنگ فیلدهای فعال فرم (فعلاً مستقیماً استفاده نمی‌شود)
  static const Color formFieldDisabled = Color(
      0xFFF5F5F5); // رنگ فیلدهای غیرفعال فرم (فعلاً مستقیماً استفاده نمی‌شود)
  static const Color formFieldBorder =
      Colors.grey; // رنگ حاشیه فیلدهای فرم (فعلاً مستقیماً استفاده نمی‌شود)

  // Profile Colors
  static const Color profileEditableIcon =
      Colors.green; // آیکون فیلدهای قابل ویرایش در پروفایل
  static const Color profileFilledIcon =
      Colors.blue; // آیکون فیلدهای پر شده در پروفایل
  static const Color profileEmptyIcon =
      Colors.orange; // آیکون فیلدهای خالی در پروفایل
  static const Color profileLogoutButton =
      Colors.red; // رنگ دکمه خروج از حساب کاربری

  // Admin Colors
  static const Color adminAddCategory = Colors
      .blue; // رنگ دکمه افزودن دسته‌بندی در پنل ادمین (فعلاً استفاده نمی‌شود)
  static const Color adminLoadingBackground =
      Color(0xFFE3F2FD); // پس‌زمینه کانتینر لودینگ در ادمین
  static const Color adminLoadingBorder =
      Color(0xFF90CAF9); // حاشیه کانتینر لودینگ در ادمین

  // General UI Colors
  static const Color greyText = Color(0xFF757575);
  static const Color greyBackground = Color(0xFFF5F5F5);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color searchFieldBackground = Color(0xFFF8F9FA);
  static const Color filterButtonBackground = Color(0xFF2196F3);
  static const Color filterButtonText = Color(0xFFFFFFFF);
  // Very soft green page background
  static const Color softGreenBackground = Color.fromARGB(
      244, 28, 241, 142); // پس‌زمینه خیلی ملایم سبز برای کل صفحات
  // Slightly darker green for product cards
  static const Color productCardBackground = Color.fromARGB(
      255, 221, 228, 116); // کمی تیره‌تر از پس‌زمینه صفحه برای تمایز کارت‌ها

  // Modern Search & Filter Colors
  static const Color searchFieldBorder = Color(0xFFE1E5E9);
  static const Color searchFieldFocused = Color(0xFF2196F3);
  static const Color searchIconColor = Color(0xFF9E9E9E);
  static const Color filterIconColor = Color(0xFFFFFFFF);

  // Enhanced Card and Shadow Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFF0F2F5);
  static const Color cardShadowLight = Color(0x0A000000);
  static const Color cardShadowMedium = Color(0x15000000);
  static const Color cardShadowHeavy = Color(0x25000000);
  static const Color borderColor = Color(0xFFE1E5E9);
  static const Color backgroundLight = Color(0xFFF8F9FA);

  // Loading and Animation Colors
  static const Color loadingBackground = Color(0xFFE3F2FD);
  static const Color loadingIndicator = Color(0xFF2196F3);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}

// ============= Gradients =============
class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [AppColors.blueGradientStart, AppColors.blueGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      AppColors.shimmerBase,
      AppColors.shimmerHighlight,
      AppColors.shimmerBase,
    ],
    stops: [0.1, 0.3, 0.4],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    tileMode: TileMode.clamp,
  );
}

// ============= Animation Durations =============
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration tabTransition = Duration(milliseconds: 250);
  static const Duration cardHover = Duration(milliseconds: 150);
  static const Duration searchDelay = Duration(milliseconds: 300);
}

// ============= Category Icons =============
class AppCategoryIcons {
  static const Map<String, IconData> categoryIconMap = {
    'همه': Icons.grid_view_rounded,
    'کتاب': Icons.menu_book_rounded,
    'لباس': Icons.checkroom_rounded,
    'الکترونیک': Icons.devices_rounded,
    'خانه و آشپزخانه': Icons.kitchen_rounded,
    'ورزش': Icons.sports_soccer_rounded,
    'کیف و کفش': Icons.shopping_bag_rounded,
    'زیبایی': Icons.face_rounded,
    'اسباب بازی': Icons.toys_rounded,
    'سلامت': Icons.health_and_safety_rounded,
    'خودرو': Icons.directions_car_rounded,
    'باغبانی': Icons.eco_rounded,
  };

  static IconData getIcon(String category) {
    return categoryIconMap[category] ?? Icons.category_rounded;
  }
}

// ============= Text Styles =============
class AppTextStyles {
  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ); // استفاده در: عناوین اصلی صفحات، عنوان‌های بزرگ

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ); // استفاده در: عنوان "فروشگاه اینترنتی" در صفحه اصلی

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ); // استفاده در: عناوین فرعی، عنوان دیالوگ‌ها، پیام "هیچ محصولی یافت نشد"

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  ); // استفاده در: متن‌های اصلی، محتوای کلی

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  ); // استفاده در: متن‌های SnackBar، محتوای متوسط

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  ); // استفاده در: متن‌های کوچک، جزئیات

  // Product Styles
  static const TextStyle productTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ); // استفاده در: نام محصولات در کارت‌های محصول و سبد خرید

  static const TextStyle productPrice = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.productPrice,
  ); // استفاده در: قیمت نهایی محصولات، مجموع قیمت‌ها، قیمت در تاریخچه سفارشات

  static const TextStyle productOldPrice = TextStyle(
    fontSize: 12,
    decoration: TextDecoration.lineThrough,
    color: AppColors.productOldPrice,
  ); // استفاده در: قیمت قدیمی محصولات (با خط خورده) در کارت محصول

  // Form Styles
  static const TextStyle formLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  ); // استفاده در: برچسب‌های فرم‌ها، لیبل فیلدها

  static const TextStyle formHint = TextStyle(
    fontSize: 14,
    color: AppColors.greyText,
  ); // استفاده در: متن‌های راهنما در فرم‌ها

  // Button Styles
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  ); // استفاده در: متن روی تمام دکمه‌ها، دکمه افزودن به سبد خرید

  static const TextStyle linkText = TextStyle(
    fontSize: 14,
    color: AppColors.primaryBlue,
  ); // استفاده در: لینک‌ها، متن‌های قابل کلیک

  // Special Styles
  static const TextStyle errorText = TextStyle(
    fontSize: 12,
    color: AppColors.errorRed,
  ); // استفاده در: پیام‌های خطا

  static const TextStyle successText = TextStyle(
    fontSize: 14,
    color: AppColors.successGreen,
  ); // استفاده در: پیام‌های موفقیت

  static const TextStyle greyText = TextStyle(
    fontSize: 12,
    color: AppColors.greyText,
  );

  static const TextStyle categoryText = TextStyle(
    fontSize: 12,
    color: AppColors.primaryBlue,
  );

  static const TextStyle logoutText = TextStyle(
    fontSize: 16,
    color: AppColors.profileLogoutButton,
  );

  // Modern Tab Styles
  static const TextStyle tabActive = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.tabActiveText,
  );

  static const TextStyle tabInactive = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.tabInactiveText,
  );

  // Enhanced Product Styles
  static const TextStyle productTitleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlack,
    height: 1.3,
  );

  static const TextStyle productDescription = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.greyText,
    height: 1.4,
  );

  static const TextStyle productPriceLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.productPrice,
  );

  // Modern Button Text
  static const TextStyle modernButtonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryWhite,
    letterSpacing: 0.5,
  );
}

// ============= Dimensions =============
class AppDimensions {
  // Padding
  static const double paddingXSmall = 4.0; // فاصله‌گذاری بسیار کوچک
  static const double paddingSmall =
      8.0; // فاصله‌گذاری کوچک، استفاده در کارت‌های محصول
  static const double paddingMedium =
      16.0; // فاصله‌گذاری متوسط، استفاده در اکثر صفحات
  static const double paddingLarge = 24.0; // فاصله‌گذاری بزرگ
  static const double paddingXLarge = 32.0; // فاصله‌گذاری بسیار بزرگ

  // Margin
  static const double marginXSmall = 4.0;
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;
  static const double marginXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;

  // Heights
  static const double buttonHeight = 48.0;
  static const double textFieldHeight = 56.0;
  static const double appBarHeight = kToolbarHeight;
  static const double productImageHeight = 100.0;
  static const double loadingIndicatorHeight = 20.0;

  // Widths
  static const double loadingIndicatorWidth = 20.0;
  static const double iconSize = 24.0;
  static const double productImageWidth = 50.0;

  // Spacing
  static const double spacingXSmall =
      4.0; // فاصله بسیار کوچک، استفاده در SizedBox.height4
  static const double spacingSmall =
      8.0; // فاصله کوچک، استفاده در SizedBox.height8
  static const double spacingMedium =
      16.0; // فاصله متوسط، استفاده در SizedBox.height16، grid spacing
  static const double spacingLarge =
      24.0; // فاصله بزرگ، استفاده در SizedBox.height24
  static const double spacingXLarge =
      32.0; // فاصله بسیار بزرگ، استفاده در SizedBox.height32

  // Loading
  static const double loadingStrokeWidth = 2.0; // ضخامت خط نشانگر بارگذاری
}

// ============= Edge Insets =============
class AppPadding {
  static const EdgeInsets allSmall = EdgeInsets.all(AppDimensions.paddingSmall);
  static const EdgeInsets allMedium =
      EdgeInsets.all(AppDimensions.paddingMedium);
  static const EdgeInsets allLarge = EdgeInsets.all(AppDimensions.paddingLarge);
  static const EdgeInsets allXLarge =
      EdgeInsets.all(AppDimensions.paddingXLarge);

  static const EdgeInsets horizontalSmall =
      EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall);
  static const EdgeInsets horizontalMedium =
      EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium);
  static const EdgeInsets horizontalLarge =
      EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge);

  static const EdgeInsets verticalSmall =
      EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall);
  static const EdgeInsets verticalMedium =
      EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium);
  static const EdgeInsets verticalLarge =
      EdgeInsets.symmetric(vertical: AppDimensions.paddingLarge);

  static const EdgeInsets onlyRightMedium =
      EdgeInsets.only(right: AppDimensions.paddingMedium + 4);
  static const EdgeInsets symmetricHorizontalMediumVertical6 =
      EdgeInsets.symmetric(
    horizontal: AppDimensions.paddingMedium - 4,
    vertical: 6,
  );
  static const EdgeInsets symmetricHorizontalLargeVertical4 =
      EdgeInsets.symmetric(
    horizontal: AppDimensions.paddingSmall + 4,
    vertical: AppDimensions.paddingXSmall,
  );

  // Bottom margins
  static const EdgeInsets bottomMedium =
      EdgeInsets.only(bottom: AppDimensions.paddingMedium);
  static const EdgeInsets bottomSmall =
      EdgeInsets.only(bottom: AppDimensions.paddingSmall);
}

// ============= SizedBox Dimensions =============
class AppSizedBox {
  static const SizedBox height4 = SizedBox(
      height: AppDimensions
          .spacingXSmall); // فاصله عمودی 4px، استفاده بین قیمت و توضیحات محصول
  static const SizedBox height8 = SizedBox(
      height: AppDimensions
          .spacingSmall); // فاصله عمودی 8px، استفاده عمومی بین المان‌ها
  static const SizedBox height12 =
      SizedBox(height: 12); // فاصله عمودی 12px، استفاده در فرم‌ها
  static const SizedBox height16 = SizedBox(
      height: AppDimensions
          .spacingMedium); // فاصله عمودی 16px، استفاده متداول بین بخش‌ها
  static const SizedBox height24 = SizedBox(
      height: AppDimensions
          .spacingLarge); // فاصله عمودی 24px، استفاده بین بخش‌های مهم
  static const SizedBox height32 = SizedBox(
      height: AppDimensions
          .spacingXLarge); // فاصله عمودی 32px، استفاده بین بخش‌های اصلی

  static const SizedBox width4 =
      SizedBox(width: AppDimensions.spacingXSmall); // فاصله افقی 4px
  static const SizedBox width8 = SizedBox(
      width: AppDimensions.spacingSmall); // فاصله افقی 8px، استفاده بین دکمه‌ها
  static const SizedBox width12 = SizedBox(width: 12); // فاصله افقی 12px
  static const SizedBox width16 = SizedBox(
      width:
          AppDimensions.spacingMedium); // فاصله افقی 16px، استفاده در سبد خرید

  static const SizedBox loadingIndicator = SizedBox(
    width: AppDimensions.loadingIndicatorWidth,
    height: AppDimensions.loadingIndicatorHeight,
  ); // ابعاد نشانگر بارگذاری
}

// ============= Border Radius =============
class AppBorderRadius {
  static BorderRadius small = BorderRadius.circular(AppDimensions.radiusSmall);
  static BorderRadius medium =
      BorderRadius.circular(AppDimensions.radiusMedium);
  static BorderRadius large = BorderRadius.circular(AppDimensions.radiusLarge);
  static BorderRadius xLarge =
      BorderRadius.circular(AppDimensions.radiusXLarge);
}

// ============= Modern Box Decorations =============
class AppDecorations {
  // Login & Auth Decorations
  static BoxDecoration loginButton = BoxDecoration(
    color: AppColors.appBarBackground,
    borderRadius: AppBorderRadius.medium,
  );

  static BoxDecoration loadingContainer = BoxDecoration(
    color: AppColors.loadingBackground,
    borderRadius: AppBorderRadius.medium,
    border: Border.all(color: AppColors.primaryBlueLight),
  );

  // Modern Product Card Decorations
  static BoxDecoration modernProductCard = BoxDecoration(
    color: AppColors.productCardBackground,
    borderRadius: AppBorderRadius.large,
    border: Border.all(color: AppColors.cardBorder, width: 1),
    boxShadow: [
      BoxShadow(
        color: AppColors.cardShadowLight,
        blurRadius: 8,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      ),
    ],
  );

  static BoxDecoration modernProductCardHover = BoxDecoration(
    color: AppColors.productCardBackground,
    borderRadius: AppBorderRadius.large,
    border: Border.all(color: AppColors.primaryBlueLight, width: 1),
    boxShadow: [
      BoxShadow(
        color: AppColors.cardShadowMedium,
        blurRadius: 15,
        offset: const Offset(0, 5),
        spreadRadius: 0,
      ),
    ],
  );

  // Modern Tab Decorations
  static BoxDecoration activeTab = BoxDecoration(
    gradient: AppGradients.blueGradient,
    borderRadius: BorderRadius.circular(25),
    boxShadow: [
      BoxShadow(
        color: AppColors.cardShadowLight,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration inactiveTab = BoxDecoration(
    color: AppColors.tabInactiveBackground,
    borderRadius: BorderRadius.circular(25),
    border: Border.all(color: AppColors.borderColor, width: 1),
  );

  // Enhanced Discount Badge
  static BoxDecoration modernDiscountBadge = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFFF6B6B), Color(0xFFFF5722)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: AppColors.discountBadge.withValues(alpha: 0.3),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Modern Search Field
  static BoxDecoration modernSearchField = BoxDecoration(
    color: AppColors.searchFieldBackground,
    borderRadius: BorderRadius.circular(30),
    border: Border.all(color: AppColors.searchFieldBorder, width: 1),
    boxShadow: [
      BoxShadow(
        color: AppColors.cardShadowLight,
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  );

  // Legacy Support
  static BoxDecoration cartItemShadow = BoxDecoration(
    color: AppColors.primaryWhite,
    borderRadius: AppBorderRadius.medium,
    boxShadow: [
      BoxShadow(
        color: AppColors.cardShadowMedium,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration productCard = modernProductCard;
}

// ============= Modern Input Decorations =============
class AppInputDecorations {
  static InputDecoration modernSearchField([String? hintText]) {
    return InputDecoration(
      hintText: hintText ?? 'جستجو محصولات...',
      hintStyle: AppTextStyles.formHint,
      prefixIcon: Icon(
        Icons.search_rounded,
        color: AppColors.searchIconColor,
        size: 22,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: AppColors.searchFieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: AppColors.searchFieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: AppColors.searchFieldFocused, width: 2),
      ),
      filled: true,
      fillColor: AppColors.searchFieldBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  static InputDecoration modernDropdownField() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: AppBorderRadius.medium,
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.medium,
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.medium,
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      filled: true,
      fillColor: AppColors.searchFieldBackground,
      contentPadding: AppPadding.symmetricHorizontalMediumVertical6,
    );
  }

  static InputDecoration formField(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: AppTextStyles.formLabel,
      hintStyle: AppTextStyles.formHint,
      border: OutlineInputBorder(
        borderRadius: AppBorderRadius.medium,
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.medium,
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.medium,
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
    );
  }

  // Legacy Support
  static InputDecoration searchField([String? hintText]) =>
      modernSearchField(hintText);
  static InputDecoration dropdownField() => modernDropdownField();
  static InputDecoration categoryDropdown = const InputDecoration(
    border: OutlineInputBorder(),
    hintText: 'انتخاب دسته‌بندی',
  );
}

// ============= Modern Button Styles =============
class AppButtonStyles {
  // Modern Primary Buttons
  static ButtonStyle modernPrimaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryBlue,
    foregroundColor: AppColors.primaryWhite,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    textStyle: AppTextStyles.modernButtonText,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    shadowColor: AppColors.primaryBlue.withValues(alpha: 0.3),
  );

  static ButtonStyle modernGradientButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.primaryWhite,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    textStyle: AppTextStyles.modernButtonText,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
    shadowColor: AppColors.primaryBlue.withValues(alpha: 0.4),
  );

  // Modern Secondary Buttons
  static ButtonStyle modernSecondaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryGreen,
    foregroundColor: AppColors.primaryWhite,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    textStyle: AppTextStyles.modernButtonText.copyWith(fontSize: 13),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 2,
    shadowColor: AppColors.primaryGreen.withValues(alpha: 0.3),
  );

  // Modern Filter Button
  static ButtonStyle modernFilterButton = IconButton.styleFrom(
    backgroundColor: AppColors.primaryBlue,
    foregroundColor: AppColors.primaryWhite,
    padding: const EdgeInsets.all(12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    shadowColor: AppColors.primaryBlue.withValues(alpha: 0.3),
  );

  // Modern Tab Button (Active)
  static ButtonStyle modernActiveTabButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.tabActiveText,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    textStyle: AppTextStyles.tabActive,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    elevation: 0,
  );

  // Modern Tab Button (Inactive)
  static ButtonStyle modernInactiveTabButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.tabInactiveBackground,
    foregroundColor: AppColors.tabInactiveText,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    textStyle: AppTextStyles.tabInactive,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
      side: BorderSide(color: AppColors.borderColor, width: 1),
    ),
    elevation: 0,
  );

  // Enhanced Danger Button
  static ButtonStyle modernDangerButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.errorRed,
    foregroundColor: AppColors.primaryWhite,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    textStyle: AppTextStyles.modernButtonText,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    shadowColor: AppColors.errorRed.withValues(alpha: 0.3),
  );

  // Enhanced Success Button
  static ButtonStyle modernSuccessButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.successGreen,
    foregroundColor: AppColors.primaryWhite,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    textStyle: AppTextStyles.modernButtonText,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    shadowColor: AppColors.successGreen.withValues(alpha: 0.3),
  );

  // Transparent Button
  static ButtonStyle modernTransparentButton = TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    minimumSize: const Size(0, 0),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // Legacy Support
  static ButtonStyle primaryButton = modernPrimaryButton;
  static ButtonStyle secondaryButton = modernSecondaryButton;
  static ButtonStyle successButton = modernSuccessButton;
  static ButtonStyle dangerButton = modernDangerButton;
  static ButtonStyle filterButton = modernFilterButton;
  static ButtonStyle transparentButton = modernTransparentButton;
  static ButtonStyle warningButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.warningOrange,
    foregroundColor: AppColors.primaryWhite,
    padding: AppPadding.verticalMedium,
    textStyle: AppTextStyles.buttonText,
  );
}

// ============= Modern Tab Styles =============
class AppTabStyles {
  static Widget modernTabWidget({
    required String title,
    required IconData icon,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration:
          isActive ? AppDecorations.activeTab : AppDecorations.inactiveTab,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color:
                isActive ? AppColors.tabActiveText : AppColors.tabInactiveText,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style:
                isActive ? AppTextStyles.tabActive : AppTextStyles.tabInactive,
          ),
        ],
      ),
    );
  }

  static Widget simpleTabWidget({
    required String title,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration:
          isActive ? AppDecorations.activeTab : AppDecorations.inactiveTab,
      child: Text(
        title,
        style: isActive ? AppTextStyles.tabActive : AppTextStyles.tabInactive,
      ),
    );
  }
}

// ============= Modern Widget Builders =============
class AppWidgetBuilders {
  static Widget modernProductCard({
    required BuildContext context,
    required Map<String, dynamic> product,
    required VoidCallback onTap,
    required VoidCallback onAddToCart,
    bool isHovered = false,
  }) {
    return AnimatedContainer(
      duration: AppAnimations.cardHover,
      decoration: isHovered
          ? AppDecorations.modernProductCardHover
          : AppDecorations.modernProductCard,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.large,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double scale = constraints.maxWidth / 240.0;
              if (scale < 0.8) scale = 0.8;
              if (scale > 1.25) scale = 1.25;

              double clampDouble(double v, double min, double max) =>
                  v < min ? min : (v > max ? max : v);

              final double padding = clampDouble(8.0 * scale, 4.0, 12.0);
              final double imageIconSize =
                  clampDouble(40.0 * scale, 24.0, 56.0);
              final double discountFont = clampDouble(10.0 * scale, 8.0, 12.0);
              final double discountPadH = clampDouble(8.0 * scale, 6.0, 12.0);
              final double discountPadV = clampDouble(4.0 * scale, 2.0, 6.0);
              final double titleFont = clampDouble(15.0 * scale, 12.0, 18.0);
              final double descFont = clampDouble(12.0 * scale, 10.0, 14.0);
              final double oldPriceFont = clampDouble(12.0 * scale, 10.0, 14.0);
              final double priceFont = clampDouble(14.0 * scale, 12.0, 18.0);
              final double buttonHeight = clampDouble(35.0 * scale, 16.0, 28.0);
              final double buttonPadH = clampDouble(20.0 * scale, 4.0, 12.0);
              final double buttonRadius = clampDouble(8.0 * scale, 6.0, 12.0);
              final double buttonTextSize =
                  clampDouble(10.0 * scale, 9.0, 12.0);
              final double smallGap = clampDouble(4.0 * scale, 2.0, 6.0);
              final double tinyGap = clampDouble(2.0 * scale, 1.0, 4.0);
              final double priceGap = clampDouble(scale * 0.20, 4.0, 14.0);
              final bool verySmall = scale <= 0.85;

              return Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image Section
                    Expanded(
                      flex: 2,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: AppBorderRadius.medium,
                              color: AppColors.productImagePlaceholder,
                            ),
                            child: product['image_url'] != null
                                ? ClipRRect(
                                    borderRadius: AppBorderRadius.medium,
                                    child: Image.network(
                                      product['image_url'],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          Icons.image_rounded,
                                          size: imageIconSize,
                                          color: AppColors.greyText,
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    Icons.image_rounded,
                                    size: imageIconSize,
                                    color: AppColors.greyText,
                                  ),
                          ),
                          // Discount Badge
                          if (product['discount'] > 0)
                            Positioned(
                              top: smallGap,
                              right: smallGap,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: discountPadH,
                                  vertical: discountPadV,
                                ),
                                decoration: AppDecorations.modernDiscountBadge,
                                child: Text(
                                  '${product['discount']}%',
                                  style: TextStyle(
                                    color: AppColors.discountBadgeText,
                                    fontSize: discountFont,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: smallGap),
                    // Product Info Section - بدون دکمه
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            style: AppTextStyles.productTitle.copyWith(
                              fontSize: titleFont,
                            ),
                            maxLines: verySmall ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (product['description'] != null &&
                              product['description'].toString().isNotEmpty) ...[
                            SizedBox(height: tinyGap),
                            Text(
                              product['description'],
                              style: AppTextStyles.productDescription.copyWith(
                                fontSize: descFont,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(height: priceGap),

                          // Price Section
                          if (product['discount'] > 0) ...[
                            Text(
                              AppUtilities.formatPrice(product['price']),
                              style: AppTextStyles.productOldPrice.copyWith(
                                fontSize: oldPriceFont,
                              ),
                            ),
                            // SizedBox(height: priceGap),
                          ],
                          Text(
                            AppUtilities.formatPrice(product['final_price']),
                            style: AppTextStyles.productPriceLarge.copyWith(
                              fontSize: priceFont,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add to Cart Button - خارج از Product Info Section
                    SizedBox(height: tinyGap),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: onAddToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.primaryWhite,
                          padding: EdgeInsets.symmetric(
                            horizontal: buttonPadH,
                            vertical: 0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(buttonRadius),
                          ),
                          elevation: 1,
                          shadowColor:
                              AppColors.primaryGreen.withValues(alpha: 0.2),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          verySmall ? '+' : 'افزودن',
                          style: TextStyle(
                            fontSize: buttonTextSize,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static Widget modernLoadingShimmer({BuildContext? context}) {
    return Container(
      decoration: AppDecorations.modernProductCard,
      child: Padding(
        padding: EdgeInsets.all(
          context != null && MediaQuery.of(context).size.width < 350
              ? 4
              : context != null && MediaQuery.of(context).size.width < 400
                  ? 6
                  : 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: context != null && MediaQuery.of(context).size.width < 400
                  ? 2
                  : 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppBorderRadius.medium,
                  gradient: AppGradients.shimmerGradient,
                ),
              ),
            ),
            SizedBox(
                height:
                    context != null && MediaQuery.of(context).size.width < 400
                        ? 2
                        : 3),
            Expanded(
              flex: context != null && MediaQuery.of(context).size.width < 400
                  ? 2
                  : 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: context != null &&
                            MediaQuery.of(context).size.width < 350
                        ? 12
                        : context != null &&
                                MediaQuery.of(context).size.width < 400
                            ? 13
                            : 15,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: AppBorderRadius.small,
                      gradient: AppGradients.shimmerGradient,
                    ),
                  ),
                  SizedBox(
                      height: context != null &&
                              MediaQuery.of(context).size.width < 400
                          ? 2
                          : 3),
                  Container(
                    height: context != null &&
                            MediaQuery.of(context).size.width < 350
                        ? 10
                        : context != null &&
                                MediaQuery.of(context).size.width < 400
                            ? 11
                            : 12,
                    width: double.infinity * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: AppBorderRadius.small,
                      gradient: AppGradients.shimmerGradient,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: context != null &&
                            MediaQuery.of(context).size.width < 350
                        ? 12
                        : context != null &&
                                MediaQuery.of(context).size.width < 400
                            ? 13
                            : 14,
                    width: double.infinity * 0.5,
                    decoration: BoxDecoration(
                      borderRadius: AppBorderRadius.small,
                      gradient: AppGradients.shimmerGradient,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
                height:
                    context != null && MediaQuery.of(context).size.width < 400
                        ? 1
                        : 3),
            Container(
              height: context != null && MediaQuery.of(context).size.width < 350
                  ? 14
                  : context != null && MediaQuery.of(context).size.width < 400
                      ? 18
                      : 22,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: AppBorderRadius.medium,
                gradient: AppGradients.shimmerGradient,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Legacy support - به تدریج حذف خواهند شد
@deprecated
const Color enterRegisterColor = AppColors.loginRegisterText;
@deprecated
const Color appBarColor = AppColors.appBarBackground;

// ============= Utility Functions =============
class AppUtilities {
  /// فرمت کردن قیمت با جداکننده 3 رقمی
  /// مثال: formatPrice(1234567) => "1,234,567 تومان"
  static String formatPrice(dynamic price) {
    if (price == null) return '0 تومان';

    return '${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )} تومان';
  }

  /// فرمت کردن عدد با جداکننده 3 رقمی بدون واحد
  /// مثال: formatNumber(1234567) => "1,234,567"
  static String formatNumber(dynamic number) {
    if (number == null) return '0';

    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
