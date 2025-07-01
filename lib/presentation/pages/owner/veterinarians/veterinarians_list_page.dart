import 'package:flutter/material.dart';

class VeterinariansListPage extends StatefulWidget {
  const VeterinariansListPage({super.key});

  @override
  State<VeterinariansListPage> createState() => _VeterinariansListPageState();
}

class _VeterinariansListPageState extends State<VeterinariansListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Map<String, String?> searchParams = {};
  String _sortBy = 'Relevancia';
  bool _showMap = false;

  final List<String> _sortOptions = [
    'Relevancia',
    'Mejor valorados',
    'Más cerca',
    'Más experiencia',
    'Precio: menor a mayor',
    'Precio: mayor a menor',
  ];

  // Mock data de veterinarios
  final List<Map<String, dynamic>> _veterinarians = [
    {
      'name': 'Dr. María González',
      'specialty': 'Medicina General',
      'clinic': 'Clínica VetCare Tuxtla',
      'experience': '8 años',
      'rating': 4.9,
      'distance': '2.3 km',
      'consultationFee': 350,
      'available': true,
      'nextAppointment': 'Hoy 3:00 PM',
    },
    {
      'name': 'Dr. Carlos López',
      'specialty': 'Cirugía',
      'clinic': 'Hospital Veterinario Central',
      'experience': '12 años',
      'rating': 4.8,
      'distance': '1.8 km',
      'consultationFee': 450,
      'available': true,
      'nextAppointment': 'Mañana 10:00 AM',
    },
    {
      'name': 'Dra. Ana García',
      'specialty': 'Dermatología',
      'clinic': 'Centro Veterinario Especializado',
      'experience': '6 años',
      'rating': 4.7,
      'distance': '3.1 km',
      'consultationFee': 400,
      'available': false,
      'nextAppointment': 'Viernes 2:00 PM',
    },
    {
      'name': 'Dr. Roberto Mendoza',
      'specialty': 'Cardiología',
      'clinic': 'Clínica del Corazón Animal',
      'experience': '15 años',
      'rating': 4.9,
      'distance': '4.2 km',
      'consultationFee': 500,
      'available': true,
      'nextAppointment': 'Mañana 4:00 PM',
    },
    {
      'name': 'Dra. Patricia Ruiz',
      'specialty': 'Oftalmología',
      'clinic': 'Centro Oftalmológico Veterinario',
      'experience': '9 años',
      'rating': 4.6,
      'distance': '2.7 km',
      'consultationFee': 380,
      'available': true,
      'nextAppointment': 'Hoy 5:30 PM',
    },
    {
      'name': 'Dr. Fernando Silva',
      'specialty': 'Medicina de Emergencias',
      'clinic': 'Hospital 24 Horas',
      'experience': '10 años',
      'rating': 4.8,
      'distance': '1.5 km',
      'consultationFee': 600,
      'available': true,
      'nextAppointment': 'Disponible ahora',
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, String?>?;
    if (arguments != null) {
      searchParams = arguments;
    }
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildAppBar(),
              _buildSearchSummary(),
              _buildToolbar(),
              Expanded(child: _showMap ? _buildMapView() : _buildListView()),
            ],
          ),
        ),
      ),
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
            child: Text(
              'Veterinarios Encontrados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
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

  Widget _buildSearchSummary() {
    if (searchParams.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Criterios de búsqueda:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (searchParams['query']?.isNotEmpty == true)
                _buildSearchTag('Búsqueda: "${searchParams['query']}"'),
              if (searchParams['specialty'] != null &&
                  searchParams['specialty'] != 'Todas las especialidades')
                _buildSearchTag('Especialidad: ${searchParams['specialty']}'),
              if (searchParams['location'] != null &&
                  searchParams['location'] != 'Cualquier ubicación')
                _buildSearchTag('Ubicación: ${searchParams['location']}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF4CAF50),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Text(
            '${_veterinarians.length} veterinarios',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const Spacer(),
          _buildSortButton(),
          const SizedBox(width: 12),
          _buildMapToggle(),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return GestureDetector(
      onTap: _showSortOptions,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort_rounded, size: 18, color: Color(0xFF757575)),
            const SizedBox(width: 6),
            Text(
              _sortBy,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showMap = !_showMap;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _showMap ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _showMap ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Icon(
          _showMap ? Icons.list_rounded : Icons.map_rounded,
          size: 20,
          color: _showMap ? Colors.white : const Color(0xFF757575),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: _veterinarians.length,
      itemBuilder: (context, index) {
        final vet = _veterinarians[index];
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.1;
            final animationValue = (_animationController.value - delay).clamp(
              0.0,
              1.0,
            );

            return Transform.translate(
              offset: Offset(0, 30 * (1 - animationValue)),
              child: Opacity(
                opacity: animationValue,
                child: _buildVeterinarianCard(vet),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVeterinarianCard(Map<String, dynamic> vet) {
    return GestureDetector(
      onTap: () => _navigateToVeterinarianProfile(vet),
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
          child: Column(
            children: [
              Row(
                children: [
                  _buildVetAvatar(vet),
                  const SizedBox(width: 16),
                  _buildVetInfo(vet),
                  _buildAvailabilityIndicator(vet),
                ],
              ),
              const SizedBox(height: 16),
              _buildVetDetails(vet),
              const SizedBox(height: 16),
              _buildActionButtons(vet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVetAvatar(Map<String, dynamic> vet) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: const Color(0xFF81D4FA).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(Icons.person_rounded, size: 28, color: Colors.white),
    );
  }

  Widget _buildVetInfo(Map<String, dynamic> vet) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vet['name'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: const Color(0xFF81D4FA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              vet['specialty'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF81D4FA),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.local_hospital_outlined,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  vet['clinic'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityIndicator(Map<String, dynamic> vet) {
    final isAvailable = vet['available'] as bool;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isAvailable ? const Color(0xFF4CAF50) : const Color(0xFFFF7043),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildVetDetails(Map<String, dynamic> vet) {
    return Row(
      children: [
        _buildDetailChip(
          Icons.star_rounded,
          vet['rating'].toString(),
          const Color(0xFF4CAF50),
        ),
        const SizedBox(width: 8),
        _buildDetailChip(
          Icons.timeline_outlined,
          vet['experience'],
          const Color(0xFFFF7043),
        ),
        const SizedBox(width: 8),
        _buildDetailChip(
          Icons.location_on_outlined,
          vet['distance'],
          Colors.grey[600]!,
        ),
        const Spacer(),
        Text(
          '\$${vet['consultationFee']}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> vet) {
    final isAvailable = vet['available'] as bool;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient:
                  isAvailable
                      ? const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      )
                      : null,
              color: isAvailable ? null : Colors.grey[300],
            ),
            child: ElevatedButton(
              onPressed: isAvailable ? () => _scheduleAppointment(vet) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isAvailable ? 'Agendar Cita' : 'No Disponible',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isAvailable ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: const Color(0xFF81D4FA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => _navigateToVeterinarianProfile(vet),
            icon: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF81D4FA),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => _toggleFavorite(vet),
            icon: Icon(
              Icons.favorite_border_rounded,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapView() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: Color(0xFF4CAF50)),
            SizedBox(height: 16),
            Text(
              'Vista de Mapa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Integración con Google Maps\npróximamente disponible',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ordenar por',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 24),
                ...(_sortOptions.map((option) => _buildSortOption(option))),
                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }

  Widget _buildSortOption(String option) {
    final isSelected = _sortBy == option;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = option;
        });
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text(
              option,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF212121),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _scheduleAppointment(Map<String, dynamic> vet) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agendar cita con ${vet['name']}'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToVeterinarianProfile(Map<String, dynamic> vet) {
    Navigator.pushNamed(context, '/veterinarian-profile', arguments: vet);
  }

  void _toggleFavorite(Map<String, dynamic> vet) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${vet['name']} agregado a favoritos'),
        backgroundColor: const Color(0xFF81D4FA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
