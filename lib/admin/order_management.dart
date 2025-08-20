import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  String selectedStatusFilter = 'all';
  String selectedPaymentFilter = 'all';

  final List<Map<String, String>> orderStatusOptions = [
    {'value': 'all', 'label': 'همه سفارشات'},
    {'value': 'pending', 'label': 'در انتظار تأیید'},
    {'value': 'preparing', 'label': 'در حال آماده‌سازی'},
    {'value': 'shipped', 'label': 'ارسال شده'},
    {'value': 'delivered', 'label': 'تحویل داده شده'},
    {'value': 'cancelled', 'label': 'لغو شده'},
  ];

  final List<Map<String, String>> paymentStatusOptions = [
    {'value': 'all', 'label': 'همه پرداخت‌ها'},
    {'value': 'unpaid', 'label': 'پرداخت نشده'},
    {'value': 'paid_online', 'label': 'پرداخت آنلاین'},
    {'value': 'payment_verified', 'label': 'پرداخت تایید شد'},
    {'value': 'paid_card_to_card', 'label': 'کارت به کارت'},
    {'value': 'cash_on_delivery', 'label': 'پرداخت در محل'},
    {'value': 'refunded', 'label': 'بازگشت وجه'},
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        isLoading = true;
      });

      var query = Supabase.instance.client.from('orders').select('''
            id,
            user_phone,
            total_amount,
            shipping_address,
            contact_phone,
            postal_code,
            status,
            payment_status,
            created_at,
            order_items (
              quantity,
              price,
              products (
                name,
                image_url
              )
            )
          ''');

      if (selectedStatusFilter != 'all') {
        query = query.eq('status', selectedStatusFilter);
      }

      if (selectedPaymentFilter != 'all') {
        query = query.eq('payment_status', selectedPaymentFilter);
      }

      final response = await query.order('created_at', ascending: false);

      setState(() {
        orders = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });

      // دیباگ: چاپ تمام status های موجود
      Set<String> existingStatuses = {};
      for (final order in orders) {
        if (order['status'] != null) {
          existingStatuses.add(order['status'].toString());
        }
      }
      debugPrint('🔍 Status های موجود در دیتابیس: $existingStatuses');

      // این فانکشن‌ها در صفحه مدیریت سفارشات لازم نیستند
      // _extractCategories();
      // _updatePriceRange();
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

  Future<void> _updateOrderStatuses(
      int orderId, String newOrderStatus, String newPaymentStatus) async {
    try {
      debugPrint(
          '🔄 تلاش برای تغییر وضعیت سفارش #$orderId به: $newOrderStatus و پرداخت به: $newPaymentStatus');

      await Supabase.instance.client.from('orders').update({
        'status': newOrderStatus,
        'payment_status': newPaymentStatus,
      }).eq('id', orderId);

      setState(() {
        final orderIndex = orders.indexWhere((order) => order['id'] == orderId);
        if (orderIndex != -1) {
          orders[orderIndex]['status'] = newOrderStatus;
          orders[orderIndex]['payment_status'] = newPaymentStatus;
        }
      });

      debugPrint('✅ تغییر وضعیت موفق بود');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('وضعیت سفارش و پرداخت با موفقیت تغییر کرد'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ خطا در تغییر وضعیت: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در تغییر وضعیت: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String _getOrderStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'در انتظار تأیید';
      case 'preparing':
        return 'در حال آماده‌سازی';
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

  String _getPaymentStatusText(String? paymentStatus) {
    if (paymentStatus == null) return 'نامشخص';
    switch (paymentStatus) {
      case 'unpaid':
        return 'پرداخت نشده';
      case 'paid_online':
        return 'پرداخت آنلاین';
      case 'payment_verified':
        return 'پرداخت تایید شد';
      case 'paid_card_to_card':
        return 'کارت به کارت';
      case 'cash_on_delivery':
        return 'پرداخت در محل';
      case 'refunded':
        return 'بازگشت وجه';
      default:
        return paymentStatus;
    }
  }

  Color _getOrderStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warningOrange;
      case 'preparing':
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

  Color _getPaymentStatusColor(String? paymentStatus) {
    if (paymentStatus == null) return AppColors.greyText;
    switch (paymentStatus) {
      case 'unpaid':
        return AppColors.errorRed;
      case 'paid_online':
        return AppColors.successGreen;
      case 'payment_verified':
        return AppColors.successGreen;
      case 'paid_card_to_card':
        return AppColors.warningOrange;
      case 'cash_on_delivery':
        return AppColors.primaryBlue;
      case 'refunded':
        return AppColors.greyText;
      default:
        return AppColors.greyText;
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // تعیین تعداد ستون‌ها بر اساس عرض صفحه
  int _getGridCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return 3; // دسکتاپ: 3 ستون
    } else if (screenWidth > 800) {
      return 2; // تبلت: 2 ستون
    } else {
      return 1; // موبایل: 1 ستون
    }
  }

  // محاسبه تعداد ردیف‌های مورد نیاز
  int _getRowCount() {
    final crossAxisCount = _getGridCrossAxisCount(context);
    return (orders.length / crossAxisCount).ceil();
  }

  // ساخت یک ردیف از کارت‌ها
  Widget _buildOrderRow(int rowIndex) {
    final crossAxisCount = _getGridCrossAxisCount(context);
    final startIndex = rowIndex * crossAxisCount;
    final endIndex = (startIndex + crossAxisCount).clamp(0, orders.length);

    final rowOrders = orders.sublist(startIndex, endIndex);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < crossAxisCount; i++)
            Expanded(
              child: i < rowOrders.length
                  ? Padding(
                      padding: EdgeInsets.only(
                        right: i > 0 ? AppDimensions.marginMedium / 2 : 0,
                        left: i < crossAxisCount - 1
                            ? AppDimensions.marginMedium / 2
                            : 0,
                      ),
                      child: _buildOrderCard(rowOrders[i]),
                    )
                  : const SizedBox(), // فضای خالی برای ردیف آخر
            ),
        ],
      ),
    );
  }

  // ساخت کارت سفارش
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderItems = order['order_items'] as List<dynamic>;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سفارش #${order['id']}',
                  style: AppTextStyles.heading3,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSmall,
                    vertical: AppDimensions.paddingXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: _getOrderStatusColor(order['status'])
                        .withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSmall),
                    border: Border.all(
                      color: _getOrderStatusColor(order['status']),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getOrderStatusText(order['status']),
                    style: TextStyle(
                      color: _getOrderStatusColor(order['status']),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSmall,
                    vertical: AppDimensions.paddingXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(order['payment_status'])
                        .withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSmall),
                    border: Border.all(
                      color: _getPaymentStatusColor(order['payment_status']),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getPaymentStatusText(order['payment_status']),
                    style: TextStyle(
                      color: _getPaymentStatusColor(order['payment_status']),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'مشتری: ${order['user_phone']}',
                  style: AppTextStyles.bodySmall,
                ),
                Text(
                  AppUtilities.formatPrice(order['total_amount']),
                  style: AppTextStyles.productPrice.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginXSmall),
            Text(
              'تاریخ: ${_formatDate(order['created_at'])}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              'محصولات (${orderItems.length})',
              style: AppTextStyles.formLabel,
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showOrderDetails(order),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('جزئیات'),
                  ),
                ),
                const SizedBox(width: AppDimensions.marginSmall),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showStatusDialog(
                        order['id'], order['status'], order['payment_status']),
                    icon: const Icon(Icons.edit),
                    label: const Text('تغییر وضعیت'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    final orderItems = order['order_items'] as List<dynamic>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('جزئیات سفارش #${order['id']}'),
        content: SizedBox(
          width: MediaQuery.of(context).size.height * 0.6,
          height: MediaQuery.of(context).size.height * 0.7,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اطلاعات سفارش
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('شماره تماس مشتری'),
                          subtitle: Text(order['user_phone'] ?? 'نامشخص'),
                          dense: true,
                        ),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text('شماره تماس تحویل'),
                          subtitle: Text(order['contact_phone'] ?? 'نامشخص'),
                          dense: true,
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('آدرس ارسال'),
                          subtitle: Text(order['shipping_address'] ?? 'نامشخص'),
                          dense: true,
                        ),
                        ListTile(
                          leading: const Icon(Icons.mail),
                          title: const Text('کد پستی'),
                          subtitle: Text(order['postal_code'] ?? 'نامشخص'),
                          dense: true,
                        ),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('تاریخ ثبت'),
                          subtitle: Text(_formatDate(order['created_at'])),
                          dense: true,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // محصولات سفارش
                Text(
                  'محصولات سفارش (${orderItems.length})',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 8),

                ...orderItems.map((item) {
                  final product = item['products'];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // تصویر محصول
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product['image_url'] != null
                                ? Image.network(
                                    product['image_url'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: AppColors.greyBackground,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: AppColors.greyText,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.greyBackground,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: AppColors.greyText,
                                    ),
                                  ),
                          ),

                          const SizedBox(width: 12),

                          // جزئیات محصول
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'] ?? 'نام محصول نامشخص',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'تعداد: ${item['quantity']}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.greyText,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'قیمت واحد: ${AppUtilities.formatPrice(item['price'])}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.greyText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'جمع: ${AppUtilities.formatPrice(item['price'] * item['quantity'])}',
                                  style: AppTextStyles.productPrice.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // مجموع کل
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF52A5E9)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مجموع کل سفارش:',
                        style: AppTextStyles.heading3,
                      ),
                      Text(
                        AppUtilities.formatPrice(order['total_amount']),
                        style: AppTextStyles.productPrice.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showStatusDialog(
                  order['id'], order['status'], order['payment_status']);
            },
            icon: const Icon(Icons.edit),
            label: const Text('تغییر وضعیت'),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(
      int orderId, String currentOrderStatus, String currentPaymentStatus) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedOrderStatus = currentOrderStatus;
        String selectedPaymentStatus = currentPaymentStatus;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('تغییر وضعیت سفارش #$orderId'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وضعیت سفارش:',
                      style: AppTextStyles.heading3,
                    ),
                    AppSizedBox.height8,
                    ...orderStatusOptions
                        .where((status) => status['value'] != 'all')
                        .map(
                          (status) => RadioListTile<String>(
                            title: Text(status['label']!),
                            value: status['value']!,
                            groupValue: selectedOrderStatus,
                            onChanged: (value) {
                              setState(() {
                                selectedOrderStatus = value!;
                              });
                            },
                          ),
                        )
                        .toList(),
                    AppSizedBox.height16,
                    Text(
                      'وضعیت پرداخت:',
                      style: AppTextStyles.heading3,
                    ),
                    AppSizedBox.height8,
                    ...paymentStatusOptions
                        .where((status) => status['value'] != 'all')
                        .map(
                          (status) => RadioListTile<String>(
                            title: Text(status['label']!),
                            value: status['value']!,
                            groupValue: selectedPaymentStatus,
                            onChanged: (value) {
                              setState(() {
                                selectedPaymentStatus = value!;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('لغو'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateOrderStatuses(
                      orderId,
                      selectedOrderStatus,
                      selectedPaymentStatus,
                    );
                  },
                  child: const Text('ذخیره'),
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
        title: const Text(
          'مدیریت سفارشات',
          style: AppTextStyles.heading2,
        ),
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.appBarIcon),
        actions: [
          IconButton(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh),
            tooltip: 'بروزرسانی',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header و فیلتر بهتر
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.greyBackground.withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.greyText.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مدیریت سفارشات',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'مجموع ${orders.length} سفارش',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.greyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: selectedStatusFilter,
                        decoration: const InputDecoration(
                          labelText: 'فیلتر بر اساس وضعیت سفارش',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: orderStatusOptions
                            .map((status) => DropdownMenuItem(
                                  value: status['value'],
                                  child: Text(status['label']!),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedStatusFilter = value;
                            });
                            _loadOrders();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                AppSizedBox.height16, // فاصله بین فیلترها
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox.shrink(), // فضای خالی برای تراز
                    ),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: selectedPaymentFilter,
                        decoration: const InputDecoration(
                          labelText: 'فیلتر بر اساس وضعیت پرداخت',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: paymentStatusOptions
                            .map((status) => DropdownMenuItem(
                                  value: status['value'],
                                  child: Text(status['label']!),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedPaymentFilter = value;
                            });
                            _loadOrders();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: AppColors.greyText,
                            ),
                            SizedBox(height: AppDimensions.marginMedium),
                            Text(
                              'هیچ سفارشی یافت نشد',
                              style: AppTextStyles.bodyLarge,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingMedium,
                          ),
                          itemCount: _getRowCount(),
                          itemBuilder: (context, rowIndex) {
                            return _buildOrderRow(rowIndex);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
