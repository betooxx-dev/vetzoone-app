import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/injection/injection.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/storage/shared_preferences_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('🔐 Iniciando proceso de login...');
        
        // Ejecutar login (esto ya limpia datos previos y pre-carga datos del veterinario)
        final loginUseCase = sl<LoginUseCase>();
        await loginUseCase.call(
          _emailController.text.trim(),
          _passwordController.text,
        );

        print('✅ Login completado, verificando datos cargados...');

        if (mounted) {
          final userRole = await SharedPreferencesHelper.getUserRole();
          print('👤 Rol del usuario: $userRole');
          
          // Verificar que los datos estén realmente cargados
          if (userRole == 'VETERINARIAN') {
            final hasVetProfile = await SharedPreferencesHelper.hasVetProfile();
            print('🩺 ¿Tiene perfil de veterinario?: $hasVetProfile');
          }
          
          // Navegar según el rol
          if (userRole == 'PET_OWNER') {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (userRole == 'VETERINARIAN') {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
          
          print('🎯 Navegación completada exitosamente');
        }
      } catch (e) {
        print('❌ Error durante el login: $e');
        if (mounted) {
          String errorMessage = 'Error al iniciar sesión';
          if (e is ServerException) {
            errorMessage = e.message;
          } else if (e is NetworkException) {
            errorMessage = 'Error de conexión. Verifica tu internet.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: const TextStyle(fontSize: 14),
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 6), // Más tiempo para leer el mensaje completo
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                    const SizedBox(height: AppSizes.spaceXXL),
                    Container(
                      width: 140,
                      height: 140,
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
                    const Text(
                      'Bienvenido de vuelta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnDark,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceS),
                    const Text(
                      'Inicia sesión en tu cuenta',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textOnDark,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceXXL),
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
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Correo electrónico',
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: AppColors.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusM,
                                  ),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusM,
                                  ),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusM,
                                  ),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusM,
                                  ),
                                  borderSide: const BorderSide(
                                    color: AppColors.error,
                                    width: 2,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusM,
                                  ),
                                  borderSide: const BorderSide(
                                    color: AppColors.error,
                                    width: 2,
                                  ),
                                ),
                                errorStyle: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.error,
                                  height: 1.3,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingM,
                                  vertical: AppSizes.paddingM,
                                ),
                              ),
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
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppColors.primary,
                                ),
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
                                    color: AppColors.primary,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusM,
                                  ),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusM,
                                  ),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusM,
                                  ),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusM,
                                  ),
                                  borderSide: const BorderSide(
                                    color: AppColors.error,
                                    width: 2,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusM,
                                  ),
                                  borderSide: const BorderSide(
                                    color: AppColors.error,
                                    width: 2,
                                  ),
                                ),
                                errorStyle: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.error,
                                  height: 1.2,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingM,
                                  vertical: AppSizes.paddingM,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'La contraseña es obligatoria';
                                }

                                List<String> errors = [];

                                if (value.length < 9) {
                                  errors.add('• Mínimo 9 caracteres');
                                }
                                if (value.length > 20) {
                                  errors.add('• Máximo 20 caracteres');
                                }
                                if (!RegExp(r'[a-z]').hasMatch(value)) {
                                  errors.add('• Al menos una letra minúscula');
                                }
                                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                  errors.add('• Al menos una letra mayúscula');
                                }
                                if (!RegExp(r'[0-9]').hasMatch(value)) {
                                  errors.add('• Al menos un número');
                                }
                                if (!RegExp(
                                  r'[!@#$%^&*(),.?":{}|<>]',
                                ).hasMatch(value)) {
                                  errors.add('• Al menos un símbolo especial');
                                }

                                if (errors.isNotEmpty) {
                                  return 'La contraseña debe cumplir:\n${errors.join('\n')}';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.spaceXL),
                            SizedBox(
                              width: double.infinity,
                              height: AppSizes.buttonHeight,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusM,
                                    ),
                                  ),
                                  elevation: 8,
                                  shadowColor: AppColors.secondary.withOpacity(
                                    0.3,
                                  ),
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
                                          'Iniciar Sesión',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.spaceM),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceXL),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿No tienes cuenta? ',
                          style: TextStyle(color: AppColors.textOnDark),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            'Regístrate',
                            style: TextStyle(
                              color: AppColors.secondary,
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
        Positioned(
          bottom: -30,
          left: -40,
          child: Container(
            width: AppSizes.decorativeShapeS,
            height: AppSizes.decorativeShapeL,
            decoration: BoxDecoration(
              color: AppColors.yellowOverlay,
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            ),
          ),
        ),
      ],
    );
  }
}
