import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/admin_category_model.dart';
import '../services/admin_category_service.dart';
import '../widgets/admin_theme.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final _service = AdminCategoryService();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  AdminCategoryModel? _editingCategory;
  List<AdminCategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    try {
      final categories = await _service.getCategories();

      if (!mounted) return;

      setState(() => _categories = categories);
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      _showMessage('El nombre es obligatorio');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final editing = _editingCategory;

      if (editing == null) {
        await _service.createCategory(name: name, description: description);
      } else {
        await _service.updateCategory(
          id: editing.id,
          name: name,
          description: description,
        );
      }

      _clearForm();
      await _load();
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _delete(AdminCategoryModel category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.surface,
        title: const Text(
          'Eliminar categoria',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Eliminar ${category.name}?',
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
      await _service.deleteCategory(category.id);
      await _load();
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  void _startEdit(AdminCategoryModel category) {
    setState(() {
      _editingCategory = category;
      _nameController.text = category.name;
      _descriptionController.text = category.description ?? '';
    });
  }

  void _clearForm() {
    setState(() {
      _editingCategory = null;
      _nameController.clear();
      _descriptionController.clear();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Categorias',
      subtitle: 'Organiza las categorias que se muestran en la tienda.',
      icon: Icons.category_outlined,
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
        IconButton(
          tooltip: 'Actualizar',
          icon: const Icon(Icons.refresh),
          onPressed: _load,
        ),
        const SizedBox(width: 8),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 820;
          final form = _CategoryForm(
            nameController: _nameController,
            descriptionController: _descriptionController,
            isSaving: _isSaving,
            isEditing: _editingCategory != null,
            onSave: _save,
            onCancel: _clearForm,
          );
          final list = _CategoryList(
            isLoading: _isLoading,
            categories: _categories,
            onEdit: _startEdit,
            onDelete: _delete,
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 380, child: form),
                const SizedBox(width: 18),
                Expanded(child: list),
              ],
            );
          }

          return ListView(
            children: [
              form,
              const SizedBox(height: 16),
              SizedBox(height: 520, child: list),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final bool isSaving;
  final bool isEditing;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _CategoryForm({
    required this.nameController,
    required this.descriptionController,
    required this.isSaving,
    required this.isEditing,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AdminColors.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isEditing ? Icons.edit_outlined : Icons.add_box_outlined,
                  color: AdminColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEditing ? 'Editar categoria' : 'Nueva categoria',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: adminInputDecoration('Nombre', icon: Icons.sell),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            style: const TextStyle(color: Colors.white),
            decoration: adminInputDecoration(
              'Descripcion',
              icon: Icons.notes_outlined,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: adminFilledButtonStyle(),
            onPressed: isSaving ? null : onSave,
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(isEditing ? 'Actualizar' : 'Crear'),
          ),
          if (isEditing) ...[
            const SizedBox(height: 8),
            TextButton(
              style: adminTextButtonStyle(),
              onPressed: isSaving ? null : onCancel,
              child: const Text('Cancelar edicion'),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final bool isLoading;
  final List<AdminCategoryModel> categories;
  final ValueChanged<AdminCategoryModel> onEdit;
  final ValueChanged<AdminCategoryModel> onDelete;

  const _CategoryList({
    required this.isLoading,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Listado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _CountPill(count: categories.length),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AdminColors.accent,
                    ),
                  );
                }

                if (categories.isEmpty) {
                  return const EmptyAdminState(
                    icon: Icons.category_outlined,
                    title: 'Sin categorias',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: AdminColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AdminColors.border),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: AdminColors.primary.withOpacity(
                            0.18,
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: AdminColors.accent,
                          ),
                        ),
                        title: Text(
                          category.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          category.description ?? 'Sin descripcion',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AdminColors.muted),
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              tooltip: 'Editar',
                              color: Colors.white,
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => onEdit(category),
                            ),
                            IconButton(
                              tooltip: 'Eliminar',
                              color: Colors.redAccent,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => onDelete(category),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final int count;

  const _CountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AdminColors.primary.withOpacity(0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AdminColors.border),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: AdminColors.accent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
