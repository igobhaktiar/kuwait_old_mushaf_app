class AyahSegsModel {
  int? suraId;
  List<Seg>? segs;
  int? ayaId;

  AyahSegsModel({this.suraId, this.segs, this.ayaId});

  AyahSegsModel.fromJson(Map<String, dynamic> json) {
    suraId = json['sura_id'];
    if (json['segs'] != null) {
      segs = <Seg>[];
      json['segs'].forEach((v) {
        segs!.add(Seg.fromJson(v));
      });
    }
    ayaId = json['aya_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sura_id'] = suraId;
    if (segs != null) {
      data['segs'] = segs!.map((v) => v.toJson()).toList();
    }
    data['aya_id'] = ayaId;
    return data;
  }
}

class Seg {
  int? y;
  int? x;
  int? w;
  int? h;

  Seg({this.y, this.x, this.w, this.h});

  Seg.fromJson(Map<String, dynamic> json) {
    y = json['y'];
    x = json['x'];
    w = json['w'];
    h = json['h'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['y'] = y;
    data['x'] = x;
    data['w'] = w;
    data['h'] = h;
    return data;
  }
}
