import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../model/item_model.dart';

import 'item_photo.dart';

class RemoteItemPhoto extends StatefulWidget {
  const RemoteItemPhoto({
    super.key,
    required this.item,
    required this.loadPhoto,
    this.width = double.infinity,
    this.height = 160,
  });

  final ItemModel item;
  final Future<Uint8List> Function(int) loadPhoto;
  final double width;
  final double height;

  @override
  State<RemoteItemPhoto> createState() =>
      _RemoteItemPhotoState();
}

class _RemoteItemPhotoState extends State<RemoteItemPhoto> {
  Future<Uint8List>? _future;

  void _load() {
    _future = widget.item.hasPhoto
        ? widget.loadPhoto(widget.item.itemId)
        : null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(
      covariant RemoteItemPhoto oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item.itemId != widget.item.itemId ||
        oldWidget.item.version != widget.item.version ||
        oldWidget.item.hasPhoto != widget.item.hasPhoto) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_future == null) {
      return ItemPhoto(
        legacyUrl: widget.item.imgUrl,
        width: widget.width,
        height: widget.height,
      );
    }

    return FutureBuilder<Uint8List>(
      future: _future,

      builder: (context, snapshot) {
        if (snapshot.connectionState !=
            ConnectionState.done) {
          return SizedBox(
            width: widget.width,
            height: widget.height,

            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            width: widget.width,
            height: widget.height,

            child: Center(
              child: IconButton(
                tooltip: 'Tentar carregar foto novamente',
                onPressed: () => setState(_load),
                icon: const Icon(Icons.refresh),
              ),
            ),
          );
        }

        return ItemPhoto(
          bytes: snapshot.data,
          width: widget.width,
          height: widget.height,
        );
      },
    );
  }
}