import 'package:animation_2/models/Menu.dart';
import 'package:animation_2/models/cart_counter.dart';
import 'package:animation_2/screens/home/components/Add_Menu.dart';
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
  List<OrderItem> processingItems = []; // รายการที่กำลังทำ

  @override
  void initState() {
    super.initState();
    widget.controller.initializeCurrentOrder(widget.order);
    isOrderAccepted = widget.controller.isTableConfirmed(widget.order.table);

    // เริ่มต้นแผนที่ด้วยจำนวนสินค้าตั้งต้นและสถานะการตรวจสอบ
    for (var item in widget.controller.currentOrder.orderItems) {
      _itemQuantities[item.id] = item.qty;
      _checkedItems[item.id] = false; // เริ่มต้นด้วยการไม่ตรวจสอบทุกสินค้า
    }

    // เช็คสถานะของรายการและอัปเดต processingItems
    _updateProcessingItems();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // อัปเดตข้อมูล processingItems ทุกครั้งที่เข้ามา
    _updateProcessingItems();
  }

  // ฟังก์ชันสำหรับอัปเดตรายการที่กำลังทำ
  void _updateProcessingItems() {
    processingItems = widget.controller.currentOrder.orderItems
        .where((item) => item.status == 'COOKING') // เพิ่มเฉพาะรายการที่มีสถานะ COOKING
        .toList();
  }

  // ฟังก์ชันสำหรับลบสินค้าออกจากออเดอร์
  void _removeItem(int id) {
    setState(() {
      widget.controller.currentOrder.orderItems.removeWhere((item) => item.id == id);
      _itemQuantities.remove(id);
      _checkedItems.remove(id);
    });
    _updateProcessingItems(); // อัปเดตรายการที่กำลังทำ
  }

  // ฟังก์ชันสำหรับแยกกลุ่มรายการอาหารที่มีสถานะ PREPARING
  List<OrderItem> get preparingItems => widget.controller.currentOrder.orderItems
      .where((item) => item.status == 'PREPARING') // เฉพาะสถานะ PREPARING
      .toList();

  // ฟังก์ชันสำหรับแยกกลุ่มรายการอาหารที่ถูกทำเครื่องหมาย
  List<OrderItem> get selectedItems => widget.controller.currentOrder.orderItems
      .where((item) => _checkedItems[item.id] ?? false)
      .toList();

  // ฟังก์ชันสำหรับยืนยันรายการอาหาร
  void _confirmItems() async {
    // ดึงรายการที่ถูกทำเครื่องหมาย
    List<OrderItem> itemsToConfirm = selectedItems;

    // สร้างลิสต์สำหรับรายการที่ไม่ได้ทำเครื่องหมาย
    List<OrderItem> itemsToPrepare = widget.controller.currentOrder.orderItems.where((item) => !_checkedItems[item.id]!).toList();

    // เปลี่ยนสถานะของรายการที่ถูกทำเครื่องหมายเป็น 'COOKING' เฉพาะเมื่อสถานะปัจจุบันไม่ใช่ 'COOKING'
    itemsToConfirm.forEach((item) {
      if (item.status != 'COOKING') {
        item.status = 'COOKING';
      }
    });

    // เปลี่ยนสถานะของรายการที่ไม่ได้ทำเครื่องหมายเป็น 'PREPARING' เฉพาะเมื่อสถานะปัจจุบันไม่ใช่ 'COOKING'
    itemsToPrepare.forEach((item) {
      if (item.status != 'COOKING') {
        item.status = 'PREPARING';
      }
    });

    // รวมทั้งสองลิสต์
    List<OrderItem> itemsToSend = [...itemsToConfirm, ...itemsToPrepare];

    if (itemsToSend.isNotEmpty) {
      // เรียกใช้ confirmOrder และส่งรายการที่ต้องการ
      bool success = await widget.controller.confirmOrder(
        widget.order.id,
        widget.order.table,
        itemsToSend, // ส่งลิสต์ที่รวมทั้งสอง
      );

      if (success) {
        setState(() {
          // ย้ายเฉพาะรายการที่ถูกทำเครื่องหมายไปยัง "กำลังทำ"
          processingItems.addAll(itemsToConfirm);
          // ลบรายการที่ถูกย้ายออกจาก "รายการอาหารเข้า"
          widget.controller.currentOrder.orderItems
              .removeWhere((item) => _checkedItems[item.id] ?? false);
          // รีเซ็ตสถานะการตรวจสอบของรายการที่ถูกย้ายแล้ว
          for (var item in itemsToConfirm) {
            _checkedItems[item.id] = false;
          }
        });

        // แสดง Snackbar เมื่อรับรายการอาหารสำเร็จ
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเลือกอย่างน้อยหนึ่งรายการ')),
      );
    }
  }

  // ฟังก์ชันสำหรับการเสร็จสิ้น
  void _completeOrder() async {
    if (processingItems.isNotEmpty) {
      // ส่งรายการที่อยู่ใน processingItems ไปยัง submitStatus
      bool success = await widget.controller.submitStatus(widget.order.id, 'completed', processingItems);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('การทำรายการเสร็จสิ้น')),
        );
        // นำทางไปยังหน้า CartOrder
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CartOrder(controller: widget.controller),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('การทำรายการไม่สำเร็จ')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่มีรายการในกำลังทำ')),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    //_updateProcessingItems();
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            // เรียกใช้ฟังก์ชันนี้เมื่อกดปุ่ม BackButton
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartOrder(controller:  HomeController())),
            );
            // เรียกใช้ refreshPage() ในหน้า CartOrder
            widget.controller.refreshOrdersList(); // ตัวอย่างฟังก์ชันที่สามารถรีเฟรชได้
          },
        ),
        backgroundColor: Color(0xFFE4F0E6),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'รายละเอียดโต๊ะ ${widget.order.table}',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFFE4F0E6)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงรายการที่มีสถานะ PREPARING
            if (preparingItems.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'รายการอาหารเข้า',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // แสดงรายการอาหารที่มีสถานะ PREPARING
              ...preparingItems.map((item) => _buildListTile(item)),
            ],
            // แสดงรายการที่กำลังทำ
            if (processingItems.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'กำลังทำ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // แสดงรายการกำลังทำทั้งหมด
              ...processingItems.map((item) => _buildListTile(item, isProcessing: true)),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ปุ่มยืนยันรายการอาหาร
            Expanded(
              child: ElevatedButton(
                onPressed: selectedItems.isNotEmpty ? _confirmItems : null,
                style: ElevatedButton.styleFrom(
                  primary: selectedItems.isNotEmpty ? Colors.orange[300] : Colors.grey,
                  onSurface: Colors.grey,
                ),

                child: Text(
                  "ยืนยันรายการอาหาร",
                  style: TextStyle(color: Colors.black),
                ),

              ),
            ),
            SizedBox(width: 8.0),
            // ปุ่มเสร็จสิ้น
            Expanded(
              child: ElevatedButton(
                onPressed: processingItems.isNotEmpty ? _completeOrder : null,
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onSurface: Colors.grey,
                ),
                child: Text(
                  "เสร็จสิ้น",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสำหรับสร้าง ListTile ของแต่ละรายการ
  Widget _buildListTile(OrderItem item, {bool isProcessing = false}) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white,
        backgroundImage: AssetImage(item.imagePath),
      ),
      title: Text(item.menuName),
      subtitle: Text('จำนวน: ${_itemQuantities[item.id] ?? 1}'),
      trailing: isProcessing
          ? null
          : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            activeColor: Colors.green,
            value: _checkedItems[item.id] ?? false,
            onChanged: (bool? value) {
              setState(() {
                _checkedItems[item.id] = value!;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.cancel_presentation_rounded, color: Colors.red),
            onPressed: () {
              _showRemoveConfirmationDialog(item.id);
            },
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันแสดงการยืนยันการลบสินค้า
  void _showRemoveConfirmationDialog(int id) {
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
              onPressed: () async {
                _removeItem(id); // ลบสินค้าเมื่อผู้ใช้กดยืนยัน
                Navigator.of(context).pop(); // ปิด dialog หลังลบสินค้าแล้ว
                // เรียกฟังก์ชันยืนยันรายการอาหาร
                _confirmItems();
              },
              child: Text('ใช่'),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันเพิ่มเมนูใหม่จาก AddMenuDetails
  void _addMenuToOrder(OrderItem newItem) {
    setState(() {
      // ตรวจสอบว่ามีรายการเดียวกันอยู่ในรายการอาหารที่มีสถานะ "PREPARING"
      bool itemExists = widget.controller.currentOrder.orderItems.any((item) =>
      item.menuId == newItem.menuId && item.status == "PREPARING");

      if (itemExists) {
        // ถ้ามีรายการเดียวกันอยู่แล้ว ก็เพิ่มเฉพาะจำนวน
        var existingItem = widget.controller.currentOrder.orderItems
            .firstWhere((item) => item.menuId == newItem.menuId && item.status == "PREPARING");

        existingItem.qty += newItem.qty; // เพิ่มจำนวนของรายการที่มีอยู่
      } else {
        // ถ้าไม่มีรายการเดียวกัน ให้สร้างรายการใหม่
        OrderItem itemToAdd = OrderItem(
          id: newItem.id, // ให้ ID ใหม่
          menuId: newItem.menuId,
          menuName: newItem.menuName,
          qty: newItem.qty,
          price: newItem.price,
          imagePath: newItem.imagePath,
          remark: newItem.remark,
          status: "PREPARING", // กำหนดสถานะให้เป็น PREPARING
        );
        widget.controller.currentOrder.orderItems.add(itemToAdd);
      }

      _itemQuantities[newItem.id] = newItem.qty; // อัปเดตจำนวน
      _checkedItems[newItem.id] = false; // เริ่มต้นการตรวจสอบ
    });
  }

}
