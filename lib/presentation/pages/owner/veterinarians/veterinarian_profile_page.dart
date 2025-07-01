import 'package:flutter/material.dart';

class VeterinarianProfilePage extends StatefulWidget {
  const VeterinarianProfilePage({super.key});

  @override
  State<VeterinarianProfilePage> createState() =>
      _VeterinarianProfilePageState();
}

class _VeterinarianProfilePageState extends State<VeterinarianProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Map<String, dynamic> veterinarian = {};
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _initializeVeterinarianData();
    _animationController.forward();
  }

  void _initializeVeterinarianData() {
    final defaultVet = {
      'name': 'Dr. María González',
      'specialty': 'Medicina General',
      'clinic': 'Clínica VetCare Tuxtla',
      'experience': '8 años',
      'rating': 4.9,
      'distance': '2.3 km',
      'consultationFee': 350,
      'available': true,
      'nextAppointment': 'Hoy 3:00 PM',
      'license': 'MVZCOL-12345',
      'phone': '+52 961 123 4567',
      'email': 'maria.gonzalez@vetcare.com',
      'address': 'Av. Central Norte 1234, Tuxtla Gutiérrez',
      'description':
          'Especialista en medicina general con más de 8 años de experiencia. Comprometida con brindar el mejor cuidado a cada paciente.',
      'services': [
        'Consultas generales',
        'Vacunación',
        'Desparasitación',
        'Cirugías menores',
        'Medicina preventiva',
        'Urgencias',
      ],
      'schedule': {
        'Lunes': '9:00 AM - 6:00 PM',
        'Martes': '9:00 AM - 6:00 PM',
        'Miércoles': '9:00 AM - 6:00 PM',
        'Jueves': '9:00 AM - 6:00 PM',
        'Viernes': '9:00 AM - 6:00 PM',
        'Sábado': '9:00 AM - 2:00 PM',
        'Domingo': 'Cerrado',
      },
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map<String, dynamic>) {
        setState(() {
          veterinarian = {...defaultVet, ...arguments};
        });
      } else {
        setState(() {
          veterinarian = defaultVet;
        });
      }
    });

    veterinarian = defaultVet;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildVeterinarianInfo(),
                  _buildTabBar(),
                  _buildTabBarView(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF81D4FA),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
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
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite ? Colors.red : const Color(0xFF212121),
              size: 24,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF212121)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: _handleMenuAction,
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(
                          Icons.share_outlined,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 12),
                        const Text('Compartir perfil'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(
                          Icons.report_outlined,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 12),
                        const Text('Reportar'),
                      ],
                    ),
                  ),
                ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Hero(
                tag: 'vet_${veterinarian['name'] ?? 'default'}',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                veterinarian['name'] ?? 'Veterinario',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                veterinarian['specialty'] ?? 'Especialidad',
                style: TextStyle(
                  fontSize: 16,
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVeterinarianInfo() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem(
                'Calificación',
                '${veterinarian['rating'] ?? 0.0}',
                Icons.star_rounded,
                const Color(0xFF4CAF50),
              ),
              _buildStatItem(
                'Experiencia',
                veterinarian['experience'] ?? '0 años',
                Icons.timeline_outlined,
                const Color(0xFFFF7043),
              ),
              _buildStatItem(
                'Distancia',
                veterinarian['distance'] ?? '0 km',
                Icons.location_on_outlined,
                const Color(0xFF81D4FA),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.local_hospital_outlined,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  veterinarian['clinic'] ?? 'Clínica no especificada',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.attach_money_rounded,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                "Consulta desde \$${veterinarian['consultationFee'] ?? 0}",
                style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      (veterinarian['available'] ?? false)
                          // ignore: deprecated_member_use
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          // ignore: deprecated_member_use
                          : const Color(0xFFFF7043).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            (veterinarian['available'] ?? false)
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF7043),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (veterinarian['available'] ?? false)
                          ? 'Disponible'
                          : 'No disponible',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            (veterinarian['available'] ?? false)
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF7043),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF81D4FA),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(6),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF757575),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Sobre'),
          Tab(text: 'Servicios'),
          Tab(text: 'Horarios'),
          Tab(text: 'Reseñas'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(24),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildAboutTab(),
          _buildServicesTab(),
          _buildScheduleTab(),
          _buildReviewsTab(),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sobre el veterinario',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            veterinarian['description'] ?? 'Descripción no disponible',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildContactInfo(),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información de contacto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          Icons.badge_outlined,
          'Cédula profesional',
          veterinarian['license'] ?? 'No especificada',
        ),
        _buildContactItem(
          Icons.phone_outlined,
          'Teléfono',
          veterinarian['phone'] ?? 'No especificado',
        ),
        _buildContactItem(
          Icons.email_outlined,
          'Email',
          veterinarian['email'] ?? 'No especificado',
        ),
        _buildContactItem(
          Icons.location_on_outlined,
          'Dirección',
          veterinarian['address'] ?? 'No especificada',
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF81D4FA)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF212121),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    final services = veterinarian['services'] as List<String>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servicios disponibles',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: const Color(0xFF81D4FA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.medical_services_outlined,
                        color: Color(0xFF81D4FA),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        services[index],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Color(0xFF757575),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleTab() {
    final schedule = veterinarian['schedule'] as Map<String, String>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horarios de atención',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: schedule.length,
            itemBuilder: (context, index) {
              final day = schedule.keys.elementAt(index);
              final hours = schedule[day]!;
              final isToday = _isToday(day);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isToday
                          // ignore: deprecated_member_use
                          ? const Color(0xFF81D4FA).withOpacity(0.1)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isToday
                            ? const Color(0xFF81D4FA)
                            : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.w600,
                          color:
                              isToday
                                  ? const Color(0xFF81D4FA)
                                  : const Color(0xFF212121),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        hours,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isToday
                                  ? const Color(0xFF81D4FA)
                                  : const Color(0xFF757575),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF81D4FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'HOY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Reseñas y calificaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${veterinarian['rating'] ?? 0.0} (127)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              _buildReviewItem(
                'Ana García',
                5,
                'Excelente atención. La Dra. María es muy profesional y cuidadosa con las mascotas.',
                '2 días',
              ),
              _buildReviewItem(
                'Carlos López',
                5,
                'Mi perro se sintió muy cómodo durante la consulta. Altamente recomendada.',
                '1 semana',
              ),
              _buildReviewItem(
                'María Fernández',
                4,
                'Buen servicio, aunque tuve que esperar un poco más de lo esperado.',
                '2 semanas',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(
    String name,
    int rating,
    String comment,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: const Color(0xFF81D4FA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF81D4FA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 14,
                            color: const Color(0xFF4CAF50),
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          'hace $time',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _scheduleAppointment,
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.calendar_today_rounded),
      label: const Text(
        'Agendar Cita',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  bool _isToday(String day) {
    final today = DateTime.now();
    final dayNames = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    final todayName = dayNames[today.weekday - 1];
    return day == todayName;
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? '${veterinarian['name']} agregado a favoritos'
              : '${veterinarian['name']} removido de favoritos',
        ),
        backgroundColor:
            isFavorite ? const Color(0xFF4CAF50) : const Color(0xFF757575),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compartir perfil de ${veterinarian['name']}'),
            backgroundColor: const Color(0xFF81D4FA),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte enviado'),
            backgroundColor: Color(0xFFFF7043),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }

  void _scheduleAppointment() {
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
                Text(
                  'Agendar cita con ${veterinarian['name']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Próxima disponibilidad: ${veterinarian['nextAppointment']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Cita agendada con ${veterinarian['name']}',
                              ),
                              backgroundColor: const Color(0xFF4CAF50),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Confirmar'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }
}
