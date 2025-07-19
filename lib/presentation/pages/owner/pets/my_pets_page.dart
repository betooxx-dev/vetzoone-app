import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/pet/pet_bloc.dart';
import '../../../blocs/pet/pet_event.dart';
import '../../../blocs/pet/pet_state.dart';
import '../../../widgets/common/empty_state_widget.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../../domain/entities/pet.dart';


class MyPetsPage extends StatefulWidget {
  const MyPetsPage({super.key});

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> {
  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final userId = await SharedPreferencesHelper.getUserId();
    if (userId != null) {
      context.read<PetBloc>().add(LoadPetsEvent(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: BlocConsumer<PetBloc, PetState>(
              listener: (context, state) {
                if (state is PetError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is PetOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadPets();
                }
              },
              builder: (context, state) {
                if (state is PetLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PetsLoaded) {
                  if (state.pets.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.pets_rounded,
                      title: 'No tienes mascotas registradas',
                      message: 'Agrega tu primera mascota para comenzar a gestionar su cuidado y salud.',
                      buttonText: 'Agregar Mascota',
                      onButtonPressed: () => Navigator.pushNamed(context, '/add-pet'),
                    );
                  }
                  return _buildPetsList(state.pets);
                } else if (state is PetError) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Error al cargar mascotas',
                    message: state.message,
                    iconColor: Colors.red,
                    buttonText: 'Reintentar',
                    onButtonPressed: _loadPets,
                  );
                }
                return EmptyStateWidget(
                  icon: Icons.pets_rounded,
                  title: 'No tienes mascotas registradas',
                  message: 'Agrega tu primera mascota para comenzar a gestionar su cuidado y salud.',
                  buttonText: 'Agregar Mascota',
                  onButtonPressed: () => Navigator.pushNamed(context, '/add-pet'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis Mascotas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                Text(
                  'Gestiona la información de tus mascotas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsList(List<Pet> pets) {
    return RefreshIndicator(
      onRefresh: () async => _loadPets(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          return _buildPetCard(pet);
        },
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildPetAvatar(pet),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPetInfo(pet),
              ),
              _buildPetActions(pet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetAvatar(Pet pet) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF4CAF50).withOpacity(0.1),
      ),
      child: pet.imageUrl != null && pet.imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                pet.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultPetIcon(pet.type),
              ),
            )
          : _buildDefaultPetIcon(pet.type),
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
      size: 30,
    );
  }

  Widget _buildPetInfo(Pet pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pet.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_getPetTypeText(pet.type)} • ${pet.breed}',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              pet.gender == PetGender.MALE ? Icons.male : 
              pet.gender == PetGender.FEMALE ? Icons.female : Icons.help_outline,
              size: 16,
              color: pet.gender == PetGender.MALE ? Colors.blue : 
                     pet.gender == PetGender.FEMALE ? Colors.pink : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              _getGenderText(pet.gender),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(width: 12),
            _buildStatusChip(pet.status),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildPetActions(Pet pet) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            Navigator.pushNamed(context, '/edit-pet', arguments: pet);
            break;
          case 'delete':
            _showDeleteConfirmation(pet);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: Color(0xFF4CAF50)),
              SizedBox(width: 12),
              Text('Editar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: Colors.red),
              SizedBox(width: 12),
              Text('Eliminar', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/add-pet'),
      backgroundColor: const Color(0xFF4CAF50),
      child: const Icon(Icons.add, color: Colors.white),
    );
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

  void _showDeleteConfirmation(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Mascota'),
        content: Text('¿Estás seguro de que deseas eliminar a ${pet.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PetBloc>().add(DeletePetEvent(petId: pet.id));
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}