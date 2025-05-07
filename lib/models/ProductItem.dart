import 'package:flutter/material.dart';
import 'Menu.dart';

class ProductItem {
  int quantity;
  final Menu menu;
  final String remark;

  ProductItem({this.quantity = 1, required this.menu,required this.remark});

  Map<String, dynamic> toJson() {
    return {
      'id': menu.id,
      'quantity': quantity,
    };
  }

  void increment() {//
    quantity++;
  }

  void decrement() {
    if (quantity > 1) {
      quantity--;
    }
  }

  int getQuantity() {
    return quantity;
  }
}
