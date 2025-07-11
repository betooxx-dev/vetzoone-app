import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFFFAFAFA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildQuickActions(),
                  _buildAppointmentCard(),
                  _buildMedicalActionsSection(),
                  _buildDetailsSections(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildSliverAppBar() {
    final status =
        appointment['status'] as AppointmentStatus? ??
        AppointmentStatus.scheduled;
    final colors = _getStatusColors(status);

    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: colors['primary'],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors['primary']!, colors['secondary']!],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Detalle de Cita',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusText(status),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withAlpha(230),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: _handleMenuAction,
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'reschedule',
                  child: Row(
                    children: [
                      Icon(Icons.schedule, size: 20, color: Color(0xFF757575)),
                      SizedBox(width: 12),
                      Text('Reprogramar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, size: 20, color: Color(0xFFFF7043)),
                      SizedBox(width: 12),
                      Text('Cancelar cita'),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final status =
        appointment['status'] as AppointmentStatus? ??
        AppointmentStatus.scheduled;

    return Container(
      margin: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (status == AppointmentStatus.confirmed) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _startConsultation,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Iniciar Consulta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _rescheduleAppointment,
                icon: const Icon(Icons.schedule_rounded),
                label: const Text('Reprogramar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81D4FA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else if (status == AppointmentStatus.inProgress) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _completeConsultation,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Finalizar Consulta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else if (status == AppointmentStatus.scheduled) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _rescheduleAppointment,
                icon: const Icon(Icons.schedule_rounded),
                label: const Text('Reprogramar Cita'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81D4FA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: AppointmentCard(
        petName: appointment['petName'] ?? '',
        veterinarianName: 'Dr. María González',
        appointmentType: appointment['appointmentType'] ?? '',
        dateTime: appointment['dateTime'] ?? DateTime.now(),
        status: appointment['status'] ?? AppointmentStatus.scheduled,
        notes: appointment['notes'],
        isOwnerView: false,
        ownerName: appointment['ownerName'],
        onTap: null,
      ),
    );
  }

  Widget _buildMedicalActionsSection() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.medical_services, color: Color(0xFF81D4FA), size: 24),
              SizedBox(width: 8),
              Text(
                'Acciones Médicas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Primera fila de botones
          Row(
            children: [
              Expanded(
                child: _buildMedicalActionButton(
                  icon: Icons.note_add_rounded,
                  title: 'Crear Registro Médico',
                  subtitle: 'Nuevo expediente',
                  color: const Color(0xFF81D4FA),
                  onTap: () {
                    Navigator.pushNamed(context, '/create-medical-record');
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMedicalActionButton(
                  icon: Icons.medication_rounded,
                  title: 'Prescribir Medicamentos',
                  subtitle: 'Nueva receta',
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    Navigator.pushNamed(context, '/prescribe-treatment');
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Segunda fila - botón único centrado
          _buildMedicalActionButton(
            icon: Icons.vaccines_rounded,
            title: 'Registrar Vacuna',
            subtitle: 'Aplicar nueva vacuna',
            color: const Color(0xFF9C27B0),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(51), width: 1),
        ),
        child:
            isFullWidth
                ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
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
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withAlpha(51),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildPatientInfoSection(),
          const SizedBox(height: 24),
          _buildOwnerInfoSection(),
          const SizedBox(height: 24),
          _buildMedicalHistorySection(),
          if (appointment['notes'] != null &&
              appointment['notes']!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildNotesSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildPatientInfoSection() {
    final petDetails = appointment['petDetails'] as Map<String, dynamic>? ?? {};

    return _buildDetailCard(
      title: 'Información del Paciente',
      icon: Icons.pets_rounded,
      iconColor: const Color(0xFF4CAF50),
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
      iconColor: const Color(0xFF81D4FA),
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
      iconColor: const Color(0xFFFF7043),
      children: [
        if (history.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No hay historial médico disponible',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
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
                  color: Color(0xFF212121),
                ),
              ),
              Text(
                record['date'] ?? '',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            record['notes'] ?? '',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildDetailCard(
      title: 'Notas adicionales',
      icon: Icons.note_outlined,
      iconColor: const Color(0xFF9C27B0),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            appointment['notes'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF212121),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                  color: iconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
                      isClickable
                          ? const Color(0xFF81D4FA)
                          : const Color(0xFF212121),
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
      return FloatingActionButton.extended(
        onPressed: _createMedicalRecord,
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.note_add_rounded),
        label: const Text('Crear Expediente'),
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
          'primary': const Color(0xFF81D4FA),
          'secondary': const Color(0xFF4FC3F7),
        };
      case AppointmentStatus.confirmed:
        return {
          'primary': const Color(0xFF4CAF50),
          'secondary': const Color(0xFF66BB6A),
        };
      case AppointmentStatus.inProgress:
        return {
          'primary': const Color(0xFFFF9800),
          'secondary': const Color(0xFFFFB74D),
        };
      case AppointmentStatus.completed:
        return {
          'primary': const Color(0xFF66BB6A),
          'secondary': const Color(0xFF4CAF50),
        };
      case AppointmentStatus.cancelled:
        return {
          'primary': const Color(0xFF757575),
          'secondary': const Color(0xFF9E9E9E),
        };
      case AppointmentStatus.rescheduled:
        return {
          'primary': const Color(0xFFFF7043),
          'secondary': const Color(0xFFFF8A65),
        };
    }
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Icons.schedule_rounded;
      case AppointmentStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case AppointmentStatus.inProgress:
        return Icons.medical_services_rounded;
      case AppointmentStatus.completed:
        return Icons.check_circle_rounded;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.rescheduled:
        return Icons.update_rounded;
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
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      iconColor: const Color(0xFF4CAF50),
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
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
        backgroundColor: const Color(0xFF81D4FA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            backgroundColor: const Color(0xFF81D4FA),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Ver agenda',
              textColor: Colors.white,
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
    TimeOfDay? selectedTime;

    return StatefulBuilder(
      builder: (context, setModalState) {
        final canConfirm = selectedDate != null && selectedTime != null;

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF81D4FA).withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.schedule_rounded,
                        color: Color(0xFF81D4FA),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reprogramar Cita',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          Text(
                            '${appointment['petName']} - ${appointment['ownerName']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Date Time Selector
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      DateTimeSelector(
                        initialDate: DateTime.now().add(
                          const Duration(days: 1),
                        ),
                        initialTime: const TimeOfDay(hour: 9, minute: 0),
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                        disabledWeekdays: const [7], // Domingo deshabilitado
                        onDateChanged: (date) {
                          setModalState(() {
                            selectedDate = date;
                          });
                        },
                        onTimeChanged: (time) {
                          setModalState(() {
                            selectedTime = time;
                          });
                        },
                      ),

                      const SizedBox(height: 32),

                      // Info adicional
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF81D4FA).withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF81D4FA),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Se notificará automáticamente al propietario sobre la nueva fecha y hora.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
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

              // Buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            canConfirm
                                ? () {
                                  final newDateTime = DateTime(
                                    selectedDate!.year,
                                    selectedDate!.month,
                                    selectedDate!.day,
                                    selectedTime!.hour,
                                    selectedTime!.minute,
                                  );
                                  Navigator.pop(context, {
                                    'dateTime': newDateTime,
                                  });
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF81D4FA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[300],
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatNewDateTime(DateTime dateTime) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    final hour =
        dateTime.hour == 0
            ? 12
            : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';

    return '${dateTime.day} ${months[dateTime.month - 1]} $hour:$minute $period';
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
      iconColor: const Color(0xFFFF7043),
      confirmButtonColor: const Color(0xFFFF7043),
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
            backgroundColor: const Color(0xFFFF7043),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
