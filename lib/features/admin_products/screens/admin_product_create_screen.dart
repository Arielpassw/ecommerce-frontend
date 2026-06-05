import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/admin_category_model.dart';
import '../services/admin_category_service.dart';
import '../services/admin_product_service.dart';
import '../widgets/admin_theme.dart';

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
      _showMessage('Crea una categoria primero');
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
    return AdminPageShell(
      title: 'Crear producto',
      subtitle: 'Agrega un producto nuevo al catalogo de la tienda.',
      icon: Icons.add_box_outlined,
      leading: IconButton(
        tooltip: 'Volver',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/admin/products'),
      ),
      actions: [
        IconButton(
          tooltip: 'Inicio',
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go('/home'),
        ),
        const SizedBox(width: 8),
      ],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: AdminPanel(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text(
                    'Informacion del producto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _AdminFormField(
                    controller: _nameController,
                    label: 'Nombre',
                    icon: Icons.inventory_2_outlined,
                    validator: _required,
                  ),
                  _AdminFormField(
                    controller: _descriptionController,
                    label: 'Descripcion',
                    icon: Icons.notes_outlined,
                    maxLines: 3,
                    validator: _required,
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    dropdownColor: AdminColors.surfaceAlt,
                    style: const TextStyle(color: Colors.white),
                    decoration: adminInputDecoration(
                      'Categoria',
                      icon: Icons.category_outlined,
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
                    validator: (value) =>
                        value == null ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 560;
                      final price = _AdminFormField(
                        controller: _priceController,
                        label: 'Precio',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: _numberRequired,
                      );
                      final stock = _AdminFormField(
                        controller: _stockController,
                        label: 'Stock',
                        icon: Icons.warehouse_outlined,
                        keyboardType: TextInputType.number,
                        validator: _integerRequired,
                      );

                      if (isCompact) {
                        return Column(children: [price, stock]);
                      }

                      return Row(
                        children: [
                          Expanded(child: price),
                          const SizedBox(width: 12),
                          Expanded(child: stock),
                        ],
                      );
                    },
                  ),
                  _AdminFormField(
                    controller: _imageUrlController,
                    label: 'Imagen URL',
                    icon: Icons.image_outlined,
                  ),
                  _AdminFormField(
                    controller: _discountController,
                    label: 'Descuento',
                    icon: Icons.local_offer_outlined,
                    keyboardType: TextInputType.number,
                    validator: _optionalNumber,
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AdminColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AdminColors.border),
                    ),
                    child: SwitchListTile(
                      value: _isFeatured,
                      activeColor: AdminColors.accent,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Producto destacado',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _isFeatured = value);
                      },
                    ),
                  ),
                  FilledButton.icon(
                    style: adminFilledButtonStyle(),
                    onPressed: _isLoading ? null : _save,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Guardar producto'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }

    return null;
  }

  String? _numberRequired(String? value) {
    final message = _required(value);
    if (message != null) return message;

    return double.tryParse(value!.trim()) == null ? 'Numero invalido' : null;
  }

  String? _integerRequired(String? value) {
    final message = _required(value);
    if (message != null) return message;

    return int.tryParse(value!.trim()) == null ? 'Numero invalido' : null;
  }

  String? _optionalNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    return double.tryParse(value.trim()) == null ? 'Numero invalido' : null;
  }
}

class _AdminFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const _AdminFormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: adminInputDecoration(label, icon: icon),
      ),
    );
  }
}
