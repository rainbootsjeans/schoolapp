import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopBox extends StatelessWidget {
  Widget child;
  PopBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: width * 0.8,
              constraints: BoxConstraints(maxHeight: height * 0.5),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: child,
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: width * 0.8,
              height: height * 0.05,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: context.theme.colorScheme.onSurface,
                    width: 0.1,
                  ),
                ),
              ),
              child: const Center(
                child: Text('확인', style: TextStyle(fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
