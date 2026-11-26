import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../viewmodel/item_form_view_model.dart';

import 'item_photo.dart';
import 'remote_item_photo.dart';

class ItemPhotoPicker extends StatelessWidget {
  const ItemPhotoPicker({
    super.key,
    required this.form,
    required this.loadPhoto,
  });

  final ItemFormViewModel form;
  final Future<Uint8List> Function(int) loadPhoto;

  String get _photoInformation {
    final photo = form.photo;

    if (photo == null) {
      return 'JPEG ou PNG • até 10 MB antes da compressão';
    }

    final size = photo.bytes.length / 1024;

    return '${photo.name} • ${size.toStringAsFixed(1)} KB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          'Fotografia do objeto',
          style: Theme.of(context).textTheme.titleMedium,
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(16),

          child: form.removePhoto ||
              form.photo != null ||
              form.item == null

              ? ItemPhoto(
            bytes: form.photo?.bytes,
            height: 200,
          )

              : RemoteItemPhoto(
            item: form.item!,
            loadPhoto: loadPhoto,
            height: 200,
          ),
        ),

        const SizedBox(height: 8),

        Text(_photoInformation),

        const Text(
          'A fotografia será comprimida automaticamente.',
        ),

        const Text(
          'Não publique números de documentos ou outros dados pessoais.',
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,

          children: [
            OutlinedButton.icon(
              onPressed: form.isPicking || form.isSaving
                  ? null
                  : form.pickPhoto,

              icon: const Icon(Icons.upload_file),

              label: Text(
                form.isPicking
                    ? 'Processando foto...'
                    : 'Selecionar foto',
              ),
            ),

            if (!form.removePhoto &&
                (form.photo != null ||
                    form.item?.hasPhoto == true ||
                    (form.item?.imgUrl?.isNotEmpty ?? false)))

              TextButton.icon(
                onPressed: form.isPicking || form.isSaving
                    ? null
                    : form.clearPhoto,

                icon: const Icon(Icons.delete_outline),

                label: const Text('Remover foto'),
              ),
          ],
        ),
      ],
    );
  }
}