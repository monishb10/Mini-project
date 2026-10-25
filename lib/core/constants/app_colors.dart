import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette - Modern Indigo & Deep Slate
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800
  static const Color primaryContainer = Color(0xFFEEF2FF); // Indigo 50

  // Secondary & Accent - Cyan / Sky
  static const Color secondary = Color(0xFF0EA5E9); // Sky 500
  static const Color secondaryLight = Color(0xFF38BDF8); // Sky 400
  static const Color secondaryDark = Color(0xFF0369A1); // Sky 700

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoLight = Color(0xFFDBEAFE);

  // Pattern Mining Special Colors (Clusters)
  static const Color clusterA = Color(0xFF8B5CF6); // Purple (Tech Innovators)
  static const Color clusterB = Color(0xFFEC4899); // Pink (Cultural & Arts)
  static const Color clusterC = Color(0xFF10B981); // Green (Sports & Fitness)
  static const Color clusterD = Color(
    0xFFF97316,
  ); // Orange (Social & Leadership)
  static const Color clusterAtRisk = Color(
    0xFFEF4444,
  ); // Red (Low Participation)

  // Light Theme Neutral Colors
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceSecondaryLight = Color(0xFFF1F5F9); // Slate 100
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate 400

  // Dark Theme Neutral Colors
  static const Color backgroundDark = Color(0xFF0B0F19); // Deep Midnight
  static const Color surfaceDark = Color(0xFF151C2C); // Dark Slate Card
  static const Color surfaceSecondaryDark = Color(0xFF1E293B); // Slate 800
  static const Color borderDark = Color(0xFF334155); // Slate 700
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Sidebar Gradient
  static const LinearGradient sidebarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
  );

  // Card Glow Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
  );
}
