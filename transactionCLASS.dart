class TransactionClass{
  int id;
  String category;
  double val;

  TransactionClass(
   this.id, this.category, this.val
  );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'category': category,
      'val': val,
      
    };
    return map;
  }

  TransactionClass.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    category = map['category'];
    val = map['val'];
    
  }
}

