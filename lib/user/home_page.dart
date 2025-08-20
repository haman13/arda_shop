// ignore_for_file: prefer_function_declarations_over_variables

import 'package:arda_shop/theme.dart';
import 'package:arda_shop/user/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart.dart';
import 'profile.dart';
import 'register_page.dart';
import 'user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;

  // متغیرهای جستجو و فیلتر
  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = ['همه'];
  double _minPrice = 0;
  double _maxPrice = 1000000;
  RangeValues _priceRange = const RangeValues(0, 1000000);

  // TabController برای مدیریت تب‌ها
  late TabController _tabController;
  int _currentTabIndex = 0;
  late final ScrollController _categoryScrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); // شروع با یک تب
    _tabController.addListener(_onTabChanged);
    _categoryScrollController = ScrollController();
    _waitForUserProviderAndLoadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging ||
        _tabController.index != _currentTabIndex) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
      _filterProducts();
    }
  }

  /// صبر برای initialize شدن UserProvider و سپس بارگذاری محصولات
  Future<void> _waitForUserProviderAndLoadProducts() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // صبر تا UserProvider initialize شود
    while (!userProvider.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    debugPrint('UserProvider initialized, loading products...');
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('products').select();

      setState(() {
        _products = List<Map<String, dynamic>>.from(response);
        _filteredProducts = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });

      // استخراج دسته‌بندی‌ها و به‌روزرسانی TabController
      _extractCategories();
      _updatePriceRange();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطا در بارگذاری محصولات: $e',
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

  void _extractCategories() {
    final Set<String> categorySet = {'همه'};
    for (final product in _products) {
      if (product['category'] != null &&
          product['category'].toString().isNotEmpty) {
        categorySet.add(product['category']);
      }
    }

    final newCategories = categorySet.toList();

    // اگر تعداد دسته‌بندی‌ها تغییر کرده، TabController را به‌روزرسانی کن
    if (newCategories.length != _categories.length) {
      final oldController = _tabController;
      _tabController = TabController(length: newCategories.length, vsync: this);
      _tabController.addListener(_onTabChanged);
      _currentTabIndex = 0;

      // dispose کردن TabController قدیمی بعد از ایجاد یکی جدید
      WidgetsBinding.instance.addPostFrameCallback((_) {
        oldController.dispose();
      });
    }

    setState(() {
      _categories = newCategories;
    });
  }

  void _updatePriceRange() {
    if (_products.isEmpty) return;

    final prices =
        _products.map((p) => (p['final_price'] as num).toDouble()).toList();
    setState(() {
      _minPrice = prices.reduce((a, b) => a < b ? a : b);
      _maxPrice = prices.reduce((a, b) => a > b ? a : b);
      _priceRange = RangeValues(_minPrice, _maxPrice);
    });
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        // فیلتر بر اساس جستجو
        final matchesSearch = _searchController.text.isEmpty ||
            product['name']
                .toString()
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        // فیلتر بر اساس تب انتخابی (دسته‌بندی)
        final selectedCategory = _categories[_currentTabIndex];
        final matchesCategory = selectedCategory == 'همه' ||
            (product['category'] != null &&
                product['category'] == selectedCategory);

        // فیلتر بر اساس قیمت
        final productPrice = (product['final_price'] as num).toDouble();
        final matchesPrice = productPrice >= _priceRange.start &&
            productPrice <= _priceRange.end;

        return matchesSearch && matchesCategory && matchesPrice;
      }).toList();
    });
  }

  // تعیین حداکثر عرض هر کارت برای auto-fit شدن تعداد ستون‌ها
  double _getMaxCrossAxisExtent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1400) {
      return 320; // دسکتاپ‌های عریض: کارت بزرگ‌تر
    } else if (screenWidth >= 1200) {
      return 300; // دسکتاپ: کارت نسبتاً بزرگ
    } else if (screenWidth >= 1000) {
      return 280; // لپ‌تاپ‌های متوسط
    } else if (screenWidth >= 800) {
      return 260; // تبلت‌های بزرگ
    } else if (screenWidth >= 600) {
      return 240; // تبلت/فبلت
    } else {
      return 200; // موبایل‌ها
    }
  }

  // تعیین نسبت طول به عرض بر اساس عرض صفحه (ساده‌سازی شده برای هماهنگی با auto-fit)
  double _getChildAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // موبایل‌های خیلی کوچک و کوچک: ارتفاع بیشتر
    if (screenWidth < 350) return 1.1;
    if (screenWidth < 400) return 1.05;

    // دستگاه‌های بزرگ‌تر: ارتفاع کمی بیشتر برای جاگیری بهتر محتوا
    if (screenWidth >= 1200) return 0.95; // دسکتاپ
    if (screenWidth >= 800) return 0.93; // تبلت
    if (screenWidth >= 500) return 0.92; // موبایل معمولی

    return 1.1; // موبایل کوچک
  }

  // تعیین ارتفاع تب‌ها بر اساس سایز صفحه
  double _getTabHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 350) {
      return 40; // موبایل خیلی کوچک
    } else if (screenWidth < 400) {
      return 45; // موبایل کوچک: تب‌های کوتاه‌تر
    } else if (screenWidth < 600) {
      return 50; // موبایل معمولی
    } else {
      return 55; // تبلت و دسکتاپ
    }
  }

  // تعیین padding تب‌ها بر اساس سایز صفحه
  EdgeInsets _getTabPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 350) {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    } else if (screenWidth < 400) {
      return const EdgeInsets.symmetric(horizontal: 10, vertical: 5);
    } else if (screenWidth < 600) {
      return const EdgeInsets.symmetric(horizontal: 14, vertical: 7);
    } else {
      return const EdgeInsets.symmetric(horizontal: 18, vertical: 9);
    }
  }

  // تعیین اندازه آیکون تب‌ها
  double _getTabIconSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 400 ? 16 : 18;
  }

  // تعیین فاصله بین آیکون و متن تب
  double _getTabIconSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 400 ? 4 : 8;
  }

  // تعیین فاصله grid بر اساس سایز صفحه
  double _getGridSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 350) {
      return 4; // موبایل خیلی کوچک: فاصله خیلی کم
    } else if (screenWidth < 400) {
      return 5; // موبایل کوچک: فاصله کم
    } else if (screenWidth < 600) {
      return 8; // موبایل معمولی
    } else {
      return AppDimensions.spacingMedium; // تبلت و دسکتاپ
    }
  }

  // تعیین padding grid بر اساس سایز صفحه
  EdgeInsets _getGridPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 350) {
      return const EdgeInsets.all(4); // موبایل خیلی کوچک
    } else if (screenWidth < 400) {
      return const EdgeInsets.all(6); // موبایل کوچک: padding کم
    } else if (screenWidth < 600) {
      return const EdgeInsets.all(10); // موبایل معمولی
    } else {
      return AppPadding.allMedium; // تبلت و دسکتاپ
    }
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // بررسی لاگین بودن کاربر
      if (!userProvider.isLoggedIn || userProvider.userPhone == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لطفاً ابتدا وارد حساب کاربری خود شوید',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.primaryWhite),
            ),
            backgroundColor: AppColors.warningOrange,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return;
      }

      // بررسی اینکه آیا userId در cache وجود دارد
      String? userId = userProvider.userId;

      final supabase = Supabase.instance.client;

      // اگر userId کش نداریم، پیدا کنیم و کش کنیم
      if (userId == null) {
        // نمایش لودینگ فقط برای اولین بار
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryBlue,
            ),
          ),
        );

        final userData = await supabase
            .from('users')
            .select('id')
            .eq('phone', userProvider.userPhone!)
            .single();

        userId = userData['id'].toString();
        userProvider.setUserId(userId); // کش کردن userId

        // بستن دیالوگ لودینگ
        if (mounted) Navigator.pop(context);
      }

      // بررسی وضعیت موجود با query سریع و اضافه/بروزرسانی
      try {
        // استفاده از stored procedure اگر موجود باشد (سریع‌تر)
        await supabase.rpc('add_to_cart', params: {
          'p_user_id': userId,
          'p_product_id': product['id'],
          'p_quantity': 1,
        });
      } catch (rpcError) {
        // fallback به روش معمولی اما بهینه‌شده
        final existingItem = await supabase
            .from('cart_items')
            .select('id, quantity')
            .eq('user_id', userId)
            .eq('product_id', product['id'])
            .maybeSingle();

        if (existingItem != null) {
          // بروزرسانی تعداد
          await supabase.from('cart_items').update({
            'quantity': (existingItem['quantity'] as int) + 1,
          }).eq('id', existingItem['id']);
        } else {
          // اضافه کردن آیتم جدید
          await supabase.from('cart_items').insert({
            'user_id': userId,
            'product_id': product['id'],
            'quantity': 1,
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'محصول به سبد خرید اضافه شد',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.primaryWhite),
            ),
            backgroundColor: AppColors.successGreen,
            duration: Duration(milliseconds: 1500), // کوتاه‌تر کردن مدت نمایش
          ),
        );
      }
    } catch (e) {
      // بستن دیالوگ لودینگ در صورت خطا
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطا: ${e.toString()}',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.primaryWhite),
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _showProductDetails(Map<String, dynamic> product) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        int Function(dynamic) countDigits = (dynamic value) {
          final String s = value?.toString() ?? '';
          return RegExp(r'\d').allMatches(s).length;
        };
        final int totalDigits =
            countDigits(product['price']) + countDigits(product['final_price']);
        final double dialogWidth = totalDigits >= 12 ? 350.0 : 330.0;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.xLarge,
          ),
          elevation: 8,
          child: Container(
            width: dialogWidth,
            height: 650.0,
            decoration: BoxDecoration(
              borderRadius: AppBorderRadius.xLarge,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.cardBackground,
                  AppColors.backgroundLight,
                ],
              ),
            ),
            child: ClipRRect(
              borderRadius: AppBorderRadius.xLarge,
              child: Column(
                children: [
                  // Header with close button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppGradients.blueGradient,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'جزئیات محصول',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.primaryWhite,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.primaryWhite,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // تصویر محصول با discount badge
                          Expanded(
                            flex: 3,
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: AppBorderRadius.large,
                                    color: AppColors.imagePlaceholder,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.cardShadowMedium,
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: product['image_url'] != null
                                      ? ClipRRect(
                                          borderRadius: AppBorderRadius.large,
                                          child: Image.network(
                                            product['image_url'],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(
                                                Icons.image_rounded,
                                                size: 80,
                                                color: AppColors.greyText,
                                              );
                                            },
                                          ),
                                        )
                                      : Icon(
                                          Icons.image_rounded,
                                          size: 80,
                                          color: AppColors.greyText,
                                        ),
                                ),
                                // Discount Badge
                                if (product['discount'] > 0)
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration:
                                          AppDecorations.modernDiscountBadge,
                                      child: Text(
                                        '${product['discount']}% تخفیف',
                                        style: const TextStyle(
                                          color: AppColors.discountBadgeText,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // اطلاعات محصول (اسکرول‌پذیر برای جلوگیری از اورفلو)
                          Expanded(
                            flex: 2,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.zero,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: AppTextStyles.productTitleLarge,
                                  ),
                                  const SizedBox(height: 12),

                                  if (product['description'] != null &&
                                      product['description']
                                          .toString()
                                          .isNotEmpty) ...[
                                    Text(
                                      product['description'],
                                      style: AppTextStyles.productDescription,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  // قیمت با استایل مدرن
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundLight,
                                      borderRadius: AppBorderRadius.medium,
                                      border: Border.all(
                                          color: AppColors.borderColor),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.local_offer_rounded,
                                          color: AppColors.primaryGreen,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        if (product['discount'] > 0) ...[
                                          Text(
                                            AppUtilities.formatPrice(
                                                product['price']),
                                            style: AppTextStyles.productOldPrice
                                                .copyWith(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        Text(
                                          AppUtilities.formatPrice(
                                              product['final_price']),
                                          style: AppTextStyles.productPriceLarge
                                              .copyWith(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // دکمه‌های عملیات
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: AppGradients.blueGradient,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primaryBlue
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              _addToCart(product);
                                            },
                                            style: AppButtonStyles
                                                .modernGradientButton,
                                            icon: const Icon(
                                              Icons.shopping_cart_rounded,
                                              size: 20,
                                            ),
                                            label: Text(
                                              'افزودن به سبد خرید',
                                              style: AppTextStyles
                                                  .modernButtonText,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'فیلتر محصولات',
                style: AppTextStyles.heading3,
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // فیلتر دسته‌بندی
                    if (_categories.length > 1) ...[
                      Text(
                        'دسته‌بندی:',
                        style: AppTextStyles.formLabel,
                      ),
                      AppSizedBox.height8,
                      DropdownButtonFormField<String>(
                        value: _categories[_currentTabIndex],
                        decoration: AppInputDecorations.formField('دسته‌بندی'),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              style: AppTextStyles.bodyMedium,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            _currentTabIndex = _categories.indexOf(value!);
                          });
                        },
                      ),
                      AppSizedBox.height16,
                    ],

                    // فیلتر قیمت
                    Text(
                      'محدوده قیمت:',
                      style: AppTextStyles.formLabel,
                    ),
                    AppSizedBox.height8,
                    Text(
                      '${AppUtilities.formatNumber(_priceRange.start.round())} - ${AppUtilities.formatNumber(_priceRange.end.round())} تومان',
                      style: AppTextStyles.greyText,
                    ),
                    RangeSlider(
                      values: _priceRange,
                      min: _minPrice,
                      max: _maxPrice,
                      divisions: 20,
                      activeColor: AppColors.primaryBlue,
                      inactiveColor: AppColors.greyBackground,
                      labels: RangeLabels(
                        _priceRange.start.round().toString(),
                        _priceRange.end.round().toString(),
                      ),
                      onChanged: (values) {
                        setDialogState(() {
                          _priceRange = values;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: AppButtonStyles.transparentButton,
                  child: Text(
                    'انصراف',
                    style: AppTextStyles.linkText,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // بازنشانی فیلترها
                    setDialogState(() {
                      _currentTabIndex = 0;
                      _priceRange = RangeValues(_minPrice, _maxPrice);
                    });
                  },
                  style: AppButtonStyles.transparentButton,
                  child: Text(
                    'بازنشانی',
                    style: AppTextStyles.linkText,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentTabIndex = _currentTabIndex;
                      _priceRange = _priceRange;
                    });
                    _filterProducts();
                    Navigator.of(context).pop();
                  },
                  style: AppButtonStyles.primaryButton,
                  child: Text(
                    'اعمال فیلتر',
                    style: AppTextStyles.buttonText,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Row(
            children: [
              // دکمه ورود/ثبت نام یا آیکون پروفایل بر اساس وضعیت ورود
              Expanded(
                flex: MediaQuery.of(context).size.width < 600 ? 3 : 2,
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    if (userProvider.isLoggedIn) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width < 400
                              ? 4
                              : AppDimensions.paddingMedium,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfilePage()),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: AppColors.appBarIcon,
                                    size:
                                        MediaQuery.of(context).size.width < 400
                                            ? 20
                                            : 24,
                                  ),
                                  if (MediaQuery.of(context).size.width >=
                                      400) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      userProvider.userName ?? 'کاربر',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.appBarIcon,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        margin: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.width < 400
                              ? 2
                              : AppDimensions.paddingSmall / 2,
                          horizontal: MediaQuery.of(context).size.width < 400
                              ? 4
                              : AppDimensions.paddingSmall,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width < 400
                              ? 8
                              : AppDimensions.paddingSmall * 1.5,
                          vertical: MediaQuery.of(context).size.width < 400
                              ? 2
                              : AppDimensions.paddingSmall / 2,
                        ),
                        decoration: AppDecorations.loginButton,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          },
                          style: AppButtonStyles.transparentButton,
                          child: Text(
                            MediaQuery.of(context).size.width < 400
                                ? 'ورود'
                                : 'ورود/ثبت نام',
                            style: AppTextStyles.linkText.copyWith(
                              color: AppColors.loginRegisterText,
                              fontSize: MediaQuery.of(context).size.width < 400
                                  ? 12
                                  : 14,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              // عنوان فروشگاه
              Expanded(
                flex: MediaQuery.of(context).size.width < 600 ? 2 : 3,
                child: Center(
                  child: Text(
                    MediaQuery.of(context).size.width < 400
                        ? 'آردا شاپ'
                        : 'فروشگاه اینترنتی',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primaryBlack,
                      fontSize:
                          MediaQuery.of(context).size.width < 600 ? 16 : 20,
                    ),
                  ),
                ),
              ),
              // آیکون سبد خرید
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.shopping_cart,
                      color: AppColors.appBarIcon,
                      size: MediaQuery.of(context).size.width < 400 ? 20 : 24,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartPage()),
                      );
                    },
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width < 400 ? 4 : 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: kToolbarHeight,
        backgroundColor: AppColors.appBarBackground,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          // نوار جستجوی مدرن
          Container(
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width < 350
                  ? 4
                  : MediaQuery.of(context).size.width < 400
                      ? 6
                      : AppDimensions.paddingMedium,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: AppDecorations.modernSearchField,
                    child: TextField(
                      controller: _searchController,
                      decoration: AppInputDecorations.modernSearchField(),
                      onChanged: (value) => _filterProducts(),
                    ),
                  ),
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width < 400 ? 6 : 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.blueGradient,
                    borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width < 400 ? 8 : 12,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardShadowLight,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _showFilterDialog,
                    icon: Icon(
                      Icons.tune_rounded,
                      color: AppColors.filterIconColor,
                      size: MediaQuery.of(context).size.width < 400 ? 20 : 24,
                    ),
                    style: AppButtonStyles.modernFilterButton,
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width < 400 ? 8 : 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dropdown برای صفحات خیلی کوچک
          if (!_isLoading &&
              _categories.length > 1 &&
              MediaQuery.of(context).size.width <= 320)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.searchFieldBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: DropdownButton<String>(
                value: _categories[_currentTabIndex],
                isExpanded: true,
                underline: const SizedBox(),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryBlack,
                ),
                items: _categories.asMap().entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.value,
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    final index = _categories.indexOf(newValue);
                    setState(() {
                      _currentTabIndex = index;
                    });
                    _filterProducts();
                  }
                },
              ),
            ),

          // تب‌های مدرن دسته‌بندی (فقط برای صفحات بزرگ‌تر از 320px)
          if (!_isLoading &&
              _categories.length > 1 &&
              MediaQuery.of(context).size.width > 320)
            Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  final delta = event.scrollDelta.dy;
                  _categoryScrollController.jumpTo(
                    (_categoryScrollController.position.pixels + delta).clamp(
                      _categoryScrollController.position.minScrollExtent,
                      _categoryScrollController.position.maxScrollExtent,
                    ),
                  );
                }
              },
              child: Container(
                height: _getTabHeight(context),
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width < 350
                      ? 4
                      : MediaQuery.of(context).size.width < 400
                          ? 6
                          : AppDimensions.paddingMedium,
                ),
                child: ListView.builder(
                  controller: _categoryScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isActive = index == _currentTabIndex;
                    return Padding(
                      padding: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width < 400 ? 4 : 6,
                        top: MediaQuery.of(context).size.width < 400 ? 4 : 6,
                        bottom: MediaQuery.of(context).size.width < 400 ? 4 : 6,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          _tabController.animateTo(index);
                          setState(() {
                            _currentTabIndex = index;
                          });
                          _filterProducts();
                        },
                        child: AnimatedContainer(
                          duration: AppAnimations.tabTransition,
                          padding: _getTabPadding(context),
                          decoration: isActive
                              ? AppDecorations.activeTab
                              : AppDecorations.inactiveTab,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (MediaQuery.of(context).size.width >= 350) ...[
                                Icon(
                                  AppCategoryIcons.getIcon(category),
                                  size: _getTabIconSize(context),
                                  color: isActive
                                      ? AppColors.tabActiveText
                                      : AppColors.tabInactiveText,
                                ),
                                SizedBox(width: _getTabIconSpacing(context)),
                              ],
                              Text(
                                category,
                                style: isActive
                                    ? AppTextStyles.tabActive.copyWith(
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    400
                                                ? 11
                                                : 14,
                                      )
                                    : AppTextStyles.tabInactive.copyWith(
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    400
                                                ? 11
                                                : 14,
                                      ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // محتوای محصولات مدرن
          Expanded(
            child: _isLoading
                ? Padding(
                    padding: _getGridPadding(context),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: _getMaxCrossAxisExtent(context),
                        childAspectRatio: _getChildAspectRatio(context),
                        crossAxisSpacing: _getGridSpacing(context),
                        mainAxisSpacing: _getGridSpacing(context),
                      ),
                      itemCount: 8, // Loading shimmer count
                      itemBuilder: (context, index) {
                        return AppWidgetBuilders.modernLoadingShimmer(
                            context: context);
                      },
                    ),
                  )
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: AppColors.greyText,
                            ),
                            AppSizedBox.height16,
                            Text(
                              'هیچ محصولی یافت نشد',
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColors.greyText,
                              ),
                            ),
                            AppSizedBox.height8,
                            Text(
                              'تلاش کنید با کلمات کلیدی دیگری جستجو کنید',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.greyText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: _getGridPadding(context),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: _getMaxCrossAxisExtent(context),
                          childAspectRatio: _getChildAspectRatio(context),
                          crossAxisSpacing: _getGridSpacing(context),
                          mainAxisSpacing: _getGridSpacing(context),
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return AppWidgetBuilders.modernProductCard(
                            context: context,
                            product: product,
                            onTap: () => _showProductDetails(product),
                            onAddToCart: () => _addToCart(product),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
