import 'package:flutter/material.dart';

import '../model/item_model.dart';
import '../model/item_status.dart';

class ItemActionMenu extends StatelessWidget {
  const ItemActionMenu({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
    this.onRedeem,
    this.isBusy = false,
  });

  final ItemModel item;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRedeem;

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    if (isBusy) {
      return const Padding(
        padding: EdgeInsets.all(12),

        child: SizedBox(
          width: 20,
          height: 20,

          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    return PopupMenuButton<String>(
      tooltip: 'Gerenciar objeto',

      onSelected: (action) {
        switch (action) {
          case 'edit':
            onEdit?.call();
            break;

          case 'redeem':
            onRedeem?.call();
            break;

          case 'delete':
            onDelete?.call();
            break;
        }
      },

      itemBuilder: (_) => [
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Text('Editar'),
          ),

        if (onRedeem != null &&
            item.status == ItemStatus.unclaimed)
          const PopupMenuItem(
            value: 'redeem',
            child: Text('Marcar como recuperado'),
          ),

        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: Text('Excluir'),
          ),
      ],
    );
  }
}