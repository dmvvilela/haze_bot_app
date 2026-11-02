/// Only these new cosmetics belong to Plus. Colors, expressions, voices,
/// themes and every pre-existing setting remain independent and free.
enum HazeFaceStyle { classic, orbit, pixel, aurora }

enum HazeAccessory { none, glasses, crown, headphones, comet }

class HazeLook {
  final HazeFaceStyle style;
  final HazeAccessory accessory;

  const HazeLook({
    this.style = HazeFaceStyle.classic,
    this.accessory = HazeAccessory.none,
  });

  bool get needsPlus =>
      style != HazeFaceStyle.classic || accessory != HazeAccessory.none;

  Map<String, dynamic> toJson() => {
    'style': style.name,
    'accessory': accessory.name,
  };

  factory HazeLook.fromJson(Map<String, dynamic> json) => HazeLook(
    style:
        HazeFaceStyle.values
            .where((v) => v.name == json['style'])
            .firstOrNull ??
        HazeFaceStyle.classic,
    accessory:
        HazeAccessory.values
            .where((v) => v.name == json['accessory'])
            .firstOrNull ??
        HazeAccessory.none,
  );

  @override
  bool operator ==(Object other) =>
      other is HazeLook && style == other.style && accessory == other.accessory;
  @override
  int get hashCode => Object.hash(style, accessory);
}
