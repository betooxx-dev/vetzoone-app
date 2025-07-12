import 'package:flutter/material.dart';
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
    final colors = _getStatusColors(status);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(colors),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppointmentInfo(),
                  const SizedBox(height: 24),
                  _buildPetInfo(),
                  const SizedBox(height: 24),
                  _buildVeterinarianInfo(),
                  const SizedBox(height: 24),
                  _buildLocationInfo(),
                  const SizedBox(height: 24),
                  _buildCostInfo(),
                  if (_canCancelAppointment()) ...[
                    const SizedBox(height: 32),
                    _buildCancelButton(),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Map<String, Color> colors) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: colors['primary'],
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
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
                appointment['appointmentType'] ?? 'Consulta',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getStatusText(status),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
    return _buildInfoCard(
      title: 'Información de la Cita',
      icon: Icons.calendar_today_outlined,
      children: [
        _buildInfoRow(
          'Fecha',
          appointment['date'] ?? 'No especificada',
          Icons.today_outlined,
        ),
        _buildInfoRow(
          'Hora',
          appointment['time'] ?? 'No especificada',
          Icons.access_time_outlined,
        ),
        _buildInfoRow(
          'Duración',
          appointment['duration'] ?? 'No especificada',
          Icons.timer_outlined,
        ),
        if (appointment['notes'] != null && appointment['notes'].isNotEmpty)
          _buildInfoRow('Notas', appointment['notes'], Icons.note_outlined),
      ],
    );
  }

  Widget _buildPetInfo() {
    return _buildInfoCard(
      title: 'Información de la Mascota',
      icon: Icons.pets_outlined,
      children: [
        _buildInfoRow(
          'Nombre',
          appointment['petName'] ?? 'No especificado',
          Icons.pets_rounded,
        ),
        _buildInfoRow(
          'Especie',
          appointment['petSpecies'] ?? 'No especificado',
          Icons.category_outlined,
        ),
      ],
    );
  }

  Widget _buildVeterinarianInfo() {
    return _buildInfoCard(
      title: 'Veterinario',
      icon: Icons.person_outline,
      children: [
        _buildInfoRow(
          'Nombre',
          appointment['veterinarianName'] ?? 'No asignado',
          Icons.person_rounded,
        ),
        _buildInfoRow(
          'Especialidad',
          appointment['veterinarianSpecialty'] ?? 'No especificada',
          Icons.medical_services_outlined,
        ),
        _buildInfoRow(
          'Clínica',
          appointment['clinic'] ?? 'No especificada',
          Icons.local_hospital_outlined,
        ),
        _buildInfoRow(
          'Teléfono',
          appointment['phone'] ?? 'No disponible',
          Icons.phone_outlined,
          isClickable: true,
        ),
        _buildInfoRow(
          'Email',
          appointment['email'] ?? 'No disponible',
          Icons.email_outlined,
          isClickable: true,
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return _buildInfoCard(
      title: 'Ubicación',
      icon: Icons.location_on_outlined,
      children: [
        _buildInfoRow(
          'Dirección',
          appointment['address'] ?? 'No especificada',
          Icons.location_on_outlined,
          isClickable: true,
        ),
      ],
    );
  }

  Widget _buildCostInfo() {
    return _buildInfoCard(
      title: 'Costo',
      icon: Icons.attach_money_outlined,
      children: [
        _buildInfoRow(
          'Consulta',
          appointment['cost'] ?? 'No especificado',
          Icons.monetization_on_outlined,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
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
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isClickable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
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
                              ? const Color(0xFF2196F3)
                              : const Color(0xFF212121),
                      fontWeight: FontWeight.w600,
                      decoration: isClickable ? TextDecoration.underline : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _cancelAppointment,
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('Cancelar Cita'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF7043),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Map<String, Color> _getStatusColors(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return {
          'primary': const Color(0xFF2196F3),
          'secondary': const Color(0xFF64B5F6),
        };
      case AppointmentStatus.confirmed:
        return {
          'primary': const Color(0xFF4CAF50),
          'secondary': const Color(0xFF81C784),
        };
      case AppointmentStatus.inProgress:
        return {
          'primary': const Color(0xFFFF9800),
          'secondary': const Color(0xFFFFB74D),
        };
      case AppointmentStatus.completed:
        return {
          'primary': const Color(0xFF4CAF50),
          'secondary': const Color(0xFF81C784),
        };
      case AppointmentStatus.cancelled:
        return {
          'primary': const Color(0xFFFF7043),
          'secondary': const Color(0xFFFF8A65),
        };
      case AppointmentStatus.rescheduled:
        return {
          'primary': const Color(0xFF9C27B0),
          'secondary': const Color(0xFFBA68C8),
        };
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
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _emailVeterinarian(String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo email para $email...'),
        backgroundColor: const Color(0xFF2196F3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openMap(String address) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo mapa para: $address'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        status = AppointmentStatus.cancelled;
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
