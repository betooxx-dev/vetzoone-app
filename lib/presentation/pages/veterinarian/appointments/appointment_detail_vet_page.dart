import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../widgets/cards/appointment_card.dart';
import '../../../../core/widgets/confirmation_modal.dart';
import '../../../../core/widgets/date_time_selector.dart';

class AppointmentDetailVetPage extends StatefulWidget {
  const AppointmentDetailVetPage({super.key});

  @override
  State<AppointmentDetailVetPage> createState() =>
      _AppointmentDetailVetPageState();
}

class _AppointmentDetailVetPageState extends State<AppointmentDetailVetPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic> appointment = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _initializeDefaultData();
  }

  void _initializeDefaultData() {
    final defaultAppointment = {
      'id': '1',
      'petName': 'Max',
      'ownerName': 'Juan Pérez',
      'ownerPhone': '+52 961 123 4567',
      'ownerEmail': 'juan.perez@email.com',
      'appointmentType': 'Control de rutina, revisar vacunas pendientes',
      'dateTime': DateTime.now(),
      'status': AppointmentStatus.confirmed,
      'notes': 'Control de rutina, revisar vacunas pendientes',
      'petDetails': {
        'species': 'Perro',
        'breed': 'Labrador Retriever',
        'age': '3 años',
        'weight': '25 kg',
        'color': 'Dorado',
        'lastVisit': '15 Oct 2024',
      },
      'medicalHistory': [
        {
          'date': '15 Oct 2024',
          'type': 'Vacunación',
          'notes': 'Vacuna múltiple aplicada',
        },
        {
          'date': '20 Sep 2024',
          'type': 'Consulta',
          'notes': 'Revisión general, excelente estado',
        },
      ],
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map<String, dynamic>) {
        setState(() {
          appointment = {...defaultAppointment, ...arguments};
        });
      } else {
        setState(() {
          appointment = defaultAppointment;
        });
      }
    });

    appointment = defaultAppointment;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          _buildBackgroundShapes(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildModernAppBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSizes.paddingL),
                        child: Column(
                          children: [
                            _buildQuickActions(),
                            const SizedBox(height: AppSizes.spaceL),
                            _buildAppointmentCard(),
                            const SizedBox(height: AppSizes.spaceL),
                            _buildMedicalActionsSection(),
                            const SizedBox(height: AppSizes.spaceL),
                            _buildDetailsSections(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildBackgroundShapes() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: AppSizes.decorativeShapeXL,
            height: AppSizes.decorativeShapeXL,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(125),
            ),
          ),
        ),
        Positioned(
          top: 200,
          left: -80,
          child: Container(
            width: AppSizes.decorativeShapeL,
            height: AppSizes.decorativeShapeL,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(90),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -60,
          child: Container(
            width: AppSizes.decorativeShapeM,
            height: AppSizes.decorativeShapeM,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(60),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernAppBar() {
    final status =
        appointment['status'] as AppointmentStatus? ??
        AppointmentStatus.scheduled;
    final colors = _getStatusColors(status);

    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors['primary']!, colors['secondary']!],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: colors['primary']!.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalle de Cita',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceXS),
                Text(
                  _getStatusText(status),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.white),
              onSelected: _handleMenuAction,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'reschedule',
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSizes.spaceM),
                          const Text('Reprogramar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, size: 20, color: AppColors.error),
                          const SizedBox(width: AppSizes.spaceM),
                          const Text('Cancelar cita'),
                        ],
                      ),
                    ),
                  ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final status =
        appointment['status'] as AppointmentStatus? ??
        AppointmentStatus.scheduled;

    return Container(
      child: Row(
        children: [
          if (status == AppointmentStatus.confirmed) ...[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _startConsultation,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Iniciar Consulta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _rescheduleAppointment,
                  icon: const Icon(Icons.schedule_rounded),
                  label: const Text('Reprogramar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                  ),
                ),
              ),
            ),
          ] else if (status == AppointmentStatus.inProgress) ...[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _completeConsultation,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Finalizar Consulta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                  ),
                ),
              ),
            ),
          ] else if (status == AppointmentStatus.scheduled) ...[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _rescheduleAppointment,
                  icon: const Icon(Icons.schedule_rounded),
                  label: const Text('Reprogramar Cita'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppointmentCard() {
    return AppointmentCard(
      petName: appointment['petName'] ?? '',
      veterinarianName: 'Dr. María González',
      appointmentType: appointment['appointmentType'] ?? '',
      dateTime: appointment['dateTime'] ?? DateTime.now(),
      status: appointment['status'] ?? AppointmentStatus.scheduled,
      notes: appointment['notes'],
      isOwnerView: false,
      ownerName: appointment['ownerName'],
      onTap: null,
    );
  }

  Widget _buildMedicalActionsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(
                  Icons.medical_services,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              const Text(
                'Acciones Médicas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceL),
          Row(
            children: [
              Expanded(
                child: _buildMedicalActionButton(
                  icon: Icons.note_add_rounded,
                  title: 'Crear Registro Médico',
                  subtitle: 'Nuevo expediente',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pushNamed(context, '/create-medical-record');
                  },
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              Expanded(
                child: _buildMedicalActionButton(
                  icon: Icons.medication_rounded,
                  title: 'Prescribir Medicamentos',
                  subtitle: 'Nueva receta',
                  color: AppColors.secondary,
                  onTap: () {
                    Navigator.pushNamed(context, '/prescribe-treatment');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceM),
          _buildMedicalActionButton(
            icon: Icons.vaccines_rounded,
            title: 'Registrar Vacuna',
            subtitle: 'Aplicar nueva vacuna',
            color: AppColors.accent,
            onTap: () {
              Navigator.pushNamed(context, '/register-vaccination');
            },
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child:
            isFullWidth
                ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingS),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: AppSizes.spaceM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: AppSizes.spaceXS),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: color, size: 16),
                  ],
                )
                : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(height: AppSizes.spaceM),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.spaceXS),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildDetailsSections() {
    return Column(
      children: [
        _buildPatientInfoSection(),
        const SizedBox(height: AppSizes.spaceL),
        _buildOwnerInfoSection(),
        const SizedBox(height: AppSizes.spaceL),
        _buildMedicalHistorySection(),
        if (appointment['notes'] != null &&
            appointment['notes']!.isNotEmpty) ...[
          const SizedBox(height: AppSizes.spaceL),
          _buildNotesSection(),
        ],
      ],
    );
  }

  Widget _buildPatientInfoSection() {
    final petDetails = appointment['petDetails'] as Map<String, dynamic>? ?? {};

    return _buildDetailCard(
      title: 'Información del Paciente',
      icon: Icons.pets_rounded,
      iconColor: AppColors.primary,
      children: [
        _buildDetailRow('Nombre', appointment['petName'] ?? ''),
        if (petDetails['species'] != null)
          _buildDetailRow('Especie', petDetails['species']),
        if (petDetails['breed'] != null)
          _buildDetailRow('Raza', petDetails['breed']),
        if (petDetails['age'] != null)
          _buildDetailRow('Edad', petDetails['age']),
        if (petDetails['weight'] != null)
          _buildDetailRow('Peso', petDetails['weight']),
        if (petDetails['color'] != null)
          _buildDetailRow('Color', petDetails['color']),
        if (petDetails['lastVisit'] != null)
          _buildDetailRow('Última visita', petDetails['lastVisit']),
      ],
    );
  }

  Widget _buildOwnerInfoSection() {
    return _buildDetailCard(
      title: 'Info. del Propietario',
      icon: Icons.person_rounded,
      iconColor: AppColors.secondary,
      children: [
        _buildDetailRow('Nombre', appointment['ownerName'] ?? ''),
        if (appointment['ownerPhone'] != null)
          _buildDetailRow(
            'Teléfono',
            appointment['ownerPhone'],
            isClickable: false,
          ),
        if (appointment['ownerEmail'] != null)
          _buildDetailRow(
            'Email',
            appointment['ownerEmail'],
            isClickable: true,
          ),
      ],
    );
  }

  Widget _buildMedicalHistorySection() {
    final history =
        appointment['medicalHistory'] as List<Map<String, dynamic>>? ?? [];

    return _buildDetailCard(
      title: 'Historial Médico Reciente',
      icon: Icons.history_rounded,
      iconColor: AppColors.accent,
      children: [
        if (history.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Text(
              'No hay historial médico disponible',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...history.map((record) => _buildHistoryItem(record)),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> record) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record['type'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                record['date'] ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceXS),
          Text(
            record['notes'] ?? '',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildDetailCard(
      title: 'Notas adicionales',
      icon: Icons.note_outlined,
      iconColor: AppColors.orange,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Text(
            appointment['notes'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppSizes.spaceM),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceM),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isClickable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceS),
          Expanded(
            child: GestureDetector(
              onTap:
                  isClickable
                      ? () => _handleClickableValue(label, value)
                      : null,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isClickable ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  decoration: isClickable ? TextDecoration.underline : null,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    final status =
        appointment['status'] as AppointmentStatus? ??
        AppointmentStatus.scheduled;

    if (status == AppointmentStatus.inProgress) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusRound),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _createMedicalRecord,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.white,
          icon: const Icon(Icons.note_add_rounded),
          label: const Text('Crear Expediente'),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Programada';
      case AppointmentStatus.confirmed:
        return 'Confirmada';
      case AppointmentStatus.inProgress:
        return 'En progreso';
      case AppointmentStatus.completed:
        return 'Completada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
      case AppointmentStatus.rescheduled:
        return 'Reprogramada';
    }
  }

  Map<String, Color> _getStatusColors(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return {
          'primary': AppColors.secondary,
          'secondary': AppColors.secondary.withOpacity(0.8),
        };
      case AppointmentStatus.confirmed:
        return {
          'primary': AppColors.primary,
          'secondary': AppColors.primary.withOpacity(0.8),
        };
      case AppointmentStatus.inProgress:
        return {
          'primary': AppColors.orange,
          'secondary': AppColors.orange.withOpacity(0.8),
        };
      case AppointmentStatus.completed:
        return {
          'primary': AppColors.success,
          'secondary': AppColors.success.withOpacity(0.8),
        };
      case AppointmentStatus.cancelled:
        return {
          'primary': AppColors.textSecondary,
          'secondary': AppColors.textSecondary.withOpacity(0.8),
        };
      case AppointmentStatus.rescheduled:
        return {
          'primary': AppColors.accent,
          'secondary': AppColors.accent.withOpacity(0.8),
        };
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'reschedule':
        _rescheduleAppointment();
        break;
      case 'cancel':
        _cancelAppointment();
        break;
    }
  }

  void _handleClickableValue(String label, String value) {
    if (label == 'Email') {
      _emailOwner(value);
    }
  }

  void _startConsultation() {
    setState(() {
      appointment['status'] = AppointmentStatus.inProgress;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Consulta iniciada para ${appointment['petName']}'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }

  Future<void> _completeConsultation() async {
    final confirmed = await ConfirmationModal.show(
      context: context,
      title: 'Finalizar consulta',
      message:
          '¿Estás seguro de que quieres finalizar esta consulta?\n\nAsegúrate de haber completado todos los registros médicos necesarios.',
      confirmText: 'Finalizar',
      icon: Icons.check_circle_outline_rounded,
      iconColor: AppColors.success,
    );

    if (confirmed == true) {
      setState(() {
        appointment['status'] = AppointmentStatus.completed;
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Consulta finalizada exitosamente'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
        );
      }
    }
  }

  void _createMedicalRecord() {
    Navigator.pushNamed(context, '/create-medical-record');
  }

  void _emailOwner(String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enviar email a: $email'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }

  Future<void> _rescheduleAppointment() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRescheduleModal(),
    );

    if (result != null) {
      final newDateTime = result['dateTime'] as DateTime;

      setState(() {
        appointment['status'] = AppointmentStatus.rescheduled;
        appointment['dateTime'] = newDateTime;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cita reprogramada para ${_formatNewDateTime(newDateTime)}',
            ),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            action: SnackBarAction(
              label: 'Ver agenda',
              textColor: AppColors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/my-schedule');
              },
            ),
          ),
        );
      }
    }
  }

  Widget _buildRescheduleModal() {
    DateTime? selectedDate;
    String? selectedTimeSlot;

    return StatefulBuilder(
      builder: (context, setModalState) {
        final canConfirm = selectedDate != null && selectedTimeSlot != null;

        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusXL),
              topRight: Radius.circular(AppSizes.radiusXL),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: AppSizes.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Icon(
                        Icons.schedule_rounded,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reprogramar Cita',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${appointment['petName']} - ${appointment['ownerName']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingL,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Selection
                      _buildModalFormSection(
                        title: 'Fecha',
                        child: GestureDetector(
                          onTap:
                              () => _selectDateForReschedule(setModalState, (
                                date,
                              ) {
                                selectedDate = date;
                                selectedTimeSlot =
                                    null; // Reset time slot when date changes
                              }),
                          child: Container(
                            padding: const EdgeInsets.all(AppSizes.paddingM),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusL,
                              ),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColors.secondary,
                                  size: AppSizes.iconM,
                                ),
                                const SizedBox(width: AppSizes.spaceM),
                                Expanded(
                                  child: Text(
                                    selectedDate != null
                                        ? _formatDate(selectedDate!)
                                        : 'Selecciona una fecha',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          selectedDate != null
                                              ? AppColors.textPrimary
                                              : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.textSecondary,
                                  size: AppSizes.iconS,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.spaceL),

                      // Time Slot Selection
                      if (selectedDate != null)
                        _buildTimeSlotSelectionForReschedule(
                          selectedDate!,
                          selectedTimeSlot,
                          (timeSlot) {
                            setModalState(() {
                              selectedTimeSlot = timeSlot;
                            });
                          },
                        ),

                      const SizedBox(height: AppSizes.spaceL),

                      // Info message
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          border: Border.all(
                            color: AppColors.secondary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                            const SizedBox(width: AppSizes.spaceM),
                            const Expanded(
                              child: Text(
                                'Se notificará automáticamente al propietario sobre la nueva fecha y hora.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.paddingM,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusM,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceM),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient:
                              canConfirm
                                  ? LinearGradient(
                                    colors: [
                                      AppColors.secondary,
                                      AppColors.secondary.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                  : null,
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: ElevatedButton(
                          onPressed:
                              canConfirm
                                  ? () {
                                    final newDateTime = _createDateTimeFromSlot(
                                      selectedDate!,
                                      selectedTimeSlot!,
                                    );
                                    Navigator.pop(context, {
                                      'dateTime': newDateTime,
                                    });
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                canConfirm
                                    ? Colors.transparent
                                    : AppColors.textSecondary.withOpacity(0.3),
                            shadowColor: Colors.transparent,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.paddingM,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusM,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Confirmar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Agregar estos métodos helper nuevos:

  Widget _buildModalFormSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spaceS),
        child,
      ],
    );
  }

  Widget _buildTimeSlotSelectionForReschedule(
    DateTime selectedDate,
    String? selectedTimeSlot,
    Function(String) onTimeSlotSelected,
  ) {
    final availableSlots = _getAvailableTimeSlotsForDate(selectedDate);

    if (availableSlots.isEmpty) {
      return _buildModalFormSection(
        title: 'Horarios disponibles',
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.warning,
                size: AppSizes.iconM,
              ),
              const SizedBox(width: AppSizes.spaceM),
              const Expanded(
                child: Text(
                  'No hay horarios disponibles para este día',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildModalFormSection(
      title: 'Horarios disponibles',
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Wrap(
          spacing: AppSizes.spaceM,
          runSpacing: AppSizes.spaceM,
          children:
              availableSlots.map((timeSlot) {
                final isSelected = selectedTimeSlot == timeSlot;
                return GestureDetector(
                  onTap: () => onTimeSlotSelected(timeSlot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingS,
                    ),
                    decoration: BoxDecoration(
                      gradient:
                          isSelected
                              ? AppColors.primaryGradient
                              : LinearGradient(
                                colors: [AppColors.white, Colors.grey.shade100],
                              ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : null,
                    ),
                    child: Text(
                      timeSlot,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected
                                ? AppColors.white
                                : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  void _selectDateForReschedule(
    StateSetter setModalState,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setModalState(() {
        onDateSelected(picked);
      });
    }
  }

  List<String> _getAvailableTimeSlotsForDate(DateTime date) {
    final dayOfWeek = date.weekday;

    // Domingo - no hay disponibilidad
    if (dayOfWeek == 7) {
      return [];
    }

    // Sábado - horario reducido
    if (dayOfWeek == 6) {
      return [
        '9:00 AM',
        '10:00 AM',
        '11:00 AM',
        '12:00 PM',
        '1:00 PM',
        '2:00 PM',
      ];
    }

    // Lunes a Viernes - horario completo
    return [
      '8:00 AM',
      '9:00 AM',
      '10:00 AM',
      '11:00 AM',
      '12:00 PM',
      '1:00 PM',
      '2:00 PM',
      '3:00 PM',
      '4:00 PM',
      '5:00 PM',
      '6:00 PM',
    ];
  }

  DateTime _createDateTimeFromSlot(DateTime date, String timeSlot) {
    // Parse the time slot string (e.g., "9:00 AM" -> hour: 9, minute: 0)
    final timeParts = timeSlot.split(':');
    final hour = int.parse(timeParts[0]);
    final minutePart = timeParts[1].split(' ');
    final minute = int.parse(minutePart[0]);
    final period = minutePart[1];

    int adjustedHour = hour;
    if (period == 'PM' && hour != 12) {
      adjustedHour = hour + 12;
    } else if (period == 'AM' && hour == 12) {
      adjustedHour = 0;
    }

    return DateTime(date.year, date.month, date.day, adjustedHour, minute);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    final weekdays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
  }

  String _formatNewDateTime(DateTime dateTime) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    final weekdays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '${weekdays[dateTime.weekday - 1]}, ${dateTime.day} de ${months[dateTime.month - 1]} a las $displayHour:$minute $period';
  }

  Future<void> _cancelAppointment() async {
    final confirmed = await ConfirmationModal.show(
      context: context,
      title: 'Cancelar cita',
      message:
          '¿Estás seguro de que quieres cancelar esta cita?\n\nSe notificará automáticamente al propietario.',
      confirmText: 'Cancelar cita',
      cancelText: 'No cancelar',
      icon: Icons.cancel_outlined,
      iconColor: AppColors.error,
      confirmButtonColor: AppColors.error,
    );

    if (confirmed == true) {
      setState(() {
        appointment['status'] = AppointmentStatus.cancelled;
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cita cancelada exitosamente'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
        );
      }
    }
  }
}
