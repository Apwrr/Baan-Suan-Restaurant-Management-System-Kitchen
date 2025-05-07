import 'dart:convert';
import 'package:animation_2/models/ProductItem.dart';
import 'package:animation_2/screens/home/components/cart_order_list.dart';
import 'package:animation_2/screens/home/components/orderGropModel.dart';
import 'package:animation_2/screens/home/components/test.dart';

import 'package:http/http.dart' as http;
import 'models/Menu.dart';
import 'dart:async';

class ApiService {
  final String baseUrl = "https://204rylujk7.execute-api.ap-southeast-2.amazonaws.com/dev/menu-list/0";

  Future<List<Menu>> fetchMenus() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonResponse = json.decode(responseBody);
      print(jsonResponse.length);
      print('Menu ok!');
      return jsonResponse.map((menu) => Menu.fromJson(menu)).toList();
    } else {
      throw Exception('Failed to load menus');
    }
  }

  Future<List<Order>> fetchOrdersList() async {
    final response = await http.get(Uri.parse('https://204rylujk7.execute-api.ap-southeast-2.amazonaws.com/dev/orders/list'));

    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(responseBody);
      print('orderList ok!');
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<bool> submitStatus(int? orderId, String status, List<OrderItem> selectedItems) async {
    final url = Uri.parse('https://204rylujk7.execute-api.ap-southeast-2.amazonaws.com/dev/orders/$orderId/updateItem');

    // เตรียมข้อมูลที่จะส่ง
    final headers = {"Content-Type": "application/json"};

    // สร้างข้อมูล JSON
    final body = json.encode({
      'status': status,
      'items': selectedItems.map((item) => item.toJson()).toList(), // แปลง OrderItem เป็น JSON
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  String _errorMessage = '';
  Future<bool> confirmOrder(int? orderId, int? table, List<OrderItem> orderItems) async {
    final url = Uri.parse('https://204rylujk7.execute-api.ap-southeast-2.amazonaws.com/dev/orders/confirmOrder');
    print('orderId: $orderId, table: $table, orderItems: $orderItems');
    print('Orders ID!');
    final headers = {"Content-Type": "application/json"};

    final List<Map<String, dynamic>> orderItemsPayload = orderItems.map((item) {
      return {
        'id': item.id,
        'menuId': item.menuId,
        'price': item.price,
        'quantity': item.qty,
        'remark': item.remark,
        'status': item.status,
      };
    }).toList();

    final body = json.encode({
      'orderId': orderId,
      'table': table,
      'orderItems': orderItemsPayload,
    });
    print('Request payload: $body');

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      final decodedResponse = utf8.decode(response.bodyBytes);
      print(decodedResponse);
      final Map<String, dynamic> errorResponse = jsonDecode(decodedResponse);
      _errorMessage = _formatErrorMessage(errorResponse['message'] ?? 'Unknown error');
      return false;
    }
  }

  // ฟังก์ชันเพื่อจัดรูปแบบข้อความให้แสดงในหลายบรรทัด
  String _formatErrorMessage(String message) {
    // เพิ่ม \n หลังจากแต่ละข้อความ
    // สมมุติว่าข้อความมีรูปแบบ "Ingredient <ingredient>: required <required>, available <available>"
    String replace = message.replaceAll('Ingredient', '\nIngredient');
    replace = replace.replaceAll('available', '\navailable');
    return replace;
  }

  String getErrorMessage() => _errorMessage;
  Future<List<GroupedOrder>> fetchGroupedOrders() async {
    final response = await http.get(
      Uri.parse('https://204rylujk7.execute-api.ap-southeast-2.amazonaws.com/dev/orders/groupItem/list'),
    );

    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonData = json.decode(responseBody);
      return jsonData.map((e) => GroupedOrder.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load grouped orders');
    }
  }
  Future<void> confirmGroupOrder(GroupedOrder order) async {
    final url = Uri.parse('https://204rylujk7.execute-api.ap-southeast-2.amazonaws.com/dev/orders/confirmGroupOrder');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "menuId": order.menuId,
        "menuName": order.menuName,
        "imagePath": order.imagePath,
        "items": order.items.map((item) => {
          "table": item.table,
          "qty": item.qty,
          "remark": item.remark,
        }).toList(),
      }),
    );

    if (response.statusCode == 200) {
      print('ส่งข้อมูลสำเร็จ: ${order.menuName}');
    } else {
      print('ส่งข้อมูลล้มเหลว: ${response.body}');
      throw Exception('Failed to confirm group order');
    }
  }
}
