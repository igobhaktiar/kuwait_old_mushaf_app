class ExternalLibrary {
  int? _count;
  List<Results>? _results;

  ExternalLibrary({int? count, List<Results>? results}) {
    if (count != null) {
      _count = count;
    }
    if (results != null) {
      _results = results;
    }
  }

  int? get count => _count;
  set count(int? count) => _count = count;
  List<Results>? get results => _results;
  set results(List<Results>? results) => _results = results;

  ExternalLibrary.fromJson(Map<String, dynamic> json) {
    _count = json['count'];
    if (json['results'] != null) {
      _results = <Results>[];
      json['results'].forEach((v) {
        _results!.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = _count;
    if (_results != null) {
      data['results'] = _results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? _name;
  List<Resource>? _resources;

  Results({String? modified, String? name, List<Resource>? resources});

  List<Resource>? get resources => _resources;
  set resources(List<Resource>? resources) => _resources = resources;

  Results.fromJson(Map<String, dynamic> json) {
    _name = json['name'];
    if (json['resources'] != null) {
      _resources = <Resource>[];
      json['resources'].forEach((v) {
        _resources!.add(Resource.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = _name;
    if (_resources != null) {
      data['resources'] = _resources!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Resource {
  String? title;
  String? url;
  String? modified;

  Resource({this.modified, this.title, this.url});

  Resource.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    url = json['url'];
    modified = json['modified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['url'] = url;
    return data;
  }
}
