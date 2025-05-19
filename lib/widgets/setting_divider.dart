import 'package:flutter/material.dart';

class SettingDivider extends StatelessWidget {
  final String title;
  const SettingDivider({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40),
        Row(children: [SizedBox(width: 20), Text(title)]),
      ],
    );
  }
}
