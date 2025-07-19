import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

class RegisterTypeSelectionPage extends StatefulWidget {
  const RegisterTypeSelectionPage({super.key});

  @override
  State<RegisterTypeSelectionPage> createState() =>
      _RegisterTypeSelectionPageState();
}

class _RegisterTypeSelectionPageState extends State<RegisterTypeSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              AppColors.backgroundDarkSecondary,
              AppColors.backgroundDarkCard,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(children: [_buildHeader(), _buildContent()]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDarkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gray700, width: 1),
                  boxShadow: AppColors.cardShadow,
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.textSecondaryDark,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/LogoV.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Título principal
            const Text(
              'Únete a VetZoone',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Subtítulo
            const Text(
              'Selecciona el tipo de cuenta que mejor\nse adapte a ti',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textTertiaryDark,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 50),

            // Card Dueño de Mascota
            _buildAccountTypeCard(
              context: context,
              icon: Icons.pets,
              title: 'Dueño de\nMascota',
              subtitle: 'Agenda citas y lleva el control\nmédico de tu mascota',
              gradient: [AppColors.vetSecondary, AppColors.secondary],
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, '/register/owner');
              },
            ),

            const SizedBox(height: 20),

            // Card Veterinario
            _buildAccountTypeCard(
              context: context,
              icon: Icons.medical_services,
              title: 'Veterinario',
              subtitle: 'Gestiona tu consulta y\natiende a más pacientes',
              gradient: [AppColors.vetPrimary, AppColors.primary],
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, '/register/veterinarian');
              },
            ),

            const SizedBox(height: 40),

            // Link de inicio de sesión
            TextButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.pushNamed(context, '/login');
              },
              child: const Text(
                '¿Ya tienes cuenta? Inicia sesión',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondaryDark,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gray700, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícono con gradiente
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.white, size: 32),
            ),

            const SizedBox(width: 20),

            // Contenido de texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textTertiaryDark,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Flecha
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gray800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondaryDark,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
