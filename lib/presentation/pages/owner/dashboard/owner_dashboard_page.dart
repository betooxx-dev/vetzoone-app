import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/pet/pet_bloc.dart';
import '../../../blocs/pet/pet_event.dart';
import '../../../blocs/pet/pet_state.dart';
import '../../../blocs/appointment/index.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../../domain/entities/pet.dart';
import '../../../../domain/entities/appointment.dart';


class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  String _userGreeting = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPets();
    _loadUpcomingAppointments();
  }

  Future<void> _loadUserData() async {
    final greeting = await UserService.getUserGreeting();
    setState(() {
      _userGreeting = greeting;
    });
  }

  Future<void> _loadPets() async {
    final userId = await SharedPreferencesHelper.getUserId();
    if (userId != null) {
      context.read<PetBloc>().add(LoadPetsEvent(userId: userId));
    }
  }

  Future<void> _loadUpcomingAppointments() async {
    final userId = await SharedPreferencesHelper.getUserId();
    if (userId != null) {
      final now = DateTime.now();
      final fifteenDaysLater = now.add(const Duration(days: 15));
      context.read<AppointmentBloc>().add(LoadUpcomingAppointmentsEvent(userId: userId, dateFrom: now, dateTo: fifteenDaysLater));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadPets();
            await _loadUpcomingAppointments();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildMyPetsSection(),
                const SizedBox(height: 24),
                _buildUpcomingAppointments(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userGreeting,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cuida mejor a tus mascotas',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/notifications'),
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: 'Agregar Mascota',
                  icon: Icons.add,
                  color: const Color(0xFF4CAF50),
                  onTap: () => Navigator.pushNamed(context, '/add-pet'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  title: 'Agendar Cita',
                  icon: Icons.calendar_today,
                  color: const Color(0xFF2196F3),
                  onTap: () => Navigator.pushNamed(context, '/search-veterinarians'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 140, // Altura un poco mayor para el texto
        padding: const EdgeInsets.all(16), // Padding más pequeño
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, // Ícono más pequeño
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 12),
            Flexible( // Cambié Expanded por Flexible
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2, // Altura de línea más compacta
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4), // Espaciado al final
          ],
        ),
      ),
    );
  }

  Widget _buildMyPetsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Mascotas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/my-pets'),
                child: const Text(
                  'Ver todas',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<PetBloc, PetState>(
            builder: (context, state) {
              if (state is PetLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state is PetsLoaded) {
                if (state.pets.isEmpty) {
                  return _buildNoPetsCard();
                }
                return _buildPetsList(state.pets);
              } else if (state is PetError) {
                return _buildErrorCard(state.message);
              }
              return _buildNoPetsCard();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPetsList(List<Pet> pets) {
    // Mostrar máximo 3 mascotas en el dashboard
    final displayPets = pets.take(3).toList();
    
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayPets.length,
        itemBuilder: (context, index) {
          final pet = displayPets[index];
          return _buildPetCard(pet);
        },
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/pet-detail',
          arguments: pet.id,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        pet.imageUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultPetIcon(pet.type),
                      ),
                    )
                  : _buildDefaultPetIcon(pet.type),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPetTypeText(pet.type),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusChip(pet.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultPetIcon(PetType type) {
    IconData iconData;
    switch (type) {
      case PetType.DOG:
        iconData = Icons.pets;
        break;
      case PetType.CAT:
        iconData = Icons.pets;
        break;
      case PetType.BIRD:
        iconData = Icons.flutter_dash;
        break;
      default:
        iconData = Icons.pets;
    }

    return Icon(
      iconData,
      color: const Color(0xFF4CAF50),
      size: 24,
    );
  }

  Widget _buildStatusChip(PetStatus? status) {
    if (status == null) return const SizedBox();

    Color color;
    String text;
    switch (status) {
      case PetStatus.HEALTHY:
        color = Colors.green;
        text = 'Saludable';
        break;
      case PetStatus.TREATMENT:
        color = Colors.blue;
        text = 'En tratamiento';
        break;
      case PetStatus.ATTENTION:
        color = Colors.orange;
        text = 'Necesita atención';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNoPetsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.pets_outlined,
              color: Color(0xFF4CAF50),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tienes mascotas registradas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega tu primera mascota para comenzar',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/add-pet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Agregar Mascota'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar mascotas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('retry_pets_button'),
            onPressed: _loadPets,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Próximas Citas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/my-appointments'),
                child: const Text(
                  'Ver todas',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<AppointmentBloc, AppointmentState>(
            builder: (context, state) {
              if (state is AppointmentsOverviewState) {
                if (state.loadingUpcoming) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state.errorUpcoming != null) {
                  return _buildAppointmentErrorCard(state.errorUpcoming!);
                } else if (state.upcoming.isEmpty) {
                  return _buildNoAppointmentsCard();
                } else {
                  return _buildUpcomingAppointmentsList(state.upcoming);
                }
              }
              return _buildNoAppointmentsCard();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointmentsList(List<Appointment> appointments) {
    // Mostrar máximo 3 citas próximas en el dashboard
    final displayAppointments = appointments.take(3).toList();
    
    return Column(
      children: displayAppointments.asMap().entries.map((entry) {
        final index = entry.key;
        final appointment = entry.value;
        return Padding(
          key: Key('appointment_card_${appointment.id}_$index'),
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAppointmentCard(appointment),
        );
      }).toList(),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      key: Key('appointment_container_${appointment.id}'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Crear un mapa simple para evitar conflictos de tipos
          final appointmentData = {
            'id': appointment.id,
            'appointmentType': appointment.notes ?? 'Consulta',
            'petName': 'Mascota', // Placeholder hasta que tengamos datos del pet
            'veterinarianName': 'Veterinario', // Placeholder hasta que tengamos datos del vet
            'date': _formatAppointmentDate(appointment.appointmentDate),
            'time': _formatTime(appointment.appointmentDate),
            'notes': appointment.notes ?? '',
            'status': _mapAppointmentStatusToString(appointment.status),
          };
          
          Navigator.pushNamed(
            context,
            '/appointment-detail',
            arguments: appointmentData,
          );
        },
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getStatusIcon(appointment.status),
                color: _getStatusColor(appointment.status),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.notes ?? 'Consulta',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusText(appointment.status),
                    style: TextStyle(
                      fontSize: 14,
                      color: _getStatusColor(appointment.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatAppointmentDate(appointment.appointmentDate),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getStatusColor(appointment.status),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAppointmentsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF4CAF50),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tienes citas próximas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agenda una consulta para tu mascota',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('schedule_appointment_button'),
            onPressed: () => Navigator.pushNamed(context, '/search-veterinarians'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Agendar Cita'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentErrorCard(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar citas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('retry_appointments_button'),
            onPressed: _loadUpcomingAppointments,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // Helper methods para appointments
  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return const Color(0xFFFF9800);
      case AppointmentStatus.confirmed:
        return const Color(0xFF4CAF50);
      case AppointmentStatus.inProgress:
        return const Color(0xFF2196F3);
      case AppointmentStatus.completed:
        return const Color(0xFF8BC34A);
      case AppointmentStatus.cancelled:
        return const Color(0xFFF44336);
      case AppointmentStatus.rescheduled:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Icons.schedule_outlined;
      case AppointmentStatus.confirmed:
        return Icons.check_circle_outline;
      case AppointmentStatus.inProgress:
        return Icons.medical_services_outlined;
      case AppointmentStatus.completed:
        return Icons.task_alt;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.rescheduled:
        return Icons.update_outlined;
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pendiente';
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

  String _formatAppointmentDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    // Si es hoy
    if (date.day == now.day && 
        date.month == now.month && 
        date.year == now.year) {
      return 'Hoy, ${_formatTime(date)}';
    }
    
    // Si es mañana
    final tomorrow = now.add(const Duration(days: 1));
    if (date.day == tomorrow.day && 
        date.month == tomorrow.month && 
        date.year == tomorrow.year) {
      return 'Mañana, ${_formatTime(date)}';
    }
    
    // Si es en los próximos 7 días
    if (difference.inDays >= 0 && difference.inDays <= 7) {
      final weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      final weekday = weekdays[date.weekday - 1];
      return '$weekday, ${_formatTime(date)}';
    }
    
    // Fecha completa
    return '${date.day}/${date.month} ${_formatTime(date)}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  // Helper para mapear el enum interno al enum de la UI existente
  String _mapAppointmentStatusToString(AppointmentStatus status) {
    // Esto devuelve strings que la página de destino puede interpretar
    switch (status) {
      case AppointmentStatus.pending:
        return 'scheduled'; // Mapeamos pending a scheduled para compatibilidad
      case AppointmentStatus.confirmed:
        return 'confirmed';
      case AppointmentStatus.inProgress:
        return 'inProgress';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.cancelled:
        return 'cancelled';
      case AppointmentStatus.rescheduled:
        return 'rescheduled';
    }
  }

  String _getPetTypeText(PetType type) {
    switch (type) {
      case PetType.DOG:
        return 'Perro';
      case PetType.CAT:
        return 'Gato';
      case PetType.BIRD:
        return 'Ave';
      case PetType.RABBIT:
        return 'Conejo';
      case PetType.HAMSTER:
        return 'Hámster';
      case PetType.FISH:
        return 'Pez';
      case PetType.REPTILE:
        return 'Reptil';
      case PetType.OTHER:
        return 'Otro';
    }
  }
}