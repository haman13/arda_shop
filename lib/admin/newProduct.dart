import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

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
  double _finalPrice = 0;
  File? _selectedImage;
  Uint8List? _webImageBytes;
  XFile? _pickedFile;

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
    String? imageUrl;
    final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
    final bucket = 'product-images';
    final path = 'products/$fileName';
    final supabase = Supabase.instance.client;

    if (kIsWeb && _webImageBytes != null) {
      print('Uploading image (web)...');
      final storageResponse = await supabase.storage
          .from(bucket)
          .uploadBinary(path, _webImageBytes!);
      print('Upload response: $storageResponse');
      if (storageResponse.isEmpty) {
        print('Upload failed');
        return;
      }
      imageUrl = supabase.storage.from(bucket).getPublicUrl(path);
    } else if (!kIsWeb && _selectedImage != null) {
      print('Uploading image (mobile)...');
      final storageResponse =
          await supabase.storage.from(bucket).upload(path, _selectedImage!);
      print('Upload response: $storageResponse');
      if (storageResponse.isEmpty) {
        print('Upload failed');
        return;
      }
      imageUrl = supabase.storage.from(bucket).getPublicUrl(path);
    } else {
      print('No image selected');
      return;
    }

    print('imageUrl: $imageUrl');

    try {
      final insertResponse = await supabase.from('products').insert({
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'discount': double.tryParse(_discountController.text) ?? 0,
        'final_price': _finalPrice,
        'description': _descController.text,
        'image_url': imageUrl,
        'stock': int.tryParse(_stockController.text) ?? 0,
      });
      print('insertResponse: $insertResponse');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('محصول با موفقیت اضافه شد!')),
      );
    } catch (e) {
      print('Insert error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ثبت محصول: $e')),
      );
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
                decoration: const InputDecoration(labelText: 'نام محصول'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'نام محصول را وارد کنید';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'قیمت (تومان)'),
                keyboardType: TextInputType.number,
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(labelText: 'تخفیف (%)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('مبلغ بعد از تخفیف: '),
                  Text(_finalPrice.toStringAsFixed(0)),
                  const Text(' تومان'),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'توضیحات'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
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
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('انتخاب عکس محصول'),
              ),
              if (kIsWeb && _webImageBytes != null)
                Image.memory(_webImageBytes!, height: 100),
              if (!kIsWeb && _selectedImage != null)
                Image.file(_selectedImage!, height: 100),
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
          onPressed: _submit,
          child: const Text('افزودن'),
        ),
      ],
    );
  }
}
