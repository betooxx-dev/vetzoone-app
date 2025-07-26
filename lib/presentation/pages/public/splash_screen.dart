import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _backgroundRotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateToNextScreen();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    _backgroundRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    _logoController.forward();
    _backgroundController.repeat();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/landing');
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Stack(
          children: [
            // Formas decorativas animadas
            _buildAnimatedBackground(),

            // Contenido principal
            Center(
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo en círculo blanco
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusRound,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.2),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                                BoxShadow(
                                  color: AppColors.secondary.withOpacity(0.4),
                                  blurRadius: 25,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSizes.paddingL),
                              child: Image.asset(
                                'assets/images/LogoV.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSizes.spaceXXL),

                          // Texto descriptivo
                          const Text(
                            'Cuidando a tu mascota',
                            style: TextStyle(
                              fontSize: 20,
                              color: AppColors.textOnDark,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: AppSizes.spaceXXL),

                          // Indicador de carga
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusRound,
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(AppSizes.paddingM),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Stack(
          children: [
            // Forma morada rotativa
            Positioned(
              top: 100 + (50 * _backgroundRotationAnimation.value),
              left: -80 + (20 * _backgroundRotationAnimation.value),
              child: Transform.rotate(
                angle: _backgroundRotationAnimation.value * 2 * 3.14159,
                child: Container(
                  width: AppSizes.decorativeShapeXL,
                  height: AppSizes.decorativeShapeL,
                  decoration: BoxDecoration(
                    color: AppColors.purpleOverlay,
                    borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                  ),
                ),
              ),
            ),

            // Forma naranja flotante
            Positioned(
              top: 200 - (30 * _backgroundRotationAnimation.value),
              right: -60 + (40 * _backgroundRotationAnimation.value),
              child: Container(
                width: AppSizes.decorativeShapeM,
                height: AppSizes.decorativeShapeM,
                decoration: BoxDecoration(
                  color: AppColors.orangeOverlay,
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                ),
              ),
            ),

            // Forma amarilla pulsante
            Positioned(
              bottom: 150 + (20 * _backgroundRotationAnimation.value),
              left: -40,
              child: Transform.scale(
                scale: 1.0 + (0.2 * _backgroundRotationAnimation.value),
                child: Container(
                  width: AppSizes.decorativeShapeS,
                  height: AppSizes.decorativeShapeL,
                  decoration: BoxDecoration(
                    color: AppColors.yellowOverlay,
                    borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                  ),
                ),
              ),
            ),

            // Forma adicional inferior derecha
            Positioned(
              bottom: 80 - (25 * _backgroundRotationAnimation.value),
              right: -70,
              child: Transform.rotate(
                angle: -_backgroundRotationAnimation.value * 1.5 * 3.14159,
                child: Container(
                  width: AppSizes.decorativeShapeM,
                  height: AppSizes.decorativeShapeS,
                  decoration: BoxDecoration(
                    color: AppColors.purpleOverlay,
                    borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
