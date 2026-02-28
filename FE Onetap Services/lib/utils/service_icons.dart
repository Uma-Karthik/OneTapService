class ServiceIcons {
  ServiceIcons._();

  static const String fallback = '🔧';

  static const List<String> options = [
    '🧹',
    '🔧',
    '⚡',
    '🎨',
    '🪚',
    '❄️',
    '🔨',
    '🪛',
    '💡',
    '🚿',
    '🪟',
    '🚪',
    '🔑',
    '📦',
    '🧰',
    '⚙️',
  ];

  static const Map<String, String> _categoryIcons = {
    'cleaning': '🧹',
    'plumbing': '🔧',
    'electrical': '⚡',
    'painting': '🎨',
    'carpentry': '🪚',
    'ac repair': '❄️',
  };

  static const Map<String, String> _iconAliases = {
    'cleaning': '🧹',
    'plumbing': '🔧',
    'electrical': '⚡',
    'painting': '🎨',
    'carpentry': '🪚',
    'ac': '❄️',
    'ac repair': '❄️',
    'air conditioning': '❄️',
    'wrench': '🔧',
    'broom': '🧹',
    'lightning': '⚡',
    'brush': '🎨',
    'saw': '🪚',
    'hammer': '🔨',
  };

  static String forCategory(String? rawCategory) {
    final category = (rawCategory ?? '').trim().toLowerCase();
    return _categoryIcons[category] ?? fallback;
  }

  static String normalize(String? rawIcon, {String? category}) {
    final icon = (rawIcon ?? '').trim();
    if (icon.isEmpty || icon.toLowerCase() == 'null') {
      return forCategory(category);
    }

    final mappedAlias = _iconAliases[icon.toLowerCase()];
    if (mappedAlias != null) {
      return mappedAlias;
    }

    if (_looksMojibake(icon)) {
      return forCategory(category);
    }

    return icon;
  }

  static bool _looksMojibake(String value) {
    return value.contains('ð') ||
        value.contains('â') ||
        value.contains('Ã') ||
        value.contains('Â');
  }
}
