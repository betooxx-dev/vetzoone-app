import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImagePickerWidget extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final Function(File?) onImageSelected;
  final double size;
  final bool isRequired;

  const ImagePickerWidget({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.onImageSelected,
    this.size = 120,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Foto de la mascota',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF212121),
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: () => _selectImage(context),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: _buildImageContent(),
            ),
          ),
        ),
        if (imageFile != null || (imageUrl != null && imageUrl!.isNotEmpty))
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextButton.icon(
                onPressed: () => onImageSelected(null),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 18,
                ),
                label: const Text(
                  'Eliminar imagen',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageContent() {
    // Prioridad: archivo local > URL de red > placeholder
    if (imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          imageFile!,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Error cargando imagen local: $error');
            return _buildPlaceholder();
          },
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          width: size,
          height: size,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                color: const Color(0xFF4CAF50),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(
          'Agregar foto',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _selectImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    final selectedImage = await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
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
                leading: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
                title: const Text('Tomar foto'),
                onTap: () async {
                  final file = await _pickFromCamera(picker);
                  Navigator.pop(context, file);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF4CAF50),
                ),
                title: const Text('Seleccionar de galería'),
                onTap: () async {
                  final file = await _pickFromGallery(picker);
                  Navigator.pop(context, file);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (selectedImage != null) {
      print('📸 Image selected: ${selectedImage.path}');
      onImageSelected(selectedImage);
    }
  }

  Future<File?> _pickFromCamera(ImagePicker picker) async {
    final cameraPermission = await Permission.camera.request();

    if (cameraPermission.isGranted) {
      try {
        final XFile? image = await picker.pickImage(
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

  Future<File?> _pickFromGallery(ImagePicker picker) async {
    final galleryPermission = await Permission.photos.request();

    if (galleryPermission.isGranted) {
      try {
        final XFile? image = await picker.pickImage(
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
  Future<File?> _copyToPermanentDirectory(File tempFile) async {
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
      final fileName = 'pet_image_$timestamp$extension';
      final newPath = path.join(imagesDir.path, fileName);

      // Copiar archivo
      final newFile = await tempFile.copy(newPath);
      
      print('📁 Imagen de mascota copiada a directorio permanente: ${newFile.path}');
      print('📏 Tamaño del archivo: ${await newFile.length()} bytes');
      
      return newFile;
    } catch (e) {
      print('❌ Error copiando archivo a directorio permanente: $e');
      return tempFile; // Retornar archivo original como fallback
    }
  }
}
