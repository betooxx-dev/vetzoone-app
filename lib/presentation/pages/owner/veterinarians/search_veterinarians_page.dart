import 'package:flutter/material.dart';

class SearchVeterinariansPage extends StatefulWidget {
  const SearchVeterinariansPage({super.key});

  @override
  State<SearchVeterinariansPage> createState() =>
      _SearchVeterinariansPageState();
}

class _SearchVeterinariansPageState extends State<SearchVeterinariansPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _searchController = TextEditingController();
  String? _selectedSpecialty;
  String? _selectedLocation;
  bool _isLoading = false;

  final List<String> _specialties = [
    'Todas las especialidades',
    'Medicina General',
    'Cirugía',
    'Dermatología',
    'Cardiología',
    'Neurología',
    'Oftalmología',
    'Traumatología',
    'Medicina Interna',
    'Anestesiología',
    'Radiología',
    'Patología',
    'Medicina de Emergencias',
  ];

  final List<String> _locations = [
    'Cualquier ubicación',
    'Tuxtla Gutiérrez',
    'San Cristóbal de las Casas',
    'Tapachula',
    'Comitán',
    'Palenque',
    'Tonalá',
    'Ocosingo',
    'Yajalón',
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
    _searchController.dispose();
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchSection(),
                      const SizedBox(height: 24),
                      _buildFiltersSection(),
                      const SizedBox(height: 32),
                      _buildQuickFilters(),
                      const SizedBox(height: 32),
                      _buildSearchButton(),
                      const SizedBox(height: 32),
                      _buildPopularVeterinarians(),
                    ],
                  ),
                ),
              ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buscar Veterinarios',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                Text(
                  'Encuentra el mejor cuidado para tu mascota',
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
              },
              icon: const Icon(
                Icons.tune_rounded,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Búsqueda Rápida',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o clínica...',
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF4CAF50),
            ),
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                      icon: const Icon(
                        Icons.clear_rounded,
                        color: Color(0xFF757575),
                      ),
                    )
                    : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtros',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildSpecialtyDropdown(),
            const SizedBox(height: 16),
            _buildLocationDropdown(),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecialtyDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSpecialty,
      isExpanded: true, // Agregar esta línea para evitar overflow
      decoration: InputDecoration(
        labelText: 'Especialidad',
        prefixIcon: const Icon(
          Icons.medical_services_outlined,
          color: Color(0xFF4CAF50),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items:
          _specialties.map((String specialty) {
            return DropdownMenuItem<String>(
              value: specialty,
              child: Text(specialty, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedSpecialty = newValue;
        });
      },
    );
  }

  Widget _buildLocationDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedLocation,
      isExpanded: true, // Agregar esta línea para evitar overflow
      decoration: InputDecoration(
        labelText: 'Ubicación',
        prefixIcon: const Icon(
          Icons.location_on_outlined,
          color: Color(0xFF4CAF50),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items:
          _locations.map((String location) {
            return DropdownMenuItem<String>(
              value: location,
              child: Text(
                location,
                overflow: TextOverflow.ellipsis, 
              ),
            );
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedLocation = newValue;
        });
      },
    );
  }

  Widget _buildQuickFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Búsquedas Populares',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildQuickFilterChip(
              'Medicina General',
              Icons.medical_services_outlined,
            ),
            _buildQuickFilterChip('Cirugía', Icons.healing_outlined),
            _buildQuickFilterChip('Emergencias', Icons.local_hospital_outlined),
            _buildQuickFilterChip('Vacunación', Icons.vaccines_outlined),
            _buildQuickFilterChip('Cerca de mí', Icons.location_on_outlined),
            _buildQuickFilterChip('Mejor valorados', Icons.star_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip(String label, IconData icon) {
    return GestureDetector(
      onTap: () => _applyQuickFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          // ignore: deprecated_member_use
          border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF4CAF50)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _performSearch,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.5,
                  ),
                )
                : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_rounded, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Buscar Veterinarios',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildPopularVeterinarians() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Veterinarios Destacados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            TextButton(
              onPressed: () {
                _navigateToVeterinariansList();
              },
              child: const Text(
                'Ver todos',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildPopularVetCard(
                'Dr. María González',
                'Medicina General',
                'Clínica VetCare',
                4.9,
                '8 años',
              ),
              const SizedBox(width: 16),
              _buildPopularVetCard(
                'Dr. Carlos López',
                'Cirugía',
                'Hospital Veterinario',
                4.8,
                '12 años',
              ),
              const SizedBox(width: 16),
              _buildPopularVetCard(
                'Dra. Ana García',
                'Dermatología',
                'Centro Animal',
                4.7,
                '6 años',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopularVetCard(
    String name,
    String specialty,
    String clinic,
    double rating,
    String experience,
  ) {
    return GestureDetector(
      onTap: () => _navigateToVeterinarianProfile(name),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              specialty,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF81D4FA),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              clinic,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.timeline_outlined,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  experience,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _applyQuickFilter(String filter) {
    setState(() {
      switch (filter) {
        case 'Medicina General':
          _selectedSpecialty = 'Medicina General';
          break;
        case 'Cirugía':
          _selectedSpecialty = 'Cirugía';
          break;
        case 'Emergencias':
          _selectedSpecialty = 'Medicina de Emergencias';
          break;
        case 'Vacunación':
          _selectedSpecialty = 'Medicina General';
          break;
        case 'Cerca de mí':
          // Implementar geolocalización
          break;
        case 'Mejor valorados':
          // Implementar filtro por rating
          break;
      }
    });
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    // Simular búsqueda
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      _navigateToVeterinariansList();
    }
  }

  void _navigateToVeterinariansList() {
    Navigator.pushNamed(
      context,
      '/veterinarians-list',
      arguments: {
        'query': _searchController.text,
        'specialty': _selectedSpecialty,
        'location': _selectedLocation,
      },
    );
  }

  void _navigateToVeterinarianProfile(String veterinarianName) {
    Navigator.pushNamed(
      context,
      '/veterinarian-profile',
      arguments: {'name': veterinarianName},
    );
  }
}
