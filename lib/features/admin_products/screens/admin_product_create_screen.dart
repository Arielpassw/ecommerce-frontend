import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/admin_category_model.dart';
import '../services/admin_category_service.dart';
import '../services/admin_product_service.dart';

class AdminProductCreateScreen extends StatefulWidget {
  const AdminProductCreateScreen({super.key});

  @override
  State<AdminProductCreateScreen> createState() =>
      _AdminProductCreateScreenState();
}

class _AdminProductCreateScreenState extends State<AdminProductCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AdminProductService();
  final _categoryService = AdminCategoryService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _discountController = TextEditingController();

  bool _isFeatured = false;
  bool _isLoading = false;
  String? _selectedCategoryId;
  List<AdminCategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        if (categories.isNotEmpty) {
          _selectedCategoryId = categories.first.id;
        }
      });
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      _showMessage('Create a category first');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final discountText = _discountController.text.trim();

      await _service.createProduct(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        categoryId: _selectedCategoryId!,
        imageUrl: _imageUrlController.text.trim(),
        isFeatured: _isFeatured,
        discount: discountText.isEmpty ? null : double.parse(discountText),
      );

      if (!mounted) return;
      context.go('/admin/products');
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/products'),
        ),
        actions: [
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: _required,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategoryId = value);
                  },
                  validator: (value) => value == null ? 'Required field' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: _numberRequired,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: _integerRequired,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _discountController,
                  decoration: const InputDecoration(
                    labelText: 'Discount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: _optionalNumber,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _isFeatured,
                  title: const Text('Featured product'),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() => _isFeatured = value);
                  },
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _save,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Save product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required field';
    }

    return null;
  }

  String? _numberRequired(String? value) {
    final message = _required(value);
    if (message != null) return message;

    return double.tryParse(value!.trim()) == null ? 'Invalid number' : null;
  }

  String? _integerRequired(String? value) {
    final message = _required(value);
    if (message != null) return message;

    return int.tryParse(value!.trim()) == null ? 'Invalid number' : null;
  }

  String? _optionalNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    return double.tryParse(value.trim()) == null ? 'Invalid number' : null;
  }
}
