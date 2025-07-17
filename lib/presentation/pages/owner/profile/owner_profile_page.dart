import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../core/services/user_service.dart';
import '../../../../core/injection/injection.dart';
import '../../../../data/datasources/user/user_remote_data_source.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../widgets/common/profile_image_picker_widget.dart';

class OwnerProfilePage extends StatefulWidget {
  const OwnerProfilePage({super.key});

  @override
  State<OwnerProfilePage> createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  bool _isEditing = false;
  bool _isLoading = false;
  Map<String, dynamic> userData = {};
  File? _selectedImageFile;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await UserService.getCurrentUser();
    setState(() {
      userData = {
        'firstName': user['firstName'],
        'lastName': user['lastName'],
        'fullName': user['fullName'], // Para mostrar en el header
        'email': user['email'],
        'phone': user['phone'],
        'profileImage': user['profilePhoto'],
      };
    });
    _updateControllers();
  }

  void _updateControllers() {
    _firstNameController.text = userData['firstName'] ?? '';
    _lastNameController.text = userData['lastName'] ?? '';
    _phoneController.text = userData['phone'] ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (userData.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(
                _isEditing ? Icons.check : Icons.edit,
                color: const Color(0xFF0D9488),
              ),
              onPressed: _isEditing ? _saveProfile : _toggleEditing,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildPersonalInfoCard(),
            const SizedBox(height: 20),
            _buildOptionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_isEditing)
            ProfileImagePickerWidget(
              imageFile: _selectedImageFile,
              imageUrl: userData['profileImage'],
              onImageSelected: (file) {
                setState(() {
                  _selectedImageFile = file;
                });
              },
              size: 100,
            )
          else
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0D9488), width: 3),
              ),
              child: ClipOval(
                child: _selectedImageFile != null
                    ? Image.file(
                        _selectedImageFile!,
                        fit: BoxFit.cover,
                      )
                    : (userData['profileImage'] != null &&
                            userData['profileImage'].isNotEmpty)
                        ? Image.network(
                            userData['profileImage'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          )
                        : _buildDefaultAvatar(),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            userData['fullName'] ?? '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userData['email'] ?? '',
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),

        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F9FF),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 50, color: Color(0xFF0D9488)),
    );
  }



  Widget _buildPersonalInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Personal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoField(
            icon: Icons.person_outline,
            label: 'Nombre',
            controller: _firstNameController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            icon: Icons.person,
            label: 'Apellido',
            controller: _lastNameController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            icon: Icons.email_outlined,
            label: 'Correo electrónico',
            value: userData['email'],
            enabled: false,
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            icon: Icons.phone_outlined,
            label: 'Teléfono',
            controller: _phoneController,
            enabled: _isEditing,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    TextEditingController? controller,
    String? value,
    required bool enabled,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? value : null,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0D9488)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Opciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          _buildOptionItem(
            icon: Icons.logout,
            title: 'Cerrar sesión',
            onTap: _showLogoutDialog,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive ? Colors.red : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDestructive ? Colors.red : const Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFE5E7EB),
      margin: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await SharedPreferencesHelper.getUserId();
      if (userId == null) {
        throw Exception('No se encontró ID del usuario');
      }

      final userRemoteDataSource = sl<UserRemoteDataSource>();
      
      // Obtener nombre y apellido de los controladores
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      final userData = {
        'first_name': firstName,
        'last_name': lastName,
        'phone': _phoneController.text.trim(),
      };

      Map<String, dynamic> updatedUser;

      if (_selectedImageFile != null) {
        updatedUser = await userRemoteDataSource.updateUserWithFile(
          userId,
          userData,
          _selectedImageFile!,
        );
      } else {
        updatedUser = await userRemoteDataSource.updateUser(userId, userData);
      }

      // Actualizar datos locales
      setState(() {
        this.userData['firstName'] = updatedUser['first_name'];
        this.userData['lastName'] = updatedUser['last_name'];
        this.userData['fullName'] = '${updatedUser['first_name']} ${updatedUser['last_name']}';
        this.userData['phone'] = updatedUser['phone'];
        if (updatedUser['profile_photo'] != null) {
          this.userData['profileImage'] = updatedUser['profile_photo'];
        }
        _isEditing = false;
        _selectedImageFile = null;
      });

      // Actualizar controladores
      _updateControllers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
      }
    } catch (e) {
      print('❌ Error actualizando perfil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }





  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cerrar Sesión'),
            content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
    );
  }
}
