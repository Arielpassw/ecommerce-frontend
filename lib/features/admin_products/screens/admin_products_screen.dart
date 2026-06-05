import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/admin_category_model.dart';
import '../models/admin_product_model.dart';
import '../services/admin_category_service.dart';
import '../services/admin_product_service.dart';
import '../widgets/admin_theme.dart';

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
        backgroundColor: AdminColors.surface,
        title: const Text(
          'Eliminar producto',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Eliminar ${product.name}?',
          style: const TextStyle(color: AdminColors.muted),
        ),
        actions: [
          TextButton(
            style: adminTextButtonStyle(),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: adminFilledButtonStyle(),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
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
    final featuredCount = _products.where((item) => item.isFeatured).length;
    final lowStockCount = _products.where((item) => item.stock <= 5).length;

    return AdminPageShell(
      title: 'Productos',
      subtitle: 'Gestiona el catalogo, precios, stock y destacados.',
      icon: Icons.inventory_2_outlined,
      actions: [
        IconButton(
          tooltip: 'Inicio',
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go('/home'),
        ),
        IconButton(
          tooltip: 'Categorias',
          icon: const Icon(Icons.category_outlined),
          onPressed: () => context.go('/admin/categories'),
        ),
        IconButton(
          tooltip: 'Actualizar',
          icon: const Icon(Icons.refresh),
          onPressed: _load,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => context.go('/admin/products/create'),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo'),
          ),
        ),
      ],
      child: Column(
        children: [
          _StatsRow(
            products: _products.length,
            categories: _categories.length,
            featured: featuredCount,
            lowStock: lowStockCount,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AdminPanel(
              padding: EdgeInsets.zero,
              child: _ProductsList(
                isLoading: _isLoading,
                products: _products,
                onRefresh: _load,
                onEdit: _editProduct,
                onDelete: _deleteProduct,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int products;
  final int categories;
  final int featured;
  final int lowStock;

  const _StatsRow({
    required this.products,
    required this.categories,
    required this.featured,
    required this.lowStock,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem('Productos', '$products', Icons.inventory_2_outlined),
      _StatItem('Categorias', '$categories', Icons.category_outlined),
      _StatItem('Destacados', '$featured', Icons.star_border),
      _StatItem('Stock bajo', '$lowStock', Icons.warning_amber_outlined),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isCompact ? 2 : 4,
            mainAxisExtent: 98,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final item = items[index];

            return AdminPanel(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AdminColors.primary.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item.icon, color: AdminColors.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AdminColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem(this.label, this.value, this.icon);
}

class _ProductsList extends StatelessWidget {
  final bool isLoading;
  final List<AdminProductModel> products;
  final Future<void> Function() onRefresh;
  final ValueChanged<AdminProductModel> onEdit;
  final ValueChanged<AdminProductModel> onDelete;

  const _ProductsList({
    required this.isLoading,
    required this.products,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AdminColors.accent),
      );
    }

    if (products.isEmpty) {
      return const EmptyAdminState(
        icon: Icons.inventory_2_outlined,
        title: 'Sin productos',
      );
    }

    return RefreshIndicator(
      color: AdminColors.accent,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final product = products[index];

          return _ProductTile(
            product: product,
            onEdit: () => onEdit(product),
            onDelete: () => onDelete(product),
          );
        },
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final AdminProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AdminColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AdminColors.border),
            ),
            child: product.imageUrl == null
                ? const Icon(Icons.image_outlined, color: AdminColors.muted)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_outlined,
                        color: AdminColors.muted,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (product.isFeatured)
                      const Icon(
                        Icons.star,
                        color: AdminColors.accent,
                        size: 18,
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  product.categoryName ?? 'Sin categoria',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AdminColors.muted),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _InfoChip('\$${product.price.toStringAsFixed(2)}'),
                    _InfoChip('Stock ${product.stock}'),
                    if (product.discount != null)
                      _InfoChip('${product.discount!.toStringAsFixed(0)}% off'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Editar',
            color: Colors.white,
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
          IconButton(
            tooltip: 'Eliminar',
            color: Colors.redAccent,
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;

  const _InfoChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AdminColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AdminColors.accent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
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
    final selectedCategory = widget.categories.any(
      (category) => category.id == _categoryId,
    )
        ? _categoryId
        : null;

    return AlertDialog(
      backgroundColor: AdminColors.surface,
      title: const Text(
        'Editar producto',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogField(
                  controller: _nameController,
                  label: 'Nombre',
                  icon: Icons.inventory_2_outlined,
                  validator: _required,
                ),
                _DialogField(
                  controller: _descriptionController,
                  label: 'Descripcion',
                  icon: Icons.notes_outlined,
                  validator: _required,
                  maxLines: 2,
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  dropdownColor: AdminColors.surfaceAlt,
                  style: const TextStyle(color: Colors.white),
                  decoration: adminInputDecoration(
                    'Categoria',
                    icon: Icons.category_outlined,
                  ),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DialogField(
                        controller: _priceController,
                        label: 'Precio',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: _numberRequired,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogField(
                        controller: _stockController,
                        label: 'Stock',
                        icon: Icons.warehouse_outlined,
                        keyboardType: TextInputType.number,
                        validator: _integerRequired,
                      ),
                    ),
                  ],
                ),
                _DialogField(
                  controller: _imageUrlController,
                  label: 'Imagen URL',
                  icon: Icons.image_outlined,
                ),
                _DialogField(
                  controller: _discountController,
                  label: 'Descuento',
                  icon: Icons.local_offer_outlined,
                  keyboardType: TextInputType.number,
                  validator: _optionalNumber,
                ),
                SwitchListTile(
                  value: _isFeatured,
                  activeColor: AdminColors.accent,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Producto destacado',
                    style: TextStyle(color: Colors.white),
                  ),
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
          style: adminTextButtonStyle(),
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: adminFilledButtonStyle(),
          onPressed: _isSaving ? null : _save,
          child: const Text('Guardar'),
        ),
      ],
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

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const _DialogField({
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
      padding: const EdgeInsets.only(bottom: 12),
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
