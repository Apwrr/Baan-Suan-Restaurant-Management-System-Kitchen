import 'package:flutter/material.dart';



class Price extends StatelessWidget {
  const Price({
    Key? key,
    required this.amount,
  }) : super(key: key);
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: "\฿",
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(fontWeight: FontWeight.w600, color: Colors.blue),
        children: [
          TextSpan(
            text: amount.toString(),
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: " บาท",
            style:
            TextStyle(color: Colors.black26, fontWeight: FontWeight.normal),
          )
        ],
      ),
    );
  }
}
