import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_app/controllers/allergy_controller.dart';
import 'package:school_app/widgets/allergy_check_box.dart';

AllergyController allergyController = Get.put(AllergyController());

class AllergySelector extends StatelessWidget {
  const AllergySelector({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: width * 0.8,
            constraints: BoxConstraints(maxHeight: height * 0.5),
            decoration: BoxDecoration(color: context.theme.colorScheme.surface),
            child: SingleChildScrollView(
              child: Center(
                child: Wrap(
                  children:
                      allergyController.allergyModel.value.allergyList.map((
                        allergy,
                      ) {
                        return AllergyCheckBox(allergyName: allergy);
                      }).toList(),
                ),
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
    );
  }
}
