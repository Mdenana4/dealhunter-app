import 'dart:math' show pi;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int dealCount;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.dealCount = 0,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ringControllers;

  @override
  void initState() {
    super.initState();
    // 3 expanding ring animations for radar pulse
    _ringControllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 2000 + i * 400),
      ),
    );
    for (final c in _ringControllers) {
      c.repeat();
    }
  }

  @override
  void dispose() {
    for (final c in _ringControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // Glassmorphism background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkBackground.withOpacity(0.85),
                ),
              ),
            ),
            // Nav items row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Home (0)
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  badge: widget.dealCount > 0 ? widget.dealCount.toString() : null,
                ),
                // Explore (1)
                _buildNavItem(
                  index: 1,
                  icon: Icons.explore_rounded,
                  label: 'Explore',
                ),
                // Radar center button (2)
                _buildRadarButton(),
                // Saved (3)
                _buildNavItem(
                  index: 3,
                  icon: Icons.bookmark_rounded,
                  label: 'Saved',
                ),
                // Profile (4)
                _buildNavItem(
                  index: 4,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    String? badge,
  }) {
    final isActive = widget.currentIndex == index;
    final color = isActive ? AppColors.electricOrange : AppColors.textMuted;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: AnimatedScale(
          scale: isActive ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 24,
                    shadows: isActive
                        ? [
                            Shadow(
                              color: AppColors.electricOrange.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  if (badge != null)
                    Positioned(
                      top: -6,
                      right: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.electricOrange,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.darkBackground,
                            width: 1.5,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarButton() {
    final isActive = widget.currentIndex == 2;

    return GestureDetector(
      onTap: () => widget.onTap(2),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Expanding rings
            ..._ringControllers.asMap().entries.map((entry) {
              final i = entry.key;
              final ctrl = entry.value;
              return AnimatedBuilder(
                animation: ctrl,
                builder: (context, child) {
                  return Container(
                    width: 40 + ctrl.value * 30,
                    height: 40 + ctrl.value * 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.deepPurple.withOpacity(
                          (1 - ctrl.value) * 0.4,
                        ),
                        width: 1,
                      ),
                    ),
                  );
                },
              );
            }),
            // Main button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive
                    ? AppColors.orangePurple
                    : LinearGradient(
                        colors: [
                          AppColors.electricOrange.withOpacity(0.6),
                          AppColors.deepPurple.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricOrange.withOpacity(isActive ? 0.4 : 0.2),
                    blurRadius: isActive ? 16 : 8,
                    spreadRadius: isActive ? 2 : 0,
                  ),
                ],
              ),
              child: Icon(
                Icons.radar,
                color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
