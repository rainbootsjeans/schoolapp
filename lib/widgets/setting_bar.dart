import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingBar extends StatelessWidget {
  final List<Widget> children;
  final Function? onTap;
  const SettingBar({super.key, required this.children, this.onTap});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            if (onTap != null) {
              onTap!();
            }
          },
          child: Container(
            width: width - 32,
            height: 60,
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [SizedBox(width: 20), ...children, SizedBox(width: 20)],
            ),
          ),
        ),
      ],
    );
  }
}
