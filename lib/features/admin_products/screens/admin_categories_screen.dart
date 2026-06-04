import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/admin_category_model.dart';
import '../services/admin_category_service.dart';

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
      _showMessage('Name is required');
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
        title: const Text('Delete category'),
        content: Text('Delete ${category.name}?'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin categories'),
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
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
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
                    SizedBox(width: 360, child: form),
                    const VerticalDivider(width: 1),
                    Expanded(child: list),
                  ],
                );
              }

              return ListView(
                children: [
                  form,
                  const Divider(height: 1),
                  SizedBox(height: 520, child: list),
                ],
              );
            },
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing ? 'Edit category' : 'Create category',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: isSaving ? null : onSave,
            icon: const Icon(Icons.save),
            label: Text(isEditing ? 'Update' : 'Create'),
          ),
          if (isEditing) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: isSaving ? null : onCancel,
              child: const Text('Cancel edit'),
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categories.isEmpty) {
      return const Center(child: Text('No categories yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final category = categories[index];

        return Card(
          child: ListTile(
            title: Text(category.name),
            subtitle: Text(category.description ?? 'No description'),
            trailing: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit),
                  onPressed: () => onEdit(category),
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete),
                  onPressed: () => onDelete(category),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
