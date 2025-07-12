import 'package:flutter/material.dart';

class VeterinarianProfilePage extends StatefulWidget {
  final Map<String, dynamic>? veterinarianData;

  const VeterinarianProfilePage({super.key, this.veterinarianData});

  @override
  State<VeterinarianProfilePage> createState() =>
      _VeterinarianProfilePageState();
}

class _VeterinarianProfilePageState extends State<VeterinarianProfilePage> {
  late Map<String, dynamic> veterinarian;

  @override
  void initState() {
    super.initState();
    _initializeVeterinarianData();
  }

  void _initializeVeterinarianData() {
    final defaultVeterinarian = {
      'id': '1',
      'name': 'Dr. María González',
      'specialty': 'Medicina General Veterinaria',
      'clinic': 'Veterinaria Central',
      'experience': '8 años',
      'distance': '2.3 km',
      'location': 'Av. Central #123, Tuxtla Gutiérrez',
      'phone': '+52 961 123 4567',
      'email': 'maria.gonzalez@vetcentral.com',
      'schedule': {
        'Lunes': '8:00 AM - 6:00 PM',
        'Martes': '8:00 AM - 6:00 PM',
        'Miércoles': '8:00 AM - 6:00 PM',
        'Jueves': '8:00 AM - 6:00 PM',
        'Viernes': '8:00 AM - 6:00 PM',
        'Sábado': '9:00 AM - 2:00 PM',
        'Domingo': 'Cerrado',
      },
      'services': [
        'Consultas generales',
        'Vacunación',
        'Cirugías menores',
        'Emergencias',
        'Control de peso',
        'Análisis clínicos',
      ],
      'nextAppointment': 'Hoy 3:00 PM',
      'consultationPrice': 450,
      'description':
          'Veterinaria especializada en medicina general con amplia experiencia en el cuidado integral de mascotas. Enfoque preventivo y trato personalizado.',
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map<String, dynamic>) {
        setState(() {
          veterinarian = Map<String, dynamic>.from(arguments);
          // Ensure schedule exists with default values
          if (veterinarian['schedule'] == null) {
            veterinarian['schedule'] = {
              'Lunes': '8:00 AM - 6:00 PM',
              'Martes': '8:00 AM - 6:00 PM',
              'Miércoles': '8:00 AM - 6:00 PM',
              'Jueves': '8:00 AM - 6:00 PM',
              'Viernes': '8:00 AM - 6:00 PM',
              'Sábado': '9:00 AM - 2:00 PM',
              'Domingo': 'Cerrado',
            };
          }
          // Ensure services exists
          if (veterinarian['services'] == null) {
            veterinarian['services'] = [
              'Consultas generales',
              'Vacunación',
              'Cirugías menores',
              'Emergencias',
            ];
          }
        });
      }
    });

    veterinarian = widget.veterinarianData ?? defaultVeterinarian;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildVeterinarianInfo(),
                _buildContactInfo(),
                _buildScheduleInfo(),
                _buildServicesInfo(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF4CAF50),
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
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Hero(
                tag: 'vet-${veterinarian['id'] ?? 'default'}',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
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
                'Experiencia',
                veterinarian['experience'] ?? '0 años',
                Icons.timeline_outlined,
                const Color(0xFFFF7043),
              ),
              _buildStatItem(
                'Distancia',
                veterinarian['distance'] ?? '0 km',
                Icons.location_on_outlined,
                const Color(0xFF2196F3),
              ),
              _buildStatItem(
                'Consulta',
                '\$${veterinarian['consultationPrice'] ?? 0}',
                Icons.attach_money_outlined,
                const Color(0xFF4CAF50),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            veterinarian['description'] ?? 'Sin descripción disponible',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF757575),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
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
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Información de Contacto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.business_outlined,
            'Clínica',
            veterinarian['clinic'] ?? 'No especificada',
          ),
          _buildContactItem(
            Icons.location_on_outlined,
            'Dirección',
            veterinarian['location'] ?? 'No especificada',
          ),
          _buildContactItem(
            Icons.phone_outlined,
            'Teléfono',
            veterinarian['phone'] ?? 'No especificado',
            isClickable: true,
          ),
          _buildContactItem(
            Icons.email_outlined,
            'Email',
            veterinarian['email'] ?? 'No especificado',
            isClickable: true,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value, {
    bool isClickable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap:
                      isClickable
                          ? () => _handleContactAction(label, value)
                          : null,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          isClickable
                              ? const Color(0xFF2196F3)
                              : const Color(0xFF212121),
                      decoration: isClickable ? TextDecoration.underline : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleInfo() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Horarios de Atención',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          ...veterinarian['schedule'].entries.map<Widget>((entry) {
            return _buildScheduleItem(entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String day, String hours) {
    final isToday = _isToday(day);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color:
                  isToday ? const Color(0xFF4CAF50) : const Color(0xFF212121),
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              color:
                  isToday ? const Color(0xFF4CAF50) : const Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Servicios Disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                veterinarian['services'].map<Widget>((service) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      service,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  );
                }).toList(),
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

  void _handleContactAction(String type, String value) {
    String message = '';
    if (type == 'Teléfono') {
      message = 'Llamando a $value...';
    } else if (type == 'Email') {
      message = 'Abriendo email para $value...';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _scheduleAppointment() {
    Navigator.pushNamed(
      context,
      '/schedule-appointment',
      arguments: {'selectedVeterinarian': veterinarian},
    );
  }
}
