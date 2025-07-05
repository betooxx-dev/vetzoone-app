import 'package:flutter/material.dart';

class MyPetsPage extends StatefulWidget {
  const MyPetsPage({super.key});

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Mock data - En producción vendría de la base de datos
  final List<Map<String, String>> _pets = [
    {
      'name': 'Max',
      'breed': 'Labrador Retriever',
      'age': '3 años',
      'species': 'Perro',
      'image': 'assets/images/dog_placeholder.png',
    },
    {
      'name': 'Luna',
      'breed': 'Gato Persa',
      'age': '2 años',
      'species': 'Gato',
      'image': 'assets/images/cat_placeholder.png',
    },
    {
      'name': 'Rocky',
      'breed': 'Bulldog Francés',
      'age': '1 año',
      'species': 'Perro',
      'image': 'assets/images/dog_placeholder.png',
    },
  ];

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
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _pets.isEmpty ? _buildEmptyState() : _buildPetsList(),
            ),
          ],
        ),
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
              // ignore: deprecated_member_use
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
                  'Gestiona el cuidado de tus compañeros',
                  style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () {
                // Implementar búsqueda
              },
              icon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildStatsHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              itemCount: _pets.length,
              itemBuilder: (context, index) {
                final pet = _pets[index];
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final delay = index * 0.1;
                    final animationValue = (_animationController.value - delay)
                        .clamp(0.0, 1.0);

                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - animationValue)),
                      child: Opacity(
                        opacity: animationValue,
                        child: _buildPetCard(pet, index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total de Mascotas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_pets.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(Map<String, String> pet, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Navegar a detalle de mascota
            _navigateToPetDetail(pet);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildPetAvatar(pet),
                const SizedBox(width: 16),
                _buildPetInfo(pet),
                _buildMenuButton(pet, index),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetAvatar(Map<String, String> pet) {
    final species = pet['species']!;
    final colors = _getSpeciesColors(species);

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: colors[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(_getSpeciesIcon(species), size: 32, color: Colors.white),
    );
  }

  Widget _buildPetInfo(Map<String, String> pet) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pet['name']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: _getSpeciesColors(pet['species']!)[0].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pet['species']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getSpeciesColors(pet['species']!)[0],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            pet['breed']!,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF757575),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.cake_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                pet['age']!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(Map<String, String> pet, int index) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert_rounded, color: Colors.grey[600], size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        offset: const Offset(-10, 10),
        onSelected: (value) => _handleMenuAction(value, pet, index),
        itemBuilder:
            (context) => [
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
                    const Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'medical',
                child: Row(
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      size: 18,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 12),
                    const Text('Expediente médico'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'appointment',
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 12),
                    const Text('Agendar cita'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 12),
                    const Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.pets_rounded,
                size: 60,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No tienes mascotas registradas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Agrega tu primera mascota para comenzar a gestionar su cuidado y salud.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToAddPet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar Mascota'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToAddPet,
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Agregar Mascota',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  void _navigateToAddPet() {
    Navigator.pushNamed(context, '/add-pet');
  }

  void _navigateToPetDetail(Map<String, String> pet) {
    Navigator.pushNamed(context, '/pet-detail', arguments: pet);
  }

  void _handleMenuAction(String action, Map<String, String> pet, int index) {
    switch (action) {
      case 'edit':
        _editPet(pet, index);
        break;
      case 'medical':
        _viewMedicalRecord(pet);
        break;
      case 'appointment':
        _scheduleAppointment(pet);
        break;
      case 'delete':
        _deletePet(pet, index);
        break;
    }
  }

  void _editPet(Map<String, String> pet, int index) {
    // Implementar navegación a editar mascota
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar ${pet['name']}'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _viewMedicalRecord(Map<String, String> pet) {
    Navigator.pushNamed(context, '/medical-record', arguments: pet);
  }

  void _scheduleAppointment(Map<String, String> pet) {
    // Implementar navegación a agendar cita
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agendar cita para ${pet['name']}'),
        backgroundColor: const Color(0xFFFF7043),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _deletePet(Map<String, String> pet, int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Eliminar mascota'),
            content: Text(
              '¿Estás seguro de que quieres eliminar a ${pet['name']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _pets.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${pet['name']} eliminado'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  List<Color> _getSpeciesColors(String species) {
    switch (species.toLowerCase()) {
      case 'perro':
        return [const Color(0xFF4CAF50), const Color(0xFF66BB6A)];
      case 'gato':
        return [const Color(0xFF81D4FA), const Color(0xFF4FC3F7)];
      case 'conejo':
        return [const Color(0xFFFFB74D), const Color(0xFFFF8A65)];
      case 'ave':
        return [const Color(0xFFBA68C8), const Color(0xFF9C27B0)];
      case 'pez':
        return [const Color(0xFF4DD0E1), const Color(0xFF26C6DA)];
      case 'reptil':
        return [const Color(0xFF81C784), const Color(0xFF4CAF50)];
      default:
        return [const Color(0xFF90A4AE), const Color(0xFF607D8B)];
    }
  }

  IconData _getSpeciesIcon(String species) {
    switch (species.toLowerCase()) {
      case 'perro':
        return Icons.pets_rounded;
      case 'gato':
        return Icons.pets_rounded;
      case 'conejo':
        return Icons.cruelty_free_rounded;
      case 'ave':
        return Icons.flutter_dash_rounded;
      case 'pez':
        return Icons.pool_rounded;
      case 'reptil':
        return Icons.dataset_rounded;
      default:
        return Icons.pets_rounded;
    }
  }
}
