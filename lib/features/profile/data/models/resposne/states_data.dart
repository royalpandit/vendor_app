// ---------- State & City items ----------
class StateItem {
  final int id;
  final String name;

  StateItem({required this.id, required this.name});

  factory StateItem.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) =>
        (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    return StateItem(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}



// ---------- List wrappers to fit BaseResponse<T> ----------
// API: { status, code, message, data: [ {id,name}, ... ] }
class StatesData {
  final List<StateItem> states;

  StatesData(this.states);

  factory StatesData.fromJson(dynamic raw) {
    final list = <StateItem>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          list.add(StateItem.fromJson(e));
        } else if (e is Map) {
          list.add(StateItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return StatesData(list);
  }

  Map<String, dynamic> toJson() => {
    'states': states.map((e) => e.toJson()).toList(),
  };
}

