import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class EditProductPage extends StatefulWidget {
  const EditProductPage({super.key});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  List<Map<String, dynamic>> _products = [];
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
    double finalPrice = product['final_price']?.toDouble() ?? 0;
    String imageUrl = product['image_url'] ?? '';

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
                          Text(finalPrice.toStringAsFixed(0)),
                          const Text(' تومان'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descController,
                        decoration: const InputDecoration(labelText: 'توضیحات'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: stockController,
                        decoration: const InputDecoration(labelText: 'موجودی'),
                        keyboardType: TextInputType.number,
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
                      imageUrl.isNotEmpty
                          ? Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Image.network(imageUrl, height: 100),
                                IconButton(
                                  icon: const Icon(Icons.camera_alt,
                                      color: Colors.blue),
                                  onPressed: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) => _EditImageDialog(
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
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('انصراف'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!_editFormKey.currentState!.validate()) return;
                    calculateFinalPrice();
                    final supabase = Supabase.instance.client;
                    try {
                      final response = await supabase.from('products').update({
                        'name': nameController.text,
                        'price': double.tryParse(priceController.text) ?? 0,
                        'discount':
                            double.tryParse(discountController.text) ?? 0,
                        'final_price': finalPrice,
                        'description': descController.text,
                        'stock': int.tryParse(stockController.text) ?? 0,
                      }).eq('id', product['id']);
                      print('update response: $response');
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('محصول با موفقیت ویرایش شد!')),
                        );
                        _fetchProducts();
                      }
                    } catch (e) {
                      print('update error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('خطا در ویرایش محصول: $e')),
                      );
                    }
                  },
                  child: const Text('ذخیره تغییرات'),
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
        title: const Text('ویرایش محصولات'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ناموجود',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('قیمت: ${product['price']} تومان'),
                      Text('موجودی: ${product['stock'] ?? 0} عدد'),
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
      title: const Text('ویرایش عکس محصول'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_webImageBytes != null)
            Image.memory(_webImageBytes!, height: 120)
          else if (_selectedImage != null)
            Image.file(_selectedImage!, height: 120)
          else
            const Text('عکسی انتخاب نشده است'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _pickImage,
            icon: const Icon(Icons.image),
            label: const Text('انتخاب عکس جدید'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _uploadAndUpdate,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('ذخیره عکس جدید'),
        ),
      ],
    );
  }
}
