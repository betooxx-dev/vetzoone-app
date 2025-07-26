import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage(BuildContext context) async {
    return await showModalBottomSheet<File?>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Seleccionar imagen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFF4CAF50),
                ),
                title: const Text('Tomar foto'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _pickFromCamera();
                  Navigator.of(context).pop(file);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF4CAF50),
                ),
                title: const Text('Seleccionar de galería'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _pickFromGallery();
                  Navigator.of(context).pop(file);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  static Future<File?> _pickFromCamera() async {
    final cameraPermission = await Permission.camera.request();
    
    if (cameraPermission.isGranted) {
      try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 1024,
          maxHeight: 1024,
        );
        
        if (image != null) {
          // Copiar archivo temporal a directorio permanente
          final permanentFile = await _copyToPermanentDirectory(File(image.path));
          return permanentFile;
        }
      } catch (e) {
        print('Error picking image from camera: $e');
      }
    }
    
    return null;
  }

  static Future<File?> _pickFromGallery() async {
    final galleryPermission = await Permission.photos.request();
    
    if (galleryPermission.isGranted) {
      try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1024,
          maxHeight: 1024,
        );
        
        if (image != null) {
          // Copiar archivo temporal a directorio permanente
          final permanentFile = await _copyToPermanentDirectory(File(image.path));
          return permanentFile;
        }
      } catch (e) {
        print('Error picking image from gallery: $e');
      }
    }
    
    return null;
  }

  /// Copia el archivo temporal a un directorio permanente de la aplicación
  static Future<File?> _copyToPermanentDirectory(File tempFile) async {
    try {
      // Verificar que el archivo temporal existe
      if (!await tempFile.exists()) {
        print('❌ Archivo temporal no existe: ${tempFile.path}');
        return null;
      }

      // Obtener directorio de la aplicación
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'images'));
      
      // Crear directorio si no existe
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generar nombre único para el archivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(tempFile.path);
      final fileName = 'image_$timestamp$extension';
      final newPath = path.join(imagesDir.path, fileName);

      // Copiar archivo
      final newFile = await tempFile.copy(newPath);
      
      print('📁 Imagen copiada a directorio permanente: ${newFile.path}');
      print('📏 Tamaño del archivo: ${await newFile.length()} bytes');
      
      return newFile;
    } catch (e) {
      print('❌ Error copiando archivo a directorio permanente: $e');
      return tempFile; // Retornar archivo original como fallback
    }
  }

  /// Limpia archivos de imagen antiguos para liberar espacio
  static Future<void> cleanOldImages() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'images'));
      
      if (await imagesDir.exists()) {
        final now = DateTime.now();
        final files = await imagesDir.list().toList();
        
        for (final file in files) {
          if (file is File) {
            final stat = await file.stat();
            final age = now.difference(stat.modified);
            
            // Eliminar archivos mayores a 7 días
            if (age.inDays > 7) {
              await file.delete();
              print('🗑️ Archivo antiguo eliminado: ${file.path}');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error limpiando archivos antiguos: $e');
    }
  }
}