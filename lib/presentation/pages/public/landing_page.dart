import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Stack(
          children: [
            // Formas decorativas de fondo
            _buildDecorativeShapes(screenWidth, screenHeight),

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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(height: AppSizes.spaceXXL),

                        // Círculo principal con imagen
                        _buildMainImageCircle(),

                        const SizedBox(height: AppSizes.spaceXL),

                        // Título principal
                        const Text(
                          'Conectamos veterinarios con\ndueños de mascotas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textOnDark,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: AppSizes.spaceXXL),

                        // Tarjetas de características
                        Column(
                          children: [
                            _buildFeatureCard(
                              icon: Icons.calendar_today,
                              iconColor: AppColors.white,
                              backgroundColor: AppColors.secondary,
                              title: 'Agenda Citas',
                              subtitle:
                                  'Programa consultas\nveterinarias fácilmente',
                            ),

                            const SizedBox(height: AppSizes.spaceL),

                            _buildFeatureCard(
                              icon: Icons.description,
                              iconColor: AppColors.white,
                              backgroundColor: AppColors.accent,
                              title: 'Expediente Digital',
                              subtitle:
                                  'Historial médico completo de\ntu mascota',
                            ),

                            const SizedBox(height: AppSizes.spaceL),

                            _buildFeatureCard(
                              icon: Icons.notifications,
                              iconColor: AppColors.white,
                              backgroundColor: AppColors.orange,
                              title: 'Recordatorios',
                              subtitle: 'Nunca olvides vacunas o\ntratamientos',
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSizes.spaceXXL),

                        // Botones de acción
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: AppSizes.buttonHeight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: AppColors.primary,
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
                                child: const Text(
                                  'Comenzar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: AppSizes.spaceM),

                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              child: const Text(
                                '¿Ya tienes cuenta? Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textOnDark,
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

  Widget _buildDecorativeShapes(double screenWidth, double screenHeight) {
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

        // Forma amarilla media
        Positioned(
          top: screenHeight * 0.4,
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

        // Forma morada inferior derecha
        Positioned(
          bottom: -30,
          right: -50,
          child: Container(
            width: AppSizes.decorativeShapeL,
            height: AppSizes.decorativeShapeM,
            decoration: BoxDecoration(
              color: AppColors.purpleOverlay,
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainImageCircle() {
    return Container(
      width: AppSizes.mainCircleSize,
      height: AppSizes.mainCircleSize,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Image.asset(
            'assets/images/dog3.png',
            width: AppSizes.imageSize,
            height: AppSizes.imageSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: AppSizes.iconM),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceXS),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
