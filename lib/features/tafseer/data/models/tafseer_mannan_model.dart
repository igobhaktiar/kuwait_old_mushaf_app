import 'package:flutter/material.dart';

class TafseerMananAyahModel {
  String? modified;
  int? pageNumber;
  int? ayaNumber;
  int? soraNumber;
  String? soraName;
  List<List<TafseerChar>>? tafseerChars;

  TafseerMananAyahModel(
      {this.modified,
      this.pageNumber,
      this.ayaNumber,
      this.soraNumber,
      this.soraName,
      this.tafseerChars});

  TafseerMananAyahModel.fromJson(Map<String, dynamic> json) {
    modified = json['modified'];
    pageNumber = json['page_number'];
    ayaNumber = json['aya_number'];
    soraNumber = json['sora_number'];
    soraName = json['sora_name'];
    if (json['tafseer_chars'] != null) {
      tafseerChars = <List<TafseerChar>>[];
      json['tafseer_chars'].forEach((unicodeGroup) {
        var unicodeGroupModels =
            (unicodeGroup as List).map((e) => TafseerChar.fromJson(e)).toList();
        tafseerChars!.add(unicodeGroupModels);
      });
    }
  }
}

class TafseerChar {
  double? size;
  String? color;
  String? unicode;
  String? fontname;

  TafseerChar({this.size, this.color, this.unicode, this.fontname});

  TafseerChar.fromJson(Map<String, dynamic> json) {
    size = double.tryParse(json['size'].toString());
    color = json['color'];
    unicode = json['unicode'];
    fontname = json['fontname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['size'] = this.size;
    data['color'] = this.color;
    data['unicode'] = this.unicode;
    data['fontname'] = this.fontname;
    return data;
  }

  Color getColor() {
    if (color != null && color!.length == 6) {
      return Color(int.parse("0xFF$color"));
    }
    return Colors.black;
  }
}
