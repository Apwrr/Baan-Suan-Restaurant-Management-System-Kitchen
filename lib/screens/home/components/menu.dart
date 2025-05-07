import 'package:animation_2/api_services.dart';
import 'package:animation_2/controllers/home_controller.dart';
import 'package:animation_2/screens/home/components/menu_details.dart';
import 'package:flutter/material.dart';
import 'package:animation_2/constants.dart';
import 'package:animation_2/models/Menu.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key, required this.controller}) : super(key: key);

  final HomeController controller;

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<List<Menu>> futureMenus;

  @override
  void initState() {
    super.initState();
    futureMenus = ApiService().fetchMenus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
        ),
        title: const Text("เมนู",style: TextStyle(color: Colors.black),),
        backgroundColor: const Color(0xFFE4F0E6),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Menu>>(
        future: futureMenus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Menu> menus = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.all(defaultPadding),
              itemCount: menus.length,
              itemBuilder: (context, index) {
                return MenuDetails(
                  menu: menus[index],
                  controller: widget.controller,
                );
              },
            );
          }
        },
      ),
    );
  }
}
