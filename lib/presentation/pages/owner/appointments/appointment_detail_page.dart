import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/confirmation_modal.dart';

enum AppointmentStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rescheduled,
}

class AppointmentDetailPage extends StatefulWidget {
  final Map<String, dynamic>? appointmentData;

  const AppointmentDetailPage({super.key, this.appointmentData});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  late Map<String, dynamic> appointment;
  late AppointmentStatus status;

  @override
  void initState() {
    super.initState();
    _initializeAppointmentData();
  }

  void _initializeAppointmentData() {
    final defaultAppointment = {
      'id': '1',
      'appointmentType': 'Consulta General',
      'petName': 'Max',
      'petSpecies': 'Perro',
      'veterinarianName': 'Dr. María González',
      'veterinarianSpecialty': 'Medicina General',
      'clinic': 'Veterinaria Central',
      'date': '25 Dic 2024',
      'time': '10:00 AM',
      'duration': '30 min',
      'notes': 'Consulta de rutina para chequeo general',
      'address': 'Av. Principal 123, Ciudad',
      'phone': '+52 999 123 4567',
      'email': 'contacto@veterinariacentral.com',
      'cost': '\$500.00',
      'status': AppointmentStatus.scheduled,
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map<String, dynamic>) {
        setState(() {
          appointment = arguments;
          status = appointment['status'] ?? AppointmentStatus.scheduled;
        });
      }
    });

    appointment = widget.appointmentData ?? defaultAppointment;
    status = appointment['status'] ?? AppointmentStatus.scheduled;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFBDE3FF), Color(0xFFE8F5E8), Color(0xFFE5F3FF)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildDecorativeShapes(),
            CustomScrollView(
              slivers: [
                _buildSliverAppBar(statusColor),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAppointmentInfo(),
                        const SizedBox(height: AppSizes.spaceL),
                        _buildPetInfo(),
                        const SizedBox(height: AppSizes.spaceL),
                        _buildVeterinarianInfo(),
                        const SizedBox(height: AppSizes.spaceL),
                        _buildLocationInfo(),
                        const SizedBox(height: AppSizes.spaceL),
                        _buildCostInfo(),
                        if (_canCancelAppointment()) ...[
                          const SizedBox(height: AppSizes.spaceXXL),
                          _buildCancelButton(),
                        ],
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
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
          top: -100,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        Positioned(
          top: 150,
          left: -80,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(75),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(Color statusColor) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: statusColor,
      leading: Container(
        margin: const EdgeInsets.all(AppSizes.paddingS),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [statusColor, statusColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  _getStatusIcon(status),
                  size: 40,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSizes.spaceM),
              Text(
                appointment['appointmentType'] ?? 'Consulta',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getStatusText(status),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentInfo() {
    return _buildModernInfoCard(
      title: 'Información de la Cita',
      icon: Icons.calendar_today_outlined,
      iconColor: AppColors.primary,
      children: [
        _buildModernInfoRow(
          'Fecha',
          appointment['date'] ?? 'No especificada',
          Icons.today_outlined,
        ),
        _buildModernInfoRow(
          'Hora',
          appointment['time'] ?? 'No especificada',
          Icons.access_time_outlined,
        ),
        _buildModernInfoRow(
          'Duración',
          appointment['duration'] ?? 'No especificada',
          Icons.timer_outlined,
        ),
        if (appointment['notes'] != null && appointment['notes'].isNotEmpty)
          _buildModernInfoRow(
            'Notas',
            appointment['notes'],
            Icons.note_outlined,
          ),
      ],
    );
  }

  Widget _buildPetInfo() {
    return _buildModernInfoCard(
      title: 'Info. de la Mascota',
      icon: Icons.pets_outlined,
      iconColor: AppColors.secondary,
      children: [
        _buildModernInfoRow(
          'Nombre',
          appointment['petName'] ?? 'No especificado',
          Icons.pets_rounded,
        ),
        _buildModernInfoRow(
          'Especie',
          appointment['petSpecies'] ?? 'No especificado',
          Icons.category_outlined,
        ),
      ],
    );
  }

  Widget _buildVeterinarianInfo() {
    return _buildModernInfoCard(
      title: 'Veterinario',
      icon: Icons.person_outline,
      iconColor: AppColors.accent,
      children: [
        _buildModernInfoRow(
          'Nombre',
          appointment['veterinarianName'] ?? 'No asignado',
          Icons.person_rounded,
        ),
        _buildModernInfoRow(
          'Especialidad',
          appointment['veterinarianSpecialty'] ?? 'No especificada',
          Icons.medical_services_outlined,
        ),
        _buildModernInfoRow(
          'Clínica',
          appointment['clinic'] ?? 'No especificada',
          Icons.local_hospital_outlined,
        ),
        _buildModernInfoRow(
          'Teléfono',
          appointment['phone'] ?? 'No disponible',
          Icons.phone_outlined,
          isClickable: true,
        ),
        _buildModernInfoRow(
          'Email',
          appointment['email'] ?? 'No disponible',
          Icons.email_outlined,
          isClickable: true,
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return _buildModernInfoCard(
      title: 'Ubicación',
      icon: Icons.location_on_outlined,
      iconColor: AppColors.success,
      children: [
        _buildModernInfoRow(
          'Dirección',
          appointment['address'] ?? 'No especificada',
          Icons.location_on_outlined,
          isClickable: true,
        ),
      ],
    );
  }

  Widget _buildCostInfo() {
    return _buildModernInfoCard(
      title: 'Costo',
      icon: Icons.attach_money_outlined,
      iconColor: AppColors.warning,
      children: [
        _buildModernInfoRow(
          'Consulta',
          appointment['cost'] ?? 'No especificado',
          Icons.monetization_on_outlined,
        ),
      ],
    );
  }

  Widget _buildModernInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [iconColor, iconColor.withOpacity(0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingS),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [iconColor, iconColor.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: Icon(icon, size: 20, color: AppColors.white),
                      ),
                      const SizedBox(width: AppSizes.spaceM),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceM),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isClickable = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceS),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap:
                      isClickable
                          ? () => _handleClickableValue(label, value)
                          : null,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          isClickable
                              ? AppColors.primary
                              : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      decoration: isClickable ? TextDecoration.underline : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isClickable)
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return Container(
      width: double.infinity,
      height: AppSizes.buttonHeightL,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _cancelAppointment,
        icon: const Icon(Icons.cancel_outlined),
        label: const Text(
          'Cancelar Cita',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return AppColors.primary;
      case AppointmentStatus.confirmed:
        return AppColors.success;
      case AppointmentStatus.inProgress:
        return AppColors.warning;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.error;
      case AppointmentStatus.rescheduled:
        return AppColors.secondary;
    }
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Icons.schedule_outlined;
      case AppointmentStatus.confirmed:
        return Icons.check_circle_outline;
      case AppointmentStatus.inProgress:
        return Icons.medical_services_outlined;
      case AppointmentStatus.completed:
        return Icons.task_alt_outlined;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.rescheduled:
        return Icons.update_outlined;
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Programada';
      case AppointmentStatus.confirmed:
        return 'Confirmada';
      case AppointmentStatus.inProgress:
        return 'En curso';
      case AppointmentStatus.completed:
        return 'Completada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
      case AppointmentStatus.rescheduled:
        return 'Reprogramada';
    }
  }

  bool _canCancelAppointment() {
    return status == AppointmentStatus.scheduled ||
        status == AppointmentStatus.confirmed;
  }

  void _handleClickableValue(String label, String value) {
    if (label == 'Teléfono') {
      _callVeterinarian(value);
    } else if (label == 'Email') {
      _emailVeterinarian(value);
    } else if (label == 'Dirección') {
      _openMap(value);
    }
  }

  void _callVeterinarian(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Llamando a $phone...'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }

  void _emailVeterinarian(String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo email para $email...'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }

  void _openMap(String address) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo mapa para: $address'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }

  Future<void> _cancelAppointment() async {
    final confirmed = await ConfirmationModal.show(
      context: context,
      title: 'Cancelar cita',
      message:
          '¿Estás seguro de que quieres cancelar esta cita?\n\nEsta acción no se puede deshacer.',
      confirmText: 'Cancelar cita',
      cancelText: 'No cancelar',
      icon: Icons.cancel_outlined,
      iconColor: AppColors.error,
      confirmButtonColor: AppColors.error,
    );

    if (confirmed == true) {
      setState(() {
        appointment['status'] = AppointmentStatus.cancelled;
        status = AppointmentStatus.cancelled;
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
