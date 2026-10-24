/// Display metadata for the original 100-glade campaign.
abstract final class Campaign {
  static const totalLevels = 100;
  static const levelsPerChapter = 10;
  static const chapterNames = [
    'Dewlight Meadow',
    'Fernwater Banks',
    'Amber Orchard',
    'Willow Pass',
    'Opal Hollows',
    'Moonrise Marsh',
    'Crystal Heights',
    'Starlit Ravine',
    'Aurora Grove',
    'Heart of the Vale',
  ];
  static const _stops = [
    'First light',
    'Quiet pool',
    'Leafsong',
    'Hidden bend',
    'Lantern clearing',
    'Gentle rain',
    'Winding path',
    'Bright crossing',
    'Evening bloom',
    'Beacon',
  ];
  static String chapterLabel(int level) {
    final chapter = (level - 1) ~/ levelsPerChapter;
    return 'Chapter ${chapter + 1}: ${chapterNames[chapter]}';
  }

  static String levelName(int level) =>
      '${chapterNames[(level - 1) ~/ levelsPerChapter]}: ${_stops[(level - 1) % levelsPerChapter]}';
}
