import 'package:animation_2/api_services.dart';
import 'package:animation_2/models/Menu.dart';
import 'package:animation_2/models/ProductItem.dart';
import 'package:animation_2/screens/home/components/cart_order_list.dart';
import 'package:flutter/material.dart';

enum HomeState {
  normal,
  cart,
}

class HomeController extends ChangeNotifier {
  Map<int, bool> _checkedItems = {};
  HomeState _homeState = HomeState.normal;
  List<ProductItem> _menuCart = [];
  Order _currentOrder = Order(
    id: 0,
    table: 0,
    orderNo: '',
    status: '',
    orderItems: [],
  ); // Current active order
  final ApiService _apiService = ApiService();
  // ตัวนับ ID สำหรับสร้าง ID ใหม่โดยไม่ซ้ำกัน
  int _nextId = 1;

  // ฟังก์ชันสำหรับสร้าง ID ใหม่
  int _generateId() {
    return _nextId++;
  }

  HomeState get homeState => _homeState;

  List<ProductItem> get menuCart => _menuCart;

  Order get currentOrder => _currentOrder;

  void changeHomeState(HomeState state) {
    _homeState = state;
    notifyListeners(); // แจ้งเตือนว่ามีการเปลี่ยนแปลงสถานะ
  }

  // เพิ่มเมนูเข้าไปใน currentOrder และอัปเดตสถานะ
  Future<void> addMenuToCurrentOrder(Menu menu, int quantity) async {
    bool isExistingItem = false;

    for (var item in _currentOrder.orderItems) {
      if (item.menuId == menu.id) {
        item.qty += quantity;
        isExistingItem = true;
        break;
      }
    }


    print('Adding menu to current order: ${menu.nameTh}, Quantity: $quantity');

    // อัปเดต UI หลังจากมีการเพิ่มเมนู
    notifyListeners();
  }

  void setCurrentOrder(Order order) {
    _currentOrder = order;
    notifyListeners(); // แจ้งเตือนว่ามีการตั้งค่า order ใหม่
  }

  // Method to initialize currentOrder from widget.order
  void initializeCurrentOrder(Order order) {
    _currentOrder = order;
    notifyListeners(); // แจ้งเตือนว่ามีการตั้งค่า order ใหม่
  }

  Future<bool> submitStatus(int? orderId, String status, List<OrderItem> selectedItems) async {
    return await _apiService.submitStatus(orderId, status, selectedItems);
  }

  Future<List<Order>> fetchOrdersList() async {
    return await _apiService.fetchOrdersList();
  }

  Future<bool> confirmOrder(int? orderId, int? table, List<OrderItem> itemsToConfirm) async {
    if (itemsToConfirm.isEmpty) {
      print('No items to confirm.');
      return false;
    }

    // ส่งรายการที่ต้องการยืนยันไปยัง API
    final success = await _apiService.confirmOrder(orderId, table, itemsToConfirm);
    return success;
  }

  // สำหรับ debug แสดงข้อมูล order items ที่ถูกเพิ่ม
  void debugOrderItems() {
    print('Current order items: ${_currentOrder.orderItems}');
  }

  String getErrorMessage() => _apiService.getErrorMessage();

  // บันทึกสถานะการกดยืนยันของโต๊ะ
  Map<int, bool> tableConfirmedStatus = {};

  bool isTableConfirmed(int tableId) {
    return tableConfirmedStatus[tableId] ?? false; // คืนค่า false ถ้ายังไม่เคยกดยืนยัน
  }

  void confirmTable(int tableId) {
    tableConfirmedStatus[tableId] = true; // เก็บสถานะการยืนยันของโต๊ะ
    notifyListeners(); // แจ้งเตือนว่ามีการเปลี่ยนแปลงสถานะโต๊ะ
  }

  void resetTableConfirmation(int tableId) {
    tableConfirmedStatus[tableId] = false; // ลบสถานะการยืนยันของโต๊ะ
    notifyListeners(); // แจ้งเตือนว่ามีการเปลี่ยนแปลงสถานะโต๊ะ
  }
  Future<void> refreshOrdersList() async {
    // รีเฟรชข้อมูลตามที่คุณต้องการ
    await fetchOrdersList(); // หรือเรียกใช้ฟังก์ชันที่คุณใช้ในการดึงข้อมูลใหม่
    notifyListeners(); // แจ้งให้ UI รีเฟรช
  }
}
