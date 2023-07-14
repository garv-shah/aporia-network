// To parse this JSON data, do
//
//     final config = configFromJson(jsonString);

import 'dart:convert';

Config configFromJson(String str) => Config.fromJson(json.decode(str));

String configToJson(Config data) => json.encode(data.toJson());

class Config {
  List<View> views;
  Roles roles;

  Config({
    required this.views,
    required this.roles,
  });

  Config copyWith({
    List<View>? views,
    Roles? roles,
  }) =>
      Config(
        views: views ?? this.views,
        roles: roles ?? this.roles,
      );

  factory Config.fromJson(Map<String, dynamic> json) => Config(
    views: List<View>.from(json["views"].map((x) => View.fromJson(x))),
    roles: Roles.fromJson(json["roles"]),
  );

  Map<String, dynamic> toJson() => {
    "views": List<dynamic>.from(views.map((x) => x.toJson())),
    "roles": roles.toJson(),
  };
}

class Roles {
  Admins admins;
  Admins companies;
  Admins users;

  Roles({
    required this.admins,
    required this.companies,
    required this.users,
  });

  Roles copyWith({
    Admins? admins,
    Admins? companies,
    Admins? users,
  }) =>
      Roles(
        admins: admins ?? this.admins,
        companies: companies ?? this.companies,
        users: users ?? this.users,
      );

  factory Roles.fromJson(Map<String, dynamic> json) => Roles(
    admins: Admins.fromJson(json["admins"]),
    companies: Admins.fromJson(json["companies"]),
    users: Admins.fromJson(json["users"]),
  );

  Map<String, dynamic> toJson() => {
    "admins": admins.toJson(),
    "companies": companies.toJson(),
    "users": users.toJson(),
  };
}

class Admins {
  String name;
  List<String> abilities;

  Admins({
    required this.name,
    required this.abilities,
  });

  Admins copyWith({
    String? name,
    List<String>? abilities,
  }) =>
      Admins(
        name: name ?? this.name,
        abilities: abilities ?? this.abilities,
      );

  factory Admins.fromJson(Map<String, dynamic> json) => Admins(
    name: json["name"],
    abilities: List<String>.from(json["abilities"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "abilities": List<dynamic>.from(abilities.map((x) => x)),
  };
}

class View {
  String name;
  String displayName;
  Show show;

  View({
    required this.name,
    required this.displayName,
    required this.show,
  });

  View copyWith({
    String? name,
    String? displayName,
    Show? show,
  }) =>
      View(
        name: name ?? this.name,
        displayName: displayName ?? this.displayName,
        show: show ?? this.show,
      );

  factory View.fromJson(Map<String, dynamic> json) => View(
    name: json["name"],
    displayName: json["displayName"],
    show: Show.fromJson(json["show"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "displayName": displayName,
    "show": show.toJson(),
  };
}

class Show {
  List<String>? ability;
  List<String>? role;

  Show({
    this.ability,
    this.role,
  });

  Show copyWith({
    List<String>? ability,
    List<String>? role,
  }) =>
      Show(
        ability: ability ?? this.ability,
        role: role ?? this.role,
      );

  factory Show.fromJson(Map<String, dynamic> json) => Show(
    ability: json["ability"] == null ? [] : List<String>.from(json["ability"]!.map((x) => x)),
    role: json["role"] == null ? [] : List<String>.from(json["role"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "ability": ability == null ? [] : List<dynamic>.from(ability!.map((x) => x)),
    "role": role == null ? [] : List<dynamic>.from(role!.map((x) => x)),
  };
}
