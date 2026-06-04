import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/admin_category_model.dart';
import '../models/admin_product_model.dart';
import '../services/admin_category_service.dart';
import '../services/admin_product_service.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _service = AdminProductService();
  final _categoryService = AdminCategoryService();

  bool _isLoading = true;
  List<AdminProductModel> _products = [];
  List<AdminCategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    try {
      final products = await _service.getProducts();
      final categories = await _categoryService.getCategories();

      if (!mounted) return;

      setState(() {
        _products = products;
        _categories = categories;
      });
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteProduct(AdminProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product'),
        content: Text('Delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.deleteProduct(product.id);
      await _load();
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  Future<void> _editProduct(AdminProductModel product) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => _EditProductDialog(
        product: product,
        categories: _categories,
        service: _service,
      ),
    );

    if (updated == true) {
      await _load();
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
        title: const Text('Admin products'),
        actions: [
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/home'),
          ),
          IconButton(
            tooltip: 'Categories',
            icon: const Icon(Icons.category),
            onPressed: () => context.go('/admin/categories'),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => context.go('/admin/products/create'),
              icon: const Icon(Icons.add),
              label: const Text('New'),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? const Center(child: Text('No products yet'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final product = _products[index];

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(product.stock.toString()),
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                        '${product.categoryName ?? 'No category'} '
                        '- \$${product.price.toStringAsFixed(2)}',
                      ),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editProduct(product),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteProduct(product),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _EditProductDialog extends StatefulWidget {
  final AdminProductModel product;
  final List<AdminCategoryModel> categories;
  final AdminProductService service;

  const _EditProductDialog({
    required this.product,
    required this.categories,
    required this.service,
  });

  @override
  State<_EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<_EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _discountController;
  late bool _isFeatured;
  late String _categoryId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(
      text: widget.product.description,
    );
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _imageUrlController = TextEditingController(
      text: widget.product.imageUrl ?? '',
    );
    _discountController = TextEditingController(
      text: widget.product.discount?.toString() ?? '',
    );
    _isFeatured = widget.product.isFeatured;
    _categoryId = widget.product.categoryId;
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final discountText = _discountController.text.trim();

      await widget.service.updateProduct(
        id: widget.product.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        categoryId: _categoryId,
        imageUrl: _imageUrlController.text.trim(),
        isFeatured: _isFeatured,
        discount: discountText.isEmpty ? null : double.parse(discountText),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit product'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: _required,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: _required,
                ),
                DropdownButtonFormField<String>(
                  value: _categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: widget.categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _categoryId = value);
                    }
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        validator: _numberRequired,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(labelText: 'Stock'),
                        keyboardType: TextInputType.number,
                        validator: _integerRequired,
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
                TextFormField(
                  controller: _discountController,
                  decoration: const InputDecoration(labelText: 'Discount'),
                  keyboardType: TextInputType.number,
                  validator: _optionalNumber,
                ),
                SwitchListTile(
                  value: _isFeatured,
                  title: const Text('Featured'),
                  onChanged: (value) {
                    setState(() => _isFeatured = value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: const Text('Save'),
        ),
      ],
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
