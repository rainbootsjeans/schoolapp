import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_app/controllers/allergy_controller.dart';

class MealDetail extends StatefulWidget {
  const MealDetail({super.key});

  @override
  State<MealDetail> createState() => _MealDetailState();
}

AllergyController allergyController = Get.put(AllergyController());

class _MealDetailState extends State<MealDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(child: Column(children: [
            
          ],
        )),
    );
  }
}
