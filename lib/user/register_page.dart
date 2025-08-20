import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import 'login_page.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // بررسی تکراری نبودن شماره موبایل
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('phone', _phoneController.text)
          .maybeSingle();

      if (existingUser != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'این شماره موبایل قبلاً ثبت شده است. لطفاً با شماره دیگری تلاش کنید یا وارد شوید.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.primaryWhite),
              ),
              backgroundColor: AppColors.warningOrange,
            ),
          );
        }
        return;
      }

      // ثبت کاربر جدید
      await supabase.from('users').insert({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text, // در حالت واقعی باید رمزنگاری شود
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ثبت نام با موفقیت انجام شد',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.primaryWhite),
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
        // پاک کردن فرم
        _nameController.clear();
        _phoneController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();

        // بازگشت به صفحه قبل (مثلاً صفحه ورود)
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطا در ثبت نام: $e',
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
          'ثبت نام',
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: AppPadding.allMedium,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: AppInputDecorations.formField('نام و نام خانوادگی'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً نام و نام خانوادگی را وارد کنید';
                  }
                  return null;
                },
              ),
              AppSizedBox.height16,
              TextFormField(
                controller: _phoneController,
                decoration: AppInputDecorations.formField(
                  'شماره موبایل',
                  hint: '09xxxxxxxxx',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 11,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً شماره موبایل را وارد کنید';
                  }
                  if (value.length != 11) {
                    return 'شماره موبایل باید ۱۱ رقم باشد';
                  }
                  if (!value.startsWith('09')) {
                    return 'شماره موبایل باید با ۰۹ شروع شود';
                  }
                  return null;
                },
              ),
              AppSizedBox.height16,
              TextFormField(
                controller: _passwordController,
                decoration: AppInputDecorations.formField('رمز عبور'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً رمز عبور را وارد کنید';
                  }
                  if (value.length < 6) {
                    return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
                  }
                  return null;
                },
              ),
              AppSizedBox.height16,
              TextFormField(
                controller: _confirmPasswordController,
                decoration: AppInputDecorations.formField('تکرار رمز عبور'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً تکرار رمز عبور را وارد کنید';
                  }
                  if (value != _passwordController.text) {
                    return 'رمز عبور و تکرار آن مطابقت ندارند';
                  }
                  return null;
                },
              ),
              AppSizedBox.height24,
              SizedBox(
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: AppButtonStyles.primaryButton,
                  child: _isLoading
                      ? SizedBox(
                          width: AppDimensions.loadingIndicatorWidth,
                          height: AppDimensions.loadingIndicatorHeight,
                          child: CircularProgressIndicator(
                            color: AppColors.loadingIndicator,
                            strokeWidth: AppDimensions.loadingStrokeWidth,
                          ),
                        )
                      : Text(
                          'ثبت نام',
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
