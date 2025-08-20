import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../admin/dashbord.dart';
import '../theme.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // بررسی ورود ادمین hardcoded
        if (_phoneController.text == adminPhone &&
            _passwordController.text == adminPassword) {
          if (mounted) {
            await Provider.of<UserProvider>(context, listen: false).login(
              name: 'ادمین',
              phone: adminPhone,
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          }
          return;
        }

        final supabase = Supabase.instance.client;

        final user = await supabase
            .from('users')
            .select('*, is_blocked, block_reason')
            .eq('phone', _phoneController.text)
            .eq('password', _passwordController.text)
            .maybeSingle();

        if (user == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'شماره تماس یا رمز عبور اشتباه است',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.primaryWhite),
                ),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
          return;
        }

        // Check if user is blocked
        if (user['is_blocked'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'حساب کاربری شما مسدود شده است.\nدلیل: ${user['block_reason'] ?? 'نامشخص'}',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.primaryWhite),
                ),
                backgroundColor: AppColors.errorRed,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        }

        if (mounted) {
          await Provider.of<UserProvider>(context, listen: false).login(
            name: user['name'],
            phone: user['phone'],
          );
          if (user['role'] == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'خطا در ورود: $e',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: Text(
          'ورود به سیستم',
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Padding(
        padding: AppPadding.allMedium,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _phoneController,
                decoration: AppInputDecorations.formField(
                  'شماره تماس',
                  hint: '09xxxxxxxxx',
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                maxLength: 11,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً شماره تماس را وارد کنید';
                  }
                  if (value.length != 11) {
                    return 'شماره تماس باید ۱۱ رقم باشد';
                  }
                  if (!value.startsWith('09')) {
                    return 'شماره تماس باید با ۰۹ شروع شود';
                  }
                  return null;
                },
              ),
              AppSizedBox.height16,
              TextFormField(
                controller: _passwordController,
                decoration: AppInputDecorations.formField('رمز عبور'),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_isLoading) {
                    _login();
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً رمز عبور را وارد کنید';
                  }
                  return null;
                },
              ),
              AppSizedBox.height24,
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
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
                          'ورود',
                          style: AppTextStyles.buttonText,
                        ),
                ),
              ),
              AppSizedBox.height16,
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()),
                  );
                },
                style: AppButtonStyles.transparentButton,
                child: Text(
                  'ثبت‌نام',
                  style: AppTextStyles.linkText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
