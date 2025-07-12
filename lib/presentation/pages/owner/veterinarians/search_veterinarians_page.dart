import 'package:flutter/material.dart';

class SearchVeterinariansPage extends StatefulWidget {
  const SearchVeterinariansPage({super.key});

  @override
  State<SearchVeterinariansPage> createState() =>
      _SearchVeterinariansPageState();
}

class _SearchVeterinariansPageState extends State<SearchVeterinariansPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecialty = 'Todas las especialidades';
  String _selectedLocation = 'Cualquier ubicación';
  bool _isLoading = false;

  final List<String> _specialties = [
    'Todas las especialidades',
    'Medicina General',
    'Cirugía',
    'Dermatología',
    'Cardiología',
    'Oftalmología',
    'Neurología',
    'Odontología',
    'Oncología',
    'Ortopedia',
    'Medicina de Emergencias',
  ];

  final List<String> _locations = [
    'Cualquier ubicación',
    'Tuxtla Gutiérrez',
    'San Cristóbal de las Casas',
    'Tapachula',
    'Comitán',
    'Palenque',
    'Ocosingo',
    'Villaflores',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildSearchField(),
                      const SizedBox(height: 24),
                      _buildFilters(),
                      const SizedBox(height: 32),
                      _buildQuickFilters(),
                      const SizedBox(height: 32),
                      _buildSearchButton(),
                      const SizedBox(height: 32),
                      _buildFeaturedVeterinarians(),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                Text(
                  'Encuentra al veterinario ideal',
                  style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o especialidad...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.grey[400],
              size: 24,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          style: const TextStyle(fontSize: 16, color: Color(0xFF212121)),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
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
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  'Especialidad',
                  _selectedSpecialty,
                  _specialties,
                  (value) => setState(() => _selectedSpecialty = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownFilter(
                  'Ubicación',
                  _selectedLocation,
                  _locations,
                  (value) => setState(() => _selectedLocation = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF9CA3AF),
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
              items:
                  options.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    final quickFilters = [
      'Medicina General',
      'Cirugía',
      'Emergencias',
      'Vacunación',
      'Cerca de mí',
      'Mejor valorados',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Filtros Rápidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: quickFilters.length,
            itemBuilder: (context, index) {
              final filter = quickFilters[index];
              return Container(
                margin: EdgeInsets.only(
                  right: index < quickFilters.length - 1 ? 12 : 0,
                ),
                child: _buildQuickFilterChip(filter),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip(String label) {
    return GestureDetector(
      onTap: () => _applyQuickFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4CAF50),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    final canSearch =
        _searchController.text.isNotEmpty ||
        _selectedSpecialty != 'Todas las especialidades' ||
        _selectedLocation != 'Cualquier ubicación';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient:
              canSearch
                  ? const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  )
                  : LinearGradient(
                    colors: [Colors.grey[300]!, Colors.grey[300]!],
                  ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton(
          onPressed: canSearch && !_isLoading ? _performSearch : null,
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
      ),
    );
  }

  Widget _buildFeaturedVeterinarians() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Opciones Recomendadas',
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
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildFeaturedVetCard(
                'Dr. María González',
                'Medicina General',
                'Clínica VetCare',
                4.9,
                '8 años',
              ),
              const SizedBox(width: 16),
              _buildFeaturedVetCard(
                'Dr. Carlos López',
                'Cirugía',
                'Hospital Veterinario',
                4.8,
                '12 años',
              ),
              const SizedBox(width: 16),
              _buildFeaturedVetCard(
                'Dra. Ana García',
                'Dermatología',
                'Centro Especializado',
                4.7,
                '6 años',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedVetCard(
    String name,
    String specialty,
    String clinic,
    double rating,
    String experience,
  ) {
    return GestureDetector(
      onTap: () => _navigateToVeterinarianProfile(name),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              specialty,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              clinic,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.star_rounded, size: 12, color: Colors.amber[600]),
                const SizedBox(width: 2),
                Text(
                  rating.toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.timeline_outlined,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    experience,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
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
          break;
        case 'Mejor valorados':
          break;
      }
    });
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

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
      arguments: {'name': veterinarianName ?? ''},
    );
  }
}
