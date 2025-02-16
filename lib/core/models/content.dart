
import 'package:hive_flutter/hive_flutter.dart';

import 'content_value.dart';
part 'content.g.dart';

@HiveType(typeId: 91)
class Content {
  @HiveField(0)
  final String type;
  @HiveField(1)
  final String id;
  @HiveField(2)
  final ContentValue value;

  Content({
    required this.type,
    required this.id,
    required this.value,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      type: json['type'],
      id: json['id'],
      value: ContentValue.fromJson(json['value']),
    );
  }
}
