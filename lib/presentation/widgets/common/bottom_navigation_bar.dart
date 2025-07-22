import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/constants/app_colors.dart';

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

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  void _onItemTapped(int index) {
    if (index != widget.currentIndex) {
      widget.onTap(index);
    }
  }

  List<_BottomNavItem> get _ownerItems => [
    _BottomNavItem(
      icon: Icons.home_rounded,
      label: 'Inicio',
      activeColor: AppColors.secondary,
      gradient: AppColors.orangeGradient,
    ),
    _BottomNavItem(
      icon: Icons.pets_rounded,
      label: 'Mascotas',
      activeColor: AppColors.secondary,
      gradient: AppColors.orangeGradient,
    ),
    _BottomNavItem(
      icon: Icons.search_rounded,
      label: 'Buscar',
      activeColor: AppColors.secondary,
      gradient: AppColors.orangeGradient,
    ),
    _BottomNavItem(
      icon: Icons.calendar_today_rounded,
      label: 'Citas',
      activeColor: AppColors.secondary,
      gradient: AppColors.orangeGradient,
    ),
    _BottomNavItem(
      icon: Icons.person_rounded,
      label: 'Perfil',
      activeColor: AppColors.secondary,
      gradient: AppColors.orangeGradient,
    ),
  ];

  List<_BottomNavItem> get _veterinarianItems => [
    _BottomNavItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      activeColor: AppColors.primary,
      gradient: AppColors.primaryGradient,
    ),
    _BottomNavItem(
      icon: Icons.calendar_month_rounded,
      label: 'Agenda',
      activeColor: AppColors.primary,
      gradient: AppColors.primaryGradient,
    ),
    _BottomNavItem(
      icon: Icons.people_rounded,
      label: 'Pacientes',
      activeColor: AppColors.primary,
      gradient: AppColors.primaryGradient,
    ),
    _BottomNavItem(
      icon: Icons.settings_rounded,
      label: 'Configuración',
      activeColor: AppColors.primary,
      gradient: AppColors.primaryGradient,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = widget.isVeterinarian ? _veterinarianItems : _ownerItems;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.white, AppColors.backgroundLight],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: isSelected ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            final iconColor = Color.lerp(
              AppColors.textSecondary,
              AppColors.white,
              value,
            );
            final textColor = Color.lerp(
              AppColors.textSecondary,
              item.activeColor,
              value,
            );
            final fontWeight = FontWeight.lerp(
              FontWeight.w500,
              FontWeight.w600,
              value,
            );

            const transparentGradient = LinearGradient(
              colors: [Colors.transparent, Colors.transparent],
            );

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: Gradient.lerp(
                        transparentGradient,
                        item.gradient,
                        value,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: item.activeColor.withOpacity(0.25 * value),
                          blurRadius: 6.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(item.icon, size: 26, color: iconColor),
                        ),
                        if (item.label == 'Notificaciones')
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: fontWeight,
                      color: textColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final String label;
  final Color activeColor;
  final Gradient gradient;

  _BottomNavItem({
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.gradient,
  });
}
