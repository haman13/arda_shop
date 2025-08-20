import 'package:arda_shop/user/home_page.dart';
import 'package:arda_shop/user/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import 'user_provider.dart';
import 'login_page.dart';
import 'order_history.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  bool _isLoading = true;
  bool _hasInitialized = false;

  // وضعیت قابل ویرایش بودن فیلدها
  bool _isNameEditable = false;
  bool _isPhoneEditable = false;
  bool _isAddressEditable = false;
  bool _isPostalCodeEditable = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _loadUserInfo();
    }
  }

  void _loadUserInfo() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.isLoggedIn || userProvider.userPhone == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'لطفاً دوباره وارد شوید!',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.primaryWhite),
              ),
              backgroundColor: AppColors.warningOrange,
            ),
          );
          Navigator.pop(context);
        }
      });
      return;
    }

    try {
      final supabase = Supabase.instance.client;

      // گرفتن اطلاعات کامل کاربر از دیتابیس
      final userData = await supabase
          .from('users')
          .select()
          .eq('phone', userProvider.userPhone!)
          .single();

      setState(() {
        _nameController.text = userData['name'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _addressController.text = userData['address'] ?? '';
        _postalCodeController.text = userData['postal_code'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _nameController.text = userProvider.userName ?? '';
        _phoneController.text = userProvider.userPhone ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserInfo() async {
    // جلوگیری از اجرای همزمان
    if (_isLoading) {
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'نام نمی‌تواند خالی باشد',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.primaryWhite),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty ||
        _phoneController.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'شماره تماس باید ۱۱ رقم باشد',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.primaryWhite),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    // بررسی کد پستی (اگر وارد شده باید 10 رقم باشد)
    if (_postalCodeController.text.trim().isNotEmpty &&
        _postalCodeController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'کد پستی باید دقیقاً ۱۰ رقم باشد',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.primaryWhite),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final supabase = Supabase.instance.client;

      // بررسی تکراری نبودن شماره جدید (فقط اگر تغییر کرده)
      if (_phoneController.text.trim() != userProvider.userPhone) {
        final existingUser = await supabase
            .from('users')
            .select()
            .eq('phone', _phoneController.text.trim())
            .maybeSingle();

        if (existingUser != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'این شماره تماس قبلاً ثبت شده است',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.primaryWhite),
                ),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
          return;
        }
      }

      // آپدیت اطلاعات در دیتابیس
      final existingRecord = await supabase
          .from('users')
          .select()
          .eq('phone', userProvider.userPhone!)
          .maybeSingle();

      if (existingRecord == null) {
        throw Exception('کاربر در دیتابیس پیدا نشد!');
      }

      final userId = existingRecord['id'];

      await supabase.from('users').update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
      }).eq('id', userId);

      // آپدیت UserProvider با اطلاعات جدید
      userProvider.updateUserInfo(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      // بستن حالت ویرایش
      setState(() {
        _isNameEditable = false;
        _isPhoneEditable = false;
        _isAddressEditable = false;
        _isPostalCodeEditable = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'اطلاعات با موفقیت ذخیره شد',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.primaryWhite),
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطا در ذخیره اطلاعات: $e',
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

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'خروج از حساب کاربری',
            style: AppTextStyles.heading3,
          ),
          content: Text(
            'آیا می‌خواهید از حساب کاربری خارج شوید؟',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // بستن دیالوگ
              },
              style: AppButtonStyles.transparentButton,
              child: Text(
                'انصراف',
                style: AppTextStyles.linkText,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // بستن دیالوگ

                // خروج از UserProvider
                await Provider.of<UserProvider>(context, listen: false)
                    .logout();

                // برگشت به صفحه ورود
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                }
              },
              style: AppButtonStyles.dangerButton,
              child: Text(
                'خروج',
                style: AppTextStyles.buttonText,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditable,
    required VoidCallback onEditPressed,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final hasValue = controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.formLabel,
            ),
            AppSizedBox.width8,
            GestureDetector(
              onTap: onEditPressed,
              child: Icon(
                hasValue
                    ? (isEditable ? Icons.check : Icons.edit)
                    : (isEditable ? Icons.check : Icons.add),
                size: 20,
                color: isEditable
                    ? AppColors.profileEditableIcon
                    : (hasValue
                        ? AppColors.profileFilledIcon
                        : AppColors.profileEmptyIcon),
              ),
            ),
          ],
        ),
        AppSizedBox.height8,
        TextField(
          controller: controller,
          readOnly: !isEditable,
          decoration: AppInputDecorations.formField(
            isEditable || !hasValue ? hintText ?? label : '',
            hint: isEditable || !hasValue ? hintText : null,
          ).copyWith(
            prefixIcon: Icon(prefixIcon),
            fillColor: isEditable ? null : AppColors.formFieldDisabled,
            filled: !isEditable,
          ),
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: Text(
          'پروفایل کاربر',
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: Icon(
              Icons.logout,
              color: AppColors.profileLogoutButton,
            ),
            tooltip: 'خروج از حساب کاربری',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
                strokeWidth: AppDimensions.loadingStrokeWidth,
              ),
            )
          : SingleChildScrollView(
              padding: AppPadding.allLarge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // نام
                  _buildEditableField(
                    label: 'نام و نام خانوادگی',
                    controller: _nameController,
                    isEditable: _isNameEditable,
                    onEditPressed: () {
                      setState(() {
                        _isNameEditable = !_isNameEditable;
                      });
                    },
                    prefixIcon: Icons.person_outline,
                    hintText: 'نام و نام خانوادگی خود را وارد کنید',
                  ),
                  AppSizedBox.height16,

                  // شماره تماس
                  _buildEditableField(
                    label: 'شماره تماس',
                    controller: _phoneController,
                    isEditable: _isPhoneEditable,
                    onEditPressed: () {
                      setState(() {
                        _isPhoneEditable = !_isPhoneEditable;
                      });
                    },
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    hintText: 'شماره تماس ۱۱ رقمی',
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  AppSizedBox.height16,

                  // کد پستی
                  _buildEditableField(
                    label: 'کد پستی',
                    controller: _postalCodeController,
                    isEditable: _isPostalCodeEditable,
                    onEditPressed: () {
                      setState(() {
                        _isPostalCodeEditable = !_isPostalCodeEditable;
                      });
                    },
                    prefixIcon: Icons.markunread_mailbox_outlined,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    hintText: 'کد پستی ۱۰ رقمی خود را وارد کنید',
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  AppSizedBox.height16,

                  // آدرس
                  _buildEditableField(
                    label: 'آدرس',
                    controller: _addressController,
                    isEditable: _isAddressEditable,
                    onEditPressed: () {
                      setState(() {
                        _isAddressEditable = !_isAddressEditable;
                      });
                    },
                    prefixIcon: Icons.home_outlined,
                    maxLines: 3,
                    hintText: 'آدرس کامل خود را وارد کنید',
                  ),
                  AppSizedBox.height32,

                  // دکمه تاریخچه سفارشات
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderHistoryPage(),
                          ),
                        );
                      },
                      style: AppButtonStyles.primaryButton,
                      icon: const Icon(Icons.history),
                      label: Text(
                        'تاریخچه سفارشات',
                        style: AppTextStyles.buttonText,
                      ),
                    ),
                  ),
                  AppSizedBox.height16,

                  // دکمه ذخیره (فقط اگر حداقل یک فیلد در حالت ویرایش باشه)
                  if (_isNameEditable ||
                      _isPhoneEditable ||
                      _isAddressEditable ||
                      _isPostalCodeEditable)
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton.icon(
                        onPressed: _saveUserInfo,
                        style: AppButtonStyles.successButton,
                        icon: const Icon(Icons.save),
                        label: Text(
                          'ذخیره تغییرات',
                          style: AppTextStyles.buttonText,
                        ),
                      ),
                    ),

                  // فاصله قبل از دکمه خروج
                  AppSizedBox.height32,

                  // دکمه خروج از حساب کاربری
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.profileLogoutButton),
                        padding: AppPadding.verticalMedium,
                      ),
                      icon: Icon(
                        Icons.logout,
                        color: AppColors.profileLogoutButton,
                      ),
                      label: Text(
                        'خروج از حساب کاربری',
                        style: AppTextStyles.logoutText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
