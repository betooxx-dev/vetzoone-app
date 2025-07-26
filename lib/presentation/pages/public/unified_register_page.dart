import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/injection/injection.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../core/errors/exceptions.dart';

class UnifiedRegisterPage extends StatefulWidget {
  final String userRole; // 'PET_OWNER' or 'VETERINARIAN'

  const UnifiedRegisterPage({super.key, required this.userRole});

  @override
  State<UnifiedRegisterPage> createState() => _UnifiedRegisterPageState();
}

class _UnifiedRegisterPageState extends State<UnifiedRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _acceptTerms = false;

  Color get _primaryColor =>
      widget.userRole == 'VETERINARIAN'
          ? AppColors.accent
          : AppColors.secondary;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      setState(() {
        _isLoading = true;
      });

      try {
        final registerUseCase = sl<RegisterUseCase>();

        Map<String, dynamic> userData = {
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'password': _passwordController.text,
          'role': widget.userRole,
        };

        await registerUseCase.call(userData);

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => route.settings.name == '/landing',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cuenta creada exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Error al crear la cuenta';
          if (e is ServerException) {
            errorMessage = e.message;
          } else if (e is NetworkException) {
            errorMessage = 'Error de conexión. Verifica tu internet.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }

      setState(() {
        _isLoading = false;
      });
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Stack(
          children: [
            _buildDecorativeShapes(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSizes.spaceL),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(AppSizes.paddingM),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusM,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceXL),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusRound,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        child: Image.asset(
                          'assets/images/LogoV.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceXL),
                    Text(
                      widget.userRole == 'VETERINARIAN'
                          ? 'Crear cuenta profesional'
                          : 'Crear cuenta de dueño',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnDark,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceS),
                    Text(
                      widget.userRole == 'VETERINARIAN'
                          ? 'Regístrate como veterinario'
                          : 'Regístrate para cuidar mejor a tu mascota',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textOnDark,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceXL),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _firstNameController,
                              label: 'Nombre',
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El nombre es obligatorio';
                                }
                                if (value.trim().length < 2) {
                                  return 'El nombre debe tener al menos 2 caracteres';
                                }
                                if (value.trim().length > 50) {
                                  return 'El nombre no puede exceder 50 caracteres';
                                }
                                if (RegExp(r'[0-9]').hasMatch(value)) {
                                  return 'El nombre no puede contener números';
                                }
                                if (RegExp(
                                  r'[!@#$%^&*(),.?":{}|<>]',
                                ).hasMatch(value)) {
                                  return 'El nombre no puede contener caracteres especiales';
                                }
                                if (RegExp(r'^\s|\s$').hasMatch(value)) {
                                  return 'El nombre no puede empezar o terminar con espacios';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.spaceL),
                            _buildTextField(
                              controller: _lastNameController,
                              label: 'Apellido',
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El apellido es obligatorio';
                                }
                                if (value.trim().length < 2) {
                                  return 'El apellido debe tener al menos 2 caracteres';
                                }
                                if (value.trim().length > 50) {
                                  return 'El apellido no puede exceder 50 caracteres';
                                }
                                if (RegExp(r'[0-9]').hasMatch(value)) {
                                  return 'El apellido no puede contener números';
                                }
                                if (RegExp(
                                  r'[!@#$%^&*(),.?":{}|<>]',
                                ).hasMatch(value)) {
                                  return 'El apellido no puede contener caracteres especiales';
                                }
                                if (RegExp(r'^\s|\s$').hasMatch(value)) {
                                  return 'El apellido no puede empezar o terminar con espacios';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.spaceL),
                            _buildTextField(
                              controller: _emailController,
                              label: 'Correo electrónico',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El correo electrónico es obligatorio';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value.trim())) {
                                  return 'Ingresa un correo electrónico válido';
                                }
                                if (value.trim().length > 254) {
                                  return 'El correo electrónico es demasiado largo';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.spaceL),
                            _buildTextField(
                              controller: _phoneController,
                              label: 'Teléfono',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El número de teléfono es obligatorio';
                                }
                                final cleanedValue = value.replaceAll(
                                  RegExp(r'[\s\-\(\)\+]'),
                                  '',
                                );
                                if (cleanedValue.length < 10) {
                                  return 'El teléfono debe tener al menos 10 dígitos';
                                }
                                if (cleanedValue.length > 13) {
                                  return 'El teléfono no puede exceder 13 dígitos';
                                }
                                if (!RegExp(
                                  r'^[0-9+\s\-\(\)]+$',
                                ).hasMatch(value)) {
                                  return 'El teléfono solo puede contener números, +, -, ( ), y espacios';
                                }
                                if (!RegExp(
                                  r'^(\+52)?[0-9\s\-\(\)]{10,13}$',
                                ).hasMatch(value.trim())) {
                                  return 'Ingresa un número de teléfono mexicano válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.spaceL),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Contraseña',
                              icon: Icons.lock_outline,
                              obscureText: !_isPasswordVisible,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _primaryColor,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'La contraseña es obligatoria';
                                }
                                if (value.length < 9) {
                                  return 'La contraseña debe tener al menos 9 caracteres';
                                }
                                if (value.length > 20) {
                                  return 'La contraseña no puede exceder 20 caracteres';
                                }
                                if (!RegExp(r'[a-z]').hasMatch(value)) {
                                  return 'La contraseña debe contener al menos una letra minúscula';
                                }
                                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                  return 'La contraseña debe contener al menos una letra mayúscula';
                                }
                                if (!RegExp(r'[0-9]').hasMatch(value)) {
                                  return 'La contraseña debe contener al menos un número';
                                }
                                if (!RegExp(
                                  r'[!@#$%^&*(),.?":{}|<>]',
                                ).hasMatch(value)) {
                                  return 'La contraseña debe contener al menos un símbolo especial';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.spaceL),
                            _buildTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirmar contraseña',
                              icon: Icons.lock_outline,
                              obscureText: !_isConfirmPasswordVisible,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _primaryColor,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Debes confirmar tu contraseña';
                                }
                                if (value != _passwordController.text) {
                                  return 'Las contraseñas no coinciden';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.spaceL),
                            Row(
                              children: [
                                Checkbox(
                                  value: _acceptTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _acceptTerms = value ?? false;
                                    });
                                  },
                                  activeColor: _primaryColor,
                                ),
                                const Expanded(
                                  child: Text(
                                    'Acepto los términos y condiciones',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.spaceXL),
                            SizedBox(
                              width: double.infinity,
                              height: AppSizes.buttonHeight,
                              child: ElevatedButton(
                                onPressed:
                                    (_isLoading || !_acceptTerms)
                                        ? null
                                        : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryColor,
                                  foregroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusM,
                                    ),
                                  ),
                                  elevation: 8,
                                  shadowColor: _primaryColor.withOpacity(0.3),
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: AppColors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text(
                                          'Crear Cuenta',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceXL),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Ya tienes cuenta? ',
                          style: TextStyle(color: AppColors.textOnDark),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              color: _primaryColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeShapes() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -80,
          child: Container(
            width: AppSizes.decorativeShapeXL,
            height: AppSizes.decorativeShapeL,
            decoration: BoxDecoration(
              color: AppColors.purpleOverlay,
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: -60,
          child: Container(
            width: AppSizes.decorativeShapeM,
            height: AppSizes.decorativeShapeM,
            decoration: BoxDecoration(
              color: AppColors.orangeOverlay,
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _primaryColor),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        errorStyle: const TextStyle(
          fontSize: 10,
          color: AppColors.error,
          height: 1.4,
        ),
        errorMaxLines: 10,
      ),
      validator: validator,
    );
  }
}
