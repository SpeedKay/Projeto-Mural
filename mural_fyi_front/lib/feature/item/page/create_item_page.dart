import 'package:flutter/material.dart';

import '../model/item_category.dart';
import '../model/item_create_request.dart';
import '../model/item_model.dart';
import '../viewmodel/item_view_model.dart';

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({
    required this.viewModel,
    this.item,
    super.key,
  });

  final ItemViewModel viewModel;
  final ItemModel? item;

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _localFoundController = TextEditingController();
  final _redeemLocalController = TextEditingController();
  final _imgUrlController = TextEditingController();

  ItemCategory _category = ItemCategory.other;
  DateTime _timeFound = DateTime.now();

  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    if (item == null) return;

    _nameController.text = item.name;
    _descriptionController.text = item.description;
    _localFoundController.text = item.localFound;
    _redeemLocalController.text = item.redeemLocal;
    _imgUrlController.text = item.imgUrl ?? '';

    _category = item.category;
    _timeFound = item.timeFound;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _localFoundController.dispose();
    _redeemLocalController.dispose();
    _imgUrlController.dispose();

    super.dispose();
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _timeFound,
      firstDate: _timeFound.isBefore(DateTime(2000))
          ? _timeFound
          : DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      setState(() => _timeFound = date);
    }
  }

  String? _required(
    String? value, {
    int? maxLength,
  }) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Campo obrigatório';
    }

    if (maxLength != null && text.length > maxLength) {
      return 'Máximo de $maxLength caracteres';
    }

    return null;
  }

  String? _validateUrl(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return null;

    if (text.length > 500) {
      return 'Máximo de 500 caracteres';
    }

    final uri = Uri.tryParse(text);

    if (uri == null ||
        !(uri.scheme == 'https' || uri.scheme == 'http') ||
        uri.host.isEmpty) {
      return 'Informe uma URL HTTP ou HTTPS válida';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final request = ItemCreateRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        localFound: _localFoundController.text.trim(),
        timeFound: _timeFound,
        redeemLocal: _redeemLocalController.text.trim(),
        imgUrl: _imgUrlController.text.trim().isEmpty
            ? null
            : _imgUrlController.text.trim(),
      );

      if (_isEditing) {
        await widget.viewModel.updateItem(
          widget.item!.itemId,
          request,
        );
      } else {
        await widget.viewModel.createItem(request);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${_timeFound.day.toString().padLeft(2, '0')}/'
        '${_timeFound.month.toString().padLeft(2, '0')}/'
        '${_timeFound.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Editar objeto'
              : 'Adicionar objeto ao mural',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 740),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Dados do objeto',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 100,
                        validator: (value) => _required(
                          value,
                          maxLength: 100,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => _required(
                          value,
                          maxLength: 500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<ItemCategory>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                          border: OutlineInputBorder(),
                        ),
                        items: ItemCategory.values
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _category = value);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _localFoundController,
                        maxLength: 150,
                        decoration: const InputDecoration(
                          labelText: 'Local onde foi encontrado',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => _required(
                          value,
                          maxLength: 150,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _redeemLocalController,
                        maxLength: 150,
                        decoration: const InputDecoration(
                          labelText: 'Local de retirada',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => _required(
                          value,
                          maxLength: 150,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _chooseDate,
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(
                          'Data em que foi encontrado: $formattedDate',
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _imgUrlController,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'URL da fotografia (opcional)',
                          hintText: 'https://...',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateUrl,
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _submit,
                        icon: const Icon(Icons.save_outlined),
                        label: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _isSaving
                                ? 'Salvando...'
                                : (_isEditing
                                    ? 'Salvar alterações'
                                    : 'Cadastrar objeto'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}