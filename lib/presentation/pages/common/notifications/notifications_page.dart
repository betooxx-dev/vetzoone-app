import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NotificationType {
  appointment,
  reminder,
  medical,
  promotion,
  system,
  emergency,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

class NotificationCard extends StatelessWidget {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  final bool isRead;
  final String? actionText;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  const NotificationCard({
    super.key,
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.timestamp,
    required this.isRead,
    this.actionText,
    this.imageUrl,
    this.onTap,
    this.onMarkAsRead,
    this.onDismiss,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.transparent : _getTypeColor().withOpacity(0.3),
          width: isRead ? 0 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: _getTypeColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isRead ? const Color(0xFF7F8C8D) : const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF95A5A6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getTypeColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: isRead ? const Color(0xFF7F8C8D) : const Color(0xFF2C3E50),
                  height: 1.4,
                ),
              ),
              if (imageUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: const Color(0xFFF8F9FA),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Color(0xFF95A5A6),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getTypeColor(),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      actionText!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (type) {
      case NotificationType.appointment:
        return const Color(0xFF3498DB);
      case NotificationType.reminder:
        return const Color(0xFFF39C12);
      case NotificationType.medical:
        return const Color(0xFF27AE60);
      case NotificationType.promotion:
        return const Color(0xFF9B59B6);
      case NotificationType.system:
        return const Color(0xFF95A5A6);
      case NotificationType.emergency:
        return const Color(0xFFE74C3C);
    }
  }

  IconData _getTypeIcon() {
    switch (type) {
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.medical:
        return Icons.medical_services;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.system:
        return Icons.system_update;
      case NotificationType.emergency:
        return Icons.emergency;
    }
  }

  String _formatTimestamp() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late TabController _tabController;

  bool _isLoading = false;
  String _selectedFilter = 'Todas';
  List<Map<String, dynamic>> _allNotifications = [];
  List<Map<String, dynamic>> _filteredNotifications = [];

  final List<String> _filterOptions = [
    'Todas',
    'Citas',
    'Recordatorios',
    'Médicas',
    'Sistema'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _loadNotifications();
    _animationController.forward();
  }

  void _loadNotifications() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _allNotifications = [
            {
              'id': '1',
              'title': 'Cita Agendada',
              'message': 'Tu cita con Dr. María González ha sido confirmada para mañana a las 10:00 AM. Recuerda llegar 15 minutos antes.',
              'type': NotificationType.appointment,
              'priority': NotificationPriority.normal,
              'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
              'isRead': false,
              'actionText': 'Ver Detalles',
              'actionData': {
                'appointmentId': 'apt_001',
                'vetName': 'Dr. María González',
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
          ];
          _isLoading = false;
          _applyFilters();
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

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allNotifications);

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

  void _handleNotificationAction(String notificationId, Map<String, dynamic>? actionData) async {
    final notification = _allNotifications.firstWhere((n) => n['id'] == notificationId);
    final type = notification['type'] as NotificationType;
    
    HapticFeedback.mediumImpact();
    
    switch (type) {
      case NotificationType.appointment:
        Navigator.pushNamed(context, '/appointment-detail');
        break;
      case NotificationType.reminder:
        await Navigator.pushNamed(context, '/schedule-appointment');
        // Como ahora la navegación va directamente a my-appointments,
        // no necesitamos manejar un resultado aquí
        break;
      case NotificationType.medical:
        if (actionData?['consultationId'] != null) {
          Navigator.pushNamed(context, '/medical-record');
        } else {
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
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildFiltersSection(),
              
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
            Icons.notifications_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'Todas'
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
            'Las notificaciones aparecerán aquí cuando las recibas',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}