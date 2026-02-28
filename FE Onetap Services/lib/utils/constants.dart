import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/mock_data.dart';

class AppColors {
  // Premium cool-toned palette (no red/yellow/orange background tones)
  static const Color primary = Color(0xFF6A8DFF);
  static const Color secondary = Color(0xFF7B6DFF);
  static const Color accent = Color(0xFF35C6D3);

  // Background tones
  static const Color bgWarm = Color(0xFF090F24); // Midnight Indigo
  static const Color bgMid = Color(0xFF1E2F6C); // Royal Indigo Blue
  static const Color bgCool = Color(0xFF0D5F6B); // Deep Teal
  static const Color bgDeep = Color(0xFF050914); // Near-black navy

  // Shared glass tokens
  static const double glassBlur = 24.0;
  static const double glassOpacity = 0.08;
  static const double glassBorderWidth = 0.8;

  // Glass surfaces
  static Color glassWhite = const Color(0xFFFFFFFF).withValues(alpha: 0.12);
  static Color glassBorder = const Color(0xFFFFFFFF).withValues(alpha: 0.28);
  static Color glassHighlight = const Color(0xFFFFFFFF).withValues(alpha: 0.42);

  static Color innerGlass = const Color(0xFF90ABFF).withValues(alpha: 0.16);
  static Color innerGlassBorder = const Color(
    0xFFFFFFFF,
  ).withValues(alpha: 0.18);

  // Text on glass cards (iOS style)
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFEBEBF5); // Secondary label
  static const Color textTertiary = Color(
    0xFFEBEBF5,
  ); // Tertiary label (opacity handled in widget)
  static const Color textDark = Color(0xFF000000); // Black (on white bg)

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF60A5FA);

  // Borders
  static const Color border = Color(0xFF7FA0D8);
  static const Color divider = Color(0xFF6E88BA);

  // Backward-compatible aliases (used by other screens)
  static const Color background = bgDeep;
  static const Color surface = Color(0x26FFFFFF);
  static const Color surfaceVariant = Color(0x1FFFFFFF);

  // brandGradient alias (used by dashboards)
  static const LinearGradient brandGradient = blueGradient;
  static const LinearGradient dashboardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.bgWarm, AppColors.bgMid, AppColors.bgCool],
    stops: [0.0, 0.58, 1.0],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A122F), Color(0xFF2A3B8D), Color(0xFF0D6B75)],
    stops: [0.0, 0.56, 1.0],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6A8DFF), Color(0xFF3F64DA)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF0F7FF)],
  );
}

class AppData {
  static List<ServiceCategory> categories = [
    ServiceCategory(id: '1', name: 'Cleaning', icon: '🧹', color: Colors.cyan),
    ServiceCategory(id: '2', name: 'Plumbing', icon: '🔧', color: Colors.blue),
    ServiceCategory(
      id: '3',
      name: 'Electrical',
      icon: '⚡',
      color: Colors.amber,
    ),
    ServiceCategory(
      id: '4',
      name: 'Painting',
      icon: '🎨',
      color: Colors.purple,
    ),
    ServiceCategory(
      id: '5',
      name: 'Carpentry',
      icon: '🪚',
      color: Colors.brown,
    ),
    ServiceCategory(
      id: '6',
      name: 'AC Repair',
      icon: '❄️',
      color: Colors.lightBlue,
    ),
  ];

  static List<ServiceModel> services = MockData.mockServices;
}
