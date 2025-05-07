import 'package:flutter/material.dart';
import '../../../constants.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: BackButton(
        color: Color(0xFFE4F0E6),
      ),
      backgroundColor: Color(0xFFE4F0E6), // สีของ header
      centerTitle: true,
      title: Text(
        "HOME",
        style: TextStyle(color: Colors.black), // สีของตัวหนังสือใน header
      ),
      actions: [
        SizedBox(width: defaultPadding),
      ],
    );
  }
}
