import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class VeterinarianProfilePage extends StatefulWidget {
  const VeterinarianProfilePage({super.key});

  @override
  State<VeterinarianProfilePage> createState() =>
      _VeterinarianProfilePageState();
}

class _VeterinarianProfilePageState extends State<VeterinarianProfilePage> {
  late Map<String, dynamic> veterinarian;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    veterinarian =
        args is Map<String, dynamic>
            ? args
            : {
              'id': 'default',
              'name': 'Veterinario',
              'specialty': 'Medicina General',
              'clinic': 'Clínica Veterinaria',
              'experience': '5 años',
              'consultationFee': 50,
              'rating': 4.5,
              'description': 'Profesional dedicado al cuidado de mascotas',
              'phone': '+52 961 123 4567',
              'email': 'vet@example.com',
              'location': 'Tuxtla Gutiérrez, Chiapas',
            };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Fondo decorativo
          _buildDecorativeBackground(),

          // Contenido principal
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildVeterinarianInfo(),
                    _buildContactInfo(),
                    _buildScheduleInfo(),
                    _buildServicesInfo(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildDecorativeBackground() {
    return Stack(
      children: [
        // Fondo base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.backgroundLight, AppColors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Formas decorativas
        Positioned(
          top: -50,
          right: -30,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(75),
            ),
          ),
        ),

        Positioned(
          top: 100,
          left: -40,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),

        Positioned(
          bottom: 200,
          right: -20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: Container(
        margin: const EdgeInsets.all(AppSizes.paddingS),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Hero(
                tag: 'vet-${veterinarian['id'] ?? 'default'}',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceL),
              Text(
                veterinarian['name'] ?? 'Veterinario',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSizes.spaceXS),
              Text(
                veterinarian['specialty'] ?? 'Especialidad',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVeterinarianInfo() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem(
                'Experiencia',
                veterinarian['experience'] ?? '0 años',
                Icons.timeline_outlined,
                AppColors.secondary,
              ),
              _buildStatItem(
                'Consulta',
                '\$${veterinarian['consultationFee'] ?? 0}',
                Icons.attach_money_outlined,
                AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          Text(
            veterinarian['description'] ?? 'Sin descripción disponible',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información de Contacto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spaceL),
          _buildContactItem(
            Icons.business_outlined,
            'Clínica',
            veterinarian['clinic'] ?? 'No especificada',
          ),
          _buildContactItem(
            Icons.location_on_outlined,
            'Dirección',
            veterinarian['location'] ?? 'No especificada',
          ),
          _buildContactItem(
            Icons.phone_outlined,
            'Teléfono',
            veterinarian['phone'] ?? 'No especificado',
          ),
          _buildContactItem(
            Icons.email_outlined,
            'Email',
            veterinarian['email'] ?? 'No especificado',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleInfo() {
    final scheduleData = [
      {'day': 'Lunes', 'hours': '9:00 AM - 6:00 PM'},
      {'day': 'Martes', 'hours': '9:00 AM - 6:00 PM'},
      {'day': 'Miércoles', 'hours': '9:00 AM - 6:00 PM'},
      {'day': 'Jueves', 'hours': '9:00 AM - 6:00 PM'},
      {'day': 'Viernes', 'hours': '9:00 AM - 6:00 PM'},
      {'day': 'Sábado', 'hours': '9:00 AM - 2:00 PM'},
      {'day': 'Domingo', 'hours': 'Cerrado'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingL,
        AppSizes.paddingL,
        0,
      ),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                color: AppColors.secondary,
                size: 24,
              ),
              const SizedBox(width: AppSizes.spaceS),
              const Text(
                'Horarios de Atención',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceL),
          ...scheduleData.map(
            (schedule) =>
                _buildScheduleItem(schedule['day']!, schedule['hours']!),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String day, String hours) {
    final isClosed = hours == 'Cerrado';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: 14,
              color: isClosed ? AppColors.error : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesInfo() {
    final services = [
      'Consulta General',
      'Vacunación',
      'Cirugía',
      'Desparasitación',
      'Odontología Veterinaria',
      'Emergencias',
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingL,
        AppSizes.paddingL,
        0,
      ),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: AppSizes.spaceS),
              const Text(
                'Servicios Disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceL),
          Wrap(
            spacing: AppSizes.spaceS,
            runSpacing: AppSizes.spaceS,
            children:
                services
                    .map(
                      (service) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical: AppSizes.paddingS,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        ),
                        child: Text(
                          service,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _scheduleAppointment(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.calendar_today_rounded, color: AppColors.white),
        label: const Text(
          'Agendar Cita',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  void _scheduleAppointment() {
    Navigator.pushNamed(
      context,
      '/schedule-appointment',
      arguments: veterinarian,
    );
  }
}
