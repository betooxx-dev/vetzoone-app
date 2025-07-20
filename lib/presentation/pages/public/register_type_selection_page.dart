import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class RegisterTypeSelectionPage extends StatelessWidget {
  const RegisterTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Stack(
          children: [
            // Formas decorativas de fondo
            _buildDecorativeShapes(),

            // Contenido principal
            SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        screenHeight -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingL,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSizes.spaceL),

                        // Botón de retroceso
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(
                                  AppSizes.paddingM,
                                ),
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

                        const SizedBox(height: AppSizes.spaceXXL),

                        // Logo en círculo blanco
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

                        const SizedBox(height: AppSizes.spaceXXL),

                        // Título
                        const Text(
                          'Únete a VetZoone',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textOnDark,
                          ),
                        ),

                        const SizedBox(height: AppSizes.spaceM),

                        const Text(
                          'Selecciona el tipo de cuenta que mejor\nse adapte a ti',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textOnDark,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: AppSizes.spaceXXL * 1.5),

                        // Tarjetas de tipo de cuenta
                        _buildAccountTypeCard(
                          context: context,
                          icon: Icons.pets,
                          iconColor: AppColors.white,
                          backgroundColor: AppColors.secondary,
                          title: 'Dueño de\nMascota',
                          subtitle:
                              'Agenda citas y\nlleva el control\nmédico de tu\nmascota',
                          onTap: () {
                            Navigator.pushNamed(context, '/register/owner');
                          },
                        ),

                        const SizedBox(height: AppSizes.spaceL),

                        _buildAccountTypeCard(
                          context: context,
                          icon: Icons.medical_services,
                          iconColor: AppColors.white,
                          backgroundColor: AppColors.accent,
                          title: 'Veterinario',
                          subtitle:
                              'Gestiona tu consulta y\natiende a más pacientes',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/register/veterinarian',
                            );
                          },
                        ),

                        const SizedBox(height: AppSizes.spaceXL),

                        // Enlace a login
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
                              child: const Text(
                                'Iniciar sesión',
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
        // Forma morada superior izquierda
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

        // Forma naranja superior derecha
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

        // Forma amarilla inferior izquierda
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

  Widget _buildAccountTypeCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: AppSizes.iconL),
            ),
            const SizedBox(width: AppSizes.spaceL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceS),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSizes.spaceS),
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: backgroundColor,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
