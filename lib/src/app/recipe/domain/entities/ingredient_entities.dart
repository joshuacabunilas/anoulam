/// Rules for ingredient names on the user's list.
class IngredientEntities {
  IngredientEntities._();

  /// The backend rejects more than this many ingredients per search
  /// (`MAX_INGREDIENTS` in backend/app/schemas.py).
  static const int maxCount = 30;

  /// The backend rejects longer names (backend/app/schemas.py).
  static const int maxLength = 50;

  /// Plurals where dropping the "s" is wrong. Mirrors
  /// `_IRREGULAR_SINGULARS` in backend/app/matching.py.
  static const Map<String, String> _irregularSingulars = {
    'leaves': 'leaf',
    'tomatoes': 'tomato',
    'potatoes': 'potato',
    'mangoes': 'mango',
    'radishes': 'radish',
    'peaches': 'peach',
    'sandwiches': 'sandwich',
    'noodles': 'noodle',
    'chilies': 'chili',
    'chillies': 'chili',
    'chilis': 'chili',
    'cookies': 'cookie',
    'anchovies': 'anchovy',
  };

  /// Trims and collapses repeated whitespace: how a name is stored.
  static String clean(String name) =>
      name.trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Identity used to tell whether two names are the same ingredient:
  /// case-insensitive and singular/plural-insensitive, so "Egg", "eggs" and
  /// "Eggs" all match. Same plural rules as the backend's matching.
  static String key(String name) =>
      clean(name).toLowerCase().split(' ').map(_singular).join(' ');

  static bool same(String a, String b) => key(a) == key(b);

  static String _singular(String word) {
    final irregular = _irregularSingulars[word];
    if (irregular != null) return irregular;
    if (word.length > 4 && word.endsWith('ies')) {
      return '${word.substring(0, word.length - 3)}y';
    }
    if (word.length > 3 &&
        word.endsWith('s') &&
        !word.endsWith('ss') &&
        !word.endsWith('us')) {
      return word.substring(0, word.length - 1);
    }
    return word;
  }
}
