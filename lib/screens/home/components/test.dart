/*

import 'package:animation_2/models/Menu.dart';
import 'package:animation_2/models/cart_counter.dart';
import 'package:animation_2/screens/home/components/Add_Menu.dart';
import 'package:animation_2/screens/home/components/Footer.dart';
import 'package:animation_2/screens/home/components/cart_Order.dart';
import 'package:animation_2/screens/home/components/cart_order_list.dart';
import 'package:flutter/material.dart';
import 'package:animation_2/controllers/home_controller.dart';

class CartDetails extends StatefulWidget {
  final Order order;
  final HomeController controller;

  const CartDetails({
    Key? key,
    required this.order,
    required this.controller,
  }) : super(key: key);

  @override
  _CartDetailsState createState() => _CartDetailsState();
}

class _CartDetailsState extends State<CartDetails> {
  bool isOrderAccepted = false;
  Map<int, int> _itemQuantities = {}; // ติดตามจำนวนสินค้า
  Map<int, bool> _checkedItems = {}; // ติดตามสถานะการตรวจสอบสินค้า

  @override
  void initState() {
    super.initState();
    widget.controller.initializeCurrentOrder(widget.order); // Initialize _currentOrder with widget.order
    isOrderAccepted = widget.controller.isTableConfirmed(widget.order.table);
    // เริ่มต้นแผนที่ด้วยจำนวนสินค้าตั้งต้นและสถานะการตรวจสอบ
    for (var item in widget.controller.currentOrder.orderItems) {
      _itemQuantities[item.id] = item.qty;
      _checkedItems[item.id] = false; // เริ่มต้นด้วยการไม่ตรวจสอบทุกสินค้า
    }
  }

  // ฟังก์ชันสำหรับลบสินค้าออกจากออเดอร์
  void _removeItem(int itemId) {
    setState(() {
      widget.controller.currentOrder.orderItems.removeWhere((item) => item.menuId == itemId);
      _itemQuantities.remove(itemId);
      _checkedItems.remove(itemId);
    });
  }

  // ฟังก์ชันสำหรับเพิ่มจำนวนสินค้า
  void _incrementQuantity(int itemId) {
    setState(() {
      if (_itemQuantities[itemId] != null) {
        _itemQuantities[itemId] = (_itemQuantities[itemId]! + 1);
      }
    });
  }

  void _decrementQuantity(int itemId) {
    setState(() {
      if (_itemQuantities[itemId] != null && _itemQuantities[itemId]! > 1) {
        _itemQuantities[itemId] = (_itemQuantities[itemId]! - 1);
      }
    });
  }

  // ฟังก์ชันเพิ่มเมนูใหม่จาก AddMenuDetails
  void _addMenuToOrder(OrderItem newItem) {
    setState(() {
      bool itemExists = widget.controller.currentOrder.orderItems.any((item) => item.id == newItem.id);
      if (itemExists) {
        // ถ้าเมนูมีอยู่แล้วให้เพิ่มจำนวนสินค้า
        widget.controller.currentOrder.orderItems
            .firstWhere((item) => item.id == newItem.id)
            .qty += newItem.qty;
      } else {
        // ถ้าเมนูใหม่ให้เพิ่มลงในรายการ
        widget.controller.currentOrder.orderItems.add(newItem);
      }
      _itemQuantities[newItem.id] = newItem.qty;
      _checkedItems[newItem.id] = false;
    });
  }

  // ฟังก์ชันสำหรับแสดงการยืนยันการลบสินค้า
  void _showRemoveConfirmationDialog(int itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันการยกเลิกรายการ'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog โดยไม่ลบสินค้า
              },
              child: Text('ไม่'),
            ),
            TextButton(
              onPressed: () {
                _removeItem(itemId); // ลบสินค้าเมื่อผู้ใช้กดยืนยัน
                Navigator.of(context).pop(); // ปิด dialog หลังลบสินค้าแล้ว
              },
              child: Text('ใช่'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Color(0xFFE4F0E6),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'รายละเอียดโต๊ะ ${widget.order.table}',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMenu(controller: widget.controller),
                ),
              );
              if (result != null && result is OrderItem) {
                _addMenuToOrder(result);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(
            widget.order.orderItems.length,
                (index) => ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                backgroundImage:
                AssetImage(widget.order.orderItems[index].imagePath),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.order.orderItems[index].menuName),
                  Text(
                    'จำนวน',
                    style: TextStyle(fontSize: 14, color: Colors.black), // ข้อความ "จำนวน"
                  ),
                  isOrderAccepted
                      ? Text(
                    '   ${_itemQuantities[widget.order.orderItems[index].id] ?? 1}',
                    style: TextStyle(fontSize: 20),
                  )
                      : CartCounter(
                    quantity: _itemQuantities[widget.order.orderItems[index].id] ?? 1,
                    onIncrement: () => _incrementQuantity(widget.order.orderItems[index].id),
                    onDecrement: () => _decrementQuantity(widget.order.orderItems[index].id),
                  ),
                  if (widget.order.orderItems[index].remark.isNotEmpty)
                    Text(
                      'หมายเหตุ: ${widget.order.orderItems[index].remark}',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                ],
              ),
              trailing: isOrderAccepted
                  ? null
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    activeColor: Colors.green,
                    value: _checkedItems[widget.order.orderItems[index].id],
                    onChanged: (bool? value) {
                      setState(() {
                        _checkedItems[widget.order.orderItems[index].id] = value!;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel_presentation_rounded, color: Colors.red),
                    onPressed: () {
                      _showRemoveConfirmationDialog(widget.order.orderItems[index].menuId);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isOrderAccepted
                        ? null // ถ้า `isOrderAccepted` เป็น true, ปุ่มจะไม่สามารถกดได้
                        : () async {
                      // ตรวจสอบว่า Checkbox ทุกรายการถูกทำเครื่องหมายหรือไม่
                      bool allChecked = _checkedItems.values.every((isChecked) => isChecked);

                      if (!allChecked) {
                        // แสดงข้อความเตือนหากมีรายการที่ยังไม่ได้ทำเครื่องหมาย
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('กรุณาทำเครื่องหมายทุกรายการก่อนยืนยัน'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        // อัปเดต OrderItem ด้วยค่าจาก _itemQuantities
                        widget.controller.currentOrder.orderItems.forEach((item) {
                          item.qty = _itemQuantities[item.id] ?? item.qty;
                        });

                        bool success = await widget.controller.confirmOrder(widget.order.id, widget.order.table);
                        if (success) {
                          setState(() {
                            isOrderAccepted = true;
                            widget.controller.confirmTable(widget.order.table); // บันทึกสถานะโต๊ะ
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('รับรายการอาหารสำเร็จ'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          // แสดง dialog พร้อมข้อความจาก decodedResponse
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('วัตถุดิบไม่เพียงพอ'),
                                content: Text(widget.controller.getErrorMessage()),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // ปิด dialog
                                    },
                                    child: Text('ตกลง'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: isOrderAccepted ? Colors.grey : Colors.orange[300], // สีปุ่ม
                      onSurface: Colors.grey, // สีปุ่มเมื่อปิดการใช้งาน
                    ),
                    child: Text(
                      "ยืนยันรายการอาหาร",
                      style: TextStyle(color: Colors.black), // สีตัวหนังสือ
                    ),
                  ),
                ),

                SizedBox(width: 8.0), // ระยะห่างระหว่างปุ่ม
                Expanded(
                  child: ElevatedButton(
                    onPressed: isOrderAccepted
                        ? () {
                      // โค้ดที่ทำงานเมื่อ isOrderAccepted == true
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('ยืนยันการทำรายการสำเร็จ'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // ปิด dialog
                                },
                                child: Text('ไม่ใช่'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  try {
                                    // กรองเฉพาะรายการที่ถูกเลือก (checked)
                                    List<OrderItem> checkedItems = widget.controller.currentOrder.orderItems
                                        .where((item) => _checkedItems[item.id] == true)
                                        .toList();
                                    if (checkedItems.isNotEmpty) {
                                      // ส่งเฉพาะรายการที่ถูกเลือก (checked)
                                      bool success = await widget.controller.submitStatus(widget.order.id, 'completed', checkedItems);

                                      Navigator.of(context).pop();
                                      if (success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('รายการที่เลือกเสร็จสิ้น'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        // กลับไปยังหน้า CartOrder
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CartOrder(controller: widget.controller),
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('กรุณาเลือกอย่างน้อยหนึ่งรายการ'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                child: Text('ใช่'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                        : null, // ปุ่มจะไม่สามารถกดได้เมื่อ isOrderAccepted == false

                    style: ElevatedButton.styleFrom(
                      primary: isOrderAccepted ? Colors.green : Colors.grey, // สีปุ่มตามเงื่อนไข
                      onSurface: Colors.grey, // สีปุ่มเมื่อปิดการใช้งาน
                    ),
                    child: Text(
                      "เสร็จสิ้น",
                      style: TextStyle(color: Colors.black), // สีตัวหนังสือ
                    ),
                  ),
                ),

              ],
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

*/
