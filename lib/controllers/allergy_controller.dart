import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllergyController extends GetxController {
  final allergyModel = AllergyModel().obs;

  Future<void> initAllergy() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedAllergyList = prefs.getStringList('allergyList');

    if (savedAllergyList == null) {
      AllergyModel().myAllergyList = <String>[].obs;
      prefs.setStringList('allergyList', []);
    } else {
      AllergyModel().myAllergyList = savedAllergyList.obs;
    }
  }

  void saveAllergy(List<String> yourAllergys) async {
    final prefs = await SharedPreferences.getInstance();
    allergyModel.value.myAllergyList.assignAll(yourAllergys);
    prefs.setStringList('allergyList', yourAllergys);
  }

  List<int> getAllergyIndexes(List<String> yourAllergys) {
    return yourAllergys
        .map((item) => allergyModel.value.allergyList.indexOf(item) + 1)
        .where((index) => index != 0)
        .toList();
  }
}

class AllergyModel {
  RxList<String> myAllergyList = <String>[].obs;

  final allergyList = [
    '난류',
    '우유',
    '메밀',
    '땅콩',
    '대두',
    '밀',
    '고등어',
    '게',
    '새우',
    '돼지고기',
    '복숭아',
    '토마토',
    '아황산류',
    '호두',
    '닭고기',
    '쇠고기',
    '오징어',
    '조개류',
    '잣',
  ];
}
