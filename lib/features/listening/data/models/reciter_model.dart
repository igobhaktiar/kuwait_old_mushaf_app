class ReciterModel {
  int? id;
  String? nameEnglish;
  String? nameArabic;
  bool? isDefault;
  String? photo;
  String? compressedFile;

  ReciterModel(
      {this.id, this.nameEnglish, this.nameArabic, this.isDefault, this.photo, this.compressedFile});

  ReciterModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameEnglish = json['nameEnglish'];
    nameArabic = json['nameArabic'];
    isDefault = json['is_default'];
    photo = json['photo'];
    compressedFile = json['compressed_file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nameEnglish'] = nameEnglish;
    data['nameArabic'] = nameArabic;
    data['is_default'] = isDefault;
    data['photo'] = photo;
    data['compressed_file'] = compressedFile;
    return data;
  }
}
