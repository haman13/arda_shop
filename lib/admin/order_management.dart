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
            user_id,
            total_amount,
            status,
            payment_status,
            created_at,
            updated_at,
            user:users!inner(name, phone)
          ''');

      // اعمال فیلتر وضعیت سفارش
      if (selectedStatusFilter != 'all') {
        query = query.eq('status', selectedStatusFilter);
      }

      // اعمال فیلتر وضعیت پرداخت
      if (selectedPaymentFilter != 'all') {
        query = query.eq('payment_status', selectedPaymentFilter);
      }

      final response = await query.order('created_at', ascending: false);

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

  List<Map<String, dynamic>> get filteredOrders {
    return orders.where((order) {
      bool statusMatch = selectedStatusFilter == 'all' ||
          order['status'] == selectedStatusFilter;
      bool paymentMatch = selectedPaymentFilter == 'all' ||
          order['payment_status'] == selectedPaymentFilter;
      return statusMatch && paymentMatch;
    }).toList();
  }

  int _getRowCount() {
    return (filteredOrders.length / 2).ceil();
  }

  Widget _buildOrderRow(int rowIndex) {
    final startIndex = rowIndex * 2;
    final endIndex = (startIndex + 2).clamp(0, filteredOrders.length);
    final rowOrders = filteredOrders.sublist(startIndex, endIndex);

    return Row(
      children: [
        Expanded(
          child: _buildOrderCard(rowOrders[0]),
        ),
        if (rowOrders.length > 1) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _buildOrderCard(rowOrders[1]),
          ),
        ] else
          const Expanded(child: SizedBox()),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final user = order['user'] as Map<String, dynamic>?;
    final userName = user?['name'] ?? 'نامشخص';
    final userPhone = user?['phone'] ?? 'نامشخص';
    final totalAmount = order['total_amount'] ?? 0;
    final status = order['status'] ?? 'pending';
    final paymentStatus = order['payment_status'] ?? 'unpaid';
    final createdAt = order['created_at'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سفارش #${order['id']}',
                  style: AppTextStyles.heading3,
                ),
                _buildStatusChip(status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'مشتری: $userName',
              style: AppTextStyles.bodyMedium,
            ),
            Text(
              'تلفن: $userPhone',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'مبلغ: ${AppUtilities.formatPrice(totalAmount.toString())}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'وضعیت پرداخت: ${_getPaymentStatusText(paymentStatus)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: _getPaymentStatusColor(paymentStatus),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'تاریخ: ${_formatDate(createdAt)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showOrderDetails(order),
                    style: AppButtonStyles.primaryButton.copyWith(
                      backgroundColor:
                          MaterialStateProperty.all(AppColors.primaryBlue),
                    ),
                    child: Text(
                      'جزئیات',
                      style: AppTextStyles.buttonText.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(order),
                    style: AppButtonStyles.primaryButton.copyWith(
                      backgroundColor:
                          MaterialStateProperty.all(AppColors.successGreen),
                    ),
                    child: Text(
                      'بروزرسانی',
                      style: AppTextStyles.buttonText.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange;
        textColor = AppColors.primaryWhite;
        statusText = 'در انتظار';
        break;
      case 'preparing':
        backgroundColor = AppColors.primaryBlue;
        textColor = AppColors.primaryWhite;
        statusText = 'آماده‌سازی';
        break;
      case 'shipped':
        backgroundColor = Colors.blue;
        textColor = AppColors.primaryWhite;
        statusText = 'ارسال شده';
        break;
      case 'delivered':
        backgroundColor = AppColors.successGreen;
        textColor = AppColors.primaryWhite;
        statusText = 'تحویل شده';
        break;
      case 'cancelled':
        backgroundColor = AppColors.errorRed;
        textColor = AppColors.primaryWhite;
        statusText = 'لغو شده';
        break;
      default:
        backgroundColor = AppColors.greyLight;
        textColor = AppColors.greyText;
        statusText = 'نامشخص';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getPaymentStatusText(String paymentStatus) {
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
        return 'نامشخص';
    }
  }

  Color _getPaymentStatusColor(String paymentStatus) {
    switch (paymentStatus) {
      case 'unpaid':
        return AppColors.errorRed;
      case 'paid_online':
      case 'payment_verified':
      case 'paid_card_to_card':
        return AppColors.successGreen;
      case 'cash_on_delivery':
        return Colors.orange;
      case 'refunded':
        return Colors.blue;
      default:
        return AppColors.greyText;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'نامشخص';
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('جزئیات سفارش #${order['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('مشتری: ${order['user']?['name'] ?? 'نامشخص'}'),
              Text('تلفن: ${order['user']?['phone'] ?? 'نامشخص'}'),
              const SizedBox(height: 8),
              Text(
                  'مبلغ کل: ${AppUtilities.formatPrice(order['total_amount']?.toString() ?? '0')}'),
              Text(
                  'وضعیت: ${_getPaymentStatusText(order['payment_status'] ?? 'unpaid')}'),
              Text('تاریخ: ${_formatDate(order['created_at'] ?? '')}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('بروزرسانی وضعیت سفارش #${order['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: orderStatusOptions.map((option) {
            return ListTile(
              title: Text(option['label']!),
              leading: Radio<String>(
                value: option['value']!,
                groupValue: order['status'],
                onChanged: (value) {
                  if (value != null) {
                    _updateOrderStatusInDatabase(order['id'], value);
                    Navigator.pop(context);
                  }
                },
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatusInDatabase(
      int orderId, String newStatus) async {
    try {
      await Supabase.instance.client
          .from('orders')
          .update({'status': newStatus}).eq('id', orderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('وضعیت سفارش با موفقیت بروزرسانی شد'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        _loadOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در بروزرسانی وضعیت: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
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
          body: orientation == Orientation.landscape
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header و فیلتر بهتر
                      Container(
                        padding:
                            const EdgeInsets.all(AppDimensions.paddingMedium),
                        decoration: BoxDecoration(
                          color:
                              AppColors.greyBackground.withValues(alpha: 0.3),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                if (isLoading)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // فیلترها
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedStatusFilter,
                                    decoration:
                                        AppInputDecorations.dropdownField(),
                                    items: orderStatusOptions.map((option) {
                                      return DropdownMenuItem(
                                        value: option['value'],
                                        child: Text(
                                          option['label']!,
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedStatusFilter = value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedPaymentFilter,
                                    decoration:
                                        AppInputDecorations.dropdownField(),
                                    items: paymentStatusOptions.map((option) {
                                      return DropdownMenuItem(
                                        value: option['value'],
                                        child: Text(
                                          option['label']!,
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedPaymentFilter = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // لیست سفارشات
                      Padding(
                        padding:
                            const EdgeInsets.all(AppDimensions.paddingMedium),
                        child: orders.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 64,
                                      color: AppColors.greyLight,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'سفارشی یافت نشد',
                                      style: AppTextStyles.bodyLarge,
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadOrders,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _getRowCount(),
                                  itemBuilder: (context, rowIndex) {
                                    return _buildOrderRow(rowIndex);
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header و فیلتر بهتر
                    Container(
                      padding:
                          const EdgeInsets.all(AppDimensions.paddingMedium),
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
                              if (isLoading)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // فیلترها
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedStatusFilter,
                                  decoration:
                                      AppInputDecorations.dropdownField(),
                                  items: orderStatusOptions.map((option) {
                                    return DropdownMenuItem(
                                      value: option['value'],
                                      child: Text(
                                        option['label']!,
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedStatusFilter = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedPaymentFilter,
                                  decoration:
                                      AppInputDecorations.dropdownField(),
                                  items: paymentStatusOptions.map((option) {
                                    return DropdownMenuItem(
                                      value: option['value'],
                                      child: Text(
                                        option['label']!,
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedPaymentFilter = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // لیست سفارشات
                    Expanded(
                      child: orders.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 64,
                                    color: AppColors.greyLight,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'سفارشی یافت نشد',
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
      },
    );
  }
}
