import 'package:hive_flutter/hive_flutter.dart';

part 'content_value.g.dart';
@HiveType(typeId: 0)
class ContentValue {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String body;

  ContentValue({
    required this.title,
    required this.body,
  });
  factory ContentValue.fromJson(Map<String, dynamic> json) {
    return ContentValue(
      title: json['title'],
      body: json['body'],
    );
  }
}
