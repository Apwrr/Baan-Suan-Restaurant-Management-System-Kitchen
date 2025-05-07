class Order {
  final int id;
  final int table;
  final String orderNo;
  final String status;
  final List<OrderItem> orderItems;

  Order({
    required this.id,
    required this.table,
    required this.orderNo,
    required this.status,
    required this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      table: json['table'],
      orderNo: json['orderNo'],
      status: json['status'],
      orderItems: (json['orderItemDtoList'] as List)
          .map((item) => OrderItem
          .fromJson(item)).toList(),
    );
  }
}

class OrderItem {
  int id;
  final int menuId;
  final String menuName;
  final String imagePath;
  final int price;
  int qty;
  final String remark;
  String status;

  OrderItem({
    required this.id,
    required this.menuId,
    required this.menuName,
    required this.imagePath,
    required this.price,
    required this.qty,
    required this.remark,
    required this.status,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      menuId: json['menuId'],
      menuName: json['menuName'],
      imagePath: json['imagePath'],
      price: json['price'],
      qty: json['qty'],
      remark: json['remark'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuId': menuId,
      'menuName': menuName,
      'imagePath' : imagePath,
      'price' : price,
      'qty': qty,
      'remark' : remark,
      'status' : status,
    };
  }
}

