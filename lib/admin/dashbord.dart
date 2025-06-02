import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'newProduct.dart';
import 'editProduct.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _discountController = TextEditingController();
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

  Future<void> _pickImage(StateSetter setState) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
        });
      } else {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => const NewProductDialog(),
    );
  }

  void _showEditProductPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProductPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('داشبورد ادمین'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _showAddProductDialog,
              icon: const Icon(Icons.add),
              label: const Text('افزودن محصول'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showEditProductPage,
              icon: const Icon(Icons.edit),
              label: const Text('ویرایش محصولات'),
            ),
          ],
        ),
      ),
    );
  }
}
