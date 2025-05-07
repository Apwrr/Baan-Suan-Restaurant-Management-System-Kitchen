import 'package:animation_2/controllers/home_controller.dart';
import 'package:animation_2/screens/home/components/cart_Order.dart';
import 'package:flutter/material.dart';
import 'package:animation_2/api_services.dart';
import 'package:animation_2/screens/home/components/orderGropModel.dart';

class GroupedOrdersScreen extends StatefulWidget {
  final HomeController controller;
  const GroupedOrdersScreen({Key? key, required this.controller}) : super(key: key);

  @override
  State<GroupedOrdersScreen> createState() => _GroupedOrdersScreenState();
}

class _GroupedOrdersScreenState extends State<GroupedOrdersScreen> {
  late Future<List<GroupedOrder>> _futureGroupedOrders;

  @override
  void initState() {
    super.initState();
    _futureGroupedOrders = ApiService().fetchGroupedOrders();
  }

  Future<void> _handleAcceptAll(BuildContext context, GroupedOrder order) async {
    try {
      await ApiService().confirmGroupOrder(order);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('รับออเดอร์ "${order.menuName}" สำเร็จ!')),
      );
      // รีเฟรชข้อมูลหลังจากกดปุ่มสำเร็จ
      setState(() {
        _futureGroupedOrders = ApiService().fetchGroupedOrders();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('ออเดอร์รวม', style: TextStyle(color: Colors.black)),
        backgroundColor: Color(0xFFE4F0E6),
      ),
      body: FutureBuilder<List<GroupedOrder>>(
        future: _futureGroupedOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('ไม่มีออเดอร์'));
          } else {
            List<GroupedOrder> groupedOrders = snapshot.data!;
            return ListView.builder(
              itemCount: groupedOrders.length,
              itemBuilder: (context, index) {
                final order = groupedOrders[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Image.asset(order.imagePath, width: 50, height: 50),
                        title: Text(order.menuName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: order.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('โต๊ะ ${item.table}', style: TextStyle(fontSize: 14, color: Colors.black)),
                                  SizedBox(height: 2),
                                  Text('       ${item.qty} จาน', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () => _handleAcceptAll(context, order),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.orange, // สีปุ่ม
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            'รับทั้งหมด',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
