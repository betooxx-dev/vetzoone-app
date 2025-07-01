import 'package:flutter/material.dart';

class VeterinarianDashboardPage extends StatefulWidget {
  const VeterinarianDashboardPage({super.key});

  @override
  State<VeterinarianDashboardPage> createState() =>
      _VeterinarianDashboardPageState();
}

class _VeterinarianDashboardPageState extends State<VeterinarianDashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeOut),
    );
    _refreshController.forward();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _refreshController.reset();
    await Future.delayed(const Duration(seconds: 1));
    _refreshController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFF81D4FA),
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _refreshAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _refreshAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _refreshAnimation.value)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTodayStats(),
                              const SizedBox(height: 32),
                              _buildTodaySchedule(),
                              const SizedBox(height: 32),
                              _buildQuickActions(),
                              const SizedBox(height: 32),
                              _buildRecentPatients(),
                              const SizedBox(height: 32),
                              _buildAlertsSection(),
                              const SizedBox(
                                height: 100,
                              ), // Space for bottom nav
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: const Color(0xFF81D4FA),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dr. María González',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Medicina General',
                              style: TextStyle(
                                fontSize: 16,
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              onPressed: () {
                                // Implementar notificaciones
                              },
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              onPressed: () {
                                // Implementar configuración
                              },
                              icon: const Icon(
                                Icons.settings_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
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
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
            style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            TextButton(
              onPressed: () {
                // Ver agenda completa
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
        _buildAppointmentItem(
          time: '10:00',
          petName: 'Max',
          ownerName: 'Juan Pérez',
          type: 'Consulta General',
          status: 'next',
        ),
        const SizedBox(height: 12),
        _buildAppointmentItem(
          time: '11:30',
          petName: 'Luna',
          ownerName: 'Ana García',
          type: 'Vacunación',
          status: 'scheduled',
        ),
        const SizedBox(height: 12),
        _buildAppointmentItem(
          time: '14:00',
          petName: 'Rocky',
          ownerName: 'Carlos López',
          type: 'Cirugía Menor',
          status: 'scheduled',
        ),
      ],
    );
  }

  Widget _buildAppointmentItem({
    required String time,
    required String petName,
    required String ownerName,
    required String type,
    required String status,
  }) {
    final isNext = status == 'next';
    final color = isNext ? const Color(0xFF4CAF50) : const Color(0xFF81D4FA);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            // ignore: deprecated_member_use
            isNext ? Border.all(color: color.withOpacity(0.3), width: 2) : null,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  time.split(':')[0],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  time.split(':')[1],
                  style: TextStyle(fontSize: 12, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$petName - $ownerName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          if (isNext)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Siguiente',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_circle_outline_rounded,
                title: 'Nueva Consulta',
                gradient: const [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                onTap: () {
                  // Nueva consulta
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                icon: Icons.schedule_rounded,
                title: 'Configurar Horarios',
                gradient: const [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
                onTap: () {
                  // Configurar horarios
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: gradient[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const Spacer(),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPatients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pacientes Recientes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            TextButton(
              onPressed: () {
                // Ver todos los pacientes
              },
              child: const Text(
                'Ver todos',
                style: TextStyle(
                  color: Color(0xFF81D4FA),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 95,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            children: [
              _buildPatientCard('Max', 'Labrador', 'Juan P.'),
              const SizedBox(width: 10),
              _buildPatientCard('Luna', 'Gato Persa', 'Ana G.'),
              const SizedBox(width: 10),
              _buildPatientCard('Rocky', 'Bulldog', 'Carlos L.'),
              const SizedBox(width: 10),
              _buildPatientCard('Milo', 'Golden', 'María R.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(String petName, String breed, String ownerName) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: const Color(0xFF81D4FA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.pets_rounded,
                color: Color(0xFF81D4FA),
                size: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              petName,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              breed,
              style: const TextStyle(fontSize: 9, color: Color(0xFF757575)),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              ownerName,
              style: const TextStyle(
                fontSize: 8,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alertas y Recordatorios',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        _buildAlertCard(
          icon: Icons.warning_rounded,
          title: 'Urgencia pendiente',
          subtitle: 'Rocky - Revisión post-cirugía',
          color: const Color(0xFFFF7043),
          priority: 'alta',
        ),
        const SizedBox(height: 12),
        _buildAlertCard(
          icon: Icons.event_note_rounded,
          title: 'Seguimiento programado',
          subtitle: 'Max - Control en 1 semana',
          color: const Color(0xFF81D4FA),
          priority: 'media',
        ),
      ],
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String priority,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        priority.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
        ],
      ),
    );
  }
}
