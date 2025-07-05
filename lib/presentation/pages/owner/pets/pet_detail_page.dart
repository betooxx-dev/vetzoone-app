import 'package:flutter/material.dart';

class PetDetailPage extends StatefulWidget {
  final Map<String, String>? petData;

  const PetDetailPage({super.key, this.petData});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Mock data - En producción vendría del argumento o API
  Map<String, String> pet = {};

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

    // Inicializar datos por defecto
    _initializePetData();
    _animationController.forward();
  }

  void _initializePetData() {
    // Datos por defecto
    final defaultPet = {
      'name': 'Max',
      'breed': 'Labrador Retriever',
      'age': '3 años',
      'species': 'Perro',
      'gender': 'Macho',
      'weight': '25 kg',
      'color': 'Dorado',
      'birthDate': '15/03/2021',
      'image': 'assets/images/dog_placeholder.png',
    };

    // Intentar obtener argumentos de la ruta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;

      if (arguments != null && arguments is Map<String, String>) {
        setState(() {
          pet = arguments;
        });
      } else if (widget.petData != null) {
        setState(() {
          pet = widget.petData!;
        });
      } else {
        setState(() {
          pet = defaultPet;
        });
      }
    });

    // Usar datos por defecto inicialmente
    pet = widget.petData ?? defaultPet;
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
    final colors = _getSpeciesColors(pet['species']!);

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: colors[0],
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
                        const Text('Compartir'),
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
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'pet_${pet['name']}',
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  _getSpeciesIcon(pet['species']!),
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetInfo() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  pet['name']!,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
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
                    // ignore: deprecated_member_use
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
                  value: pet['age'] ?? 'Desconocida',
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
                  value: pet['weight'] ?? 'No registrado',
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
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF757575)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF757575),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF212121),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

  // En pet_detail_page.dart, buscar el método _buildMedicalRecordsTab() y REEMPLAZARLO por:

  Widget _buildMedicalRecordsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mostrar algunas consultas recientes como preview
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
          // Botón para ver expediente completo
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                diagnosis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.person_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                veterinarian,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
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
    final isUpcoming = status == 'Próxima';
    final statusColor =
        isUpcoming ? const Color(0xFFFF7043) : const Color(0xFF4CAF50);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isUpcoming
                  // ignore: deprecated_member_use
                  ? statusColor.withOpacity(0.3)
                  : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  vaccine,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Última aplicación',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Próxima aplicación',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nextDate,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isUpcoming ? statusColor : const Color(0xFF212121),
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

  Widget _buildAppointmentCard({
    required String date,
    required String time,
    required String type,
    required String veterinarian,
    required String status,
  }) {
    final isUpcoming = status == 'Programada';
    final statusColor =
        isUpcoming ? const Color(0xFF81D4FA) : const Color(0xFF4CAF50);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isUpcoming
                  // ignore: deprecated_member_use
                  ? statusColor.withOpacity(0.3)
                  : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  type,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
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
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '$date - $time',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.person_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                veterinarian,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
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

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editPet();
        break;
      case 'share':
        _sharePet();
        break;
      case 'delete':
        _deletePet();
        break;
    }
  }

  void _editPet() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar ${pet['name'] ?? 'mascota'}'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _sharePet() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartir información de ${pet['name'] ?? 'mascota'}'),
        backgroundColor: const Color(0xFF81D4FA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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

  void _scheduleAppointment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agendar cita para ${pet['name'] ?? 'mascota'}'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
