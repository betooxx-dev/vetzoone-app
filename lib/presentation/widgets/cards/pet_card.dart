import 'package:flutter/material.dart';

class PetCard extends StatelessWidget {
  final String petName;
  final String breed;
  final String age;
  final String species;
  final String? imagePath;
  final VoidCallback? onTap;
  final bool showMenuButton;

  const PetCard({
    super.key,
    required this.petName,
    required this.breed,
    required this.age,
    required this.species,
    this.imagePath,
    this.onTap,
    this.showMenuButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _buildPetAvatar(),
              const SizedBox(width: 16),
              _buildPetInfo(),
              if (showMenuButton) _buildMenuButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetAvatar() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: _getSpeciesColors(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: _getSpeciesColors()[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
          imagePath != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => _buildDefaultIcon(),
                ),
              )
              : _buildDefaultIcon(),
    );
  }

  Widget _buildDefaultIcon() {
    return Icon(_getSpeciesIcon(), size: 32, color: Colors.white);
  }

  Widget _buildPetInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  petName,
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
                  color: _getSpeciesColors()[0].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  species,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getSpeciesColors()[0],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            breed,
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
                age,
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

  Widget _buildMenuButton(BuildContext context) {
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
        onSelected: (value) => _handleMenuAction(context, value),
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

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        // Navegar a editar mascota
        break;
      case 'medical':
        // Navegar a expediente médico
        break;
      case 'appointment':
        // Navegar a agendar cita
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Eliminar mascota'),
            content: Text('¿Estás seguro de que quieres eliminar a $petName?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Implementar eliminación
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

  List<Color> _getSpeciesColors() {
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

  IconData _getSpeciesIcon() {
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
