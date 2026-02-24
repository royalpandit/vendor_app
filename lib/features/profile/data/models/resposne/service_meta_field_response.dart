class ServiceMetaFieldResponse {
  final int id;
  final String fieldKey;
  final String label;
  final String type;
  final List<String>? options;
  final bool isRequired;
  final bool isFilterable;

  ServiceMetaFieldResponse({
    required this.id,
    required this.fieldKey,
    required this.label,
    required this.type,
    this.options,
    required this.isRequired,
    required this.isFilterable,
  });

  factory ServiceMetaFieldResponse.fromJson(Map<String, dynamic> json) {
    final opts = json['options'];
    List<String>? parsedOptions;
    if (opts is List) {
      parsedOptions = opts.map((e) => e.toString()).toList();
    }

    return ServiceMetaFieldResponse(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      fieldKey: json['field_key'] ?? json['fieldKey'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? 'text',
      options: parsedOptions,
      isRequired: (json['is_required'] ?? false) as bool,
      isFilterable: (json['is_filterable'] ?? false) as bool,
    );
  }
}
