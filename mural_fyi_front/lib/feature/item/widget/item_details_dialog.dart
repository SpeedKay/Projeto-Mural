import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../model/item_model.dart';

import 'remote_item_photo.dart';

class ItemDetailsDialog extends StatelessWidget {
  const ItemDetailsDialog({
    super.key,
    required this.item,
    required this.loadPhoto,
  });

  final ItemModel item;
  final Future<Uint8List> Function(int) loadPhoto;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(item.name),

      content: SizedBox(
        width: 480,

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),

                child: RemoteItemPhoto(
                  item: item,
                  loadPhoto: loadPhoto,
                  height: 240,
                ),
              ),

              const SizedBox(height: 16),

              Text(item.description),

              const SizedBox(height: 12),

              Text('Categoria: ${item.category.label}'),

              Text('Encontrado em: ${item.localFound}'),

              Text(
                'Data: ${item.timeFound.day}/'
                    '${item.timeFound.month}/'
                    '${item.timeFound.year}',
              ),

              Text('Retirada: ${item.redeemLocal}'),

              Text('Situação: ${item.status.label}'),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}