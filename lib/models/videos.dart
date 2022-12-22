
import 'dart:convert';

WelcomeVideos welcomeFromJsonVideos(String str) => WelcomeVideos.fromJson(json.decode(str));

String welcomeToJsonVideos(WelcomeVideos data) => json.encode(data.toJson());

class WelcomeVideos {
  WelcomeVideos({
    this.id,
    this.results,
  });

  int? id;
  List<ResultVideos>? results;

  factory WelcomeVideos.fromJson(Map<String, dynamic> json) => WelcomeVideos(
    id: json["id"],
    results: List<ResultVideos>.from(json["results"].map((x) => ResultVideos.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "results": List<dynamic>.from(results!.map((x) => x.toJson())),
  };
}

class ResultVideos {
  ResultVideos({
    this.iso6391,
    this.iso31661,
    this.name,
    this.key,
    this.publishedAt,
    this.site,
    this.size,
    this.type,
    this.official,
    this.id,
  });

  Iso6391? iso6391;
  Iso31661? iso31661;
  String? name;
  String? key;
  DateTime? publishedAt;
  Site? site;
  int? size;
  Type? type;
  bool? official;
  String? id;

  factory ResultVideos.fromJson(Map<String, dynamic> json) => ResultVideos(
    iso6391: iso6391Values.map[json["iso_639_1"]],
    iso31661: iso31661Values.map[json["iso_3166_1"]],
    name: json["name"],
    key: json["key"],
    publishedAt: DateTime.parse(json["published_at"]),
    site: siteValues.map[json["site"]],
    size: json["size"],
    type: typeValues.map[json["type"]],
    official: json["official"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "iso_639_1": iso6391Values.reverse[iso6391],
    "iso_3166_1": iso31661Values.reverse[iso31661],
    "name": name,
    "key": key,
    "published_at": publishedAt!.toIso8601String(),
    "site": siteValues.reverse[site],
    "size": size,
    "type": typeValues.reverse[type],
    "official": official,
    "id": id,
  };
}

enum Iso31661 { US }

final iso31661Values = EnumValues({
  "US": Iso31661.US
});

enum Iso6391 { EN }

final iso6391Values = EnumValues({
  "en": Iso6391.EN
});

enum Site { YOU_TUBE }

final siteValues = EnumValues({
  "YouTube": Site.YOU_TUBE
});

enum Type { TEASER, FEATURETTE, TRAILER }

final typeValues = EnumValues({
  "Featurette": Type.FEATURETTE,
  "Teaser": Type.TEASER,
  "Trailer": Type.TRAILER
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap = {};

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap;
    return reverseMap;
  }
}
