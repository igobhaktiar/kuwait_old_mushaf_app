// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class FullPageTenReadingsResoursesModel {
  int? pageNumber;
  String? coloredImagePath;
  List<QuranTenPageJsonFiles>? quranTenPageJsonFiles;
  List<KhelafiaWordModel>? quranTenPageWord;
  List<OsoulModel>? osoul;
  List<ShwahidDalalatGroupModel>? shawahed;
  List<HwamishModel>? hawamesh;

  FullPageTenReadingsResoursesModel(
      {this.pageNumber,
      this.coloredImagePath,
      this.quranTenPageJsonFiles,
      this.quranTenPageWord,
      this.osoul,
      this.shawahed,
      this.hawamesh});

  FullPageTenReadingsResoursesModel.fromJson(Map<String, dynamic> json) {
    pageNumber = json['page_number'];
    coloredImagePath = json['image'];
    if (json['quran_ten_page_json'] != null) {
      quranTenPageJsonFiles = <QuranTenPageJsonFiles>[];
      json['quran_ten_page_json'].forEach((v) {
        quranTenPageJsonFiles!.add(QuranTenPageJsonFiles.fromJson(v));
      });
    }
    if (json['quran_ten_page_word'] != null) {
      quranTenPageWord = <KhelafiaWordModel>[];
      json['quran_ten_page_word'].forEach((v) {
        quranTenPageWord!.add(KhelafiaWordModel.fromJson(v));
      });
    }
    if (json['osoul'] != null) {
      osoul = <OsoulModel>[];
      json['osoul'].forEach((v) {
        osoul!.add(OsoulModel.fromJson(v));
      });
    }
    if (json['shawahed'] != null) {
      shawahed = <ShwahidDalalatGroupModel>[];
      json['shawahed'].forEach((v) {
        shawahed!.add(ShwahidDalalatGroupModel.fromJson(v));
      });
    }
    if (json['hawamesh'] != null) {
      hawamesh = <HwamishModel>[];
      json['hawamesh'].forEach((v) {
        hawamesh!.add(HwamishModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page_number'] = pageNumber;
    data['image'] = coloredImagePath;
    if (quranTenPageJsonFiles != null) {
      data['quran_ten_page_json'] =
          quranTenPageJsonFiles!.map((v) => v.toJson()).toList();
    }
    if (quranTenPageWord != null) {
      data['quran_ten_page_word'] =
          quranTenPageWord!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class QuranTenPageJsonFiles {
  String? wordsSectionJson;
  String? osoulSectionJson;
  String? shawahedJsonFiles;
  String? hawameshJsonFiles;

  QuranTenPageJsonFiles(
      {this.wordsSectionJson,
      this.osoulSectionJson,
      this.shawahedJsonFiles,
      this.hawameshJsonFiles});

  QuranTenPageJsonFiles.fromJson(Map<String, dynamic> json) {
    wordsSectionJson = json['words_section_json'];
    osoulSectionJson = json['osoul_section_json'];
    shawahedJsonFiles = json['shawahed_json_files'];
    hawameshJsonFiles = json['hawamesh_json_files'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['words_section_json'] = wordsSectionJson;
    data['osoul_section_json'] = osoulSectionJson;
    data['shawahed_json_files'] = shawahedJsonFiles;
    data['hawamesh_json_files'] = hawameshJsonFiles;
    return data;
  }
}

class KhelafiaWordModel {
  String? wordText;
  double? x;
  double? y;
  double? h;
  double? w;
  int? wordOrder;
  List<CharPropertiesModel>? titleUnicodeCharsList;
  List<SingleQeraaModel>? qeraat;

  KhelafiaWordModel(
      {this.wordText,
      this.x,
      this.y,
      this.h,
      this.w,
      this.wordOrder,
      this.titleUnicodeCharsList,
      this.qeraat});

  KhelafiaWordModel.fromJson(Map<String, dynamic> json) {
    wordText = json['word_text'];
    x = json['x'];
    y = json['y'];
    h = json['h'];
    w = json['w'];
    wordOrder = json['word_order'];
    if (json['detail_title_chars'] != null) {
      titleUnicodeCharsList = <CharPropertiesModel>[];
      json['detail_title_chars'].forEach((v) {
        titleUnicodeCharsList!.add(CharPropertiesModel.fromJson(v));
      });
    }
    if (json['quran_ten_word_mp3'] != null) {
      qeraat = <SingleQeraaModel>[];
      json['quran_ten_word_mp3'].forEach((v) {
        qeraat!.add(SingleQeraaModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['word_text'] = wordText;
    data['x'] = x;
    data['y'] = y;
    data['h'] = h;
    data['w'] = w;
    data['word_order'] = wordOrder;
    if (titleUnicodeCharsList != null) {
      data['detail_title_chars'] =
          titleUnicodeCharsList!.map((v) => v.toJson()).toList();
    }
    if (qeraat != null) {
      data['quran_ten_word_mp3'] = qeraat!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  bool operator ==(covariant KhelafiaWordModel other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.wordText == wordText && other.wordOrder == wordOrder;
  }

  @override
  int get hashCode {
    return wordText.hashCode ^ wordOrder.hashCode;
  }
}

class SingleQeraaModel {
  int? readingOrder;
  String? file;
  List<CharPropertiesModel>? unicodeCharsList;

  SingleQeraaModel({this.readingOrder, this.file, this.unicodeCharsList});

  SingleQeraaModel.fromJson(Map<String, dynamic> json) {
    readingOrder = json['reading_order'];
    file = json['file'];
    if (json['detail_chars'] != null) {
      unicodeCharsList = <CharPropertiesModel>[];
      json['detail_chars'].forEach((v) {
        unicodeCharsList!.add(CharPropertiesModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reading_order'] = readingOrder;
    data['file'] = file;
    if (unicodeCharsList != null) {
      data['detail_chars'] = unicodeCharsList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

//* Shwahid model
class ShwahidDalalatGroupModel {
  List<List<CharPropertiesModel>>? shahedChars;
  List<List<CharPropertiesModel>>? daleelChars;

  ShwahidDalalatGroupModel({this.shahedChars, this.daleelChars});

  ShwahidDalalatGroupModel.fromJson(Map<String, dynamic> json) {
    if (json['shahed_chars'] != null) {
      shahedChars = <List<CharPropertiesModel>>[];
      json['shahed_chars'].forEach((singleReadingLinePhrases) {
        var singleReading = (singleReadingLinePhrases as List)
            .map((e) => CharPropertiesModel.fromJson(e))
            .toList();
        shahedChars!.add(singleReading);
      });
    }
    if (json['dalal_chars'] != null) {
      daleelChars = <List<CharPropertiesModel>>[];
      json['dalal_chars'].forEach((singleReadingLinePhrases) {
        var singleReading = (singleReadingLinePhrases as List)
            .map((e) => CharPropertiesModel.fromJson(e))
            .toList();
        daleelChars!.add(singleReading);
      });
    }
  }
}

class Lines {
  List<CharPropertiesModel>? shawahed;
  List<CharPropertiesModel>? dalalat;

  Lines({this.shawahed, this.dalalat});

  Lines.fromJson(Map<String, dynamic> json) {
    if (json['shawahed'] != null) {
      shawahed = <CharPropertiesModel>[];
      json['shawahed'].forEach((singleShahidCharacter) {
        shawahed!.add(CharPropertiesModel.fromJson(singleShahidCharacter));
      });
    }
    if (json['dalalat'] != null) {
      dalalat = <CharPropertiesModel>[];
      json['dalalat'].forEach((singleDaleelCharacter) {
        dalalat!.add(CharPropertiesModel.fromJson(singleDaleelCharacter));
      });
    }
  }
}

//* Osoul Model
class OsoulModel {
  List<CharPropertiesModel>? keyChars;
  List<CharPropertiesModel>? valueChars;

  OsoulModel.fromJson(Map<String, dynamic> json) {
    keyChars = <CharPropertiesModel>[];
    valueChars = <CharPropertiesModel>[];
    if (json['key_chars'] != null) {
      json['key_chars'].forEach((v) {
        keyChars!.add(CharPropertiesModel.fromJson(v));
      });
    }
    if (json['value_chars'] != null) {
      json['value_chars'].forEach((v) {
        valueChars!.add(CharPropertiesModel.fromJson(v));
      });
    }
  }
}

//* hwamish model
class HwamishModel {
  List<CharPropertiesModel>? hamishLine;

  HwamishModel.fromJson(Map<String, dynamic> json) {
    hamishLine = <CharPropertiesModel>[];
    if (json["hawamesh_chars"] != null) {
      json['hawamesh_chars'].forEach((v) {
        hamishLine!.add(CharPropertiesModel.fromJson(v));
      });
    }
  }
}

class CharPropertiesModel {
  // double? line;
  double? size;
  CMYKColor? color;
  String? unicode;
  bool? upright;
  String? fontFamily;
  String? weight;
  bool? isNewLine;
  bool? addTab;

  CharPropertiesModel(
      {
      // this.line,
      this.size,
      this.color,
      this.unicode,
      this.upright,
      this.fontFamily,
      this.weight,
      this.isNewLine,
      this.addTab});

  CharPropertiesModel.fromJson(Map<String, dynamic> json) {
    // line = json['line'] != null ? (json['line']).toDouble() : null;
    size = json['size'] is int ? json['size'].toDouble() : json['size'];
    if (json['size'] is int) {
      print("size is int");
    }
    color = json['color'] != null ? CMYKColor.fromJson(json['color']) : null;
    unicode = json['unicode'];
    upright = json['upright'];
    fontFamily = json['fontname'];
    weight = json['weight'];
    isNewLine = json['is_new_line'];
    addTab = json['add_tab'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    // data['line'] = this.line;
    data['size'] = size;
    if (color != null) {
      data['color'] = color!.toJson();
    }
    data['unicode'] = unicode;
    data['upright'] = upright;
    data['fontname'] = fontFamily;
    data['is_new_line'] = isNewLine;
    return data;
  }

  FontWeight getFontWeight() {
    FontWeight result = FontWeight.normal;
    switch (weight.toString()) {
      case "300":
        result = FontWeight.w300;
        break;
      case "normal":
        result = FontWeight.normal;
        break;

      case "bold":
        result = FontWeight.bold;
        break;
      default:
        result = FontWeight.normal;
        break;
    }
    return result;
  }
}

class CMYKColor {
  String? ncsName;
  List<double>? ncolor;

  CMYKColor({this.ncsName, this.ncolor});

  CMYKColor.fromJson(Map<String, dynamic> json) {
    ncsName = json['ncs_name'];

    ncolor = (json['ncolor'] as List<dynamic>)
        .map((value) => double.parse(value.toString()))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ncs_name'] = ncsName;
    data['ncolor'] = ncolor;
    return data;
  }

  Color getColor() {
    var c = ncolor![0].toDouble();
    var m = ncolor![1].toDouble();
    var y = ncolor![2].toDouble();
    var k = ncolor![3].toDouble();

    // convert to RGB Color
    int r = (255 * (1 - c) * (1 - k)).toInt();
    int g = (255 * (1 - m) * (1 - k)).toInt();
    int b = (255 * (1 - y) * (1 - k)).toInt();
    // return Color.fromRGBO(r, g, b, 1);

    return Color.fromRGBO(r, g, b, 1);
  }
}
