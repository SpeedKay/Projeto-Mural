import 'package:flutter/material.dart';

import '../../auth/page/login_page.dart';
import '../../auth/view/auth_view_model.dart';
import '../../item/page/create_item_page.dart';
import '../../item/model/item_model.dart';
import '../../item/viewmodel/item_view_model.dart';
import '../../item/widget/mural_fyi_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.authViewModel,
    required this.itemViewModel,
    super.key,
  });

  final AuthViewModel authViewModel;
  final ItemViewModel itemViewModel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.itemViewModel.loadItems();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openLogin() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => LoginPage(
          viewModel: widget.authViewModel,
        ),
      ),
    );
  }

  Future<void> _openCreateItem() async {
    if (!widget.authViewModel.isAuthenticated) {
      await _openLogin();

      if (!mounted ||
          !widget.authViewModel.isAuthenticated) {
        return;
      }
    }

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CreateItemPage(
          viewModel: widget.itemViewModel,
        ),
      ),
    );
  }

  Future<void> _openEditItem(ItemModel item) async {
    if (!widget.authViewModel.isAuthenticated ||
        widget.itemViewModel.isItemBusy(item.itemId)) {
      return;
    }

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CreateItemPage(
          viewModel: widget.itemViewModel,
          item: item,
        ),
      ),
    );
  }

  Future<void> _confirmAction(
    ItemModel item, {
    required bool deleting,
  }) async {
    if (!widget.authViewModel.isAuthenticated ||
        widget.itemViewModel.isItemBusy(item.itemId)) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          deleting
              ? 'Excluir objeto?'
              : 'Marcar como recuperado?',
        ),
        content: Text(
          deleting
              ? 'Excluir definitivamente "${item.name}"?'
              : 'Confirmar a retirada de "${item.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              deleting ? 'Excluir' : 'Confirmar',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true ||
        !mounted ||
        !widget.authViewModel.isAuthenticated) {
      return;
    }

    try {
      if (deleting) {
        await widget.itemViewModel.deleteItem(item.itemId);
      } else {
        await widget.itemViewModel.markAsRedeemed(item.itemId);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            deleting
                ? 'Objeto excluído.'
                : 'Objeto marcado como recuperado.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mural FYI'),
        actions: [
          ListenableBuilder(
            listenable: widget.authViewModel,
            builder: (context, child) =>
                widget.authViewModel.isAuthenticated
                    ? TextButton.icon(
                        onPressed: widget.authViewModel.logout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Sair'),
                      )
                    : TextButton.icon(
                        onPressed: _openLogin,
                        icon: const Icon(Icons.login),
                        label: const Text('Login'),
                      ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1250),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Achados e perdidos',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Confira objetos encontrados e onde retirá-los.',
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width < 400
                          ? MediaQuery.sizeOf(context).width - 40
                          : 340,
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: widget.itemViewModel.searchItems,
                        decoration: InputDecoration(
                          hintText: 'Buscar pelo nome',
                          border: const OutlineInputBorder(),
                          isDense: true,
                          suffixIcon: IconButton(
                            tooltip: 'Pesquisar',
                            onPressed: () => widget.itemViewModel
                                .searchItems(_searchController.text),
                            icon: const Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        widget.itemViewModel.searchItems('');
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Limpar busca'),
                    ),
                    ListenableBuilder(
                      listenable: widget.authViewModel,
                      builder: (context, child) =>
                          widget.authViewModel.isAuthenticated
                              ? FilledButton.icon(
                                  onPressed: _openCreateItem,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Adicionar objeto'),
                                )
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListenableBuilder(
                    listenable: widget.authViewModel,
                    builder: (context, child) => MuralWidget(
                      viewModel: widget.itemViewModel,
                      canManage: widget.authViewModel.isAuthenticated,
                      onEdit: _openEditItem,
                      onDelete: (item) => _confirmAction(
                        item,
                        deleting: true,
                      ),
                      onRedeem: (item) => _confirmAction(
                        item,
                        deleting: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}