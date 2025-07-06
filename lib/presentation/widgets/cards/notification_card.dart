import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NotificationType {
  appointment,
  reminder,
  medical,
  system,
  promotion,
  emergency,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

class NotificationCard extends StatefulWidget {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  final bool isRead;
  final bool isExpanded;
  final Map<String, dynamic>? actionData;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onAction;
  final String? actionText;
  final IconData? customIcon;
  final String? imageUrl;

  const NotificationCard({
    super.key,
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.priority = NotificationPriority.normal,
    required this.timestamp,
    this.isRead = false,
    this.isExpanded = false,
    this.actionData,
    this.onTap,
    this.onDismiss,
    this.onMarkAsRead,
    this.onAction,
    this.actionText,
    this.customIcon,
    this.imageUrl,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case NotificationType.appointment:
        return const Color(0xFF3498DB);
      case NotificationType.reminder:
        return const Color(0xFFF39C12);
      case NotificationType.medical:
        return const Color(0xFF27AE60);
      case NotificationType.system:
        return const Color(0xFF95A5A6);
      case NotificationType.promotion:
        return const Color(0xFF9B59B6);
      case NotificationType.emergency:
        return const Color(0xFFE74C3C);
    }
  }

  Color _getPriorityColor() {
    switch (widget.priority) {
      case NotificationPriority.low:
        return const Color(0xFF95A5A6);
      case NotificationPriority.normal:
        return const Color(0xFF3498DB);
      case NotificationPriority.high:
        return const Color(0xFFF39C12);
      case NotificationPriority.urgent:
        return const Color(0xFFE74C3C);
    }
  }

  IconData _getTypeIcon() {
    if (widget.customIcon != null) return widget.customIcon!;
    
    switch (widget.type) {
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.reminder:
        return Icons.access_time;
      case NotificationType.medical:
        return Icons.medical_services;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.emergency:
        return Icons.priority_high;
    }
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(widget.timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${widget.timestamp.day}/${widget.timestamp.month}';
    }
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    if (!widget.isRead) {
      widget.onMarkAsRead?.call();
    }
    widget.onTap?.call();
  }

  void _handleAction() {
    HapticFeedback.mediumImpact();
    widget.onAction?.call();
  }

  void _handleDismiss() {
    HapticFeedback.lightImpact();
    widget.onDismiss?.call();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: widget.isRead 
                ? null 
                : Border.all(
                    color: _getPriorityColor().withOpacity(0.3),
                    width: 2,
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _handleTap,
              child: Stack(
                children: [
                  // Indicador de no leído
                  if (!widget.isRead)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  
                  // Contenido principal
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header con icono y timestamp
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getTypeColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
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
                                    widget.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: widget.isRead 
                                          ? FontWeight.w600 
                                          : FontWeight.bold,
                                      color: const Color(0xFF2C3E50),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getTimeAgo(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7F8C8D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Botón de dismiss
                            if (widget.onDismiss != null)
                              IconButton(
                                onPressed: _handleDismiss,
                                icon: const Icon(
                                  Icons.close,
                                  color: Color(0xFF95A5A6),
                                  size: 18,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Mensaje principal
                        Text(
                          widget.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.isRead 
                                ? const Color(0xFF7F8C8D) 
                                : const Color(0xFF2C3E50),
                            height: 1.4,
                          ),
                          maxLines: widget.isExpanded ? null : 2,
                          overflow: widget.isExpanded 
                              ? TextOverflow.visible 
                              : TextOverflow.ellipsis,
                        ),
                        
                        // Imagen si existe
                        if (widget.imageUrl != null) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.imageUrl!,
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
                        
                        // Botón de acción
                        if (widget.onAction != null && widget.actionText != null) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleAction,
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
                                widget.actionText!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                        
                        // Indicador de prioridad alta/urgente
                        if (widget.priority == NotificationPriority.high ||
                            widget.priority == NotificationPriority.urgent) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.priority == NotificationPriority.urgent
                                      ? Icons.warning
                                      : Icons.priority_high,
                                  color: _getPriorityColor(),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.priority == NotificationPriority.urgent
                                      ? 'URGENTE'
                                      : 'ALTA PRIORIDAD',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _getPriorityColor(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget helper para mostrar diferentes tipos de notificaciones
class NotificationCardPresets {
  static NotificationCard appointment({
    required String id,
    required String petName,
    required String veterinarianName,
    required DateTime appointmentDate,
    required VoidCallback onConfirm,
    required VoidCallback onReschedule,
    bool isRead = false,
  }) {
    return NotificationCard(
      id: id,
      title: 'Recordatorio de Cita',
      message: 'Tienes una cita programada para $petName con $veterinarianName mañana a las 10:00 AM',
      type: NotificationType.appointment,
      priority: NotificationPriority.high,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: isRead,
      actionText: 'Confirmar Cita',
      onAction: onConfirm,
    );
  }

  static NotificationCard vaccination({
    required String id,
    required String petName,
    required DateTime dueDate,
    required VoidCallback onSchedule,
    bool isRead = false,
  }) {
    return NotificationCard(
      id: id,
      title: 'Vacuna Vencida',
      message: '$petName tiene una vacuna vencida desde hace 3 días. Es importante agendar una cita pronto.',
      type: NotificationType.reminder,
      priority: NotificationPriority.urgent,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: isRead,
      actionText: 'Agendar Vacuna',
      onAction: onSchedule,
    );
  }

  static NotificationCard treatment({
    required String id,
    required String petName,
    required String medicationName,
    required VoidCallback onMarkGiven,
    bool isRead = false,
  }) {
    return NotificationCard(
      id: id,
      title: 'Hora del Medicamento',
      message: 'Es hora de dar $medicationName a $petName. No olvides seguir las indicaciones del veterinario.',
      type: NotificationType.medical,
      priority: NotificationPriority.normal,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: isRead,
      actionText: 'Marcar como Dado',
      onAction: onMarkGiven,
    );
  }

  static NotificationCard system({
    required String id,
    required String title,
    required String message,
    VoidCallback? onAction,
    String? actionText,
    bool isRead = false,
  }) {
    return NotificationCard(
      id: id,
      title: title,
      message: message,
      type: NotificationType.system,
      priority: NotificationPriority.low,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: isRead,
      actionText: actionText,
      onAction: onAction,
    );
  }
}