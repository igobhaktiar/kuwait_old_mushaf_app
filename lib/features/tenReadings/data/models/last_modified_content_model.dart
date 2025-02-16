class LastModifiedPages {
  List<PageInfo>? quran10;
  String? fontModified;
  int? lastReadyPage;
  String? mananModified;

  LastModifiedPages({this.quran10, this.fontModified, this.mananModified});

  LastModifiedPages.fromJson(Map<String, dynamic> json) {
    if (json['quran_10'] != null) {
      quran10 = <PageInfo>[];
      json['quran_10'].forEach((v) {
        quran10!.add(PageInfo.fromJson(v));
      });
    }
    fontModified = json["font_modified"];
    lastReadyPage = json["last_ready_page"];
    mananModified = json["manan_modified"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (quran10 != null) {
      data['quran_10'] = quran10!.map((v) => v.toJson()).toList();
    }
    data["font_modified"] = fontModified;
    data["last_ready_page"] = lastReadyPage;
    data["manan_modified"] = mananModified;
    return data;
  }
}

class PageInfo {
  int? pageNumber;
  String? modified;

  PageInfo({this.pageNumber, this.modified});

  PageInfo.fromJson(Map<String, dynamic> json) {
    pageNumber = json['page_number'];
    modified = json['modified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page_number'] = pageNumber;
    data['modified'] = modified;
    return data;
  }
}
