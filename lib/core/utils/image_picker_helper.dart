import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Mengambil foto dari Kamera atau Galeri
  static Future<File?> pickImage({required ImageSource source}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        // --- BEST PRACTICE OPTIMASI ---
        maxWidth: 1080, // Batasi lebar maksimal (Standar UI Mobile)
        maxHeight: 1080, // Batasi tinggi maksimal
        imageQuality:
            70, // Kompres kualitas ke 70% (Ukuran drop drastis, visual tetap tajam)
      );

      if (pickedFile != null) {
        return File(
          pickedFile.path,
        ); // Konversi XFile menjadi File standard dart:io
      }

      return null; // User membatalkan pemilihan foto
    } catch (e) {
      debugPrint("Error saat mengambil gambar: $e");
      return null;
    }
  }
}
