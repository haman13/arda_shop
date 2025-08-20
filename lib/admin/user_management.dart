import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;

  // Search and filter
  final TextEditingController _searchController = TextEditingController();
  String selectedDateFilter = 'all';

  // Statistics
  int totalUsers = 0;
  int newUsersToday = 0;
  int newUsersThisWeek = 0;

  final List<Map<String, String>> dateFilterOptions = [
    {'value': 'all', 'label': 'همه کاربران'},
    {'value': 'today', 'label': 'ثبت نام امروز'},
    {'value': 'week', 'label': 'ثبت نام این هفته'},
    {'value': 'month', 'label': 'ثبت نام این ماه'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Load users with blocking fields
      final usersResponse =
          await Supabase.instance.client.from('users').select('''
            id,
            name,
            phone,
            created_at,
            updated_at,
            address,
            postal_code,
            is_blocked,
            block_reason,
            blocked_at,
            blocked_by
          ''').order('created_at', ascending: false);

      // Calculate statistics
      final DateTime now = DateTime.now();
      final DateTime todayStart = DateTime(now.year, now.month, now.day);
      final DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));

      int todayCount = 0;
      int weekCount = 0;

      for (final user in usersResponse) {
        final createdAt = DateTime.parse(user['created_at']);
        if (createdAt.isAfter(todayStart)) todayCount++;
        if (createdAt.isAfter(weekStart)) weekCount++;
      }

      // Get order statistics for each user
      final List<Map<String, dynamic>> enrichedUsers = [];
      for (final user in usersResponse) {
        final orderStats = await _getUserOrderStats(user['phone']);
        enrichedUsers.add({
          ...user,
          'total_orders': orderStats['total_orders'],
          'total_spent': orderStats['total_spent'],
          'last_order_date': orderStats['last_order_date'],
          'is_active': _determineUserStatus(user, orderStats),
        });
      }

      setState(() {
        users = enrichedUsers;
        filteredUsers = List.from(users);
        totalUsers = users.length;
        newUsersToday = todayCount;
        newUsersThisWeek = weekCount;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در بارگذاری کاربران: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _getUserOrderStats(String userPhone) async {
    try {
      final ordersResponse = await Supabase.instance.client
          .from('orders')
          .select('total_amount, created_at')
          .eq('user_phone', userPhone);

      int totalOrders = ordersResponse.length;
      double totalSpent = 0;
      DateTime? lastOrderDate;

      if (ordersResponse.isNotEmpty) {
        for (final order in ordersResponse) {
          totalSpent += (order['total_amount'] ?? 0).toDouble();
        }

        // Find latest order
        ordersResponse.sort((a, b) => DateTime.parse(b['created_at'])
            .compareTo(DateTime.parse(a['created_at'])));
        lastOrderDate = DateTime.parse(ordersResponse.first['created_at']);
      }

      return {
        'total_orders': totalOrders,
        'total_spent': totalSpent,
        'last_order_date': lastOrderDate,
      };
    } catch (e) {
      return {
        'total_orders': 0,
        'total_spent': 0.0,
        'last_order_date': null,
      };
    }
  }

  bool _determineUserStatus(
      Map<String, dynamic> user, Map<String, dynamic> orderStats) {
    // If user is blocked, they are inactive
    if (user['is_blocked'] == true) {
      return false;
    }

    // A user is considered active if:
    // 1. They have placed orders, OR
    // 2. They registered within the last 30 days
    final DateTime now = DateTime.now();
    final DateTime createdAt = DateTime.parse(user['created_at']);
    final DateTime thirtyDaysAgo = now.subtract(const Duration(days: 30));

    bool hasOrders = orderStats['total_orders'] > 0;
    bool recentlyRegistered = createdAt.isAfter(thirtyDaysAgo);

    return hasOrders || recentlyRegistered;
  }

  void _filterUsers() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      filteredUsers = users.where((user) {
        bool matchesSearch = query.isEmpty ||
            user['name'].toString().toLowerCase().contains(query) ||
            user['phone'].toString().contains(query);

        bool matchesDateFilter = _matchesDateFilter(user);

        return matchesSearch && matchesDateFilter;
      }).toList();
    });
  }

  bool _matchesDateFilter(Map<String, dynamic> user) {
    if (selectedDateFilter == 'all') return true;

    final DateTime createdAt = DateTime.parse(user['created_at']);
    final DateTime now = DateTime.now();

    switch (selectedDateFilter) {
      case 'today':
        final DateTime todayStart = DateTime(now.year, now.month, now.day);
        return createdAt.isAfter(todayStart);
      case 'week':
        final DateTime weekStart =
            now.subtract(Duration(days: now.weekday - 1));
        return createdAt.isAfter(weekStart);
      case 'month':
        final DateTime monthStart = DateTime(now.year, now.month, 1);
        return createdAt.isAfter(monthStart);
      default:
        return true;
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => _UserDetailsModal(user: user),
    );
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

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildStatisticsRow() {
    return Container(
      padding: AppPadding.allMedium,
      margin: AppPadding.bottomMedium,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppBorderRadius.medium,
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'کل کاربران',
              totalUsers.toString(),
              Icons.people,
              AppColors.primaryBlue,
            ),
          ),
          AppSizedBox.width16,
          Expanded(
            child: _buildStatCard(
              'ثبت نام امروز',
              newUsersToday.toString(),
              Icons.person_add,
              AppColors.successGreen,
            ),
          ),
          AppSizedBox.width16,
          Expanded(
            child: _buildStatCard(
              'ثبت نام این هفته',
              newUsersThisWeek.toString(),
              Icons.group_add,
              AppColors.warningOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: AppPadding.allSmall,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppBorderRadius.small,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          AppSizedBox.height8,
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(color: color),
          ),
          AppSizedBox.height4,
          Text(
            title,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final bool isActive = user['is_active'] ?? false;
    final bool isBlocked = user['is_blocked'] ?? false;

    return Card(
      margin: AppPadding.allSmall,
      child: InkWell(
        onTap: () => _showUserDetails(user),
        borderRadius: AppBorderRadius.medium,
        child: Padding(
          padding: AppPadding.allMedium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user['name'] ?? 'نام نامشخص',
                      style: AppTextStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isBlocked
                          ? AppColors.errorRed
                          : isActive
                              ? AppColors.successGreen
                              : AppColors.greyLight,
                      borderRadius: AppBorderRadius.small,
                    ),
                    child: Text(
                      isBlocked
                          ? 'مسدود'
                          : isActive
                              ? 'فعال'
                              : 'غیرفعال',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: (isBlocked || isActive)
                            ? AppColors.primaryWhite
                            : AppColors.greyText,
                      ),
                    ),
                  ),
                ],
              ),
              AppSizedBox.height8,

              // Phone number
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: AppColors.greyText),
                  AppSizedBox.width8,
                  Text(
                    user['phone'] ?? '',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              AppSizedBox.height4,

              // Registration date
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16, color: AppColors.greyText),
                  AppSizedBox.width8,
                  Text(
                    'عضویت: ${_formatDate(user['created_at'])}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              AppSizedBox.height8,

              // Order statistics
              Container(
                padding: AppPadding.allSmall,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: AppBorderRadius.small,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${user['total_orders'] ?? 0}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        Text(
                          'سفارش',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          AppUtilities.formatPrice(user['total_spent'] ?? 0),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.successGreen,
                          ),
                        ),
                        Text(
                          'کل خرید',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = _getGridCrossAxisCount(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: Text(
          'مدیریت کاربران',
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
                strokeWidth: AppDimensions.loadingStrokeWidth,
              ),
            )
          : Padding(
              padding: AppPadding.allMedium,
              child: Column(
                children: [
                  // Statistics row
                  _buildStatisticsRow(),

                  // Search and filter
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _searchController,
                          decoration: AppInputDecorations.searchField(
                              'جستجو بر اساس نام یا شماره موبایل'),
                        ),
                      ),
                      AppSizedBox.width12,
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedDateFilter,
                          decoration: AppInputDecorations.dropdownField(),
                          items: dateFilterOptions.map((option) {
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
                              selectedDateFilter = value!;
                            });
                            _filterUsers();
                          },
                        ),
                      ),
                    ],
                  ),
                  AppSizedBox.height16,

                  // Results count
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${filteredUsers.length} کاربر یافت شد',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  AppSizedBox.height12,

                  // Users grid
                  Expanded(
                    child: filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: AppColors.greyLight,
                                ),
                                AppSizedBox.height16,
                                Text(
                                  'کاربری یافت نشد',
                                  style: AppTextStyles.bodyLarge,
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: crossAxisCount == 1
                                  ? 2.5 // موبایل: نسبت عرض به ارتفاع 2.5:1
                                  : crossAxisCount == 2
                                      ? 1.8 // تبلت: نسبت عرض به ارتفاع 1.8:1
                                      : 1.5, // دسکتاپ: نسبت عرض به ارتفاع 1.5:1
                              crossAxisSpacing: AppDimensions.paddingSmall,
                              mainAxisSpacing: AppDimensions.paddingSmall,
                            ),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              return _buildUserCard(filteredUsers[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _UserDetailsModal extends StatefulWidget {
  final Map<String, dynamic> user;

  const _UserDetailsModal({required this.user});

  @override
  State<_UserDetailsModal> createState() => _UserDetailsModalState();
}

class _UserDetailsModalState extends State<_UserDetailsModal> {
  List<Map<String, dynamic>> userOrders = [];
  bool isLoadingOrders = true;
  bool isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _loadUserOrders();
  }

  Future<void> _loadUserOrders() async {
    try {
      final ordersResponse = await Supabase.instance.client
          .from('orders')
          .select('''
            id,
            total_amount,
            status,
            created_at,
            shipping_address
          ''')
          .eq('user_phone', widget.user['phone'])
          .order('created_at', ascending: false)
          .limit(10); // Show last 10 orders

      setState(() {
        userOrders = List<Map<String, dynamic>>.from(ordersResponse);
        isLoadingOrders = false;
      });
    } catch (e) {
      setState(() {
        isLoadingOrders = false;
      });
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'در انتظار پرداخت';
      case 'paid':
        return 'پرداخت شده';
      case 'cash_on_delivery':
        return 'پرداخت در محل';
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
        return AppColors.primaryBlue;
      case 'cash_on_delivery':
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

  Future<void> _toggleUserBlock(Map<String, dynamic> user) async {
    final bool isBlocked = user['is_blocked'] ?? false;

    if (isBlocked) {
      // Unblock user
      _showUnblockConfirmDialog(user);
    } else {
      // Block user
      _showBlockDialog(user);
    }
  }

  void _showBlockDialog(Map<String, dynamic> user) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('مسدود سازی کاربر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('آیا می‌خواهید کاربر "${user['name']}" را مسدود کنید؟'),
            AppSizedBox.height16,
            TextField(
              controller: reasonController,
              decoration: AppInputDecorations.formField('دلیل مسدود سازی'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('لطفاً دلیل مسدود سازی را وارد کنید'),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              await _updateUserBlockStatus(
                  user, true, reasonController.text.trim());
            },
            style: AppButtonStyles.dangerButton,
            child: Text('مسدود کردن'),
          ),
        ],
      ),
    );
  }

  void _showUnblockConfirmDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('فعال سازی کاربر'),
        content: Text('آیا می‌خواهید کاربر "${user['name']}" را فعال کنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateUserBlockStatus(user, false, null);
            },
            style: AppButtonStyles.successButton,
            child: Text('فعال کردن'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserBlockStatus(
      Map<String, dynamic> user, bool isBlocked, String? reason) async {
    try {
      setState(() {
        isUpdatingStatus = true;
      });

      final updateData = {
        'is_blocked': isBlocked,
        'block_reason': reason,
        'blocked_at': isBlocked ? DateTime.now().toIso8601String() : null,
        'blocked_by': isBlocked ? 'ادمین' : null,
      };

      await Supabase.instance.client
          .from('users')
          .update(updateData)
          .eq('id', user['id']);

      // Update local user data
      setState(() {
        widget.user['is_blocked'] = isBlocked;
        widget.user['block_reason'] = reason;
        widget.user['blocked_at'] = updateData['blocked_at'];
        widget.user['blocked_by'] = updateData['blocked_by'];
        isUpdatingStatus = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isBlocked
                ? 'کاربر با موفقیت مسدود شد'
                : 'کاربر با موفقیت فعال شد'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isUpdatingStatus = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در تغییر وضعیت کاربر: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      child: Container(
        width: screenSize.width * 0.9,
        height: screenSize.height * 0.8,
        padding: AppPadding.allLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'جزئیات کاربر',
                    style: AppTextStyles.heading2,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Divider(color: AppColors.borderColor),
            AppSizedBox.height16,

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User information section
                    _buildInfoSection(
                      'اطلاعات کاربر',
                      [
                        _buildInfoRow('نام', widget.user['name'] ?? 'نامشخص'),
                        _buildInfoRow(
                            'شماره موبایل', widget.user['phone'] ?? ''),
                        _buildInfoRow('تاریخ عضویت',
                            _formatDate(widget.user['created_at'])),
                        _buildInfoRow('آخرین بروزرسانی',
                            _formatDate(widget.user['updated_at'])),
                        _buildInfoRow(
                            'آدرس', widget.user['address'] ?? 'وارد نشده'),
                        _buildInfoRow('کد پستی',
                            widget.user['postal_code'] ?? 'وارد نشده'),
                      ],
                    ),

                    AppSizedBox.height24,

                    // Order statistics section
                    _buildInfoSection(
                      'آمار خرید',
                      [
                        _buildInfoRow('تعداد کل سفارشات',
                            '${widget.user['total_orders'] ?? 0}'),
                        _buildInfoRow(
                            'مجموع خریدها',
                            AppUtilities.formatPrice(
                                widget.user['total_spent'] ?? 0)),
                        _buildInfoRow(
                            'وضعیت',
                            (widget.user['is_blocked'] ?? false)
                                ? 'مسدود'
                                : (widget.user['is_active'] ?? false)
                                    ? 'فعال'
                                    : 'غیرفعال'),
                      ],
                    ),

                    // Block information section (if user is blocked)
                    if (widget.user['is_blocked'] == true) ...[
                      AppSizedBox.height24,
                      _buildInfoSection(
                        'اطلاعات مسدود سازی',
                        [
                          _buildInfoRow('دلیل مسدود سازی',
                              widget.user['block_reason'] ?? 'نامشخص'),
                          _buildInfoRow(
                              'تاریخ مسدود سازی',
                              widget.user['blocked_at'] != null
                                  ? _formatDate(widget.user['blocked_at'])
                                  : 'نامشخص'),
                          _buildInfoRow('مسدود شده توسط',
                              widget.user['blocked_by'] ?? 'نامشخص'),
                        ],
                      ),
                    ],

                    AppSizedBox.height24,

                    // Block/Unblock button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isUpdatingStatus
                            ? null
                            : () => _toggleUserBlock(widget.user),
                        style: (widget.user['is_blocked'] ?? false)
                            ? AppButtonStyles.successButton
                            : AppButtonStyles.dangerButton,
                        icon: Icon(
                          (widget.user['is_blocked'] ?? false)
                              ? Icons.check_circle
                              : Icons.block,
                        ),
                        label: Text(
                          isUpdatingStatus
                              ? 'در حال بروزرسانی...'
                              : (widget.user['is_blocked'] ?? false)
                                  ? 'فعال کردن کاربر'
                                  : 'مسدود کردن کاربر',
                        ),
                      ),
                    ),

                    AppSizedBox.height24,

                    // Recent orders section
                    Text(
                      'آخرین سفارشات',
                      style: AppTextStyles.heading3,
                    ),
                    AppSizedBox.height12,

                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor),
                        borderRadius: AppBorderRadius.medium,
                      ),
                      child: isLoadingOrders
                          ? Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryBlue,
                              ),
                            )
                          : userOrders.isEmpty
                              ? const Center(
                                  child: Text('هیچ سفارشی یافت نشد'),
                                )
                              : ListView.separated(
                                  padding: AppPadding.allSmall,
                                  itemCount: userOrders.length,
                                  separatorBuilder: (context, index) => Divider(
                                    color: AppColors.borderColor,
                                  ),
                                  itemBuilder: (context, index) {
                                    final order = userOrders[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            _getStatusColor(order['status']),
                                        child: Text(
                                          '${index + 1}',
                                          style:
                                              AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.primaryWhite,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        'سفارش #${order['id']} - ${AppUtilities.formatPrice(order['total_amount'])}',
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                      subtitle: Text(
                                        '${_formatDate(order['created_at'])} - ${_getStatusText(order['status'])}',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              _getStatusColor(order['status']),
                                          borderRadius: AppBorderRadius.small,
                                        ),
                                        child: Text(
                                          _getStatusText(order['status']),
                                          style:
                                              AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.primaryWhite,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: AppPadding.allMedium,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: AppBorderRadius.medium,
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading3,
          ),
          AppSizedBox.height12,
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: AppPadding.bottomSmall,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
