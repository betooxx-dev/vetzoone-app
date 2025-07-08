import 'package:flutter/material.dart';

class EmptyStateWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;
  final double iconSize;
  final double spacing;
  final bool animated;
  final EdgeInsets padding;
  final Widget? customIcon;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    this.buttonText,
    this.onButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    this.iconSize = 80.0,
    this.spacing = 16.0,
    this.animated = true,
    this.padding = const EdgeInsets.all(40.0),
    this.customIcon,
    this.titleStyle,
    this.subtitleStyle,
  });

  factory EmptyStateWidget.pets({
    String? title,
    String? subtitle,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.pets_outlined,
      title: title ?? 'No tienes mascotas',
      subtitle: subtitle ?? 'Agrega tu primera mascota para comenzar a gestionar su salud',
      color: const Color(0xFF8B5CF6),
      buttonText: buttonText ?? 'Agregar Mascota',
      onButtonPressed: onButtonPressed,
    );
  }

  factory EmptyStateWidget.appointments({
    String? title,
    String? subtitle,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.calendar_today_outlined,
      title: title ?? 'No hay citas programadas',
      subtitle: subtitle ?? 'Aquí verás todas tus citas cuando las tengas programadas',
      color: const Color(0xFF06B6D4),
      buttonText: buttonText ?? 'Agendar Cita',
      onButtonPressed: onButtonPressed,
    );
  }

  factory EmptyStateWidget.notifications({
    String? title,
    String? subtitle,
  }) {
    return EmptyStateWidget(
      icon: Icons.notifications_none_outlined,
      title: title ?? 'No tienes notificaciones',
      subtitle: subtitle ?? 'Te notificaremos sobre citas, recordatorios y novedades',
      color: const Color(0xFFF59E0B),
    );
  }

  factory EmptyStateWidget.patients({
    String? title,
    String? subtitle,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.medical_services_outlined,
      title: title ?? 'No hay pacientes',
      subtitle: subtitle ?? 'Los pacientes que atiendas aparecerán aquí',
      color: const Color(0xFF10B981),
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  factory EmptyStateWidget.search({
    String? title,
    String? subtitle,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.search_off_outlined,
      title: title ?? 'No se encontraron resultados',
      subtitle: subtitle ?? 'Intenta con otros términos de búsqueda',
      color: const Color(0xFF6B7280),
      buttonText: buttonText ?? 'Limpiar Filtros',
      onButtonPressed: onButtonPressed,
    );
  }

  factory EmptyStateWidget.medicalRecords({
    String? title,
    String? subtitle,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.description_outlined,
      title: title ?? 'No hay registros médicos',
      subtitle: subtitle ?? 'El historial médico aparecerá aquí después de las consultas',
      color: const Color(0xFF0D9488),
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  factory EmptyStateWidget.statistics({
    String? title,
    String? subtitle,
  }) {
    return EmptyStateWidget(
      icon: Icons.analytics_outlined,
      title: title ?? 'No hay datos suficientes',
      subtitle: subtitle ?? 'Las estadísticas aparecerán cuando tengas más actividad',
      color: const Color(0xFF8B5CF6),
    );
  }

  factory EmptyStateWidget.favorites({
    String? title,
    String? subtitle,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.favorite_border_outlined,
      title: title ?? 'No tienes favoritos',
      subtitle: subtitle ?? 'Marca veterinarios como favoritos para acceso rápido',
      color: const Color(0xFFEF4444),
      buttonText: buttonText ?? 'Explorar Veterinarios',
      onButtonPressed: onButtonPressed,
    );
  }

  factory EmptyStateWidget.network({
    String? title,
    String? subtitle,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.wifi_off_outlined,
      title: title ?? 'Sin conexión',
      subtitle: subtitle ?? 'Verifica tu conexión a internet e intenta de nuevo',
      color: const Color(0xFFEF4444),
      buttonText: buttonText ?? 'Reintentar',
      onButtonPressed: onButtonPressed,
    );
  }

  factory EmptyStateWidget.error({
    String? title,
    String? subtitle,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: title ?? 'Algo salió mal',
      subtitle: subtitle ?? 'Ha ocurrido un error inesperado. Por favor intenta de nuevo',
      color: const Color(0xFFEF4444),
      buttonText: buttonText ?? 'Reintentar',
      onButtonPressed: onButtonPressed,
    );
  }

  factory EmptyStateWidget.maintenance({
    String? title,
    String? subtitle,
  }) {
    return EmptyStateWidget(
      icon: Icons.build_outlined,
      title: title ?? 'En mantenimiento',
      subtitle: subtitle ?? 'Estamos mejorando esta función. Regresa pronto',
      color: const Color(0xFFF59E0B),
    );
  }

  factory EmptyStateWidget.comingSoon({
    String? title,
    String? subtitle,
  }) {
    return EmptyStateWidget(
      icon: Icons.upcoming_outlined,
      title: title ?? 'Próximamente',
      subtitle: subtitle ?? 'Esta función estará disponible en una futura actualización',
      color: const Color(0xFF8B5CF6),
    );
  }

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _setupAnimations();
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    if (widget.animated) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? const Color(0xFF6B7280);
    
    if (!widget.animated) {
      return _buildContent(effectiveColor);
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildContent(effectiveColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(Color effectiveColor) {
    return Center(
      child: Padding(
        padding: widget.padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono principal
            _buildIcon(effectiveColor),
            SizedBox(height: widget.spacing),
            
            // Título
            _buildTitle(effectiveColor),
            SizedBox(height: widget.spacing * 0.5),
            
            // Subtítulo
            _buildSubtitle(),
            
            // Botones de acción
            if (widget.buttonText != null || widget.secondaryButtonText != null) ...[
              SizedBox(height: widget.spacing * 1.5),
              _buildButtons(effectiveColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    if (widget.customIcon != null) {
      return widget.customIcon!;
    }

    return Container(
      width: widget.iconSize + 40,
      height: widget.iconSize + 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular((widget.iconSize + 40) / 2),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Icon(
        widget.icon,
        size: widget.iconSize,
        color: color,
      ),
    );
  }

  Widget _buildTitle(Color color) {
    return Text(
      widget.title,
      style: widget.titleStyle ?? TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      widget.subtitle,
      style: widget.subtitleStyle ?? const TextStyle(
        fontSize: 14,
        color: Color(0xFF6B7280),
        height: 1.4,
      ),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildButtons(Color color) {
    return Column(
      children: [
        // Botón principal
        if (widget.buttonText != null && widget.onButtonPressed != null)
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 280),
            child: ElevatedButton(
              onPressed: widget.onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.buttonText!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        
        // Botón secundario
        if (widget.secondaryButtonText != null && widget.onSecondaryButtonPressed != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 280),
            child: OutlinedButton(
              onPressed: widget.onSecondaryButtonPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.secondaryButtonText!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Widget para múltiples empty states en un carrusel
class EmptyStateCarousel extends StatefulWidget {
  final List<EmptyStateWidget> states;
  final Duration autoScrollDuration;
  final bool autoScroll;

  const EmptyStateCarousel({
    super.key,
    required this.states,
    this.autoScrollDuration = const Duration(seconds: 4),
    this.autoScroll = true,
  });

  @override
  State<EmptyStateCarousel> createState() => _EmptyStateCarouselState();
}

class _EmptyStateCarouselState extends State<EmptyStateCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    if (widget.autoScroll && widget.states.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    Future.delayed(widget.autoScrollDuration, () {
      if (mounted && _pageController.hasClients) {
        final nextIndex = (_currentIndex + 1) % widget.states.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.states.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.states.length == 1) {
      return widget.states.first;
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.states.length,
            itemBuilder: (context, index) {
              return widget.states[index];
            },
          ),
        ),
        
        // Indicadores de página
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.states.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? const Color(0xFF0D9488)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Extensión para crear empty states rápidamente
extension EmptyStateExtension on BuildContext {
  Widget emptyPets({VoidCallback? onAddPet}) {
    return EmptyStateWidget.pets(
      onButtonPressed: onAddPet,
    );
  }

  Widget emptyAppointments({VoidCallback? onSchedule}) {
    return EmptyStateWidget.appointments(
      onButtonPressed: onSchedule,
    );
  }

  Widget emptyNotifications() {
    return EmptyStateWidget.notifications();
  }

  Widget emptySearch({VoidCallback? onClearFilters}) {
    return EmptyStateWidget.search(
      onButtonPressed: onClearFilters,
    );
  }

  Widget networkError({VoidCallback? onRetry}) {
    return EmptyStateWidget.network(
      onButtonPressed: onRetry,
    );
  }

  Widget genericError({VoidCallback? onRetry}) {
    return EmptyStateWidget.error(
      onButtonPressed: onRetry,
    );
  }
}