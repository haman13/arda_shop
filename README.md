# Arda Shop

A Flutter web-based e-commerce application with complete Persian UI and payment simulation system.

## Project Roadmap

### 1. Core Pages
- [x] Main page with product list
- [x] Product details page
- [x] Shopping cart with full functionality
- [x] Checkout process with auto-fill user data
- [x] Payment simulation system

### 2. User System
- [x] Custom authentication (login/register)
- [x] User profile with editable information
- [x] State management with Provider
- [x] Order history with accordion UI

### 3. Admin Panel
- [x] Product management (CRUD)
- [x] Order management with status updates
- [x] Responsive admin dashboard with adaptive button sizing
- [x] Enhanced order details modal with product information
- [x] Order status management with proper constraints
- [ ] User management
  - [ ] User list with search and filtering
  - [ ] User details modal with order statistics
  - [ ] User status management (active/inactive)
  - [ ] Responsive user layout (1/2/3 columns)
  - [ ] User statistics dashboard
  - [ ] Order history per user
  - [ ] Advanced user editing (Phase 2)
  - [ ] User deletion with confirmation (Phase 2)
  - [ ] User notification system (Phase 2)

### 4. Essential Features
- [x] Responsive design (mobile/tablet/desktop breakpoints)
- [x] Database integration with proper schema
- [x] User session management with authentication wrapper
- [x] Payment simulation (cash on delivery + online gateway)
- [x] Complete RTL Persian interface
- [x] Admin authentication persistence after page refresh

## Progress Summary
کل سیستم فروشگاه آنلاین با ویژگی‌های زیر کامل پیاده‌سازی شده:

### Authentication & User Management
- ثبت‌نام و ورود کاربران با شماره موبایل
- مدیریت session کاربران
- پروفایل قابل ویرایش با اطلاعات کامل

### Shopping Experience
- نمایش محصولات با جزئیات کامل
- سبد خرید عملکردی با اتصال به دیتابیس
- فرآیند checkout با پیش‌پر کردن اطلاعات کاربر
- سیستم پرداخت شبیه‌سازی شده (نقدی + آنلاین)

### Order Management
- ثبت سفارشات با وضعیت‌های مختلف
- تاریخچه سفارشات کاربران با UI accordion
- مدیریت سفارشات در پنل ادمین با نمایش جزئیات محصولات
- مدیریت responsive سفارشات (1/2/3 ستونه بر اساس اندازه صفحه)
- Modal جزئیات سفارش با اندازه‌بندی بهینه برای دسکتاپ

### Database Schema Fixes
- اصلاح جداول cart_items و orders برای سازگاری با authentication دستی
- پشتیبانی کامل از انواع وضعیت پرداخت (paid, cash_on_delivery, pending, etc.)

## Payment System Features
- **پرداخت در محل**: ثبت سفارش با وضعیت cash_on_delivery
- **درگاه آنلاین**: شبیه‌سازی پرداخت با گزینه‌های موفق/ناموفق
- **مدیریت وضعیت**: نمایش رنگی وضعیت‌های مختلف در تاریخچه

## Getting Started

This project is built with Flutter for web platform.

### Prerequisites
- Flutter SDK (version 3.27.2+)
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
4. Run `flutter run -d chrome --web-port 3000` to start the development server

## Project Structure
```
lib/
  ├── admin/              # Admin panel related code
  │   ├── dashbord.dart   # Admin dashboard
  │   ├── editProduct.dart # Product management
  │   ├── order_management.dart # Order management
  │   └── user_management.dart # User management (Phase 1)
  ├── user/               # User related code
  │   ├── home_page.dart  # Main shopping page
  │   ├── login_page.dart # User authentication
  │   ├── register_page.dart # User registration
  │   ├── profile.dart    # User profile page
  │   ├── cart.dart       # Shopping cart
  │   ├── checkout_page.dart # Order placement
  │   ├── payment_page.dart # Payment simulation
  │   ├── order_history.dart # User order history (accordion UI)
  │   └── user_provider.dart # User state management
  ├── main.dart           # Application entry point
  └── theme.dart          # App theme and constants
```

## Development Status
- **Current version:** Production Ready v1.0
- **Platform:** Web Application
- **State Management:** Provider
- **Database:** Supabase
- **Authentication:** Custom implementation
- **Localization:** Complete Persian (RTL) support
- **Payment:** Simulation system (ready for real gateway integration)

## Technical Features
- ✅ Custom user authentication system
- ✅ Shopping cart with database synchronization
- ✅ Complete checkout process with auto-fill
- ✅ Payment simulation system
- ✅ Order history with accordion UI
- ✅ Order management for admin with detailed product information
- ✅ Real-time data synchronization with Supabase
- ✅ Responsive design for web (mobile/tablet/desktop breakpoints)
- ✅ State management with Provider
- ✅ Complete Persian RTL interface
- ✅ Admin panel for product and order management
- ✅ Proper navigation handling
- ✅ Authentication wrapper for admin session persistence
- ✅ Adaptive UI components based on screen size
- ✅ Database constraint validation for order status

## Database Schema
- **users**: User information and authentication (id, name, phone, password, created_at, updated_at, address, postal_code)
- **products**: Product catalog with pricing and images
- **cart_items**: Shopping cart management (linked to custom users table)
- **orders**: Order information with payment status and shipping details
- **order_items**: Individual items in orders with product relationships

## User Management System (In Development)
### Database Schema - Users Table
```sql
-- Current users table structure
create table public.users (
  id uuid not null default gen_random_uuid (),
  name text not null,
  phone text not null,
  password text not null,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  updated_at timestamp with time zone null default CURRENT_TIMESTAMP,
  address text null,
  postal_code character varying null default '10'::character varying,
  constraint users_pkey primary key (id),
  constraint users_phone_key unique (phone),
  constraint password_length check ((length(password) >= 6)),
  constraint phone_format check ((phone ~ '^09[0-9]{9}$'::text))
);

-- To enable user blocking feature, run these ALTER TABLE commands in Supabase SQL Editor:
ALTER TABLE public.users ADD COLUMN is_blocked boolean NOT NULL DEFAULT false;
ALTER TABLE public.users ADD COLUMN block_reason text NULL;
ALTER TABLE public.users ADD COLUMN blocked_at timestamp with time zone NULL;
ALTER TABLE public.users ADD COLUMN blocked_by text NULL;
```

### Phase 1 Features (Current Development)
1. **📋 User List Management**
   - Responsive grid layout (1/2/3 columns based on screen size)
   - Display user information: name, phone, registration date
   - User status indicators (active based on recent activity)

2. **🔍 Search & Filter System**
   - Search by name or phone number
   - Filter by registration date (recent/older)
   - Real-time search functionality

3. **👤 User Details Modal**
   - Complete user information display
   - Address and postal code details
   - User registration and last update timestamps

4. **📊 Order Statistics per User**
   - Total orders count for each user
   - Total purchase amount
   - Order history integration

5. **⚙️ User Status Management**
   - Visual status indicators
   - Activity-based status determination

6. **📈 User Statistics Dashboard**
   - Total users count
   - New registrations today/this week
   - User activity overview

### Phase 2 Features (In Progress)
7. **✏️ Advanced User Editing**
   - ❌ Not implemented - Users should manage their own information via profile page

8. **🗑️ User Account Management** ✅ **COMPLETED**
   - ✅ User blocking/unblocking system with reason tracking
   - ✅ Block reason requirement and display
   - ✅ Authentication prevention for blocked users
   - ✅ Admin interface for user status management
   - ✅ No user deletion capability (security policy)

9. **📧 User Notification System**
   - ⏳ Under review and design consideration

## Payment Status Management
- **pending**: در انتظار بررسی (Orange)
- **paid**: پرداخت شده (Green)
- **cash_on_delivery**: پرداخت در محل (Blue)
- **confirmed**: تایید شده (Blue)
- **shipped**: ارسال شده (Blue)
- **delivered**: تحویل داده شده (Green)
- **cancelled**: لغو شده (Red)

## UI/UX Features
- **Accordion Order History**: Collapsible order details for better user experience
- **Auto-fill Checkout**: Customer information automatically loaded from profile
- **Color-coded Status**: Visual status indicators throughout the application
- **Responsive Design**: Optimized for various screen sizes
- **Persian RTL Layout**: Complete right-to-left interface

## Next Steps
1. **Real Payment Gateway Integration**: Replace simulation with actual payment provider
2. **User Management in Admin**: Complete admin panel with user management
3. **Advanced Search & Filtering**: Enhanced product discovery
4. **Product Reviews & Ratings**: Customer feedback system
5. **Inventory Management**: Stock tracking and management
6. **Analytics Dashboard**: Sales and user behavior insights

📋 کارهای باقی‌مانده:
- ✅ بلاک/آنبلاک کردن کاربران (انجام شده)
- ⏳ سیستم آمار کاربران پیشرفته
- ⏳ فیلترها و جستجوی پیشرفته کاربران
- ⏳ گزارش‌گیری از فعالیت کاربران

سلام! من روی پروژه Arda Shop کار می‌کنم که یک فروشگاه آنلاین کامل با Flutter Web است.
🎯 وضعیت فعلی پروژه:
پروژه 100% تکمیل شده و کاملاً عملکرد دارد شامل:
ویژگی‌های اصلی:
سیستم ثبت‌نام/ورود کامل با شماره موبایل
سبد خرید متصل به دیتابیس
فرآیند checkout با پیش‌پر کردن اطلاعات
سیستم پرداخت شبیه‌سازی شده (نقدی + آنلاین)
تاریخچه سفارشات با UI accordion زیبا
پنل ادمین برای مدیریت محصولات و سفارشات
مشخصات فنی:
Flutter 3.27.2 + Dart
دیتابیس: Supabase
Authentication: سیستم دستی (بدون Supabase Auth)
State Management: Provider
UI: فارسی کامل (RTL)
Admin: phone=09123456789, password=123456
جداول دیتابیس (تصحیح شده):
users (authentication دستی)
products (کاتالوگ)
cart_items (سبد خرید)
orders (سفارشات با انواع وضعیت پرداخت)
order_items (آیتم‌های سفارش)
🎨 آخرین تغییرات اعمال شده:
UI accordion برای تاریخچه سفارشات (دکمه "مشاهده جزئیات" بالا و "بستن جزئیات" پایین)
بهبود رنگ‌بندی برای خوانایی بهتر
سیستم پرداخت کامل با وضعیت‌های مختلف
🚨 نکات مهم:
هیچ خطای فنی وجود ندارد
Database schema صحیح است
لطفاً فقط موارد مطرح شده را تغییر دهید
کدهای موجود را حفظ کنید
## Recent Updates & Improvements

### Admin Panel Enhancements
- **Admin Profile Management**: صفحه پروفایل ادمین ساده و کاربردی
  - دکمه پروفایل در AppBar به جای دکمه back
  - نمایش اطلاعات حساب ادمین (نام، شماره تماس، نقش)
  - دکمه خروج از حساب ادمین با بازگشت به صفحه اصلی
- **Responsive Dashboard**: دکمه‌های داشبورد ادمین حالا بر اساس اندازه دستگاه تنظیم می‌شوند:
  - موبایل: 70% عرض صفحه
  - تبلت: 65% ارتفاع صفحه  
  - دسکتاپ: 60% ارتفاع صفحه

### Order Management Improvements  
- **Enhanced Product Details**: نمایش کامل اطلاعات محصولات در جزئیات سفارش شامل:
  - تصاویر محصولات (60x60 پیکسل)
  - نام محصولات با محدودیت 2 خط
  - تعداد، قیمت واحد و مجموع هر محصول
  - مدیریت خطا برای تصاویر
- **Responsive Order Layout**: طراحی responsive برای مدیریت سفارشات:
  - موبایل: 1 ستون
  - تبلت: 2 ستون
  - دسکتاپ: 3 ستون
- **Optimized Modal Size**: اندازه modal جزئیات سفارش از عرض صفحه به ارتفاع صفحه وابسته شد (60% ارتفاع)

### Authentication & Security
- **Admin Session Persistence**: AuthWrapper اضافه شده برای حفظ session ادمین پس از refresh صفحه
- **Status Validation**: اعتبارسنجی وضعیت سفارشات با قیدهای دیتابیس

### Database Status Constraints
Supported order statuses: `pending`, `paid`, `cash_on_delivery`, `shipped`, `delivered`, `cancelled`

🔧 دستورات اجرا:
```bash
flutter pub get
flutter run -d chrome --web-port 3000
```

مکالمه به زبان فارسی - پروژه آماده توسعه بیشتر یا اتصال به سیستم‌های واقعی است.

💳 پیاده‌سازی درگاه‌های پرداخت:
- ✅ ZarinPal integration
- ⏳ آیدی‌پی (IDPay)
- ⏳ سداد
- ⏳ مدیریت transaction logs

⭐ ویژگی‌های مورد نیاز:
- امتیازدهی محصولات (1-5 ستاره)
- نظرات کاربران با تأیید ادمین
- نمایش میانگین امتیاز
- فیلتر کردن بر اساس امتیاز
- گزارش نظرات نامناسب

📊 گزارش‌های مورد نیاز:
- آمار فروش روزانه/ماهانه
- محبوب‌ترین محصولات
- رفتار کاربران (هیت مپ)
- آمار بازگشت کاربران
- نرخ conversion

## Cache Management
- پیاده‌سازی caching برای محصولات
- Image optimization و lazy loading
- Database indexing بهتر

## امنیت بیشتر
- Input sanitization
- SQL injection prevention  
- Rate limiting
- HTTPS enforcement

## کیفیت کد
- Unit & Widget Testing
- Code documentation
- Type safety improvements
- Error boundary implementation

قسمت کاربر تکمیل شد. همه چیز تست شد درسته
قسمت ادمین برای قسمت پرداخت و تغییر وضعیت ارور گرفتم بررسی کنیم