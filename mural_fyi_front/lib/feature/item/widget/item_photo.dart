import 'dart:typed_data';

import 'package:flutter/material.dart';

class ItemPhoto extends StatelessWidget {
  const ItemPhoto({
    super.key,
    this.bytes,
    this.legacyUrl,
    this.height = 160,
    this.width = double.infinity,
  });

  final Uint8List? bytes;
  final String? legacyUrl;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Widget placeholder(IconData icon) {
      return Container(
        width: width,
        height: height,
        color: colors.surfaceContainerHighest,
        alignment: Alignment.center,

        child: Icon(
          icon,
          size: 36,
          color: colors.onSurfaceVariant,
        ),
      );
    }

    if (bytes != null && bytes!.isNotEmpty) {
      return Image.memory(
        bytes!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            placeholder(Icons.broken_image_outlined),
      );
    }

    if (legacyUrl != null &&
        legacyUrl!.trim().isNotEmpty) {
      return Image.network(
        legacyUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            placeholder(Icons.broken_image_outlined),
      );
    }

    return placeholder(Icons.photo_outlined);
  }
}