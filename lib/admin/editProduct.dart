import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../theme.dart';

class EditProductPage extends StatefulWidget {
  const EditProductPage({super.key});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  List<Map<String, dynamic>> _products = [];
  List<String> _existingCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final response = await supabase.from('products').select();
    setState(() {
      _products = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
    });
    _loadExistingCategories();
  }

  Future<void> _loadExistingCategories() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('products')
          .select('category')
          .not('category', 'is', null);

      final Set<String> categorySet = {};
      for (final item in response) {
        if (item['category'] != null &&
            item['category'].toString().trim().isNotEmpty) {
          categorySet.add(item['category'].toString().trim());
        }
      }

      setState(() {
        _existingCategories = categorySet.toList()..sort();
      });
    } catch (e) {
      debugPrint('خطا در بارگذاری دسته‌بندی‌ها: $e');
    }
  }

  void _editProduct(Map<String, dynamic> product) {
    final _editFormKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: product['name'] ?? '');
    final priceController =
        TextEditingController(text: product['price']?.toString() ?? '');
    final discountController =
        TextEditingController(text: product['discount']?.toString() ?? '');
    final descController =
        TextEditingController(text: product['description'] ?? '');
    final stockController =
        TextEditingController(text: product['stock']?.toString() ?? '0');
    final categoryController =
        TextEditingController(text: product['category'] ?? '');

    // متغیر برای دسته‌بندی انتخاب شده
    String? selectedCategory = product['category'];

    double finalPrice = product['final_price']?.toDouble() ?? 0;
    String imageUrl = product['image_url'] ?? '';
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void calculateFinalPrice() {
              final price = double.tryParse(priceController.text) ?? 0;
              final discount = double.tryParse(discountController.text) ?? 0;
              final discounted = price * (1 - (discount / 100));
              setState(() {
                finalPrice = discounted.ceilToDouble();
              });
            }

            Future<void> showAddCategoryDialog() async {
              final newCategoryController = TextEditingController();

              final result = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('اضافه کردن دسته‌بندی جدید'),
                    content: TextField(
                      controller: newCategoryController,
                      decoration: const InputDecoration(
                        labelText: 'نام دسته‌بندی',
                        border: OutlineInputBorder(),
                        hintText: 'مثال: لوازم الکترونیکی',
                      ),
                      autofocus: true,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('انصراف'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final categoryName =
                              newCategoryController.text.trim();
                          if (categoryName.isNotEmpty) {
                            Navigator.of(context).pop(categoryName);
                          }
                        },
                        child: const Text('اضافه کردن'),
                      ),
                    ],
                  );
                },
              );

              if (result != null && result.isNotEmpty) {
                setState(() {
                  if (!_existingCategories.contains(result)) {
                    _existingCategories.add(result);
                    _existingCategories.sort();
                  }
                  selectedCategory = result;
                  categoryController.text = result;
                });
              }
            }

            return AlertDialog(
              title: const Text('ویرایش محصول'),
              content: Form(
                key: _editFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(labelText: 'نام محصول'),
                        enabled: !isSubmitting,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'نام محصول را وارد کنید';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: priceController,
                        decoration:
                            const InputDecoration(labelText: 'قیمت (تومان)'),
                        keyboardType: TextInputType.number,
                        enabled: !isSubmitting,
                        onChanged: (_) {
                          calculateFinalPrice();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'قیمت را وارد کنید';
                          }
                          if (double.tryParse(value) == null) {
                            return 'قیمت باید عدد باشد';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: discountController,
                        decoration:
                            const InputDecoration(labelText: 'تخفیف (%)'),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        enabled: !isSubmitting,
                        onChanged: (_) {
                          calculateFinalPrice();
                        },
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              double.tryParse(value) == null) {
                            return 'تخفیف باید عدد باشد';
                          }
                          if (value != null && value.isNotEmpty) {
                            double discount = double.parse(value);
                            if (discount < 0 || discount > 100) {
                              return 'تخفیف باید بین ۰ تا ۱۰۰ باشد';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('مبلغ بعد از تخفیف: '),
                          Text(AppUtilities.formatPrice(
                              finalPrice.toStringAsFixed(0))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descController,
                        decoration: const InputDecoration(labelText: 'توضیحات'),
                        enabled: !isSubmitting,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: stockController,
                        decoration: const InputDecoration(labelText: 'موجودی'),
                        keyboardType: TextInputType.number,
                        enabled: !isSubmitting,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'موجودی را وارد کنید';
                          }
                          if (int.tryParse(value) == null) {
                            return 'موجودی باید عدد باشد';
                          }
                          if (int.parse(value) < 0) {
                            return 'موجودی نمی‌تواند منفی باشد';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // فیلد دسته‌بندی
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'دسته‌بندی:',
                            style: AppTextStyles.formLabel,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedCategory,
                            decoration: AppInputDecorations.categoryDropdown,
                            items: [
                              ..._existingCategories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }),
                              DropdownMenuItem(
                                value: 'ADD_NEW_CATEGORY',
                                child: Row(
                                  children: [
                                    Icon(Icons.add,
                                        color: AppColors.adminAddCategory),
                                    const SizedBox(width: 8),
                                    Text(
                                      'اضافه کردن دسته‌بندی جدید',
                                      style: AppTextStyles.linkText.copyWith(
                                        color: AppColors.adminAddCategory,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: isSubmitting
                                ? null
                                : (value) {
                                    if (value == 'ADD_NEW_CATEGORY') {
                                      showAddCategoryDialog();
                                    } else if (value != null) {
                                      setState(() {
                                        selectedCategory = value;
                                        categoryController.text = value;
                                      });
                                    }
                                  },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'دسته‌بندی را انتخاب کنید';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'دسته‌بندی انتخاب شده: ${categoryController.text.isEmpty ? "انتخاب نشده" : categoryController.text}',
                            style: AppTextStyles.greyText,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      imageUrl.isNotEmpty
                          ? Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Image.network(imageUrl, height: 100),
                                IconButton(
                                  icon: Icon(Icons.camera_alt,
                                      color: AppColors.primaryBlue),
                                  onPressed: isSubmitting
                                      ? null
                                      : () async {
                                          await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                _EditImageDialog(
                                              productId: product['id'],
                                              oldImageUrl: imageUrl,
                                              onImageUpdated: (String newUrl) {
                                                setState(() {
                                                  imageUrl = newUrl;
                                                });
                                              },
                                            ),
                                          );
                                        },
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),

                      // نمایش وضعیت loading
                      if (isSubmitting) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: AppPadding.allMedium,
                          decoration: AppDecorations.loadingContainer,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'در حال ذخیره تغییرات محصول...',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  style: AppButtonStyles.transparentButton,
                  child: Text(
                    'انصراف',
                    style: AppTextStyles.linkText,
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!_editFormKey.currentState!.validate()) return;

                          setState(() => isSubmitting = true);

                          try {
                            calculateFinalPrice();
                            final supabase = Supabase.instance.client;
                            final response =
                                await supabase.from('products').update({
                              'name': nameController.text,
                              'price':
                                  double.tryParse(priceController.text) ?? 0,
                              'discount':
                                  double.tryParse(discountController.text) ?? 0,
                              'final_price': finalPrice,
                              'description': descController.text,
                              'stock': int.tryParse(stockController.text) ?? 0,
                              'category': categoryController.text,
                            }).eq('id', product['id']);
                            debugPrint('update response: $response');
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'محصول با موفقیت ویرایش شد!',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primaryWhite,
                                    ),
                                  ),
                                  backgroundColor: AppColors.successGreen,
                                ),
                              );
                              _fetchProducts();
                            }
                          } catch (e) {
                            debugPrint('update error: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'خطا در ویرایش محصول: $e',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primaryWhite,
                                    ),
                                  ),
                                  backgroundColor: AppColors.errorRed,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => isSubmitting = false);
                            }
                          }
                        },
                  style: AppButtonStyles.primaryButton,
                  child: isSubmitting
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.loadingIndicator,
                          ),
                        )
                      : Text(
                          'ذخیره تغییرات',
                          style: AppTextStyles.buttonText,
                        ),
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
        backgroundColor: AppColors.appBarBackground,
        title: Text(
          'ویرایش محصولات',
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
                strokeWidth: AppDimensions.loadingStrokeWidth,
              ),
            )
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ListTile(
                  leading: product['image_url'] != null
                      ? Image.network(product['image_url'],
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(product['name'] ?? ''),
                      ),
                      if ((product['stock'] ?? 0) <= 0)
                        Container(
                          padding: AppPadding.symmetricHorizontalLargeVertical4,
                          decoration: BoxDecoration(
                            color: AppColors.errorRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ناموجود',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryWhite,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'قیمت: ${AppUtilities.formatPrice(product['price'])}'),
                      Text('موجودی: ${product['stock'] ?? 0} عدد'),
                      if (product['category'] != null &&
                          product['category'].toString().isNotEmpty)
                        Text(
                          'دسته‌بندی: ${product['category']}',
                          style: AppTextStyles.categoryText,
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editProduct(product),
                  ),
                );
              },
            ),
    );
  }
}

class _EditImageDialog extends StatefulWidget {
  final int productId;
  final String oldImageUrl;
  final Function(String) onImageUpdated;

  const _EditImageDialog({
    required this.productId,
    required this.oldImageUrl,
    required this.onImageUpdated,
    Key? key,
  }) : super(key: key);

  @override
  State<_EditImageDialog> createState() => _EditImageDialogState();
}

class _EditImageDialogState extends State<_EditImageDialog> {
  Uint8List? _webImageBytes;
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _selectedImage = null;
        });
      } else {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _webImageBytes = null;
        });
      }
    }
  }

  Future<void> _uploadAndUpdate() async {
    if (_selectedImage == null && _webImageBytes == null) return;
    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final bucket = 'product-images';
    final path = 'products/$fileName';
    String? newImageUrl;
    try {
      if (kIsWeb && _webImageBytes != null) {
        final storageResponse = await supabase.storage
            .from(bucket)
            .uploadBinary(path, _webImageBytes!);
        if (storageResponse.isEmpty) throw Exception('آپلود عکس انجام نشد');
        newImageUrl = supabase.storage.from(bucket).getPublicUrl(path);
      } else if (_selectedImage != null) {
        final storageResponse =
            await supabase.storage.from(bucket).upload(path, _selectedImage!);
        if (storageResponse.isEmpty) throw Exception('آپلود عکس انجام نشد');
        newImageUrl = supabase.storage.from(bucket).getPublicUrl(path);
      }
      // به‌روزرسانی آدرس عکس در دیتابیس
      await supabase
          .from('products')
          .update({'image_url': newImageUrl}).eq('id', widget.productId);
      // حذف آدرس عکس قبلی از دیتابیس (اختیاری: حذف فایل از Storage)
      await supabase
          .from('products')
          .update({'image_url': null}).eq('image_url', widget.oldImageUrl);
      // (اختیاری) حذف فایل قبلی از Storage:
      // final oldPath = widget.oldImageUrl.split('/product-images/').last;
      // await supabase.storage.from(bucket).remove(['products/$oldPath']);
      if (mounted) {
        widget.onImageUpdated(newImageUrl!);
        Navigator.pop(
            context); // بستن دیالوگ تغییر عکس و بازگشت به دیالوگ ویرایش محصول
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در آپلود یا ویرایش عکس: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'ویرایش عکس محصول',
        style: AppTextStyles.heading3,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_webImageBytes != null)
            Image.memory(_webImageBytes!, height: 120)
          else if (_selectedImage != null)
            Image.file(_selectedImage!, height: 120)
          else
            Text(
              'عکسی انتخاب نشده است',
              style: AppTextStyles.greyText,
            ),
          AppSizedBox.height16,
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _pickImage,
            style: AppButtonStyles.primaryButton,
            icon: const Icon(Icons.image),
            label: Text(
              'انتخاب عکس جدید',
              style: AppTextStyles.buttonText,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: AppButtonStyles.transparentButton,
          child: Text(
            'انصراف',
            style: AppTextStyles.linkText,
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _uploadAndUpdate,
          style: AppButtonStyles.primaryButton,
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.loadingIndicator,
                  ),
                )
              : Text(
                  'ذخیره عکس جدید',
                  style: AppTextStyles.buttonText,
                ),
        ),
      ],
    );
  }
}
