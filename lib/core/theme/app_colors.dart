import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Background ──
  static const Color darkBackground = Color(0xFF0A0A0F);
  static const Color cardBackground = Color(0xFF111118);
  static const Color surfaceLight = Color(0xFF1A1A24);
  static const Color surfaceLighter = Color(0xFF222230);

  // ── Brand Colors ──
  static const Color electricOrange = Color(0xFFF97316);
  static const Color electricOrangeLight = Color(0xFFFB923C);
  static const Color deepPurple = Color(0xFF8B5CF6);
  static const Color deepPurpleLight = Color(0xFFA78BFA);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color emeraldGreenLight = Color(0xFF34D399);
  static const Color crimsonRed = Color(0xFFEF4444);
  static const Color crimsonRedLight = Color(0xFFF87171);
  static const Color goldenYellow = Color(0xFFFBBF24);
  static const Color goldenYellowLight = Color(0xFFFCD34D);

  // ── Source Colors ──
  static const Color amazonOrange = Color(0xFFFF9900);
  static const Color noonYellow = Color(0xFFF7C200);
  static const Color jumiaOrange = Color(0xFFE4811C);

  // ── Text Colors ──
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // ── Status Colors ──
  static const Color statusGenuine = Color(0xFF10B981);
  static const Color statusVerified = Color(0xFF3B82F6);
  static const Color statusSuspicious = Color(0xFFF59E0B);
  static const Color statusFake = Color(0xFFEF4444);
  static const Color statusUnknown = Color(0xFF9CA3AF);

  // ── Gradient Presets ──
  static const LinearGradient orangePurple = LinearGradient(
    colors: [electricOrange, deepPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeYellow = LinearGradient(
    colors: [electricOrange, goldenYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purplePink = LinearGradient(
    colors: [deepPurple, Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldTeal = LinearGradient(
    colors: [emeraldGreen, Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldenAmber = LinearGradient(
    colors: [goldenYellow, Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Glassmorphism ──
  static BoxDecoration glassCard = BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.08),
      width: 1,
    ),
  );

  static BoxDecoration glassCardStrong = BoxDecoration(
    color: Colors.white.withOpacity(0.08),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.12),
      width: 1,
    ),
  );

  static BoxDecoration glassPill = BoxDecoration(
    color: Colors.white.withOpacity(0.06),
    borderRadius: BorderRadius.circular(50),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
  );

  // ── Status Badge Backgrounds ──
  static Color statusBadgeBg(String? status) {
    switch (status?.toUpperCase()) {
      case 'GENUINE':
        return statusGenuine.withOpacity(0.15);
      case 'VERIFIED':
        return statusVerified.withOpacity(0.15);
      case 'SUSPICIOUS':
        return statusSuspicious.withOpacity(0.15);
      case 'FAKE':
        return statusFake.withOpacity(0.15);
      default:
        return statusUnknown.withOpacity(0.15);
    }
  }

  // ── Source Color Helper ──
  static Color sourceColor(String site) {
    switch (site.toLowerCase()) {
      case 'amazon_eg':
        return amazonOrange;
      case 'noon_eg':
        return noonYellow;
      case 'jumia_eg':
        return jumiaOrange;
      default:
        return electricOrange;
    }
  }

  static String sourceLogo(String site) {
    switch (site.toLowerCase()) {
      case 'amazon_eg':
        return 'A';
      case 'noon_eg':
        return 'N';
      case 'jumia_eg':
        return 'J';
      default:
        return '?';
    }
  }
}
