import 'package:flutter/material.dart';
import '../../../../core/widgets/confirmation_modal.dart';
import '../../../widgets/cards/appointment_card.dart';

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
    _initializeAppointmentData();
    _animationController.forward();
  }

  void _initializeAppointmentData() {
    final defaultAppointment = {
      'id': '1',
      'petName': 'Max',
      'ownerName': 'Juan Pérez',
      'appointmentType': 'Consulta General',
      'dateTime': DateTime.now().add(const Duration(hours: 2)),
      'status': AppointmentStatus.confirmed,
      'duration': 30,
      'notes': 'Control de rutina, revisar vacunas pendientes',
      'ownerPhone': '+52 961 123 4567',
      'ownerEmail': 'juan.perez@email.com',
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
                  _buildMedicalActionsSection(), // ← NUEVA SECCIÓN AGREGADA
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
    final status = appointment['status'] as AppointmentStatus;
    final colors = _getStatusColors(status);

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: colors['primary'],
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF212121),
            size: 20,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF212121)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: _handleMenuAction,
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'reschedule',
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 12),
                        const Text('Reprogramar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'call',
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 12),
                        const Text('Llamar al dueño'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cancel_outlined,
                          size: 18,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Cancelar cita',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors['primary']!, colors['secondary']!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  _getStatusIcon(status),
                  size: 35,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${appointment['petName']} - ${appointment['ownerName']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                appointment['appointmentType'] ?? 'Cita',
                style: TextStyle(
                  fontSize: 14,
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final status = appointment['status'] as AppointmentStatus;
    final canStartConsultation = status == AppointmentStatus.confirmed;
    final canComplete = status == AppointmentStatus.inProgress;

    return Container(
      margin: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (canStartConsultation) ...[
            Expanded(
              child: _buildActionButton(
                'Iniciar Consulta',
                Icons.play_circle_outline_rounded,
                const Color(0xFF4CAF50),
                _startConsultation,
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (canComplete) ...[
            Expanded(
              child: _buildActionButton(
                'Finalizar',
                Icons.check_circle_outline_rounded,
                const Color(0xFF66BB6A),
                _completeConsultation,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: _buildActionButton(
              'Llamar',
              Icons.phone_outlined,
              const Color(0xFF81D4FA),
              _callOwner,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // ignore: deprecated_member_use
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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

  // ← NUEVA FUNCIÓN AGREGADA: Botones de navegación a vistas 32-34
  Widget _buildMedicalActionsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
          const SizedBox(height: 16),

          // Botones para las vistas 32-34
          Row(
            children: [
              // Vista 32: Crear Registro Médico
              Expanded(
                child: _buildMedicalActionButton(
                  icon: Icons.note_add,
                  title: 'Crear Registro Médico',
                  subtitle: 'Nuevo expediente',
                  color: const Color(0xFF81D4FA),
                  onTap: () {
                    Navigator.pushNamed(context, '/create-medical-record');
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Vista 33: Prescribir Medicamentos
              Expanded(
                child: _buildMedicalActionButton(
                  icon: Icons.medication,
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

          const SizedBox(height: 12),

          // Vista 34: Registrar Vacuna (botón ancho)
          SizedBox(
            width: double.infinity,
            child: _buildMedicalActionButton(
              icon: Icons.vaccines,
              title: 'Registrar Vacuna',
              subtitle: 'Aplicar nueva vacuna',
              color: const Color(0xFF9C27B0),
              onTap: () {
                Navigator.pushNamed(context, '/register-vaccination');
              },
              isWide: true,
            ),
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
    bool isWide = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isWide ? 20 : 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child:
              isWide
                  ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
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
                          color: color.withOpacity(0.2),
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
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
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
      title: 'Información del Propietario',
      icon: Icons.person_rounded,
      iconColor: const Color(0xFF81D4FA),
      children: [
        _buildDetailRow('Nombre', appointment['ownerName'] ?? ''),
        if (appointment['ownerPhone'] != null)
          _buildDetailRow(
            'Teléfono',
            appointment['ownerPhone'],
            isClickable: true,
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
                style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
              ),
            ],
          ),
          if (record['notes'] != null) ...[
            const SizedBox(height: 4),
            Text(
              record['notes'],
              style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildDetailCard(
      title: 'Notas de la cita',
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
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
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
                  // ignore: deprecated_member_use
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
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
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    final status = appointment['status'] as AppointmentStatus;

    if (status == AppointmentStatus.completed ||
        status == AppointmentStatus.cancelled) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == AppointmentStatus.confirmed)
          FloatingActionButton(
            heroTag: 'start',
            onPressed: _startConsultation,
            backgroundColor: const Color(0xFF4CAF50),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
          ),
        if (status == AppointmentStatus.inProgress) ...[
          FloatingActionButton(
            heroTag: 'complete',
            onPressed: _completeConsultation,
            backgroundColor: const Color(0xFF66BB6A),
            child: const Icon(Icons.check_rounded, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'medical',
            onPressed: _createMedicalRecord,
            backgroundColor: const Color(0xFF81D4FA),
            child: const Icon(
              Icons.medical_services_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ],
    );
  }

  // Métodos de validación y colores
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

  // Métodos de acciones
  void _handleMenuAction(String action) {
    switch (action) {
      case 'reschedule':
        _rescheduleAppointment();
        break;
      case 'call':
        _callOwner();
        break;
      case 'cancel':
        _cancelAppointment();
        break;
    }
  }

  void _handleClickableValue(String label, String value) {
    if (label == 'Teléfono') {
      _callOwner();
    } else if (label == 'Email') {
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

  // ← FUNCIÓN MODIFICADA: Ahora navega a vista 32
  void _createMedicalRecord() {
    Navigator.pushNamed(context, '/create-medical-record');
  }

  void _callOwner() {
    final phone = appointment['ownerPhone'] ?? '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Llamar a ${appointment['ownerName']}: $phone'),
        backgroundColor: const Color(0xFF81D4FA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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

  void _rescheduleAppointment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reprogramar cita próximamente'),
        backgroundColor: Color(0xFF81D4FA),
      ),
    );
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
