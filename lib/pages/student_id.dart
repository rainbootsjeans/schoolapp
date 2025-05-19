import 'package:flutter/material.dart';

class StudentIdPage extends StatefulWidget {
  const StudentIdPage({super.key});

  @override
  State<StudentIdPage> createState() => _StudentIdPageState();
}

class _StudentIdPageState extends State<StudentIdPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student ID')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 800 * 0.6,
              width: 500 * 0.6,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(child: Text('Student ID')),
            ),
          ],
        ),
      ),
    );
  }
}
