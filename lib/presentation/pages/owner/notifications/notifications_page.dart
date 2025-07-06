import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../widgets/cards/notification_card.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late TabController _tabController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> _allNotifications = [];
  List<Map<String, dynamic>> _filteredNotifications = [];
  String _selectedFilter = 'Todas';
  bool _isLoading = true;
  bool _showOnlyUnread = false;

  final List<String> _filterOptions = [
    'Todas',
    'Citas',
    'Recordatorios',
    'Médicas',
    'Sistema',
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _tabController = TabController(length: 2, vsync: this);
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _loadNotifications();
    _animationController.forward();
  }

  void _loadNotifications() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _allNotifications = [
            {
              'id': '1',
              'title': 'Recordatorio de Cita',
              'message': 'Tu cita con Dr. María González para Luna es mañana a las 10:00 AM. No olvides llevar su cartilla de vacunación.',
              'type': NotificationType.appointment,
              'priority': NotificationPriority.high,
              'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
              'isRead': false,
              'actionText': 'Confirmar Cita',
              'actionData': {
                'appointmentId': 'apt_001',
                'petName': 'Luna',
                'veterinarianName': 'Dr. María González',
              },
            },
            {
              'id': '2',
              'title': 'Vacuna Vencida',
              'message': 'Max tiene la vacuna antirrábica vencida desde hace 3 días. Es importante agendar una cita pronto para mantener su protección.',
              'type': NotificationType.reminder,
              'priority': NotificationPriority.urgent,
              'timestamp': DateTime.now().subtract(const Duration(days: 1)),
              'isRead': false,
              'actionText': 'Agendar Vacuna',
              'actionData': {
                'petName': 'Max',
                'vaccineType': 'Antirrábica',
              },
            },
            {
              'id': '3',
              'title': 'Hora del Medicamento',
              'message': 'Es hora de dar Amoxicilina a Milo. Recuerda que debe tomarlo con comida según las indicaciones del veterinario.',
              'type': NotificationType.medical,
              'priority': NotificationPriority.normal,
              'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
              'isRead': false,
              'actionText': 'Marcar como Dado',
              'actionData': {
                'treatmentId': 'treat_001',
                'petName': 'Milo',
                'medication': 'Amoxicilina',
              },
            },
            {
              'id': '4',
              'title': 'Consulta Completada',
              'message': 'La consulta de Luna ha sido completada. Ya puedes ver el expediente médico actualizado con el diagnóstico y tratamiento.',
              'type': NotificationType.medical,
              'priority': NotificationPriority.normal,
              'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
              'isRead': true,
              'actionText': 'Ver Expediente',
              'actionData': {
                'petName': 'Luna',
                'consultationId': 'cons_001',
              },
            },
            {
              'id': '5',
              'title': 'Promoción Especial',
              'message': '¡20% de descuento en consultas de rutina este mes! Aprovecha para mantener al día la salud de tu mascota.',
              'type': NotificationType.promotion,
              'priority': NotificationPriority.low,
              'timestamp': DateTime.now().subtract(const Duration(days: 2)),
              'isRead': true,
              'imageUrl': 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=400&h=200&fit=crop',
              'actionText': 'Ver Promoción',
              'actionData': {
                'promoCode': 'RUTINA20',
              },
            },
            {
              'id': '6',
              'title': 'Actualización de la App',
              'message': 'Nueva versión disponible con mejoras en la visualización de expedientes médicos y notificaciones más precisas.',
              'type': NotificationType.system,
              'priority': NotificationPriority.low,
              'timestamp': DateTime.now().subtract(const Duration(days: 3)),
              'isRead': true,
              'actionText': 'Actualizar',
              'actionData': {
                'version': '2.1.0',
              },
            },
            {
              'id': '7',
              'title': 'Emergencia Veterinaria',
              'message': 'Dr. Carlos López ha marcado el caso de Rocky como urgente. Se requiere atención inmediata.',
              'type': NotificationType.emergency,
              'priority': NotificationPriority.urgent,
              'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
              'isRead': true,
              'actionText': 'Ver Caso',
              'actionData': {
                'petName': 'Rocky',
                'caseId': 'emergency_001',
              },
            },
          ];
          _filteredNotifications = _allNotifications;
          _isLoading = false;
        });
      }
    });
  }

  void _filterNotifications(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  void _toggleUnreadFilter() {
    setState(() {
      _showOnlyUnread = !_showOnlyUnread;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = _allNotifications;

    // Filtrar por tipo
    if (_selectedFilter != 'Todas') {
      NotificationType? filterType;
      switch (_selectedFilter) {
        case 'Citas':
          filterType = NotificationType.appointment;
          break;
        case 'Recordatorios':
          filterType = NotificationType.reminder;
          break;
        case 'Médicas':
          filterType = NotificationType.medical;
          break;
        case 'Sistema':
          filterType = NotificationType.system;
          break;
      }
      
      if (filterType != null) {
        filtered = filtered.where((notification) {
          return notification['type'] == filterType;
        }).toList();
      }
    }

    // Filtrar por estado de lectura
    if (_showOnlyUnread) {
      filtered = filtered.where((notification) {
        return notification['isRead'] == false;
      }).toList();
    }

    _filteredNotifications = filtered;
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _allNotifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _allNotifications[index]['isRead'] = true;
        _applyFilters();
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _allNotifications) {
        notification['isRead'] = true;
      }
      _applyFilters();
    });
    
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todas las notificaciones marcadas como leídas'),
        backgroundColor: Color(0xFF27AE60),
      ),
    );
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      _allNotifications.removeWhere((n) => n['id'] == notificationId);
      _applyFilters();
    });
    
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notificación eliminada'),
        backgroundColor: Color(0xFF3498DB),
      ),
    );
  }

  void _handleNotificationAction(String notificationId, Map<String, dynamic>? actionData) {
    final notification = _allNotifications.firstWhere((n) => n['id'] == notificationId);
    final type = notification['type'] as NotificationType;
    
    HapticFeedback.mediumImpact();
    
    switch (type) {
      case NotificationType.appointment:
        Navigator.pushNamed(context, '/appointment-detail');
        break;
      case NotificationType.reminder:
        Navigator.pushNamed(context, '/schedule-appointment');
        break;
      case NotificationType.medical:
        if (actionData?['consultationId'] != null) {
          Navigator.pushNamed(context, '/medical-record');
        } else {
          // Marcar medicamento como dado
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Medicamento marcado como administrado a ${actionData?['petName']}'),
              backgroundColor: const Color(0xFF27AE60),
            ),
          );
        }
        break;
      case NotificationType.promotion:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Código promocional: ${actionData?['promoCode']}'),
            backgroundColor: const Color(0xFF9B59B6),
          ),
        );
        break;
      case NotificationType.system:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dirigiendo a la tienda de aplicaciones...'),
            backgroundColor: Color(0xFF95A5A6),
          ),
        );
        break;
      case NotificationType.emergency:
        Navigator.pushNamed(context, '/patient-history');
        break;
    }
  }

  int _getUnreadCount() {
    return _allNotifications.where((n) => !n['isRead']).length;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notificaciones',
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            if (_getUnreadCount() > 0)
              Text(
                '${_getUnreadCount()} sin leer',
                style: const TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showOnlyUnread ? Icons.mark_email_read : Icons.mark_email_unread,
              color: const Color(0xFF3498DB),
            ),
            onPressed: _toggleUnreadFilter,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF2C3E50)),
            onSelected: (value) {
              if (value == 'mark_all_read') {
                _markAllAsRead();
              } else if (value == 'settings') {
                _showNotificationSettings();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all, color: Color(0xFF27AE60)),
                    SizedBox(width: 8),
                    Text('Marcar todas como leídas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Color(0xFF95A5A6)),
                    SizedBox(width: 8),
                    Text('Configuración'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Filtros
              _buildFiltersSection(),
              
              // Lista de notificaciones
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredNotifications.isEmpty
                        ? _buildEmptyState()
                        : _buildNotificationsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      height: 60,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;
                
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) => _filterNotifications(filter),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF3498DB).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF3498DB),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF3498DB) : const Color(0xFF7F8C8D),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF3498DB) : const Color(0xFFE0E0E0),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 1,
            color: const Color(0xFFE0E0E0),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: _filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = _filteredNotifications[index];
        return NotificationCard(
          id: notification['id'],
          title: notification['title'],
          message: notification['message'],
          type: notification['type'],
          priority: notification['priority'] ?? NotificationPriority.normal,
          timestamp: notification['timestamp'],
          isRead: notification['isRead'],
          actionText: notification['actionText'],
          imageUrl: notification['imageUrl'],
          onTap: () => _markAsRead(notification['id']),
          onMarkAsRead: () => _markAsRead(notification['id']),
          onDismiss: () => _deleteNotification(notification['id']),
          onAction: () => _handleNotificationAction(
            notification['id'],
            notification['actionData'],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showOnlyUnread ? Icons.mark_email_read : Icons.notifications_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _showOnlyUnread 
                ? 'No tienes notificaciones sin leer'
                : _selectedFilter == 'Todas'
                    ? 'No tienes notificaciones'
                    : 'No hay notificaciones de $_selectedFilter',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showOnlyUnread
                ? '¡Excelente! Estás al día con todas tus notificaciones'
                : 'Las notificaciones aparecerán aquí cuando las recibas',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (_showOnlyUnread) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _toggleUnreadFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
              ),
              child: const Text('Ver todas las notificaciones'),
            ),
          ],
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configuración de Notificaciones',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 20),
              _buildSettingTile(
                'Recordatorios de Citas',
                'Recibe notificaciones antes de tus citas',
                true,
              ),
              _buildSettingTile(
                'Vacunas y Tratamientos',
                'Alertas para vacunas y medicamentos',
                true,
              ),
              _buildSettingTile(
                'Promociones',
                'Ofertas especiales de veterinarias',
                false,
              ),
              _buildSettingTile(
                'Actualizaciones del Sistema',
                'Noticias y actualizaciones de la app',
                true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar Configuración'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingTile(String title, String subtitle, bool enabled) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: enabled,
      onChanged: (value) {
        // Implementar cambio de configuración
        HapticFeedback.lightImpact();
      },
      activeColor: const Color(0xFF3498DB),
    );
  }
}