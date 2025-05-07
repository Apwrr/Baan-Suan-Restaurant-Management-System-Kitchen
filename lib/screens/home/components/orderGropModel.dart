class GroupedOrder {
  final int menuId;
  final String menuName;
  final String imagePath;
  final List<GroupedOrderItem> items;

  GroupedOrder({
    required this.menuId,
    required this.menuName,
    required this.imagePath,
    required this.items,
  });

  factory GroupedOrder.fromJson(Map<String, dynamic> json) {
    return GroupedOrder(
      menuId: json['menuId'],
      menuName: json['menuName'],
      imagePath: json['imagePath'],
      items: (json['items'] as List)
          .map((item) => GroupedOrderItem.fromJson(item))
          .toList(),
    );
  }
}

class GroupedOrderItem {
  final int table;
  final int qty;
  final List<String> remark;

  GroupedOrderItem({
    required this.table,
    required this.qty,
    required this.remark,
  });

  factory GroupedOrderItem.fromJson(Map<String, dynamic> json) {
    return GroupedOrderItem(
      table: json['table'],
      qty: json['qty'],
      remark: List<String>.from(json['remark']),
    );
  }
}