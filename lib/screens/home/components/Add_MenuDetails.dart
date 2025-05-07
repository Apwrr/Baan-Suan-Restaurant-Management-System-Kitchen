import 'package:animation_2/screens/home/components/cart_order_list.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import 'package:animation_2/models/Menu.dart';
import 'package:animation_2/controllers/home_controller.dart';

class AddMenuDetails extends StatefulWidget {
  const AddMenuDetails({
    Key? key,
    required this.menu,
    required this.controller,
  }) : super(key: key);

  final Menu menu;
  final HomeController controller;

  @override
  _AddMenuDetailsState createState() => _AddMenuDetailsState();
}

class _AddMenuDetailsState extends State<AddMenuDetails> {
  final int _quantity = 1; // ค่าเริ่มต้นจำนวนสินค้า
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white,
        backgroundImage: AssetImage(widget.menu.imagePath!),
      ),
      title: Text(
        widget.menu.nameTh!,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(fontWeight: FontWeight.bold),
      ),
      trailing: ElevatedButton(
        onPressed: () {
          // สร้าง OrderItem และส่งข้อมูลกลับไปยัง CartDetails
          OrderItem newItem = OrderItem(
            id: 0,
            menuId: widget.menu.id!,
            menuName: widget.menu.nameTh ?? 'Unknown',
            imagePath: widget.menu.imagePath ?? '',
            price: (widget.menu.price ?? 0.0).toInt(), // แปลงเป็น int
            qty: _quantity,
            remark: '', // สามารถปรับให้เป็น remark ที่ต้องการ
            status: '', // สามารถปรับให้เป็น status ที่ต้องการ
          );
          // เพิ่มเมนูเข้าไปในคำสั่งซื้อที่กำลังทำงานอยู่
          widget.controller.addMenuToCurrentOrder(widget.menu, _quantity);

          // แสดงข้อมูลปัจจุบันใน currentOrder
          widget.controller.debugOrderItems();

          // ปิดหน้าต่างและส่ง OrderItem กลับไป
          Navigator.pop(context, newItem);
        },
        child: Text('เพิ่ม'),
      ),
    );
  }
}
