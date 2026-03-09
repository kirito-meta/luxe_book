import 'package:flutter/material.dart';

/// Quiet Luxury color system.
/// Inspired by Aesop, Aman Resorts, and Japanese editorial design.
/// Near-monochrome with surgical accent use.
abstract final class AppColors {
  // ── Backgrounds ──────────────────────────────────
  static const Color background = Color(0xFF0C0C0E);
  static const Color surface = Color(0xFF141416);
  static const Color surfaceElevated = Color(0xFF1A1A1D);
  static const Color card = Color(0xFF18181B);
  static const Color cardHover = Color(0xFF202024);

  // ── Neutrals ─────────────────────────────────────
  static const Color white = Color(0xFFF5F5F3);
  static const Color white80 = Color(0xCCF5F5F3);
  static const Color white60 = Color(0x99F5F5F3);
  static const Color white40 = Color(0x66F5F5F3);
  static const Color white20 = Color(0x33F5F5F3);
  static const Color white08 = Color(0x14F5F5F3);
  static const Color white04 = Color(0x0AF5F5F3);

  // ── Text Hierarchy ───────────────────────────────
  static const Color textPrimary = Color(0xFFEAEAE8);
  static const Color textSecondary = Color(0xFF8A8A8D);
  static const Color textTertiary = Color(0xFF4E4E52);
  static const Color textMuted = Color(0xFF37373B);

  // ── Accent: Champagne Gold (the only warm color) ─
  static const Color accent = Color(0xFFC9A96E);
  static const Color accentMuted = Color(0xFF9E8355);
  static const Color accentSubtle = Color(0x1AC9A96E);

  // ── Functional ───────────────────────────────────
  static const Color success = Color(0xFF6B8F71);
  static const Color error = Color(0xFFC25450);
  static const Color warning = Color(0xFFBFA26A);
  static const Color info = Color(0xFF6B7F8F);

  // ── Borders & Dividers ───────────────────────────
  static const Color border = Color(0xFF27272A);
  static const Color borderSubtle = Color(0xFF1F1F22);
  static const Color divider = Color(0xFF1C1C1F);

  // ── Interactive ──────────────────────────────────
  static const Color buttonPrimary = Color(0xFFEAEAE8);
  static const Color buttonPrimaryText = Color(0xFF0C0C0E);
  static const Color buttonSecondary = Color(0xFF27272A);
  static const Color buttonSecondaryText = Color(0xFFEAEAE8);

  // ── Status: Live indicator ───────────────────────
  static const Color live = Color(0xFFD4453B);
  static const Color liveMuted = Color(0x33D4453B);

  // ── Gradients (extremely subtle) ─────────────────
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF141416), Color(0xFF0C0C0E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  // Change from const to static final, using hex alpha values
  static const LinearGradient imageOverlay = LinearGradient(
    colors: [
      Color(0x00000000),
      Color(0x66000000),
      Color(0xDD0C0C0E),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFC9A96E), Color(0xFFAA8C52)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [Color(0xFF18181B), Color(0xFF27272A), Color(0xFF18181B)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}