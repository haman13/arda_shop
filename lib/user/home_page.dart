import 'package:arda_shop/theme.dart';
import 'package:arda_shop/user/login_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart.dart';
import 'register_page.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('products').select();

      setState(() {
        _products = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری محصولات: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('کاربر وارد نشده است');
      }

      // بررسی وجود محصول در سبد خرید
      final existingItem = await supabase
          .from('cart_items')
          .select()
          .eq('user_id', userId)
          .eq('product_id', product['id'])
          .maybeSingle();

      if (existingItem != null) {
        // افزایش تعداد اگر محصول قبلاً در سبد خرید وجود دارد
        await supabase
            .from('cart_items')
            .update({'quantity': (existingItem['quantity'] as int) + 1}).eq(
                'id', existingItem['id']);
      } else {
        // افزودن محصول جدید به سبد خرید
        await supabase.from('cart_items').insert({
          'user_id': userId,
          'product_id': product['id'],
          'quantity': 1,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('محصول به سبد خرید اضافه شد')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در افزودن به سبد خرید: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Row(
            children: [
              // دکمه ورود/ثبت نام یا آیکون پروفایل بر اساس وضعیت ورود
              Expanded(
                flex: 2,
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    if (userProvider.isLoggedIn) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.person,
                                color: enterRegisterColor),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ProfilePage()),
                              );
                            },
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: appBarColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            'ورود/ثبت نام',
                            style: TextStyle(color: enterRegisterColor),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              // عنوان فروشگاه
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    'فروشگاه اینترنتی',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              // آیکون سبد خرید
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartPage()),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: kToolbarHeight,
        backgroundColor: appBarColor,
        elevation: 0.0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // تصویر محصول
                if (product['image_url'] != null)
                  Expanded(
                    child: Image.network(
                      product['image_url'],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Expanded(
                    child: Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
                    ),
                  ),
                // اطلاعات محصول
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (product['discount'] > 0) ...[
                        Text(
                          '${product['price']} تومان',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        '${product['final_price']} تومان',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _addToCart(product),
                          child: const Text('افزودن به سبد خرید'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
