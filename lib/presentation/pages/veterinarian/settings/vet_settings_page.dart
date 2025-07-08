import 'package:flutter/material.dart';

class VetSettingsPage extends StatefulWidget {
  const VetSettingsPage({super.key});

  @override
  State<VetSettingsPage> createState() => _VetSettingsPageState();
}

class _VetSettingsPageState extends State<VetSettingsPage> {
  // Configuraciones de notificaciones
  bool _appointmentNotifications = true;
  bool _patientReminders = true;
  bool _emergencyAlerts = true;
  bool _marketingEmails = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Configuraciones de privacidad
  bool _profileVisible = true;
  bool _phoneVisible = true;
  bool _emailVisible = true;
  bool _locationSharing = false;
  bool _analyticsEnabled = true;

  // Configuraciones de la aplicación
  String _theme = 'system'; // system, light, dark
  String _language = 'es'; // es, en
  bool _autoBackup = true;
  bool _wifiOnlySync = false;

  // Configuraciones profesionales
  bool _consultationReminders = true;
  int _reminderMinutes = 15;
  bool _patientDataEncryption = true;
  bool _automaticReports = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Configuraciones',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información del veterinario
            _buildUserHeader(),
            const SizedBox(height: 24),

            // Configuraciones de Notificaciones
            _buildNotificationSettings(),
            const SizedBox(height: 20),

            // Configuraciones Profesionales
            _buildProfessionalSettings(),
            const SizedBox(height: 20),

            // Configuraciones de Privacidad
            _buildPrivacySettings(),
            const SizedBox(height: 20),

            // Configuraciones de la Aplicación
            _buildAppSettings(),
            const SizedBox(height: 20),

            // Configuraciones de Cuenta
            _buildAccountSettings(),
            const SizedBox(height: 20),

            // Ayuda y Soporte
            _buildHelpSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dr. Ana Martínez',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Medicina General • Verificado',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Profesional Verificado',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSettingsSection(
      title: 'Notificaciones',
      icon: Icons.notifications_outlined,
      children: [
        _buildSwitchTile(
          title: 'Notificaciones de citas',
          subtitle: 'Recibe alertas sobre nuevas citas y cambios',
          value: _appointmentNotifications,
          onChanged: (value) {
            setState(() {
              _appointmentNotifications = value;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Recordatorios de pacientes',
          subtitle: 'Alertas sobre seguimiento y próximas consultas',
          value: _patientReminders,
          onChanged: (value) {
            setState(() {
              _patientReminders = value;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Alertas de emergencia',
          subtitle: 'Notificaciones urgentes fuera de horario',
          value: _emergencyAlerts,
          onChanged: (value) {
            setState(() {
              _emergencyAlerts = value;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Emails de marketing',
          subtitle: 'Recibe información sobre nuevas funciones',
          value: _marketingEmails,
          onChanged: (value) {
            setState(() {
              _marketingEmails = value;
            });
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Configuración de sonido',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMiniSwitchTile(
                title: 'Sonido',
                value: _soundEnabled,
                onChanged: (value) {
                  setState(() {
                    _soundEnabled = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMiniSwitchTile(
                title: 'Vibración',
                value: _vibrationEnabled,
                onChanged: (value) {
                  setState(() {
                    _vibrationEnabled = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfessionalSettings() {
    return _buildSettingsSection(
      title: 'Configuración Profesional',
      icon: Icons.medical_services_outlined,
      children: [
        _buildSwitchTile(
          title: 'Recordatorios de consulta',
          subtitle: 'Recibe alertas antes de cada consulta programada',
          value: _consultationReminders,
          onChanged: (value) {
            setState(() {
              _consultationReminders = value;
            });
          },
        ),
        if (_consultationReminders) ...[
          const SizedBox(height: 12),
          _buildSliderTile(
            title: 'Tiempo de recordatorio',
            subtitle: '$_reminderMinutes minutos antes de la consulta',
            value: _reminderMinutes.toDouble(),
            min: 5,
            max: 60,
            divisions: 11,
            onChanged: (value) {
              setState(() {
                _reminderMinutes = value.round();
              });
            },
          ),
        ],
        _buildSwitchTile(
          title: 'Encriptación de datos',
          subtitle: 'Protege la información médica de los pacientes',
          value: _patientDataEncryption,
          onChanged: (value) {
            setState(() {
              _patientDataEncryption = value;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Reportes automáticos',
          subtitle: 'Genera reportes semanales de actividad',
          value: _automaticReports,
          onChanged: (value) {
            setState(() {
              _automaticReports = value;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildActionTile(
          icon: Icons.schedule_outlined,
          title: 'Configurar horarios',
          subtitle: 'Gestiona tu agenda y disponibilidad',
          onTap: () {
            Navigator.pushNamed(context, '/configure-schedule');
          },
        ),
        _buildActionTile(
          icon: Icons.analytics_outlined,
          title: 'Ver estadísticas',
          subtitle: 'Revisa métricas de tu práctica profesional',
          onTap: () {
            Navigator.pushNamed(context, '/statistics');
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return _buildSettingsSection(
      title: 'Privacidad y Seguridad',
      icon: Icons.security_outlined,
      children: [
        _buildSwitchTile(
          title: 'Perfil visible',
          subtitle: 'Permite que los usuarios vean tu perfil profesional',
          value: _profileVisible,
          onChanged: (value) {
            setState(() {
              _profileVisible = value;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Mostrar teléfono',
          subtitle: 'Permite que los usuarios vean tu número de contacto',
          value: _phoneVisible,
          onChanged: (value) {
            setState(() {
              _phoneVisible = value;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Mostrar email',
          subtitle: 'Permite que los usuarios vean tu correo electrónico',
          value: _emailVisible,
          onChanged: (value) {
            setState(() {
              _emailVisible = value;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Compartir ubicación',
          subtitle: 'Ayuda a los usuarios a encontrar tu clínica',
          value: _locationSharing,
          onChanged: (value) {
            setState(() {
              _locationSharing = value;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Análisis de uso',
          subtitle: 'Ayúdanos a mejorar la app compartiendo estadísticas anónimas',
          value: _analyticsEnabled,
          onChanged: (value) {
            setState(() {
              _analyticsEnabled = value;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildActionTile(
          icon: Icons.lock_outline,
          title: 'Cambiar contraseña',
          subtitle: 'Actualiza tu contraseña de acceso',
          onTap: _showChangePasswordDialog,
        ),
        _buildActionTile(
          icon: Icons.security,
          title: 'Verificación en dos pasos',
          subtitle: 'Añade una capa extra de seguridad',
          onTap: () {
            // Implementar 2FA
          },
        ),
      ],
    );
  }

  Widget _buildAppSettings() {
    return _buildSettingsSection(
      title: 'Configuración de la App',
      icon: Icons.settings_outlined,
      children: [
        _buildDropdownTile(
          title: 'Tema de la aplicación',
          subtitle: 'Elige el aspecto visual que prefieras',
          value: _theme,
          items: const [
            {'value': 'system', 'label': 'Automático del sistema'},
            {'value': 'light', 'label': 'Claro'},
            {'value': 'dark', 'label': 'Oscuro'},
          ],
          onChanged: (value) {
            setState(() {
              _theme = value!;
            });
          },
        ),
        _buildDropdownTile(
          title: 'Idioma',
          subtitle: 'Selecciona el idioma de la interfaz',
          value: _language,
          items: const [
            {'value': 'es', 'label': 'Español'},
            {'value': 'en', 'label': 'English'},
          ],
          onChanged: (value) {
            setState(() {
              _language = value!;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Respaldo automático',
          subtitle: 'Sincroniza tus datos en la nube automáticamente',
          value: _autoBackup,
          onChanged: (value) {
            setState(() {
              _autoBackup = value;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Solo sincronizar con WiFi',
          subtitle: 'Usa solo WiFi para evitar consumo de datos móviles',
          value: _wifiOnlySync,
          onChanged: (value) {
            setState(() {
              _wifiOnlySync = value;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildActionTile(
          icon: Icons.storage_outlined,
          title: 'Gestionar almacenamiento',
          subtitle: 'Revisa y libera espacio ocupado por la app',
          onTap: _showStorageInfo,
        ),
      ],
    );
  }

  Widget _buildAccountSettings() {
    return _buildSettingsSection(
      title: 'Configuración de Cuenta',
      icon: Icons.account_circle_outlined,
      children: [
        _buildActionTile(
          icon: Icons.person_outline,
          title: 'Editar perfil profesional',
          subtitle: 'Actualiza tu información y especialidades',
          onTap: () {
            Navigator.pushNamed(context, '/professional-profile');
          },
        ),
        _buildActionTile(
          icon: Icons.verified_user_outlined,
          title: 'Verificación profesional',
          subtitle: 'Estado: Verificado',
          onTap: () {
            _showVerificationInfo();
          },
          trailing: const Icon(
            Icons.check_circle,
            color: Color(0xFF10B981),
            size: 20,
          ),
        ),
        _buildActionTile(
          icon: Icons.payment_outlined,
          title: 'Métodos de pago',
          subtitle: 'Gestiona cómo recibes pagos por consultas',
          onTap: () {
          },
        ),
        _buildActionTile(
          icon: Icons.download_outlined,
          title: 'Exportar datos',
          subtitle: 'Descarga una copia de tu información',
          onTap: _showExportOptions,
        ),
        const SizedBox(height: 16),
        _buildActionTile(
          icon: Icons.logout,
          title: 'Cerrar sesión',
          subtitle: 'Salir de la aplicación',
          onTap: _showLogoutDialog,
          isDestructive: true,
        ),
        _buildActionTile(
          icon: Icons.delete_forever_outlined,
          title: 'Eliminar cuenta',
          subtitle: 'Elimina permanentemente tu cuenta y datos',
          onTap: _showDeleteAccountDialog,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildHelpSettings() {
    return _buildSettingsSection(
      title: 'Ayuda y Soporte',
      icon: Icons.help_outline,
      children: [
        _buildActionTile(
          icon: Icons.quiz_outlined,
          title: 'Preguntas frecuentes',
          subtitle: 'Encuentra respuestas a dudas comunes',
          onTap: () {
          },
        ),
        _buildActionTile(
          icon: Icons.support_agent_outlined,
          title: 'Contactar soporte',
          subtitle: 'Obtén ayuda directa de nuestro equipo',
          onTap: () {
          },
        ),
        _buildActionTile(
          icon: Icons.book_outlined,
          title: 'Guía de uso',
          subtitle: 'Aprende a usar todas las funciones',
          onTap: () {
          },
        ),
        _buildActionTile(
          icon: Icons.feedback_outlined,
          title: 'Enviar comentarios',
          subtitle: 'Comparte tu opinión para mejorar la app',
          onTap: _showFeedbackDialog,
        ),
        _buildActionTile(
          icon: Icons.star_outline,
          title: 'Calificar la app',
          subtitle: 'Ayúdanos calificando en la tienda',
          onTap: () {
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Versión 1.0.0 (Build 100)',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF0D9488),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0D9488),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF0D9488),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF0D9488),
            inactiveTrackColor: const Color(0xFFE5E7EB),
            thumbColor: const Color(0xFF0D9488),
            overlayColor: const Color(0xFF0D9488).withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item['value'],
                    child: Text(
                      item['label']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDestructive 
                    ? const Color(0xFFEF4444).withOpacity(0.1)
                    : const Color(0xFF0D9488).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isDestructive 
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF0D9488),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDestructive 
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña actual',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nueva contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar nueva contraseña',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contraseña actualizada correctamente'),
                  backgroundColor: Color(0xFF0D9488),
                ),
              );
            },
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  void _showStorageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestión de Almacenamiento'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Uso de almacenamiento:'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Imágenes de pacientes'),
                Text('85.2 MB', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Datos de la aplicación'),
                Text('12.7 MB', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Caché'),
                Text('4.1 MB', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('102.0 MB', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Limpiar caché
            },
            child: const Text('Limpiar Caché'),
          ),
        ],
      ),
    );
  }

  void _showVerificationInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verificación Profesional'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified_user,
              size: 64,
              color: Color(0xFF10B981),
            ),
            SizedBox(height: 16),
            Text(
              'Tu cuenta está verificada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tu cédula profesional y documentos han sido validados por nuestro equipo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showExportOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Datos'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.description),
              title: Text('Exportar consultas'),
              subtitle: Text('Historial de consultas realizadas'),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Exportar pacientes'),
              subtitle: Text('Lista de pacientes atendidos'),
            ),
            ListTile(
              leading: Icon(Icons.analytics),
              title: Text('Exportar estadísticas'),
              subtitle: Text('Reportes y métricas de actividad'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exportación iniciada. Te enviaremos un email cuando esté lista.'),
                  backgroundColor: Color(0xFF0D9488),
                ),
              );
            },
            child: const Text('Exportar Todo'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar Comentarios'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Cuéntanos tu experiencia',
                hintText: 'Describe qué te gusta y qué podríamos mejorar...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                Icon(Icons.star, color: Colors.amber),
                Icon(Icons.star, color: Colors.amber),
                Icon(Icons.star, color: Colors.amber),
                Icon(Icons.star_border, color: Colors.grey),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Gracias por tus comentarios!'),
                  backgroundColor: Color(0xFF0D9488),
                ),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cuenta'),
        content: const Text(
          'Esta acción no se puede deshacer. Se eliminarán permanentemente:\n\n• Tu perfil profesional\n• Historial de consultas\n• Datos de pacientes\n• Configuraciones\n\n¿Estás completamente seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Eliminar Cuenta'),
          ),
        ],
      ),
    );
  }
}