# Arda Shop

A Flutter web-based e-commerce application.

## Project Roadmap

### 1. Core Pages
- [x] Main page with product list
- [x] Product details page
- [x] Simple shopping cart
- [x] Checkout process

### 2. User System
- [x] Basic authentication (login/register)
- [x] User profile
- [x] State management with Provider
- [ ] Order history

### 3. Admin Panel
- [x] Product management (CRUD)
- [ ] Order management
- [ ] User management

### 4. Essential Features
- [x] Responsive design
- [x] Database integration
- [x] User session management
- [ ] Payment gateway integration

## Progress Summary
- User registration و ورود با شماره موبایل و رمز عبور پیاده‌سازی شد.
- سبد خرید و نمایش محصولات برای کاربر فعال است.
- اتصال به دیتابیس Supabase و خواندن/نوشتن اطلاعات انجام شد.
- فرآیند ثبت سفارش (Checkout) کامل پیاده‌سازی شد شامل:
  - دریافت اطلاعات ارسال (آدرس، شماره تماس، کد پستی)
  - ثبت سفارش در جداول orders و order_items
  - پاک کردن سبد خرید پس از ثبت موفق سفارش
- مدیریت وضعیت کاربر با Provider برای کل برنامه
- صفحه پروفایل کاربر با نمایش اطلاعات شخصی
- بهبود UI/UX با آیکون پروفایل هنگام لاگین بودن
- مرحله بعد: پیاده‌سازی تاریخچه سفارشات و مدیریت سفارشات در پنل ادمین

## Getting Started

This project is built with Flutter for web platform.

### Prerequisites
- Flutter SDK
- Dart SDK
- Web browser

### Dependencies
- Provider (State Management)
- Supabase Flutter (Backend & Database)
- Flutter Localizations (Persian language support)

### Running the project
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Supabase credentials in `theme.dart`
4. Run `flutter run -d chrome` to start the development server

## Project Structure
```
lib/
  ├── admin/              # Admin panel related code
  │   ├── dashbord.dart   # Admin dashboard
  │   └── editProduct.dart # Product management
  ├── user/               # User related code
  │   ├── home_page.dart  # Main shopping page
  │   ├── login_page.dart # User authentication
  │   ├── register_page.dart # User registration
  │   ├── profile.dart    # User profile page
  │   ├── cart.dart       # Shopping cart
  │   ├── checkout_page.dart # Order placement
  │   └── user_provider.dart # User state management
  ├── main.dart           # Application entry point
  └── theme.dart          # App theme and constants
```

## Development Status
- Current version: Beta
- Focus: Web platform
- State Management: Provider
- Database: Supabase
- Authentication: Custom implementation with Provider
- Localization: Persian (Farsi) support

## Technical Features
- ✅ Custom user authentication system
- ✅ Shopping cart functionality
- ✅ Complete checkout process
- ✅ Real-time data synchronization with Supabase
- ✅ Responsive design for web
- ✅ State management with Provider
- ✅ Persian language interface
- ✅ Admin panel for product management

## Next Steps
1. Implement order history for users
2. Add order management for admin panel
3. Add payment gateway integration
4. Implement user management in admin panel
5. Add product search and filtering
6. Enhance UI/UX with animations and improved styling

## Database Schema
- `users`: User information and authentication
- `products`: Product catalog with pricing
- `cart_items`: Shopping cart management
- `orders`: Order information
- `order_items`: Individual items in orders

## Contributing
Please read our contributing guidelines before submitting pull requests.

## License
This project is licensed under the MIT License.


// مشکل ورود به صفحه فروشگاه با دیتابیس به عنوان کاربر حل شد .
// مرحله بعد: پیاده‌سازی ثبت سفارش (Checkout) و نمایش سفارشات قبلی کاربر
// همچنین وضعیت سبد خرید و Database integration به حالت انجام شده تغییر کرد و // مرحله بعدی (Checkout) به عنوان گام بعدی مشخص شد.