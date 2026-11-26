import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class PhotoCompressionService {
  const PhotoCompressionService();

  static const int maxInputBytes = 10 * 1024 * 1024;
  static const int maxOutputBytes = 200 * 1024;
  static const int targetBytes = 100 * 1024;
  static const int maxDimension = 800;
  static const int maxInputPixels = 24000000;

  Future<Uint8List> compress(Uint8List bytes) {
    return compute(_compressImage, bytes);
  }

  static Uint8List _compressImage(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > maxInputBytes) {
      throw const FormatException(
        'Selecione uma fotografia de até 10 MB.',
      );
    }

    final decoder = img.findDecoderForData(bytes);

    if (decoder == null ||
        (decoder is! img.JpegDecoder &&
            decoder is! img.PngDecoder)) {
      throw const FormatException(
        'Selecione uma imagem JPEG ou PNG válida.',
      );
    }

    final info = decoder.startDecode(bytes);

    if (info == null ||
        info.width <= 0 ||
        info.height <= 0 ||
        info.width * info.height > maxInputPixels) {
      throw const FormatException(
        'Imagem inválida ou superior a 24 megapixels.',
      );
    }

    final decoded = decoder.decodeFrame(0);

    if (decoded == null) {
      throw const FormatException(
        'Não foi possível processar a fotografia.',
      );
    }

    var image = img.bakeOrientation(decoded);

    image = _resize(image, maxDimension);

    final background = img.Image(
      width: image.width,
      height: image.height,
      numChannels: 3,
    );

    img.fill(
      background,
      color: img.ColorRgb8(255, 255, 255),
    );

    image = img.compositeImage(background, image);

    while (true) {
      Uint8List? compressed;

      for (final quality in [80, 70, 60, 50]) {
        compressed = img.encodeJpg(
          image,
          quality: quality,
        );

        if (compressed.length <= targetBytes) {
          return compressed;
        }
      }

      if (compressed != null &&
          compressed.length <= maxOutputBytes) {
        return compressed;
      }

      final longestSide = math.max(
        image.width,
        image.height,
      );

      if (longestSide <= 200) {
        break;
      }

      image = _resize(
        image,
        math.max(
          200,
          (longestSide * 0.8).round(),
        ),
      );
    }

    throw const FormatException(
      'Não foi possível reduzir a fotografia para 200 KB.',
    );
  }

  static img.Image _resize(
      img.Image image,
      int maxSize,
      ) {
    final longestSide = math.max(
      image.width,
      image.height,
    );

    if (longestSide <= maxSize) {
      return image;
    }

    final scale = maxSize / longestSide;

    return img.copyResize(
      image,
      width: math.max(
        1,
        (image.width * scale).round(),
      ),
      height: math.max(
        1,
        (image.height * scale).round(),
      ),
      interpolation: img.Interpolation.average,
    );
  }
}