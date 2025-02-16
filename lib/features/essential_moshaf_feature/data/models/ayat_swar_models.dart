class SurahModel {
  int? number;
  String? name;
  String? englishName;
  String? englishNameTranslation;
  String? revelationType;
  List<BasicAyahModel>? ayahs;

  SurahModel(
      {this.number,
      this.name,
      this.englishName,
      this.englishNameTranslation,
      this.revelationType,
      this.ayahs});

  SurahModel.fromJson(Map<String, dynamic> json) {
    number =
        (json['number'] is int) ? json['number'] : int.tryParse(json['number']);
    name = json['name'];
    englishName = json['englishName'];
    englishNameTranslation = json['englishNameTranslation'];
    revelationType = json['revelationType'];
    if (json['ayahs'] != null) {
      ayahs = <BasicAyahModel>[];
      json['ayahs'].forEach((v) {
        ayahs!.add(BasicAyahModel.fromJson(v));
      });
    }
  }
}

class BasicAyahModel {
  int? number;
  String? text;
  int? numberInSurah;
  int? juz;
  int? manzil;
  int? page;
  int? ruku;
  int? hizbQuarter;
  SagdaModel? sajda;

  BasicAyahModel(
      {this.number,
      this.text,
      this.numberInSurah,
      this.juz,
      this.manzil,
      this.page,
      this.ruku,
      this.hizbQuarter,
      this.sajda});

  BasicAyahModel.fromJson(Map<String, dynamic> json) {
    number = json['number'] == null
        ? null
        : (json['number'] is int)
            ? json['number']
            : int.tryParse(json['number']);
    text = json['text'];
    numberInSurah = (json['numberInSurah'] is int)
        ? json['numberInSurah']
        : int.tryParse(json['numberInSurah']);
    juz = json['juz'];
    manzil = json['manzil'];
    page = json['page'];
    ruku = json['ruku'];
    hizbQuarter = json['hizbQuarter'];
    sajda = (json['sajda'] == null || json['sajda'] == false)
        ? null
        : SagdaModel.fromJson(json['sajda']);
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number'] = number;
    data['text'] = text;
    data['numberInSurah'] = numberInSurah;
    data['juz'] = juz;
    data['manzil'] = manzil;
    data['page'] = page;
    data['ruku'] = ruku;
    data['hizbQuarter'] = hizbQuarter;
    data['sajda'] = sajda?.toJson();
    return data;
  }
}

class SagdaModel {
  int? id;
  bool? recommended;
  bool? obligatory;

  SagdaModel({this.id, this.recommended, this.obligatory});

  SagdaModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    recommended = json['recommended'];
    obligatory = json['obligatory'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['recommended'] = recommended;
    data['obligatory'] = obligatory;
    return data;
  }
}

//* READY TO USE COMPLETE METADATA MODELS
class AyahModel {
  int? number;
  String? text;
  int? numberInSurah;
  int? juz;
  int? manzil;
  int? page;
  int? ruku;
  int? hizbQuarter;
  SagdaModel? sajda;
  String? surah;
  String? surahEnglish;
  int? surahNumber;

  AyahModel(
      {this.number,
      this.text,
      this.numberInSurah,
      this.juz,
      this.manzil,
      this.page,
      this.ruku,
      this.hizbQuarter,
      this.sajda,
      this.surah,
      this.surahEnglish,
      this.surahNumber});

  AyahModel.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    text = json['text'];
    numberInSurah = json['numberInSurah'];
    juz = json['juz'];
    manzil = json['manzil'];
    page = json['page'];
    ruku = json['ruku'];
    hizbQuarter = json['hizbQuarter'];
    sajda = (json['sajda'] == null || json['sajda'] == false)
        ? null
        : SagdaModel.fromJson(json['sajda']);
    surah = json['surah'];
    surahEnglish = json['surah_english'];
    surahNumber = json["surah_number"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number'] = number;
    data['text'] = text;
    data['numberInSurah'] = numberInSurah;
    data['juz'] = juz;
    data['manzil'] = manzil;
    data['page'] = page;
    data['ruku'] = ruku;
    data['hizbQuarter'] = hizbQuarter;
    data['sajda'] = sajda;
    data['surah'] = surah;
    data['surah_english'] = surahEnglish;
    data['surah_number'] = surahNumber;
    return data;
  }
}
