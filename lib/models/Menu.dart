class Menu {
  final int? id;
  final String? nameTh;
  final String? imagePath;
  final double? price;
  final String? status;
  final int? menuCategoryId;

  Menu({this.id, this.nameTh, this.imagePath, this.price, this.status, this.menuCategoryId});

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      nameTh: json['nameTh'],
      imagePath: json['imagePath'],
      price: json['price'],
      menuCategoryId: json['menuCategoryId'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameTh': nameTh,
      'imagePath': imagePath,
      'price': price,
      'menuCategoryId': menuCategoryId,
    };
  }
}



