import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'user/register_page.dart';
import 'admin/dashbord.dart';
import 'theme.dart';
import 'user/home_page.dart';
import 'user/login_page.dart';
import 'package:provider/provider.dart';
import 'user/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فروشگاه اینترنتی',
      scrollBehavior: const AppScrollBehavior(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
        useMaterial3: true,
        fontFamily: 'Vazirmatn',
        scaffoldBackgroundColor: AppColors.softGreenBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.softGreenBackground,
          elevation: 0,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fa', 'IR'),
      ],
      locale: const Locale('fa', 'IR'),
      home: const AuthWrapper(),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

// AuthWrapper برای تشخیص نوع کاربر بعد از refresh
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  Widget? _targetPage;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // صبر تا UserProvider initialize شود
      while (!userProvider.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // اگر کاربر لاگین هست، بررسی کن ادمین هست یا خیر
      if (userProvider.isLoggedIn && userProvider.userPhone != null) {
        // بررسی ادمین hardcoded
        if (userProvider.userPhone == adminPhone) {
          setState(() {
            _targetPage = const AdminDashboard();
            _isLoading = false;
          });
          return;
        }

        // بررسی ادمین از دیتابیس
        try {
          final supabase = Supabase.instance.client;
          final user = await supabase
              .from('users')
              .select('role')
              .eq('phone', userProvider.userPhone!)
              .single();

          if (user['role'] == 'admin') {
            setState(() {
              _targetPage = const AdminDashboard();
              _isLoading = false;
            });
            return;
          }
        } catch (e) {
          // اگر خطا داشت، به عنوان کاربر عادی در نظر بگیر
          debugPrint('Error checking admin role: $e');
        }
      }

      // در غیر این صورت به صفحه اصلی برو
      setState(() {
        _targetPage = const HomePage();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error in AuthWrapper: $e');
      setState(() {
        _targetPage = const HomePage();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 16),
              Text(
                'در حال بارگذاری...',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return _targetPage ?? const HomePage();
  }
}
