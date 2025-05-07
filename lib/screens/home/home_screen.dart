import 'package:animation_2/constants.dart';
import 'package:animation_2/controllers/home_controller.dart';
import 'package:animation_2/screens/home/components/menu.dart';
import 'package:flutter/material.dart';
import 'components/footer.dart';
import 'components/header.dart';
import 'components/cart_Order.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController controller = HomeController();

  void _onVerticalGesture(DragUpdateDetails details) {
    if (details.primaryDelta! < -0.7) {
      setState(() {
        controller.changeHomeState(HomeState.cart);
      });
    } else if (details.primaryDelta! > 12) {
      setState(() {
        controller.changeHomeState(HomeState.normal);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Container(
          color: Color(0xFFEAEAEA),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, BoxConstraints constraints) {
                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: panelTransition,
                        top: controller.homeState == HomeState.normal
                            ? headerHeight
                            : -(constraints.maxHeight -
                            cartBarHeight * 2 -
                            headerHeight),
                        left: 0,
                        right: 0,
                        height: constraints.maxHeight -
                            headerHeight -
                            cartBarHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              bottomLeft:
                              Radius.circular(defaultPadding * 1.5),
                              bottomRight:
                              Radius.circular(defaultPadding * 1.5),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => CartOrder(controller: HomeController())
                                          )
                                      );
                                    },
                                    child: Container(
                                      width: 180, // กำหนดความกว้างของ Container
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(defaultPadding),
                                        ),
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Text(
                                              'รายการอาหาร',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16, // กำหนดขนาดตัวอักษร
                                                fontWeight: FontWeight.bold, // ทำให้ตัวอักษรเป็นตัวหนา
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8, // ระยะห่างจากด้านบนของ Container
                                            left: 8, // ระยะห่างจากด้านขวาของ Container
                                            child: Icon(
                                              Icons.restaurant_menu,
                                              color: Colors.green[200],
                                              size: 50.0, // ขนาดของไอคอน
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // การ์ดใหม่ทางด้านล่าง
                                  SizedBox(height: 40), // เพิ่มช่องว่างระหว่างการ์ด
                                  /*Container(
                                    width: 180, // กำหนดความกว้างของ Container
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(defaultPadding),
                                      ),
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Center(
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) => MenuScreen(controller: HomeController())));
                                        },
                                        icon: Icon(
                                          Icons.fastfood_rounded,
                                          color: Colors.blue[200],
                                          size: 80.0, // สีของไอคอนการ์ดใหม่
                                        ),
                                      ),
                                    ),
                                  ),*/
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Card Panel
                      AnimatedPositioned(
                        duration: panelTransition,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: controller.homeState == HomeState.normal
                            ? cartBarHeight
                            : (constraints.maxHeight - cartBarHeight),
                        //child: GestureDetector(
                        //onVerticalDragUpdate: _onVerticalGesture,
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          color: Color(0xFFEAEAEA),
                          child: AnimatedSwitcher(
                            duration: panelTransition,
                            child: controller.homeState == HomeState.normal
                                ? Footer(controller: controller)
                                : Footer(controller: controller),
                          ),
                        ),
                      ),
                      // Header
                      AnimatedPositioned(
                        duration: panelTransition,
                        top: controller.homeState == HomeState.normal
                            ? 0
                            : -headerHeight,
                        right: 0,
                        left: 0,
                        height: headerHeight,
                        child: HomeHeader(),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
