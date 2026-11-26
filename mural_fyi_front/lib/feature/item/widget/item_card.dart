import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../model/item_model.dart';
import '../model/item_status.dart';

import 'remote_item_photo.dart';
import 'item_details_dialog.dart';
import 'item_action_menu.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.loadPhoto,
    this.onEdit,
    this.onDelete,
    this.onRedeem,
    this.isBusy = false,
    this.listMode = false,
  });

  final ItemModel item;

  final Future<Uint8List> Function(int) loadPhoto;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRedeem;

  final bool isBusy;
  final bool listMode;

  bool get _canManage =>
      onEdit != null ||
          onDelete != null ||
          onRedeem != null;

  Widget _photo({
    double height = 142,
    double width = double.infinity,
  }) {
    return RemoteItemPhoto(
      item: item,
      loadPhoto: loadPhoto,
      height: height,
      width: width,
    );
  }

  Widget _menu() {
    return ItemActionMenu(
      item: item,
      onEdit: onEdit,
      onDelete: onDelete,
      onRedeem: onRedeem,
      isBusy: isBusy,
    );
  }

  void _showDetails(BuildContext context) {
    showDialog<void>(
      context: context,

      builder: (_) => ItemDetailsDialog(
        item: item,
        loadPhoto: loadPhoto,
      ),
    );
  }

  Widget _info(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final recovered = item.status == ItemStatus.redeemed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,

      children: [
        Text(
          item.category.label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,

          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.primary,
            letterSpacing: .7,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,

          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          item.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Icon(
              Icons.place_outlined,
              size: 16,
              color: colors.primary,
            ),

            const SizedBox(width: 4),

            Expanded(
              child: Text(
                item.localFound,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 5,
          ),

          decoration: BoxDecoration(
            color: recovered
                ? const Color(0xffdcefe5)
                : const Color(0xffffedcf),

            borderRadius: BorderRadius.circular(8),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              Icon(
                recovered
                    ? Icons.check_circle_outline
                    : Icons.schedule,

                size: 15,

                color: recovered
                    ? const Color(0xff175e3c)
                    : const Color(0xff88530a),
              ),

              const SizedBox(width: 4),

              Flexible(
                child: Text(
                  item.status.label,
                  maxLines: 2,

                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,

                    color: recovered
                        ? const Color(0xff175e3c)
                        : const Color(0xff88530a),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,

      child: InkWell(
        onTap: () => _showDetails(context),

        child: listMode

            ? LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 440;

            return Padding(
              padding: const EdgeInsets.all(10),

              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(12),

                    child: _photo(
                      width: compact ? 76 : 148,
                      height: compact ? 96 : 145,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _info(context),
                  ),

                  if (_canManage) _menu(),
                ],
              ),
            );
          },
        )

            : Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,

          children: [
            Stack(
              children: [
                _photo(),

                if (_canManage)
                  Positioned(
                    top: 8,
                    right: 8,

                    child: Material(
                      color: Theme.of(context)
                          .colorScheme.surface,

                      shape: const CircleBorder(),

                      child: _menu(),
                    ),
                  ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),

                child: _info(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}