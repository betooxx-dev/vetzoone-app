import 'package:flutter/material.dart';
import 'dart:async';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _checkController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _checkAnimation;

  bool _isVerified = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  final String _userEmail = "usuario@ejemplo.com";

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEmailCheck();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _pulseController.repeat(reverse: true);
  }

  void _startEmailCheck() {
    Timer(const Duration(seconds: 10), () {
      if (mounted && !_isVerified) {
        _verifyEmail();
      }
    });
  }

  void _verifyEmail() {
    setState(() {
      _isVerified = true;
    });

    _pulseController.stop();
    _checkController.forward();

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
        );
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown > 0) return;

    setState(() {
      _isResending = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isResending = false;
      _resendCooldown = 60; 
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCooldown--;
      });

      if (_resendCooldown <= 0) {
        timer.cancel();
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Correo de verificación reenviado'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _checkController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildBackButton(),
              const Spacer(),
              _buildVerificationContent(),
              const Spacer(),
              _buildActionButtons(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationContent() {
    return Column(
      children: [
        _buildEmailIcon(),
        const SizedBox(height: 40),
        _buildTitle(),
        const SizedBox(height: 16),
        _buildDescription(),
        const SizedBox(height: 32),
        _buildEmailDisplay(),
      ],
    );
  }

  Widget _buildEmailIcon() {
    return AnimatedBuilder(
      animation: _isVerified ? _checkAnimation : _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isVerified ? _checkAnimation.value : _pulseAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    _isVerified
                        ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                        : [const Color(0xFF81D4FA), const Color(0xFF4FC3F7)],
              ),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: (_isVerified
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF81D4FA))
                      // ignore: deprecated_member_use
                      .withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              _isVerified ? Icons.check_circle_outline : Icons.email_outlined,
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Text(
      _isVerified ? '¡Verificación Exitosa!' : 'Verifica tu correo',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: _isVerified ? const Color(0xFF4CAF50) : const Color(0xFF212121),
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      _isVerified
          ? 'Tu cuenta ha sido verificada correctamente.\nSerás redirigido en un momento.'
          : 'Te hemos enviado un enlace de verificación.\nRevisa tu bandeja de entrada y spam.',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF757575),
        height: 1.5,
      ),
    );
  }

  Widget _buildEmailDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.email_outlined,
              color: Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Correo enviado a:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _userEmail,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF212121),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isVerified) {
      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          ),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Continuar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient:
                _resendCooldown > 0
                    ? null
                    : const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    ),
            color: _resendCooldown > 0 ? const Color(0xFFE0E0E0) : null,
            boxShadow:
                _resendCooldown > 0
                    ? null
                    : [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
          ),
          child: ElevatedButton(
            onPressed:
                _resendCooldown > 0 || _isResending ? null : _resendEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor:
                  _resendCooldown > 0 ? const Color(0xFF757575) : Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child:
                _isResending
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.5,
                      ),
                    )
                    : Text(
                      _resendCooldown > 0
                          ? 'Reenviar en ${_resendCooldown}s'
                          : 'Reenviar correo',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF4CAF50), width: 2),
          ),
          child: TextButton(
            onPressed: _verifyEmail,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Ya verifiqué mi correo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Usar otro correo electrónico',
            style: TextStyle(
              color: Color(0xFF757575),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
