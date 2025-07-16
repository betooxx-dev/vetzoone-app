import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProfileImagePickerWidget extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final Function(File?) onImageSelected;
  final double size;
  final Color borderColor;
  final bool showEditIcon;

  const ProfileImagePickerWidget({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.onImageSelected,
    this.size = 120,
    this.borderColor = const Color(0xFF4CAF50),
    this.showEditIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: _buildImageContent(),
            ),
          ),
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: borderColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _selectImage(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    // Prioridad: archivo local > URL de red > placeholder
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error cargando imagen de perfil local: $error');
          return _buildDefaultAvatar();
        },
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: borderColor,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: borderColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: borderColor,
      ),
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
              Text(
                'Foto de perfil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: borderColor,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.camera_alt, color: borderColor),
                title: const Text('Tomar foto'),
                onTap: () async {
                  final file = await _pickFromCamera(picker);
                  Navigator.pop(context, file);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: borderColor),
                title: const Text('Seleccionar de galería'),
                onTap: () async {
                  final file = await _pickFromGallery(picker);
                  Navigator.pop(context, file);
                },
              ),
              if (imageFile != null || (imageUrl != null && imageUrl!.isNotEmpty))
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Eliminar foto', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context, File(''));
                  },
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (selectedImage != null) {
      // Si el path está vacío, significa que se quiere eliminar la imagen
      if (selectedImage.path.isEmpty) {
        onImageSelected(null);
      } else {
        print('📸 Profile image selected: ${selectedImage.path}');
        onImageSelected(selectedImage);
      }
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
      final fileName = 'profile_image_$timestamp$extension';
      final newPath = path.join(imagesDir.path, fileName);

      // Copiar archivo
      final newFile = await tempFile.copy(newPath);
      
      print('📁 Imagen de perfil copiada a directorio permanente: ${newFile.path}');
      print('📏 Tamaño del archivo: ${await newFile.length()} bytes');
      
      return newFile;
    } catch (e) {
      print('❌ Error copiando archivo a directorio permanente: $e');
      return tempFile; // Retornar archivo original como fallback
    }
  }
} 