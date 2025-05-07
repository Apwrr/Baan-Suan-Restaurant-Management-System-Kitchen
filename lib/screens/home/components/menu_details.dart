import 'package:animation_2/controllers/home_controller.dart';
import 'package:animation_2/models/Menu.dart';
import 'package:animation_2/screens/home/components/price.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';

class MenuDetails extends StatefulWidget {
  const MenuDetails({
    Key? key,
    required this.menu,
    required this.controller,
  }) : super(key: key);

  final Menu menu;
  final HomeController controller;

  @override
  _MenuDetailsState createState() => _MenuDetailsState();
}

class _MenuDetailsState extends State<MenuDetails> {
  bool isOpen = true; // ตัวแปรเพื่อเก็บสถานะ ON/OFF
  String status = 'ACTIVE'; // เก็บสถานะสำหรับส่ง API

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
      trailing: FittedBox(
        child: Row(
          children: [
            Switch(
              value: isOpen,
              onChanged: (value) {
                setState(() {
                  isOpen = value;
                  status = isOpen ? 'ACTIVE' : 'INACTIVE'; // อัพเดทสถานะสำหรับส่ง API
                });
              },
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
            ),
            Text(
              isOpen ? 'เปิดเมนู' : 'ปิดเมนู',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isOpen ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
