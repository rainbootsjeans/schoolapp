import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentNumberController extends GetxController {
  final studentModel = StudentModel().obs;

  Future<void> initStudentNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStudentNumber = prefs.getString('studentNumber');

    if (savedStudentNumber == null) {
      studentModel.value.studentNumber.value = '10101';
      await prefs.setString('studentNumber', '10101');
    } else {
      studentModel.value.studentNumber.value = savedStudentNumber;
    }
  }

  void saveStudentNumber(int grade, int classNum, int number) async {
    final prefs = await SharedPreferences.getInstance();
    final formattedClassNumber = classNum.toString().padLeft(2, '0');
    final formattedNumber = number.toString().padLeft(2, '0');
    final studentNumber = '$grade$formattedClassNumber$formattedNumber';

    studentModel.value.studentNumber.value = studentNumber;
    await prefs.setString('studentNumber', studentNumber);
  }

  String getStudentNumber() {
    return studentModel.value.studentNumber.value;
  }

  Map<String, int> parseStudentId(String studentId) {
    int grade = int.parse(studentId.substring(0, 1));
    int classNum = int.parse(studentId.substring(1, 3));
    int number = int.parse(studentId.substring(3, 5));

    return {'grade': grade, 'class': classNum, 'number': number};
  }
}

class StudentModel {
  RxString studentNumber = ''.obs;
}
