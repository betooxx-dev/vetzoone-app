import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/services/user_service.dart';
import '../../../../core/injection/injection.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../../data/datasources/vet/vet_remote_datasource.dart';

class VeterinarianDashboardPage extends StatefulWidget {
  const VeterinarianDashboardPage({super.key});

  @override
  State<VeterinarianDashboardPage> createState() =>
      _VeterinarianDashboardPageState();
}

class _VeterinarianDashboardPageState extends State<VeterinarianDashboardPage> {
  String userGreeting = 'Cargando...';
  bool _isCheckingVetProfile = true;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    await _loadUserData();
    await _checkVetProfile();
  }

  Future<void> _loadUserData() async {
    final greeting = await UserService.getUserGreeting();
    setState(() {
      userGreeting = greeting;
    });
  }

  Future<void> _checkVetProfile() async {
    try {
      setState(() {
        _isCheckingVetProfile = true;
      });

      final userId = await SharedPreferencesHelper.getUserId();
      if (userId == null) {
        print('❌ No se encontró userId en SharedPreferences');
        return;
      }

      // Primero verificar en SharedPreferences
      final savedVetData = await SharedPreferencesHelper.getVetData();
      if (savedVetData != null) {
        print('✅ Datos del veterinario encontrados en SharedPreferences');
        print('Veterinario: ${savedVetData['name']} - Licencia: ${savedVetData['license']}');
        return; // Ya tiene perfil completo guardado localmente
      }

      print('🔍 No se encontraron datos locales, verificando en servidor para userId: $userId');
      
      final vetDataSource = sl<VetRemoteDataSource>();
      final vetData = await vetDataSource.getVetByUserId(userId);
      
      // Si se encuentra en el servidor, guardar en SharedPreferences
      await SharedPreferencesHelper.saveVetData(vetData);
      print('✅ Veterinario encontrado en servidor y guardado localmente');
    } catch (e) {
      print('❌ Error al verificar perfil de veterinario: $e');
      
      // Verificar si es un error 404 (veterinario no encontrado)
      if (e.toString().contains('404') || e.toString().contains('no encontrado')) {
        print('🚨 Veterinario no encontrado - Mostrando modal de completar perfil');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            print('🔄 Widget montado, mostrando modal...');
            _showCompleteProfileModal();
          } else {
            print('❌ Widget no montado, no se puede mostrar modal');
          }
        });
      }
    } finally {
      setState(() {
        _isCheckingVetProfile = false;
      });
    }
  }

  void _showCompleteProfileModal() {
    print('🔄 Intentando mostrar modal de completar perfil');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          // Blur background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          // Modal
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Título
                  const Text(
                    'Completa tu perfil profesional',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Descripción
                  const Text(
                    'Para utilizar tu cuenta de veterinario, necesitas completar la siguiente información profesional.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF757575),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Botón Continuar
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF81D4FA).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showVetProfileForm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Continuar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVetProfileForm() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VetProfileFormModal(
        onProfileCompleted: () {
          Navigator.pop(context);
          // Recargar el dashboard después de completar el perfil
          _checkVetProfile();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingVetProfile) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF81D4FA)),
              ),
              SizedBox(height: 16),
              Text(
                'Verificando perfil profesional...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTodayStats(),
                    const SizedBox(height: 32),
                    _buildTodaySchedule(),
                    const SizedBox(height: 32),
                    _buildQuickActions(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userGreeting,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Medicina General',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen de Hoy',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Citas',
                value: '8',
                subtitle: '3 completadas',
                icon: Icons.calendar_today_rounded,
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Pacientes',
                value: '6',
                subtitle: '2 nuevos',
                icon: Icons.pets_rounded,
                color: const Color(0xFF81D4FA),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Ingresos',
                value: '\$2,450',
                subtitle: 'Hoy',
                icon: Icons.attach_money_rounded,
                color: const Color(0xFF66BB6A),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Urgencias',
                value: '1',
                subtitle: 'Pendiente',
                icon: Icons.warning_rounded,
                color: const Color(0xFFFF7043),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Agenda de Hoy',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/my-schedule');
              },
              child: const Text(
                'Ver agenda',
                style: TextStyle(
                  color: Color(0xFF81D4FA),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/appointment-detail-vet');
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF4CAF50), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '10:00',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Max - Juan Pérez',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Consulta General',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Siguiente',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Configurar\nHorarios',
                icon: Icons.schedule_rounded,
                color: const Color(0xFFFF7043),
                onTap: () {
                  Navigator.pushNamed(context, '/configure-schedule');
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                title: 'Ver\nEstadísticas',
                icon: Icons.analytics_rounded,
                color: const Color(0xFF9C27B0),
                onTap: () {
                  Navigator.pushNamed(context, '/statistics');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget del formulario modal para completar el perfil del veterinario
class VetProfileFormModal extends StatefulWidget {
  final VoidCallback onProfileCompleted;

  const VetProfileFormModal({
    super.key,
    required this.onProfileCompleted,
  });

  @override
  State<VetProfileFormModal> createState() => _VetProfileFormModalState();
}

class _VetProfileFormModalState extends State<VetProfileFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _licenseController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isLoading = false;
  String _fullName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final firstName = await SharedPreferencesHelper.getUserFirstName();
    final lastName = await SharedPreferencesHelper.getUserLastName();
    
    setState(() {
      _fullName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    });
    
    print('📝 Nombre construido automáticamente: $_fullName');
  }

  @override
  void dispose() {
    _licenseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndSaveVetData(String userId) async {
    try {
      print('🔄 Obteniendo datos completos del veterinario...');
      
      final vetDataSource = sl<VetRemoteDataSource>();
      final vetData = await vetDataSource.getVetByUserId(userId);
      
      print('📥 Datos del veterinario obtenidos: $vetData');
      
      // Guardar en SharedPreferences
      await SharedPreferencesHelper.saveVetData(vetData);
      
      print('✅ Datos del veterinario guardados en SharedPreferences');
    } catch (e) {
      print('❌ Error al obtener y guardar datos del veterinario: $e');
      // No hacer throw aquí para no interrumpir el flujo principal
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await SharedPreferencesHelper.getUserId();
      if (userId == null) {
        throw Exception('No se encontró ID del usuario');
      }

      // Datos según el DTO requerido
      final vetData = {
        'name': _fullName,
        'license': _licenseController.text.trim(),
        'description': _descriptionController.text.trim(),
        'user_id': userId,
      };

      print('📋 Enviando datos del veterinario: $vetData');

      final vetDataSource = sl<VetRemoteDataSource>();
      await vetDataSource.createVet(vetData);

      print('✅ Perfil de veterinario creado exitosamente');

      // Obtener los datos completos del veterinario recién creado
      await _fetchAndSaveVetData(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil profesional completado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onProfileCompleted();
      }
    } catch (e) {
      print('❌ Error al crear perfil de veterinario: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al completar el perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blur background
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        // Modal
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.medical_services_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Información Profesional',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Información del nombre (automático)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF81D4FA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF81D4FA).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                color: Color(0xFF81D4FA),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Nombre profesional',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF81D4FA),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _fullName.isNotEmpty ? _fullName : 'Cargando...',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Este nombre se obtiene automáticamente de tu perfil',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF757575),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Campo Licencia
                    TextFormField(
                      controller: _licenseController,
                      decoration: InputDecoration(
                        labelText: 'Cédula profesional',
                        hintText: '09718342',
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
                          color: Color(0xFF81D4FA),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
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
                          borderSide: const BorderSide(
                            color: Color(0xFF81D4FA),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu cédula profesional';
                        }
                        if (value.trim().length < 4) {
                          return 'La cédula profesional debe tener al menos 4 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Leyenda de validación
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFE69C),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFFB45309),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tu cédula profesional será validada con el Registro Nacional de Profesionales Veterinarios',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB45309),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Campo Descripción
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Descripción profesional',
                        hintText: 'Veterinario especializado en cirugía y medicina preventiva...',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(
                            Icons.description_outlined,
                            color: Color(0xFF81D4FA),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
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
                          borderSide: const BorderSide(
                            color: Color(0xFF81D4FA),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa una descripción';
                        }
                        if (value.trim().length < 20) {
                          return 'La descripción debe tener al menos 20 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Botón único - obligatorio completar
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF81D4FA).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Completar Perfil Profesional',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
