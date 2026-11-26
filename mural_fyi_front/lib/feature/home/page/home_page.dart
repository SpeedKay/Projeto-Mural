import 'package:flutter/material.dart';

import '../../auth/page/login_page.dart';
import '../../auth/view/auth_view_model.dart';

import '../../item/page/create_item_page.dart';
import '../../item/model/item_model.dart';
import '../../item/viewmodel/item_view_model.dart';
import '../../item/widget/mural_fyi_widget.dart';

import '../widget/mural_header.dart';

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
  bool _listMode = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.itemViewModel.loadItems();
      }
    });
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
            onPressed: () =>
                Navigator.pop(dialogContext, false),

            child: const Text('Cancelar'),
          ),

          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),

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
        await widget.itemViewModel.deleteItem(
          item.itemId,
        );
      } else {
        await widget.itemViewModel.markAsRedeemed(
          item.itemId,
        );
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
    return ListenableBuilder(
      listenable: widget.authViewModel,

      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mural FYI',

            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),

          actions: [
            if (widget.authViewModel.isAuthenticated)

              TextButton.icon(
                onPressed: widget.authViewModel.logout,
                icon: const Icon(Icons.logout),
                label: const Text('Sair'),
              )

            else

              TextButton.icon(
                onPressed: _openLogin,
                icon: const Icon(Icons.login),
                label: const Text('Login'),
              ),

            const SizedBox(width: 8),
          ],
        ),

        floatingActionButton:
        widget.authViewModel.isAuthenticated

            ? FloatingActionButton(
          onPressed: _openCreateItem,
          tooltip: 'Adicionar objeto',
          child: const Icon(Icons.add),
        )

            : null,

        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1250,
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              child: MuralWidget(
                viewModel: widget.itemViewModel,

                header: MuralHeader(
                  viewModel: widget.itemViewModel,
                  listMode: _listMode,

                  onModeChanged: (value) =>
                      setState(() => _listMode = value),
                ),

                listMode: _listMode,

                canManage:
                widget.authViewModel.isAuthenticated,

                onEdit: _openEditItem,

                onDelete: (item) =>
                    _confirmAction(item, deleting: true),

                onRedeem: (item) =>
                    _confirmAction(item, deleting: false),
              ),
            ),
          ),
        ),
      ),
    );
  }
}