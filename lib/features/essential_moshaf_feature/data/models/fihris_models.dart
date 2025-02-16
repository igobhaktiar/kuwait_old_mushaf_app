// ignore_for_file: public_member_api_docs, sort_constructors_first
class SurahFihrisModel {
  int? number;
  int? page;
  String? name;
  String? revelationTypeArabic;
  String? englishName;
  String? revelationType;
  int? count;
  int? juz;

  SurahFihrisModel(
      {this.number,
      this.page,
      this.name,
      this.revelationTypeArabic,
      this.englishName,
      this.revelationType,
      this.count,
      this.juz});

  SurahFihrisModel.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    page = json['page'];
    name = json['name'];
    revelationTypeArabic = json['revelationTypeArabic'];
    englishName = json['englishName'];
    revelationType = json['revelationType'];
    count = json['count'];
    juz = json['juz'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number'] = number;
    data['page'] = page;
    data['name'] = name;
    data['revelationTypeArabic'] = revelationTypeArabic;
    data['englishName'] = englishName;
    data['revelationType'] = revelationType;
    data['count'] = count;
    data['juz'] = juz;
    return data;
  }

  @override
  bool operator ==(covariant SurahFihrisModel other) {
    if (identical(this, other)) return true;

    return other.number == number &&
        other.page == page &&
        other.name == name &&
        other.revelationTypeArabic == revelationTypeArabic &&
        other.englishName == englishName &&
        other.revelationType == revelationType &&
        other.count == count &&
        other.juz == juz;
  }

  @override
  int get hashCode {
    return number.hashCode ^
        page.hashCode ^
        name.hashCode ^
        revelationTypeArabic.hashCode ^
        englishName.hashCode ^
        revelationType.hashCode ^
        count.hashCode ^
        juz.hashCode;
  }
}

//* AJZAA FIHRIS MODEL
class JuzFihrisModel {
  int? number;
  String? name;
  int? pageStart;
  int? pageEnd;
  int? count;

  JuzFihrisModel(
      {this.number, this.name, this.pageStart, this.pageEnd, this.count});

  JuzFihrisModel.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    name = json['name'];
    pageStart = json['page_start'];
    pageEnd = json['page_end'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number'] = number;
    data['name'] = name;
    data['page_start'] = pageStart;
    data['page_end'] = pageEnd;
    data['count'] = count;
    return data;
  }
}

//*AHZAB FIHRIS MODELS
class HizbFihrisModel {
  int? number;
  String? name;
  int? pageStart;
  int? juz;
  int? count;

  HizbFihrisModel(
      {this.number, this.name, this.pageStart, this.juz, this.count});

  HizbFihrisModel.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    name = json['name'];
    pageStart = json['page_start'];
    juz = json['juz'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number'] = number;
    data['name'] = name;
    data['page_start'] = pageStart;
    data['juz'] = juz;
    data['count'] = count;
    return data;
  }
}
