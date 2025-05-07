import 'package:animation_2/screens/home/components/GroupedOrdersScreen.dart';
import 'package:flutter/material.dart';
import 'package:animation_2/controllers/home_controller.dart';
import 'package:animation_2/screens/home/components/cart_Details.dart';
import 'package:animation_2/screens/home/components/footer.dart';
import 'package:animation_2/api_services.dart';

import 'cart_order_list.dart';

class CartOrder extends StatefulWidget {
  const CartOrder({Key? key, required this.controller}) : super(key: key);

  final HomeController controller;

  @override
  _CartOrderState createState() => _CartOrderState();
}

class _CartOrderState extends State<CartOrder> {
  late Future<List<Order>> futureOrdersList;

  @override
  void initState() {
    super.initState();
    futureOrdersList = ApiService().fetchOrdersList();
    _refreshPage(); // เรียกใช้เพื่อดึงข้อมูลเมื่อเริ่มต้น
  }

  Future<void> _refreshPage() async {
    setState(() {
      futureOrdersList = ApiService().fetchOrdersList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Color(0xFFE4F0E6),
        ),
        backgroundColor: Color(0xFFE4F0E6),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "รายการอาหาร",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: FutureBuilder<List<Order>>(
          future: futureOrdersList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('ไม่มีรายการสั่งอาหาร', style: TextStyle(fontSize: 18, color: Colors.black54),),);
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('ไม่มีรายการสั่งอาหาร', style: TextStyle(fontSize: 18, color: Colors.black54),),);
            } else {
              List<Order> orders = snapshot.data!;
              return Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    dataRowHeight: 100,
                    headingTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    dataTextStyle: TextStyle(
                      fontSize: 14,
                    ),
                    columns: [
                      DataColumn(
                        label: Text(
                          'หมายเลขโต๊ะ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'เมนู',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'จำนวน',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'รายละเอียด',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                    rows: orders.map((order) => DataRow(cells: [
                      DataCell(
                        Center(
                          child: Text(
                            order.table.toString(),
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ),
                      ),
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < order.orderItems.length && i < 4; i++)
                              Text(
                                order.orderItems[i].menuName,
                                style: TextStyle(fontSize: 14, color: Colors.black),
                              ),
                            if (order.orderItems.length > 4)
                              Text(
                                'มีเมนูอื่นๆ',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartDetails(
                                order: order,
                                controller: widget.controller,
                              ),
                            ),
                          );
                        },
                      ),
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < order.orderItems.length && i < 4; i++)
                              Text(
                                order.orderItems[i].qty.toString(),
                                style: TextStyle(fontSize: 14, color: Colors.black),
                              ),
                            if (order.orderItems.length > 4)
                              Text(
                                '......',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartDetails(
                                order: order,
                                controller: widget.controller,
                              ),
                            ),
                          );
                        },
                      ),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CartDetails(
                                  order: order,
                                  controller: widget.controller,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue.shade300, // สีของปุ่ม
                          ),
                          child: Text(
                            'รายละเอียด',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ])).toList(),
                  ),
                ),
              );

            }
          },
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupedOrdersScreen(controller: HomeController(),),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange, // สีของปุ่ม

              ),
              child: Text(
                'ออเดอร์รวม',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
          Footer(controller: widget.controller), // Footer อยู่ใต้ปุ่ม "ออเดอร์รวม"
        ],
      ),
    );
  }
}
