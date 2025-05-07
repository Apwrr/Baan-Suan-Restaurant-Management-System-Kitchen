import 'package:flutter/material.dart';
import '../../../constants.dart';

class CartCounter extends StatelessWidget {
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int quantity;
  final double buttonSize;
  final double iconSize;

  const CartCounter({
    Key? key,
    required this.onIncrement,
    required this.onDecrement,
    required this.quantity,
    this.buttonSize = 28.0,
    this.iconSize = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildOutlineButton(
          icon: Icons.remove,
          press: onDecrement,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: defaultPadding / 4),
          child: Text(
            quantity.toString().padLeft(2),
            style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18.0),
          ),
        ),
        buildOutlineButton(
          icon: Icons.add,
          press: onIncrement,
        ),
      ],
    );
  }

  SizedBox buildOutlineButton({
    required IconData icon,
    required VoidCallback press,
  }) {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: OutlinedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          )),
        ),
        onPressed: press,
        child: Icon(icon, size: iconSize),
      ),
    );
  }
}
