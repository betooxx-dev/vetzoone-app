import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/pet/pet_bloc.dart';
import '../../../blocs/pet/pet_event.dart';
import '../../../blocs/pet/pet_state.dart';
import '../../../widgets/common/empty_state_widget.dart';
import '../../../../domain/entities/pet.dart';
import '../../../../domain/entities/appointment.dart';
import 'package:intl/intl.dart';


class PetDetailPage extends StatefulWidget {
  final String petId;

  const PetDetailPage({super.key, required this.petId});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadPetDetail();
  }

  void _loadPetDetail() {
    context.read<PetBloc>().add(GetPetByIdEvent(petId: widget.petId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocBuilder<PetBloc, PetState>(
        builder: (context, state) {
          if (state is PetLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is PetLoaded) {
            return _buildPetDetail(state.pet, state.appointments);
          } else if (state is PetError) {
            return Scaffold(
              body: EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Error al cargar mascota',
                message: state.message,
                iconColor: Colors.red,
                buttonText: 'Reintentar',
                onButtonPressed: _loadPetDetail,
              ),
            );
          }

          return Scaffold(
            body: EmptyStateWidget(
              icon: Icons.pets_rounded,
              title: 'Mascota no encontrada',
              message: 'No se pudo cargar la información de la mascota.',
              buttonText: 'Volver',
              onButtonPressed: () => Navigator.pop(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetDetail(Pet pet, List<Appointment> appointments) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(pet),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildInfoCard(pet),
              const SizedBox(height: 16),
              _buildHealthCard(pet),
              const SizedBox(height: 16),
              _buildActionsCard(pet),
              const SizedBox(height: 16),
              _buildMedicalRecordsCard(pet),
              const SizedBox(height: 16),
              _buildAppointmentsCard(appointments),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(Pet pet) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF4CAF50),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed:
                () => Navigator.pushNamed(context, '/edit-pet', arguments: pet),
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          pet.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (pet.imageUrl != null && pet.imageUrl!.isNotEmpty)
              Image.network(
                pet.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        _buildDefaultBackground(pet.type),
              )
            else
              _buildDefaultBackground(pet.type),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultBackground(PetType type) {
    return Container(
      color: const Color(0xFF4CAF50),
      child: Icon(
        _getPetIcon(type),
        size: 100,
        color: Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildInfoCard(Pet pet) {
    return Container(
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
                child: Icon(
                  Icons.info_outline,
                  color: const Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Información General',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Tipo', _getPetTypeText(pet.type), Icons.category),
          const SizedBox(height: 12),
          _buildInfoRow('Raza', pet.breed, Icons.pets),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Género',
            _getGenderText(pet.gender),
            _getGenderIcon(pet.gender),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Fecha de nacimiento',
            '${pet.birthDate.day}/${pet.birthDate.month}/${pet.birthDate.year}',
            Icons.cake,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Edad',
            _calculateAge(pet.birthDate),
            Icons.access_time,
          ),
          if (pet.description != null && pet.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pet.description!,
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthCard(Pet pet) {
    return Container(
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
                child: Icon(
                  Icons.health_and_safety,
                  color: const Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Estado de Salud',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatusChip(pet.status),
              const Spacer(),
              Text(
                'Última actualización',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(Pet pet) {
    return Container(
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
                child: Icon(
                  Icons.widgets,
                  color: const Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Acciones Rápidas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Cita',
                  Icons.calendar_today,
                  () => Navigator.pushNamed(context, '/schedule-appointment'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Historial',
                  Icons.history,
                  () => Navigator.pushNamed(
                    context,
                    '/medical-record',
                    arguments: {'petId': pet.id, 'petName': pet.name},
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordsCard(Pet pet) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medical_information,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Historial Médico',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed:
                    () => Navigator.pushNamed(
                      context,
                      '/medical-record',
                      arguments: {'petId': pet.id, 'petName': pet.name},
                    ),
                child: const Text('Ver todo'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay registros médicos recientes',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsCard(List<Appointment> appointments) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.event,
                  color: Color(0xFFFF9800),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Historial de Citas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (appointments.isEmpty)
            const Text(
              'No han habido citas para esta mascota.',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                final formattedDate = DateFormat('dd/MM/yyyy').format(appointment.appointmentDate);
                return ListTile(
                  leading: const Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
                  title: Text(
                    'Fecha: $formattedDate',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(appointment.notes ?? 'Sin notas'),
                  trailing: Text(_mapAppointmentStatusToString(appointment.status)),
                );
              },
            ),
        ],
      ),
    );
  }

  String _mapAppointmentStatusToString(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pendiente';
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4CAF50)),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getGenderText(PetGender gender) {
    switch (gender) {
      case PetGender.MALE:
        return 'Macho';
      case PetGender.FEMALE:
        return 'Hembra';
      case PetGender.UNKNOWN:
        return 'Desconocido';
    }
  }

  IconData _getGenderIcon(PetGender gender) {
    switch (gender) {
      case PetGender.MALE:
        return Icons.male;
      case PetGender.FEMALE:
        return Icons.female;
      case PetGender.UNKNOWN:
        return Icons.help_outline;
    }
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Column(
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  IconData _getPetIcon(PetType type) {
    switch (type) {
      case PetType.DOG:
        return Icons.pets;
      case PetType.CAT:
        return Icons.pets;
      case PetType.BIRD:
        return Icons.flutter_dash;
      default:
        return Icons.pets;
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

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final years = (difference.inDays / 365).floor();
    final months = ((difference.inDays % 365) / 30).floor();

    if (years > 0) {
      return years == 1 ? '1 año' : '$years años';
    } else if (months > 0) {
      return months == 1 ? '1 mes' : '$months meses';
    } else {
      final days = difference.inDays;
      return days == 1 ? '1 día' : '$days días';
    }
  }
}
