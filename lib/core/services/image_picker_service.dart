import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

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
          return File(image.path);
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
          return File(image.path);
        }
      } catch (e) {
        print('Error picking image from gallery: $e');
      }
    }
    
    return null;
  }
}