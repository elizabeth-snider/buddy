import 'dart:convert';

Transactions userFromJson(String str) => Transactions.fromJson(json.decode(str));

String userToJson(Transactions data) => json.encode(data.toJson());

class Transactions{
  int id;
  String category;
  String val;

  Transactions({
   this.id, this.category, this.val
  });

  factory Transactions.fromJson(Map<String, dynamic> json) => Transactions(
    id: json['id'],
    category: json['category'],
    val: json['val'],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category": category,
    "val": val,
  };

}