import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/pet/pet_bloc.dart';
import '../../../blocs/pet/pet_event.dart';
import '../../../blocs/pet/pet_state.dart';
import '../../../widgets/common/empty_state_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../domain/entities/pet.dart';
import '../../../../domain/entities/appointment.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
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

  Future<void> _reloadPetsOnPop() async {
    final userId = await SharedPreferencesHelper.getUserId();
    if (userId != null && mounted) {
      context.read<PetBloc>().add(LoadPetsEvent(userId: userId));
    }
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

  void _showDeleteDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_rounded, color: AppColors.error, size: 24),
              SizedBox(width: 8),
              Text(
                'Eliminar Mascota',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro que deseas eliminar a ${pet.name}?',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Esta acción es irreversible y se eliminarán:',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Información de la mascota\n• Historial médico\n• Citas programadas\n• Fotografías',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _deletePet(pet.id);
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deletePet(String petId) {
    context.read<PetBloc>().add(DeletePetEvent(petId: petId));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _reloadPetsOnPop();
        return true;
      },
      child: Scaffold(
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
              BlocConsumer<PetBloc, PetState>(
                listener: (context, state) {
                  if (state is PetOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    Navigator.pop(context);
                  } else if (state is PetError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is PetLoading) {
                    return const Scaffold(
                      backgroundColor: Colors.transparent,
                      body: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondary,
                        ),
                      ),
                    );
                  } else if (state is PetLoaded) {
                    return _buildPetDetail(state.pet, state.appointments);
                  } else if (state is PetError) {
                    return Scaffold(
                      backgroundColor: Colors.transparent,
                      body: EmptyStateWidget(
                        icon: Icons.error_outline,
                        title: 'Error al cargar mascota',
                        message: state.message,
                        iconColor: AppColors.error,
                        buttonText: 'Reintentar',
                        onButtonPressed: _loadPetDetail,
                      ),
                    );
                  }

                  return Scaffold(
                    backgroundColor: Colors.transparent,
                    body: EmptyStateWidget(
                      icon: Icons.pets_rounded,
                      title: 'Mascota no encontrada',
                      message:
                          'No se pudo cargar la información de la mascota.',
                      iconColor: AppColors.secondary,
                      buttonText: 'Volver',
                      onButtonPressed: () => Navigator.pop(context),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetDetail(Pet pet, List<Appointment> appointments) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(pet),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              children: [
                _buildInfoCard(pet),
                const SizedBox(height: AppSizes.spaceL),
                _buildHealthCard(pet),
                const SizedBox(height: AppSizes.spaceL),
                _buildAppointmentsCard(appointments),
                const SizedBox(height: AppSizes.spaceL),
                _buildActionButtons(pet),
                const SizedBox(height: AppSizes.spaceXL),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(Pet pet) {
    return SliverAppBar(
      expandedHeight: 250,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.secondary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.edit, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.pushNamed(context, '/edit-pet', arguments: pet).then((
                result,
              ) {
                if (result == true) {
                  _loadPetDetail();
                }
              });
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          pet.name,
          style: const TextStyle(
            color: AppColors.white,
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
                  colors: [
                    Colors.transparent,
                    AppColors.black.withOpacity(0.7),
                  ],
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
      color: AppColors.secondary,
      child: Icon(
        _getPetIcon(type),
        size: 100,
        color: AppColors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildInfoCard(Pet pet) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.spaceS),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              const Text(
                'Información General',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceL),
          _buildInfoRow('Tipo', _getPetTypeText(pet.type), Icons.category),
          const SizedBox(height: AppSizes.spaceM),
          _buildInfoRow('Raza', pet.breed, Icons.pets),
          const SizedBox(height: AppSizes.spaceM),
          _buildInfoRow(
            'Género',
            _getGenderText(pet.gender),
            _getGenderIcon(pet.gender),
          ),
          const SizedBox(height: AppSizes.spaceM),
          _buildInfoRow(
            'Fecha de nacimiento',
            '${pet.birthDate.day}/${pet.birthDate.month}/${pet.birthDate.year}',
            Icons.cake,
          ),
          const SizedBox(height: AppSizes.spaceM),
          _buildInfoRow(
            'Edad',
            _calculateAge(pet.birthDate),
            Icons.access_time,
          ),
          if (pet.description != null && pet.description!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spaceL),
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              pet.description!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
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
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.favorite, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Estado de Salud',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHealthStatus(pet.status ?? PetStatus.HEALTHY),
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Próximas Citas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (appointments.isEmpty)
            const Text(
              'No hay citas programadas',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            )
          else
            ...appointments
                .take(3)
                .map((appointment) => _buildAppointmentItem(appointment))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Pet pet) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.spaceS),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(
                  Icons.settings,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              const Text(
                'Acciones',
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
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/medical-record',
                      arguments: {'petId': pet.id, 'petName': pet.name},
                    );
                  },
                  icon: const Icon(Icons.medical_services),
                  label: const Text('Ver Historial'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDeleteDialog(pet),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Eliminar Mascota'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSizes.spaceS),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthStatus(PetStatus status) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case PetStatus.HEALTHY:
        statusColor = AppColors.success;
        statusText = 'Saludable';
        statusIcon = Icons.check_circle;
        break;
      case PetStatus.TREATMENT:
        statusColor = AppColors.warning;
        statusText = 'En tratamiento';
        statusIcon = Icons.medical_services;
        break;
      case PetStatus.ATTENTION:
        statusColor = AppColors.error;
        statusText = 'Requiere atención';
        statusIcon = Icons.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${DateFormat('dd/MM/yyyy').format(appointment.appointmentDate)} - Dr. Veterinario',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
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
      case PetType.FISH:
        return Icons.set_meal;
      case PetType.RABBIT:
        return Icons.pets;
      case PetType.HAMSTER:
        return Icons.pets;
      case PetType.REPTILE:
        return Icons.pets;
      case PetType.OTHER:
        return Icons.pets;
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

  String _getPetTypeText(PetType type) {
    switch (type) {
      case PetType.DOG:
        return 'Perro';
      case PetType.CAT:
        return 'Gato';
      case PetType.BIRD:
        return 'Ave';
      case PetType.FISH:
        return 'Pez';
      case PetType.RABBIT:
        return 'Conejo';
      case PetType.HAMSTER:
        return 'Hámster';
      case PetType.REPTILE:
        return 'Reptil';
      case PetType.OTHER:
        return 'Otro';
    }
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
