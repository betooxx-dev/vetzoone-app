import 'package:flutter/material.dart';

enum AppointmentStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rescheduled,
}

class AppointmentCard extends StatelessWidget {
  final String petName;
  final String veterinarianName;
  final String appointmentType;
  final DateTime dateTime;
  final AppointmentStatus status;
  final String? clinic;
  final String? notes;
  final double? cost;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onConfirm;
  final bool isOwnerView;
  final String? ownerName;

  const AppointmentCard({
    super.key,
    required this.petName,
    required this.veterinarianName,
    required this.appointmentType,
    required this.dateTime,
    required this.status,
    this.clinic,
    this.notes,
    this.cost,
    this.onTap,
    this.onCancel,
    this.onReschedule,
    this.onConfirm,
    this.isOwnerView = true,
    this.ownerName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // ignore: deprecated_member_use
            color: _getStatusColor().withOpacity(0.2),
            width: 1,
          ),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildMainInfo(),
              const SizedBox(height: 12),
              _buildDetails(),
              if (_shouldShowActions()) ...[
                const SizedBox(height: 16),
                _buildActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointmentType,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                isOwnerView ? veterinarianName : '$petName - $ownerName',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoItem(
            Icons.pets_rounded,
            'Mascota',
            petName,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoItem(
            Icons.schedule_rounded,
            'Fecha y hora',
            _formatDateTime(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      children: [
        if (clinic != null)
          Row(
            children: [
              Icon(
                Icons.local_hospital_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  clinic!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        if (cost != null) ...[
          if (clinic != null) const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.attach_money_rounded,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Costo: \$${cost!.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
        if (notes != null && notes!.isNotEmpty) ...[
          if (clinic != null || cost != null) const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.note_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  notes!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF757575)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF757575),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF212121),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final canCancel = status == AppointmentStatus.scheduled || 
                     status == AppointmentStatus.confirmed;
    final canReschedule = status == AppointmentStatus.scheduled;
    final canConfirm = status == AppointmentStatus.scheduled && !isOwnerView;

    return Row(
      children: [
        if (canConfirm && onConfirm != null) ...[
          Expanded(
            child: _buildActionButton(
              'Confirmar',
              Icons.check_rounded,
              const Color(0xFF4CAF50),
              onConfirm!,
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (canReschedule && onReschedule != null) ...[
          Expanded(
            child: _buildActionButton(
              'Reprogramar',
              Icons.schedule_rounded,
              const Color(0xFF81D4FA),
              onReschedule!,
            ),
          ),
          if (canCancel) const SizedBox(width: 8),
        ],
        if (canCancel && onCancel != null)
          Expanded(
            child: _buildActionButton(
              'Cancelar',
              Icons.close_rounded,
              const Color(0xFFFF7043),
              onCancel!,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: color),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  bool _shouldShowActions() {
    return (onCancel != null || onReschedule != null || onConfirm != null) &&
           status != AppointmentStatus.completed &&
           status != AppointmentStatus.cancelled;
  }

  Color _getStatusColor() {
    switch (status) {
      case AppointmentStatus.scheduled:
        return const Color(0xFF81D4FA);
      case AppointmentStatus.confirmed:
        return const Color(0xFF4CAF50);
      case AppointmentStatus.inProgress:
        return const Color(0xFFFF9800);
      case AppointmentStatus.completed:
        return const Color(0xFF66BB6A);
      case AppointmentStatus.cancelled:
        return const Color(0xFF757575);
      case AppointmentStatus.rescheduled:
        return const Color(0xFFFF7043);
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Icons.schedule_rounded;
      case AppointmentStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case AppointmentStatus.inProgress:
        return Icons.medical_services_rounded;
      case AppointmentStatus.completed:
        return Icons.check_circle_rounded;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.rescheduled:
        return Icons.update_rounded;
    }
  }

  String _getStatusText() {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Programada';
      case AppointmentStatus.confirmed:
        return 'Confirmada';
      case AppointmentStatus.inProgress:
        return 'En curso';
      case AppointmentStatus.completed:
        return 'Completada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
      case AppointmentStatus.rescheduled:
        return 'Reprogramada';
    }
  }

  String _formatDateTime() {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    // Si es hoy
    if (dateTime.day == now.day && 
        dateTime.month == now.month && 
        dateTime.year == now.year) {
      return 'Hoy ${_formatTime()}';
    }
    
    // Si es mañana
    final tomorrow = now.add(const Duration(days: 1));
    if (dateTime.day == tomorrow.day && 
        dateTime.month == tomorrow.month && 
        dateTime.year == tomorrow.year) {
      return 'Mañana ${_formatTime()}';
    }
    
    // Si es en los próximos 7 días
    if (difference.inDays >= 0 && difference.inDays <= 7) {
      final weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      final weekday = weekdays[dateTime.weekday - 1];
      return '$weekday ${_formatTime()}';
    }
    
    // Fecha completa
    return '${dateTime.day}/${dateTime.month} ${_formatTime()}';
  }

  String _formatTime() {
    final hour = dateTime.hour == 0 ? 12 : dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    
    return '$hour:$minute $period';
  }
}