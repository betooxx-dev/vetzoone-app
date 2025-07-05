import 'package:flutter/material.dart';
import '../../../../core/widgets/confirmation_modal.dart';
import '../../../widgets/cards/appointment_card.dart';

class AppointmentDetailPage extends StatefulWidget {
  const AppointmentDetailPage({super.key});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage>
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
      'veterinarianName': 'Dr. María González',
      'appointmentType': 'Consulta General',
      'dateTime': DateTime.now().add(const Duration(hours: 2)),
      'status': AppointmentStatus.confirmed,
      'clinic': 'Clínica VetCare Tuxtla',
      'cost': 350.0,
      'notes': 'Control de rutina, revisar vacunas pendientes',
      'veterinarianPhone': '+52 961 123 4567',
      'veterinarianEmail': 'maria.gonzalez@vetcare.com',
      'clinicAddress': 'Av. Central Norte 1234, Tuxtla Gutiérrez',
      'specialty': 'Medicina General',
      'rating': 4.9,
      'experience': '8 años',
      'petDetails': {
        'species': 'Perro',
        'breed': 'Labrador Retriever',
        'age': '3 años',
        'weight': '25 kg',
      },
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
                  _buildAppointmentCard(),
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
      expandedHeight: 220,
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
                  if (_canEditAppointment())
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 12),
                          const Text('Editar cita'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(
                          Icons.share_outlined,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 12),
                        const Text('Compartir'),
                      ],
                    ),
                  ),
                  if (_canCancelAppointment()) const PopupMenuDivider(),
                  if (_canCancelAppointment())
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
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
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
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                appointment['appointmentType'] ?? 'Cita',
                style: const TextStyle(
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

  Widget _buildAppointmentCard() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: AppointmentCard(
        petName: appointment['petName'] ?? '',
        veterinarianName: appointment['veterinarianName'] ?? '',
        appointmentType: appointment['appointmentType'] ?? '',
        dateTime: appointment['dateTime'] ?? DateTime.now(),
        status: appointment['status'] ?? AppointmentStatus.scheduled,
        clinic: appointment['clinic'],
        notes: appointment['notes'],
        cost: appointment['cost'],
        onTap: null, // No tap action in detail view
        onCancel: _canCancelAppointment() ? _cancelAppointment : null,
        onReschedule:
            _canRescheduleAppointment() ? _rescheduleAppointment : null,
        isOwnerView: true,
      ),
    );
  }

  Widget _buildDetailsSections() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildPetDetailsSection(),
          const SizedBox(height: 24),
          _buildVeterinarianDetailsSection(),
          const SizedBox(height: 24),
          _buildClinicDetailsSection(),
          if (appointment['notes'] != null &&
              appointment['notes']!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildNotesSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildPetDetailsSection() {
    final petDetails = appointment['petDetails'] as Map<String, dynamic>? ?? {};

    return _buildDetailCard(
      title: 'Información de la mascota',
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
      ],
    );
  }

  Widget _buildVeterinarianDetailsSection() {
    return _buildDetailCard(
      title: 'Información del veterinario',
      icon: Icons.person_rounded,
      iconColor: const Color(0xFF81D4FA),
      children: [
        _buildDetailRow('Nombre', appointment['veterinarianName'] ?? ''),
        if (appointment['specialty'] != null)
          _buildDetailRow('Especialidad', appointment['specialty']),
        if (appointment['experience'] != null)
          _buildDetailRow('Experiencia', appointment['experience']),
        if (appointment['rating'] != null)
          _buildDetailRow('Calificación', '${appointment['rating']} ⭐'),
        if (appointment['veterinarianPhone'] != null)
          _buildDetailRow(
            'Teléfono',
            appointment['veterinarianPhone'],
            isClickable: true,
          ),
        if (appointment['veterinarianEmail'] != null)
          _buildDetailRow(
            'Email',
            appointment['veterinarianEmail'],
            isClickable: true,
          ),
      ],
    );
  }

  Widget _buildClinicDetailsSection() {
    return _buildDetailCard(
      title: 'Información de la clínica',
      icon: Icons.local_hospital_rounded,
      iconColor: const Color(0xFFFF7043),
      children: [
        _buildDetailRow('Clínica', appointment['clinic'] ?? ''),
        if (appointment['clinicAddress'] != null)
          _buildDetailRow(
            'Dirección',
            appointment['clinicAddress'],
            isClickable: true,
          ),
        if (appointment['cost'] != null)
          _buildDetailRow(
            'Costo',
            '\$${appointment['cost']?.toStringAsFixed(0)}',
          ),
      ],
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
                          ? const Color(0xFF4CAF50)
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
        if (_canRescheduleAppointment())
          FloatingActionButton(
            heroTag: 'reschedule',
            onPressed: _rescheduleAppointment,
            backgroundColor: const Color(0xFF81D4FA),
            child: const Icon(Icons.schedule_rounded, color: Colors.white),
          ),
        if (_canRescheduleAppointment() && _canCancelAppointment())
          const SizedBox(height: 12),
        if (_canCancelAppointment())
          FloatingActionButton(
            heroTag: 'cancel',
            onPressed: _cancelAppointment,
            backgroundColor: const Color(0xFFFF7043),
            child: const Icon(Icons.cancel_outlined, color: Colors.white),
          ),
      ],
    );
  }

  // Métodos de validación
  bool _canEditAppointment() {
    final status = appointment['status'] as AppointmentStatus;
    return status == AppointmentStatus.scheduled;
  }

  bool _canCancelAppointment() {
    final status = appointment['status'] as AppointmentStatus;
    return status == AppointmentStatus.scheduled ||
        status == AppointmentStatus.confirmed;
  }

  bool _canRescheduleAppointment() {
    final status = appointment['status'] as AppointmentStatus;
    return status == AppointmentStatus.scheduled;
  }

  // Métodos de colores y iconos
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

  // Métodos de acciones
  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editAppointment();
        break;
      case 'share':
        _shareAppointment();
        break;
      case 'cancel':
        _cancelAppointment();
        break;
    }
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

  void _editAppointment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de editar cita próximamente'),
        backgroundColor: Color(0xFF81D4FA),
      ),
    );
  }

  void _shareAppointment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Información de la cita copiada'),
        backgroundColor: Color(0xFF4CAF50),
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

  void _rescheduleAppointment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reprogramar cita próximamente'),
        backgroundColor: const Color(0xFF81D4FA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _callVeterinarian(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Llamar a $phone'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _emailVeterinarian(String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enviar email a $email'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openMap(String address) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrir mapa: $address'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
