import 'dart:convert';

Transactions userFromJson(String str) => Transactions.fromJson(json.decode(str));

String userToJson(Transactions data) => json.encode(data.toJson());

class Transactions{
  String category;
  String val;

  Transactions({
   this.category, this.val
  });

  factory Transactions.fromJson(Map<String, dynamic> json) => Transactions(
    category: json['category'],
    val: json['val'],
  );

  Map<String, dynamic> toJson() => {
    "category": category,
    "val": val,
  };

}