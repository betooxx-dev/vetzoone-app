import 'package:flutter/material.dart';

class PetDetailPage extends StatefulWidget {
  final Map<String, dynamic>? petData;

  const PetDetailPage({super.key, this.petData});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Map<String, dynamic> pet;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _initializePetData();
    _animationController.forward();
  }

  void _initializePetData() {
    final defaultPet = {
      'name': 'Max',
      'breed': 'Labrador Retriever',
      'age': '3 años',
      'species': 'Perro',
      'gender': 'Macho',
      'weight': '25 kg',
      'color': 'Dorado',
      'birthDate': '2021-03-15',
      'notes': 'Mascota muy amigable y activa',
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;

      if (arguments != null && arguments is Map<String, dynamic>) {
        setState(() {
          pet = Map<String, dynamic>.from(arguments);
        });
      } else if (widget.petData != null) {
        setState(() {
          pet = Map<String, dynamic>.from(widget.petData!);
        });
      } else {
        setState(() {
          pet = defaultPet;
        });
      }
    });

    pet =
        widget.petData != null
            ? Map<String, dynamic>.from(widget.petData!)
            : defaultPet;
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
                children: [_buildPetInfo(), _buildTabBar(), _buildTabBarView()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    final colors = _getSpeciesColors(pet['species'] ?? 'Perro');

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: colors[0],
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
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
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 12),
                        const Text('Editar información'),
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
                        const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors[0], colors[0].withOpacity(0.8)],
            ),
          ),
          child: _buildHeroSection(),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Hero(
            tag: 'pet-${pet['name']}',
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: Icon(
                Icons.pets_rounded,
                size: 60,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            pet['name'] ?? 'Sin nombre',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${pet['species'] ?? 'Sin especie'} • ${pet['breed'] ?? 'Sin raza'}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetInfo() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pet['name'] ?? 'Sin nombre',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getSpeciesColors(
                    pet['species'] ?? 'Perro',
                  )[0].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pet['species'] ?? 'Perro',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getSpeciesColors(pet['species'] ?? 'Perro')[0],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              pet['breed'] ?? 'Raza desconocida',
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.cake_outlined,
                  label: 'Edad',
                  value:
                      _calculateAge(pet['birthDate']) ??
                      pet['age'] ??
                      'Desconocida',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.wc_rounded,
                  label: 'Sexo',
                  value: pet['gender'] ?? 'No especificado',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Peso',
                  value:
                      pet['weight'] != null
                          ? '${pet['weight']}'
                          : 'No registrado',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.palette_outlined,
                  label: 'Color',
                  value: pet['color'] ?? 'No especificado',
                ),
              ),
            ],
          ),
          if (pet['notes'] != null && pet['notes'].toString().isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Notas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pet['notes'].toString(),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF4CAF50)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
      ],
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(6),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF757575),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Expediente'),
          Tab(text: 'Vacunas'),
          Tab(text: 'Citas'),
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
          _buildMedicalRecordsTab(),
          _buildVaccinationsTab(),
          _buildAppointmentsTab(),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMedicalRecordCard(
            date: '15 Nov 2024',
            diagnosis: 'Consulta de rutina',
            veterinarian: 'Dr. María González',
            notes: 'Mascota en excelente estado de salud.',
            status: 'Completado',
          ),
          const SizedBox(height: 12),
          _buildMedicalRecordCard(
            date: '20 Oct 2024',
            diagnosis: 'Vacunación anual',
            veterinarian: 'Dr. Carlos López',
            notes: 'Aplicación de vacuna múltiple.',
            status: 'Completado',
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed:
                  () => Navigator.pushNamed(
                    context,
                    '/medical-record',
                    arguments: pet,
                  ),
              icon: const Icon(Icons.folder_open_outlined),
              label: const Text('Ver Expediente Completo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildVaccinationsTab() {
    return ListView(
      children: [
        _buildVaccinationCard(
          vaccine: 'Vacuna Múltiple (DHPP)',
          date: '20 Oct 2024',
          nextDate: '20 Oct 2025',
          status: 'Al día',
        ),
        const SizedBox(height: 12),
        _buildVaccinationCard(
          vaccine: 'Antirrábica',
          date: '15 Oct 2024',
          nextDate: '15 Oct 2025',
          status: 'Al día',
        ),
        const SizedBox(height: 12),
        _buildVaccinationCard(
          vaccine: 'Bordetella',
          date: '10 May 2024',
          nextDate: '10 May 2025',
          status: 'Próxima',
        ),
      ],
    );
  }

  Widget _buildAppointmentsTab() {
    return ListView(
      children: [
        _buildAppointmentCard(
          date: '25 Dic 2024',
          time: '10:00 AM',
          type: 'Consulta de seguimiento',
          veterinarian: 'Dr. María González',
          status: 'Programada',
        ),
        const SizedBox(height: 12),
        _buildAppointmentCard(
          date: '15 Nov 2024',
          time: '3:00 PM',
          type: 'Consulta de rutina',
          veterinarian: 'Dr. María González',
          status: 'Completada',
        ),
        const SizedBox(height: 12),
        _buildAppointmentCard(
          date: '20 Oct 2024',
          time: '11:00 AM',
          type: 'Vacunación',
          veterinarian: 'Dr. Carlos López',
          status: 'Completada',
        ),
      ],
    );
  }

  Widget _buildMedicalRecordCard({
    required String date,
    required String diagnosis,
    required String veterinarian,
    required String notes,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      status == 'Completado'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        status == 'Completado' ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            diagnosis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            veterinarian,
            style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 8),
          Text(
            notes,
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

  Widget _buildVaccinationCard({
    required String vaccine,
    required String date,
    required String nextDate,
    required String status,
  }) {
    final isUpToDate = status == 'Al día';
    final statusColor = isUpToDate ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.vaccines_outlined, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccine,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aplicada: $date',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                Text(
                  'Próxima: $nextDate',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String date,
    required String time,
    required String type,
    required String veterinarian,
    required String status,
  }) {
    final isCompleted = status == 'Completada';
    final statusColor = isCompleted ? Colors.green : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date - $time',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                Text(
                  veterinarian,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _scheduleAppointment(),
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.calendar_today_outlined),
      label: const Text(
        'Agendar Cita',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  List<Color> _getSpeciesColors(String species) {
    switch (species.toLowerCase()) {
      case 'perro':
        return [const Color(0xFF4CAF50), const Color(0xFF81C784)];
      case 'gato':
        return [const Color(0xFF2196F3), const Color(0xFF64B5F6)];
      case 'ave':
        return [const Color(0xFFFF9800), const Color(0xFFFFB74D)];
      case 'pez':
        return [const Color(0xFF00BCD4), const Color(0xFF4DD0E1)];
      case 'reptil':
        return [const Color(0xFF4CAF50), const Color(0xFF81C784)];
      case 'hamster':
      case 'conejo':
        return [const Color(0xFF9C27B0), const Color(0xFFBA68C8)];
      default:
        return [const Color(0xFF607D8B), const Color(0xFF90A4AE)];
    }
  }

  String? _calculateAge(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) return null;

    try {
      final birth = DateTime.parse(birthDate);
      final now = DateTime.now();
      final difference = now.difference(birth);

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
    } catch (e) {
      return null;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editPet();
        break;
      case 'delete':
        _deletePet();
        break;
    }
  }

  void _editPet() {
    Navigator.pushNamed(context, '/edit-pet', arguments: pet).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          pet = result;
        });
      }
    });
  }

  void _scheduleAppointment() {
    Navigator.pushNamed(
      context,
      '/schedule-appointment',
      arguments: {'selectedPet': pet},
    );
  }

  void _deletePet() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Eliminar mascota'),
            content: Text(
              '¿Estás seguro de que quieres eliminar a ${pet['name'] ?? 'esta mascota'}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${pet['name'] ?? 'Mascota'} eliminado'),
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
}
