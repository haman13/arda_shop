import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';

class NewProductDialog extends StatefulWidget {
  const NewProductDialog({super.key});

  @override
  State<NewProductDialog> createState() => _NewProductDialogState();
}

class _NewProductDialogState extends State<NewProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _discountController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();

  // دسته‌بندی‌های موجود در دیتابیس
  List<String> _existingCategories = [];
  String? _selectedCategory;
  bool _isLoadingCategories = true;
  bool _isSubmitting = false;

  double _finalPrice = 0;
  File? _selectedImage;
  Uint8List? _webImageBytes;
  XFile? _pickedFile;

  @override
  void initState() {
    super.initState();
    _loadExistingCategories();
  }

  Future<void> _loadExistingCategories() async {
    setState(() => _isLoadingCategories = true);
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
        _isLoadingCategories = false;
      });
    } catch (e) {
      // Log error for debugging
      debugPrint('خطا در بارگذاری دسته‌بندی‌ها: $e');
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final newCategoryController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('اضافه کردن دسته‌بندی جدید'),
          content: TextField(
            controller: newCategoryController,
            decoration: AppInputDecorations.formField('نام دسته‌بندی',
                hint: 'مثال: لوازم الکترونیکی'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                final categoryName = newCategoryController.text.trim();
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
        _selectedCategory = result;
        _categoryController.text = result;
      });
    }
  }

  void _calculateFinalPrice() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;
    final discounted = price * (1 - (discount / 100));
    setState(() {
      _finalPrice = discounted.ceilToDouble();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _pickedFile = pickedFile;
      if (kIsWeb) {
        _webImageBytes = await pickedFile.readAsBytes();
      } else {
        _selectedImage = File(pickedFile.path);
      }
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // بررسی انتخاب دسته‌بندی
    if (_categoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً دسته‌بندی را انتخاب کنید')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    String? imageUrl;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final bucket = 'product-images';
    final path = 'products/$fileName';
    final supabase = Supabase.instance.client;

    try {
      if (kIsWeb && _webImageBytes != null) {
        debugPrint('Uploading image (web)...');
        final storageResponse = await supabase.storage
            .from(bucket)
            .uploadBinary(path, _webImageBytes!);
        debugPrint('Upload response: $storageResponse');
        if (storageResponse.isEmpty) {
          debugPrint('Upload failed');
          throw Exception('آپلود تصویر ناموفق بود');
        }
        imageUrl = supabase.storage.from(bucket).getPublicUrl(path);
      } else if (!kIsWeb && _selectedImage != null) {
        debugPrint('Uploading image (mobile)...');
        final storageResponse =
            await supabase.storage.from(bucket).upload(path, _selectedImage!);
        debugPrint('Upload response: $storageResponse');
        if (storageResponse.isEmpty) {
          debugPrint('Upload failed');
          throw Exception('آپلود تصویر ناموفق بود');
        }
        imageUrl = supabase.storage.from(bucket).getPublicUrl(path);
      } else {
        debugPrint('No image selected');
        throw Exception('لطفاً تصویر محصول را انتخاب کنید');
      }

      debugPrint('imageUrl: $imageUrl');

      final insertResponse = await supabase.from('products').insert({
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'discount': double.tryParse(_discountController.text) ?? 0,
        'final_price': _finalPrice,
        'description': _descController.text,
        'category': _categoryController.text.trim(),
        'image_url': imageUrl,
        'stock': int.tryParse(_stockController.text) ?? 0,
      });
      debugPrint('insertResponse: $insertResponse');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('محصول با موفقیت اضافه شد!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('Insert error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ثبت محصول: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('افزودن محصول جدید'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: AppInputDecorations.formField('نام محصول'),
                enabled: !_isSubmitting,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'نام محصول را وارد کنید';
                  }
                  return null;
                },
              ),
              AppSizedBox.height12,
              TextFormField(
                controller: _priceController,
                decoration: AppInputDecorations.formField('قیمت (تومان)'),
                keyboardType: TextInputType.number,
                enabled: !_isSubmitting,
                onChanged: (_) => _calculateFinalPrice(),
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
              AppSizedBox.height12,
              TextFormField(
                controller: _discountController,
                decoration: AppInputDecorations.formField('تخفیف (%)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                enabled: !_isSubmitting,
                onChanged: (_) => _calculateFinalPrice(),
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
              AppSizedBox.height12,
              Row(
                children: [
                  const Text('مبلغ بعد از تخفیف: '),
                  Text(
                      AppUtilities.formatPrice(_finalPrice.toStringAsFixed(0))),
                ],
              ),
              AppSizedBox.height12,
              TextFormField(
                controller: _descController,
                decoration: AppInputDecorations.formField('توضیحات'),
                enabled: !_isSubmitting,
                maxLines: 2,
              ),
              AppSizedBox.height12,
              TextFormField(
                controller: _stockController,
                decoration: AppInputDecorations.formField('موجودی'),
                keyboardType: TextInputType.number,
                enabled: !_isSubmitting,
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
              AppSizedBox.height12,

              // فیلد دسته‌بندی
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'دسته‌بندی:',
                    style: AppTextStyles.formLabel,
                  ),
                  AppSizedBox.height8,
                  if (_isLoadingCategories)
                    Center(
                      child: Padding(
                        padding: AppPadding.allMedium,
                        child: const CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
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
                              AppSizedBox.width8,
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
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              if (value == 'ADD_NEW_CATEGORY') {
                                _showAddCategoryDialog();
                              } else if (value != null) {
                                setState(() {
                                  _selectedCategory = value;
                                  _categoryController.text = value;
                                });
                              }
                            },
                    ),
                    AppSizedBox.height8,
                    Text(
                      'دسته‌بندی انتخاب شده: ${_categoryController.text.isEmpty ? "انتخاب نشده" : _categoryController.text}',
                      style: AppTextStyles.greyText,
                    ),
                  ],
                ],
              ),
              AppSizedBox.height12,
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _pickImage,
                style: AppButtonStyles.primaryButton,
                icon: const Icon(Icons.image),
                label: Text(
                  'انتخاب عکس محصول',
                  style: AppTextStyles.buttonText,
                ),
              ),
              if (kIsWeb && _webImageBytes != null)
                Image.memory(_webImageBytes!,
                    height: AppDimensions.productImageHeight),
              if (!kIsWeb && _selectedImage != null)
                Image.file(_selectedImage!,
                    height: AppDimensions.productImageHeight),

              // نمایش وضعیت loading
              if (_isSubmitting) ...[
                AppSizedBox.height16,
                Container(
                  padding: AppPadding.allMedium,
                  decoration: AppDecorations.loadingContainer,
                  child: Row(
                    children: [
                      SizedBox(
                        width: AppDimensions.loadingIndicatorWidth,
                        height: AppDimensions.loadingIndicatorHeight,
                        child: CircularProgressIndicator(
                            strokeWidth: AppDimensions.loadingStrokeWidth),
                      ),
                      AppSizedBox.width12,
                      Expanded(
                        child: Text(
                          'در حال آپلود تصویر و اضافه کردن محصول...',
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
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          style: AppButtonStyles.transparentButton,
          child: Text(
            'انصراف',
            style: AppTextStyles.linkText,
          ),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: AppButtonStyles.primaryButton,
          child: _isSubmitting
              ? SizedBox(
                  width: AppDimensions.loadingIndicatorWidth,
                  height: AppDimensions.loadingIndicatorHeight,
                  child: CircularProgressIndicator(
                    strokeWidth: AppDimensions.loadingStrokeWidth,
                    color: AppColors.loadingIndicator,
                  ),
                )
              : Text(
                  'افزودن',
                  style: AppTextStyles.buttonText,
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
