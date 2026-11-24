import 'package:flutter/material.dart';

import '../model/item_model.dart';
import '../model/item_status.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    required this.item,
    this.onEdit,
    this.onDelete,
    this.onRedeem,
    this.isBusy = false,
    super.key,
  });

  final ItemModel item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRedeem;
  final bool isBusy;

  bool get _canManage =>
      onEdit != null ||
      onDelete != null ||
      onRedeem != null;

  String get _formattedDate =>
      '${item.timeFound.day.toString().padLeft(2, '0')}/'
      '${item.timeFound.month.toString().padLeft(2, '0')}/'
      '${item.timeFound.year}';

  Widget _itemPhoto({double height = 145}) {
    if (item.imgUrl == null || item.imgUrl!.trim().isEmpty) {
      return Container(
        height: height,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 50,
          ),
        ),
      );
    }

    return Image.network(
      item.imgUrl!,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 50,
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.name),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _itemPhoto(height: 220),
                ),
                const SizedBox(height: 16),
                Text(item.description),
                const SizedBox(height: 12),
                Text('Categoria: ${item.category.label}'),
                Text('Encontrado em: ${item.localFound}'),
                Text('Data: $_formattedDate'),
                Text('Retirada: ${item.redeemLocal}'),
                Text('Situação: ${item.status.label}'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _itemPhoto(),
                if (_canManage)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      shape: const CircleBorder(),
                      child: isBusy
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : PopupMenuButton<String>(
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
                              itemBuilder: (context) => [
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
                            ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      item.localFound,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(item.status.label),
                      avatar: Icon(
                        item.status == ItemStatus.unclaimed
                            ? Icons.access_time_outlined
                            : Icons.check_circle_outline,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}