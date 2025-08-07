import 'package:flutter/material.dart';
import '../utils/instagram_colors.dart';

class EdgeIndicator extends StatelessWidget {
  final bool isLoggedIn;
  final bool isPanelOpen;
  final bool hasResults;
  final int unfollowersCount;
  final Animation<Offset> slideInAnimation;
  final Animation<double> bounceAnimation;
  final Animation<double> glowAnimation;
  final Animation<double> pulseAnimation;
  final VoidCallback onTap;

  const EdgeIndicator({
    super.key,
    required this.isLoggedIn,
    required this.isPanelOpen,
    required this.hasResults,
    required this.unfollowersCount,
    required this.slideInAnimation,
    required this.bounceAnimation,
    required this.glowAnimation,
    required this.pulseAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn || isPanelOpen) return const SizedBox();

    return Positioned(
      right: 0,
      top: MediaQuery.of(context).size.height * 0.4,
      child: SlideTransition(
        position: slideInAnimation,
        child: ScaleTransition(
          scale: bounceAnimation,
          child: AnimatedBuilder(
            animation: glowAnimation,
            builder: (context, child) {
              return GestureDetector(
                onTap: onTap,
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    onTap();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(-5, 0),
                      ),
                      BoxShadow(
                        color: (hasResults
                                ? Colors.green
                                : InstagramColors.gradientColors[3])
                            .withValues(alpha: 0.4 * glowAnimation.value),
                        blurRadius: 25 + (15 * glowAnimation.value),
                        offset: const Offset(-10, 0),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 55,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: hasResults
                              ? [
                                  Colors.green.shade400.withValues(
                                    alpha: 0.85 + (0.15 * glowAnimation.value),
                                  ),
                                  Colors.green.shade600.withValues(
                                    alpha: 0.85 + (0.15 * glowAnimation.value),
                                  ),
                                  Colors.green.shade700.withValues(
                                    alpha: 0.85 + (0.15 * glowAnimation.value),
                                  ),
                                ]
                              : [
                                  InstagramColors.gradientColors[0].withValues(
                                    alpha: 0.85 + (0.15 * glowAnimation.value),
                                  ),
                                  InstagramColors.gradientColors[2].withValues(
                                    alpha: 0.85 + (0.15 * glowAnimation.value),
                                  ),
                                  InstagramColors.gradientColors[4].withValues(
                                    alpha: 0.85 + (0.15 * glowAnimation.value),
                                  ),
                                ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: pulseAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha: 0.25 + (0.15 * glowAnimation.value),
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                hasResults
                                    ? Icons.checklist_rounded
                                    : Icons.analytics_outlined,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (hasResults)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha: 0.9 + (0.1 * glowAnimation.value),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '$unfollowersCount',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 1.5,
                                  ),
                                  width: 3,
                                  height: 8 + (index == 1 ? 4 : 0),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha:
                                          (0.4 + (0.3 * glowAnimation.value)) *
                                              (index == 1 ? 1.2 : 0.8),
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
