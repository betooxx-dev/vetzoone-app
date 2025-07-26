import 'package:flutter/material.dart';
import 'user_avatar.dart';
import '../../../core/services/user_service.dart';

class UserHeader extends StatefulWidget {
  final List<Color> gradientColors;
  final double height;
  final bool showNotificationButton;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final String? subtitle;

  const UserHeader({
    super.key,
    this.gradientColors = const [Color(0xFF0D9488), Color(0xFF14B8A6)],
    this.height = 140,
    this.showNotificationButton = true,
    this.onNotificationTap,
    this.onAvatarTap,
    this.subtitle,
  });

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  Map<String, dynamic> userData = {};
  String userGreeting = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await UserService.getCurrentUser();
    final greeting = await UserService.getUserGreeting();
    setState(() {
      userData = user;
      userGreeting = greeting;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.gradientColors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              UserAvatar(
                imageUrl: userData['profilePhoto'],
                size: 60,
                borderColor: Colors.white,
                borderWidth: 2,
                onTap: widget.onAvatarTap,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userGreeting,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle ?? userData['email'] ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.showNotificationButton)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    onPressed: widget.onNotificationTap,
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
