import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'photo_compression_service.dart';

class SelectedPhoto {
  const SelectedPhoto(this.name, this.bytes);

  final String name;
  final Uint8List bytes;
}

abstract interface class PhotoPickerService {
  Future<SelectedPhoto?> pick();
}

class DevicePhotoPicker implements PhotoPickerService {
  const DevicePhotoPicker({
    PhotoCompressionService compressionService =
    const PhotoCompressionService(),
  }) : _compressionService = compressionService;

  final PhotoCompressionService _compressionService;

  @override
  Future<SelectedPhoto?> pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null) {
      return null;
    }

    final file = result.files.single;
    final bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      throw const FormatException(
        'Não foi possível carregar a fotografia.',
      );
    }

    final compressedBytes =
    await _compressionService.compress(bytes);

    final fileName = file.name.replaceFirst(
      RegExp(r'\.[^.]+$'),
      '',
    );

    return SelectedPhoto(
      '$fileName.jpg',
      compressedBytes,
    );
  }
}