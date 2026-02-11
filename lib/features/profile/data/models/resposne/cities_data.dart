class CitiesData {
  final List<CityItem> cities;

  CitiesData(this.cities);

  factory CitiesData.fromJson(dynamic raw) {
    final list = <CityItem>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          list.add(CityItem.fromJson(e));
        } else if (e is Map) {
          list.add(CityItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return CitiesData(list);
  }

  Map<String, dynamic> toJson() => {
    'cities': cities.map((e) => e.toJson()).toList(),
  };
}
class CityItem {
  final int id;
  final String name;

  CityItem({required this.id, required this.name});

  factory CityItem.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) =>
        (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    return CityItem(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}