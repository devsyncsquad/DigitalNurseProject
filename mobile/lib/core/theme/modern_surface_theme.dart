import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Defines the modern glassmorphic surface system that powers the refreshed
/// dashboard experience. Other features can reuse these helpers to stay
/// visually aligned without duplicating decoration logic.
class ModernSurfaceTheme {
  const ModernSurfaceTheme._();

  // Brand foundations
  static const Color primaryTeal = Color(0xFF1FB9AA);
  static const Color deepTeal = Color(0xFF0D4E47);
  static const Color midnight = Color(0xFF071D1C);
  static const Color softMint = Color(0xFFE9F9F6);
  static const Color accentYellow = Color(0xFFFFD166);
  static const Color accentBlue = Color(0xFF64C7FF);
  static const Color accentCoral = Color(0xFFFF8FA3);

  /// Page-level gradient background used by dashboards and lifestyle surfaces.
  static LinearGradient backgroundGradient() {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0F5C52),
        Color(0xFFECF6F4),
        Colors.white,
      ],
    );
  }

  /// Primary hero section gradient.
  static LinearGradient heroGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryTeal,
        Color(0xFF118074),
      ],
    );
  }

  static EdgeInsets screenPadding() {
    return EdgeInsets.only(
      left: 20.w,
      right: 20.w,
      top: 24.h,
      bottom: 40.h,
    );
  }

  static EdgeInsets heroPadding() => EdgeInsets.all(20.w);

  static double heroSpacing() => 18.h;

  static BoxDecoration heroDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: heroGradient(),
      boxShadow: [
        BoxShadow(
          color: deepTeal.withValues(alpha: 0.35),
          blurRadius: 30,
          offset: const Offset(0, 20),
        ),
      ],
    );
  }

  static BoxDecoration glassCard({Color? accent, bool highlighted = false}) {
    final Color baseAccent = accent ?? primaryTeal;
    return BoxDecoration(
      borderRadius: cardRadius(),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: highlighted ? 0.9 : 0.95),
          Colors.white.withValues(alpha: highlighted ? 0.82 : 0.9),
        ],
      ),
      border: Border.all(
        color: baseAccent.withValues(alpha: 0.08),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: baseAccent.withValues(alpha: 0.14),
          blurRadius: highlighted ? 26 : 18,
          offset: const Offset(0, 18),
        ),
      ],
    );
  }

  static BoxDecoration tintedCard(Color accent) {
    final Color blended = Color.alphaBlend(accent.withValues(alpha: 0.18), Colors.white);
    return BoxDecoration(
      borderRadius: cardRadius(),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          blended,
          Colors.white.withValues(alpha: 0.92),
        ],
      ),
      border: Border.all(
        color: accent.withValues(alpha: 0.14),
      ),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 18),
        ),
      ],
    );
  }

  static BoxDecoration pillButton(Color accent) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          accent.withValues(alpha: 0.9),
          accent.withValues(alpha: 0.75),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  static BoxDecoration iconBadge(Color accent) {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withValues(alpha: 0.95),
          accent.withValues(alpha: 0.7),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.25),
          blurRadius: 14,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static BoxDecoration frostedChip({Color baseColor = Colors.white}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      color: baseColor.withValues(alpha: 0.18),
      border: Border.all(
        color: baseColor.withValues(alpha: 0.3),
      ),
      boxShadow: [
        BoxShadow(
          color: baseColor.withValues(alpha: 0.12),
          blurRadius: 14,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  /// Returns a high-contrast foreground color for content placed inside
  /// [frostedChip] capsules so that the text/icons remain legible regardless
  /// of the provided [baseColor].
  static Color chipForegroundColor(Color baseColor) {
    final luminance = baseColor.computeLuminance();
    return luminance > 0.38 ? deepTeal : Colors.white;
  }

  static TextStyle sectionTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w700,
          color: deepTeal,
          letterSpacing: 0.2,
        );
  }

  static TextStyle sectionSubtitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          color: deepTeal.withValues(alpha: 0.65),
        );
  }

  static EdgeInsets cardPadding() => EdgeInsets.all(20.w);

  static BorderRadius cardRadius() => BorderRadius.circular(24);
}

