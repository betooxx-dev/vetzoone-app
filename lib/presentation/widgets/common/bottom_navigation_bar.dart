import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isVeterinarian;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isVeterinarian = false,
  });

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != widget.currentIndex) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      widget.onTap(index);
    }
  }

  List<_BottomNavItem> get _ownerItems => [
    _BottomNavItem(
      icon: Icons.home_rounded,
      label: 'Inicio',
      activeColor: const Color(0xFF4CAF50),
    ),
    _BottomNavItem(
      icon: Icons.pets_rounded,
      label: 'Mascotas',
      activeColor: const Color(0xFF4CAF50),
    ),
    _BottomNavItem(
      icon: Icons.search_rounded,
      label: 'Buscar',
      activeColor: const Color(0xFF4CAF50),
    ),
    _BottomNavItem(
      icon: Icons.calendar_today_rounded,
      label: 'Citas',
      activeColor: const Color(0xFF4CAF50),
    ),
    _BottomNavItem(
      icon: Icons.person_rounded,
      label: 'Perfil',
      activeColor: const Color(0xFF4CAF50),
    ),
  ];

  List<_BottomNavItem> get _veterinarianItems => [
    _BottomNavItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      activeColor: const Color(0xFF81D4FA),
    ),
    _BottomNavItem(
      icon: Icons.calendar_month_rounded,
      label: 'Agenda',
      activeColor: const Color(0xFF81D4FA),
    ),
    _BottomNavItem(
      icon: Icons.people_rounded,
      label: 'Pacientes',
      activeColor: const Color(0xFF81D4FA),
    ),
    _BottomNavItem(
      icon: Icons.settings_rounded,
      label: 'Configuración',
      activeColor: const Color(0xFF81D4FA),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = widget.isVeterinarian ? _veterinarianItems : _ownerItems;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _buildNavItem(
                item: items[index],
                index: index,
                isSelected: widget.currentIndex == index,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required _BottomNavItem item,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale:
                        isSelected && widget.currentIndex == index
                            ? _scaleAnimation.value
                            : 1.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? item.activeColor.withOpacity(0.15)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              item.icon,
                              size: 24,
                              color:
                                  isSelected
                                      ? item.activeColor
                                      : const Color(0xFF9E9E9E),
                            ),
                          ),
                          if (item.label == 'Notificaciones')
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isSelected ? item.activeColor : const Color(0xFF9E9E9E),
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final String label;
  final Color activeColor;

  _BottomNavItem({
    required this.icon,
    required this.label,
    required this.activeColor,
  });
}
