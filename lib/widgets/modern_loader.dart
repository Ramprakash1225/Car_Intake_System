import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/language_provider.dart';

/// Modern, rich loading overlay widget with animated effects
class ModernLoader extends StatelessWidget {
  final String? message;
  final Color? primaryColor;
  final Color? secondaryColor;

  const ModernLoader({
    super.key,
    this.message,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = primaryColor ?? const Color(0xFF1E3A8A);
    final secondary = secondaryColor ?? Colors.blue.shade300;
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated rotating loader
              _AnimatedLoader(primary: primary, secondary: secondary),
              const SizedBox(height: 24),
              // Message text
              if (message != null)
                Text(
                  message!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    letterSpacing: 0.5,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  languageProvider.translate('Loading...', 'ஏற்றுகிறது...'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    letterSpacing: 0.5,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                languageProvider.translate(
                    'Please wait', 'தயவுசெய்து காத்திருக்கவும்'),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedLoader extends StatefulWidget {
  final Color primary;
  final Color secondary;

  const _AnimatedLoader({
    required this.primary,
    required this.secondary,
  });

  @override
  State<_AnimatedLoader> createState() => _AnimatedLoaderState();
}

class _AnimatedLoaderState extends State<_AnimatedLoader>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.linear,
      ),
    );

    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    widget.primary,
                    widget.secondary,
                    widget.primary.withValues(alpha: 0.3),
                    widget.primary,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                  startAngle: 0,
                  endAngle: 2 * math.pi,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Icon(
                    Icons.refresh_rounded,
                    color: widget.primary,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Helper function to show modern loader overlay
void showModernLoader(BuildContext context, {String? message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (context) => ModernLoader(message: message),
  );
}

/// Helper function to hide modern loader overlay
void hideModernLoader(BuildContext context) {
  try {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  } catch (e) {
    // Silently handle if dialog is already dismissed or context is invalid
    debugPrint('Error hiding modern loader: $e');
  }
}
