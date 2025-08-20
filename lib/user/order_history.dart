import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import 'user_provider.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  Set<int> expandedOrders = {}; // برای نگهداری وضعیت باز/بسته هر سفارش

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userPhone = userProvider.userPhone;

      if (userPhone == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // دریافت سفارشات کاربر
      final response = await Supabase.instance.client
          .from('orders')
          .select('''
            id,
            total_amount,
            shipping_address,
            contact_phone,
            postal_code,
            status,
            created_at,
            order_items (
              quantity,
              price,
              products (
                name,
                image_url
              )
            )
          ''')
          .eq('user_phone', userPhone)
          .order('created_at', ascending: false);

      setState(() {
        orders = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در بارگذاری سفارشات: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'در انتظار بررسی';
      case 'paid':
        return 'پرداخت شده';
      case 'cash_on_delivery':
        return 'پرداخت در محل';
      case 'confirmed':
        return 'تایید شده';
      case 'shipped':
        return 'ارسال شده';
      case 'delivered':
        return 'تحویل داده شده';
      case 'cancelled':
        return 'لغو شده';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warningOrange;
      case 'paid':
        return AppColors.successGreen;
      case 'cash_on_delivery':
        return AppColors.primaryBlue;
      case 'confirmed':
        return AppColors.primaryBlue;
      case 'shipped':
        return AppColors.primaryBlue;
      case 'delivered':
        return AppColors.successGreen;
      case 'cancelled':
        return AppColors.errorRed;
      default:
        return AppColors.greyText;
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تاریخچه سفارشات',
          style: AppTextStyles.heading2,
        ),
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.appBarIcon),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : orders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: AppColors.greyText,
                      ),
                      SizedBox(height: AppDimensions.marginMedium),
                      Text(
                        'هیچ سفارشی ثبت نکرده‌اید',
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final orderItems = order['order_items'] as List<dynamic>;

                      final isExpanded = expandedOrders.contains(index);

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: AppDimensions.marginMedium,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMedium,
                          ),
                        ),
                        child: Column(
                          children: [
                            // هدر سفارش (همیشه نمایش داده می‌شود)
                            Padding(
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingMedium,
                              ),
                              child: Column(
                                children: [
                                  // ردیف بالا: شماره سفارش و وضعیت
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'سفارش #${order['id']}',
                                        style: AppTextStyles.heading3,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              AppDimensions.paddingSmall,
                                          vertical: AppDimensions.paddingXSmall,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            AppDimensions.radiusSmall,
                                          ),
                                          border: Border.all(
                                            color: _getStatusColor(
                                                order['status']),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          _getStatusText(order['status']),
                                          style: TextStyle(
                                            color: _getStatusColor(
                                                order['status']),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height: AppDimensions.marginSmall),

                                  // تاریخ و مبلغ کل
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'تاریخ: ${_formatDate(order['created_at'])}',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                      Text(
                                        AppUtilities.formatPrice(
                                            order['total_amount']),
                                        style:
                                            AppTextStyles.productPrice.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height: AppDimensions.marginSmall),

                                  // دکمه مشاهده جزئیات (فقط وقتی بسته است)
                                  if (!isExpanded)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          expandedOrders.add(index);
                                        });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppDimensions.paddingSmall,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.greyBackground,
                                          borderRadius: BorderRadius.circular(
                                            AppDimensions.radiusSmall,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'مشاهده جزئیات',
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                color: AppColors.primaryBlue,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(
                                                width:
                                                    AppDimensions.marginXSmall),
                                            const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: AppColors.primaryBlue,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // جزئیات (فقط در صورت باز بودن نمایش داده می‌شود)
                            if (isExpanded) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(
                                  AppDimensions.paddingMedium,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // محصولات
                                    const Text(
                                      'محصولات:',
                                      style: AppTextStyles.formLabel,
                                    ),
                                    const SizedBox(
                                        height: AppDimensions.marginXSmall),
                                    ...orderItems.map((item) {
                                      final product = item['products'];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppDimensions.paddingXSmall,
                                        ),
                                        child: Row(
                                          children: [
                                            // تصویر محصول
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  AppDimensions.radiusSmall,
                                                ),
                                                color:
                                                    AppColors.imagePlaceholder,
                                              ),
                                              child: product['image_url'] !=
                                                      null
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        AppDimensions
                                                            .radiusSmall,
                                                      ),
                                                      child: Image.network(
                                                        product['image_url'],
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            const Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          color: AppColors
                                                              .greyText,
                                                        ),
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.image_not_supported,
                                                      color: AppColors.greyText,
                                                    ),
                                            ),
                                            const SizedBox(
                                              width: AppDimensions.marginSmall,
                                            ),

                                            // اطلاعات محصول
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product['name'] ?? 'نامشخص',
                                                    style: AppTextStyles
                                                        .bodyMedium,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'تعداد: ${item['quantity']}',
                                                        style: AppTextStyles
                                                            .bodySmall,
                                                      ),
                                                      Text(
                                                        AppUtilities
                                                            .formatPrice(
                                                                item['price']),
                                                        style: AppTextStyles
                                                            .bodySmall
                                                            .copyWith(
                                                          color: AppColors
                                                              .productPrice,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    const SizedBox(
                                        height: AppDimensions.marginSmall),

                                    // آدرس ارسال
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(
                                        AppDimensions.paddingSmall,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.greyBackground,
                                        borderRadius: BorderRadius.circular(
                                          AppDimensions.radiusSmall,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'آدرس ارسال:',
                                            style: AppTextStyles.formLabel,
                                          ),
                                          const SizedBox(
                                            height: AppDimensions.marginXSmall,
                                          ),
                                          Text(
                                            order['shipping_address'] ??
                                                'نامشخص',
                                            style: AppTextStyles.bodySmall,
                                          ),
                                          const SizedBox(
                                            height: AppDimensions.marginXSmall,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'تلفن: ${order['contact_phone'] ?? 'نامشخص'}',
                                                style: AppTextStyles.bodySmall,
                                              ),
                                              Text(
                                                'کد پستی: ${order['postal_code'] ?? 'نامشخص'}',
                                                style: AppTextStyles.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                        height: AppDimensions.marginSmall),

                                    // دکمه بستن جزئیات (در انتهای جزئیات)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          expandedOrders.remove(index);
                                        });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppDimensions.paddingSmall,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.greyBackground,
                                          borderRadius: BorderRadius.circular(
                                            AppDimensions.radiusSmall,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'بستن جزئیات',
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                color: AppColors.primaryBlue,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(
                                                width:
                                                    AppDimensions.marginXSmall),
                                            const Icon(
                                              Icons.keyboard_arrow_up,
                                              color: AppColors.primaryBlue,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
