import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider with ChangeNotifier {
  int photoCount = 0;
  bool takingPhoto = false;

  void setTakePhoto(bool value) {
    takingPhoto = value;
    notifyListeners();
  }

  void setPhotoCount(int value) {
    photoCount = value;
    notifyListeners();
  }

  Future<void> cropImage(
    Uint8List file, {
    required int x,
    required int y,
    required double width,
    required double height,
    required double maxW,
    required double maxH,
  }) async {
    img.Image src = img.decodeImage(file)!;

    final wMultiple = src.width / maxW;
    final hMultiple = src.height / maxH;
    img.Image croppedImage = img.copyCrop(src,
        x: (x * wMultiple).toInt(),
        y: (y * hMultiple).toInt(),
        width: (width * wMultiple).toInt(),
        height: (height * hMultiple).toInt());

    // Save the cropped image to a new file
    saveBytesToGallery(img.encodePng(croppedImage));
  }

  Future<void> saveBytesToGallery(Uint8List bytes) async {
    try {
      // Create a temporary file from the UInt8List
      final tempDir = await getTemporaryDirectory();
      final tempFile =
          File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png');

      await tempFile.writeAsBytes(bytes);

      // Save the temporary file to the image library
      final result = await ImageGallerySaver.saveFile(tempFile.path);
      log("Image saved to gallery: $result");

      // Increase image count
      increaseAndSaveCroppedImageCount();
      setPhotoCount(photoCount + 1);

      // Delete the temporary file
      await tempFile.delete();
    } catch (e) {
      log("Error saving image: $e");
    }
  }

  Future<void> increaseAndSaveCroppedImageCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'cropped_image_count', (prefs.getInt('cropped_image_count') ?? 0) + 1);
  }
}
