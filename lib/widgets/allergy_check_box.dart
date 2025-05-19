import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_app/controllers/allergy_controller.dart';

AllergyController allergyController = Get.put(AllergyController());

class AllergyCheckBox extends StatelessWidget {
  final String allergyName;
  final RxBool isSelected = false.obs;

  AllergyCheckBox({super.key, required this.allergyName}) {
    isSelected.value = allergyController.allergyModel().myAllergyList.contains(
      allergyName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(() {
        final color =
            isSelected.value
                ? context.theme.colorScheme.primary
                : context.theme.colorScheme.onSurface;

        return GestureDetector(
          onTap: () {
            isSelected.toggle();
            if (isSelected.value) {
              allergyController.allergyModel.value.myAllergyList.add(
                allergyName,
              );
            } else {
              allergyController.allergyModel.value.myAllergyList.remove(
                allergyName,
              );
            }
          },
          child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 6, top: 6),
                      child: Icon(
                        isSelected.value
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: color,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.apple,
                      size: 45,
                      color: context.theme.colorScheme.onSecondary,
                    ),
                    const SizedBox(height: 3),
                    Text(allergyName, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
