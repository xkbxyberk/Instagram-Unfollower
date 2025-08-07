import 'package:flutter/material.dart';

mixin AnimationControllersMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late AnimationController slideController;
  late AnimationController pulseController;
  late AnimationController bounceController;
  late AnimationController slideInController;
  late AnimationController glowController;
  late AnimationController headerAnimationController;

  late Animation<Offset> slideAnimation;
  late Animation<double> pulseAnimation;
  late Animation<double> bounceAnimation;
  late Animation<Offset> slideInAnimation;
  late Animation<double> glowAnimation;
  late Animation<double> headerAnimation;

  void initializeAnimations() {
    slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    slideInController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: slideController,
        curve: Curves.easeInOutCubic,
      ),
    );

    pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: bounceController, curve: Curves.elasticOut),
    );

    slideInAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: slideInController, curve: Curves.elasticOut),
    );

    glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: glowController, curve: Curves.easeInOut),
    );

    headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: headerAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Start repeating animations
    pulseController.repeat(reverse: true);
    glowController.repeat(reverse: true);
    headerAnimationController.repeat(reverse: true);
  }

  void disposeAnimations() {
    slideController.dispose();
    pulseController.dispose();
    bounceController.dispose();
    slideInController.dispose();
    glowController.dispose();
    headerAnimationController.dispose();
  }
}
