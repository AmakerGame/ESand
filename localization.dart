import 'dart:ui';

class Lang {
  static String get code => PlatformDispatcher.instance.locale.languageCode;

  static const Map<String, Map<String, String>> _data = {
    'uk': {
      'sand': 'Пісок',
      'water': 'Вода',
      'oil': 'Нафта',
      'lava': 'Лава',
      'clay': 'Глина',
      'wall': 'Стіна',
      'wood': 'Дерево',
      'iron': 'Залізо',
      'glass': 'Скло',
      'steel': 'Сталь',
      'fire': 'Вогонь',
      'acid': 'Кислота',
      'steam': 'Пара',
      'gas': 'Газ',
      'ice': 'Лід',
      'seed': 'Насіння',
      'grass': 'Трава',
      'bacter': 'Бактерія',
      'fungus': 'Грибок',
      'flower': 'Квітка',
      'erase': 'Ластик',
      'clear': 'Очистити',
      'save': 'Зберегти',
      'load': 'Завантажити',
      'settings': 'Налаштування',
      'resume': 'Грати'
    },
    'en': {
      'sand': 'Sand',
      'water': 'Water',
      'oil': 'Oil',
      'lava': 'Lava',
      'clay': 'Clay',
      'wall': 'Wall',
      'wood': 'Wood',
      'iron': 'Iron',
      'glass': 'Glass',
      'steel': 'Steel',
      'fire': 'Fire',
      'acid': 'Acid',
      'steam': 'Steam',
      'gas': 'Gas',
      'ice': 'Ice',
      'seed': 'Seed',
      'grass': 'Grass',
      'bacter': 'Bacterium',
      'fungus': 'Fungus',
      'flower': 'Flower',
      'erase': 'Eraser',
      'clear': 'Clear',
      'save': 'Save',
      'load': 'Load',
      'settings': 'Settings',
      'resume': 'Resume'
    },
  };

  static String t(String key) {
    String k = key.toLowerCase();
    return _data[code]?[k] ?? _data['en']![k] ?? k;
  }
}
