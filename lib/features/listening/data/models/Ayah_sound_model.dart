import 'package:quran_app/core/api/end_points.dart';

class AyahSoundModel {
  int? id;
  String? file;
  int? soraNumber;
  int? ayaNumber;
  int? reciter;

  AyahSoundModel(
      {this.id, this.file, this.soraNumber, this.ayaNumber, this.reciter});

  AyahSoundModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    file = "${json['file']}";
    soraNumber = json['sora_number'];
    ayaNumber = json['aya_number'];
    reciter = json['reciter'];
  }
}
