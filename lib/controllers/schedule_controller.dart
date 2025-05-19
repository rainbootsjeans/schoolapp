import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:school_app/services/schedule_pager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ScheduleController extends GetxController {
  RxList<SubjectSwapRule> swapRules = <SubjectSwapRule>[].obs;
  static const _swapRulesKey = 'subjectSwapRules_v1';
  var uuid = const Uuid();

  RxMap<String, List<String>> weeklyTimetable = <String, List<String>>{}.obs;
  RxBool isLoadingWeeklyTimetable = false.obs;
  RxString weeklyTimetableError = ''.obs;

  int _currentGradeForWeeklyView = 0;
  int _currentClassNumForWeeklyView = 0;

  @override
  void onInit() {
    super.onInit();
    loadSwapRules();
  }

  Future<void> loadSwapRules() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? rulesJsonList = prefs.getStringList(_swapRulesKey);
    if (rulesJsonList != null && rulesJsonList.isNotEmpty) {
      swapRules.assignAll(
        rulesJsonList.map((jsonString) {
          return SubjectSwapRule.fromJson(
            jsonDecode(jsonString) as Map<String, dynamic>,
          );
        }).toList(),
      );
    } else {
      swapRules.assignAll([]);
    }
  }

  Future<void> _saveSwapRules() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rulesJsonList =
        swapRules.map((rule) {
          return jsonEncode(rule.toJson());
        }).toList();
    await prefs.setStringList(_swapRulesKey, rulesJsonList);

    if (_currentGradeForWeeklyView != 0 && _currentClassNumForWeeklyView != 0) {
      fetchWeeklyTimetable(
        grade: _currentGradeForWeeklyView,
        classNum: _currentClassNumForWeeklyView,
      );
    }
  }

  Future<void> addOrUpdateSwapRule(
    String originalSubject,
    String customSubject,
  ) async {
    if (originalSubject.trim().isEmpty || customSubject.trim().isEmpty) {
      Get.snackbar(
        "입력 오류",
        "원래 과목명과 바꿀 과목명 모두 입력해주세요.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    final String originalLowerTrimmed = originalSubject.trim().toLowerCase();
    final String customTrimmed = customSubject.trim();
    final existingRuleIndex = swapRules.indexWhere(
      (rule) =>
          rule.originalSubject.trim().toLowerCase() == originalLowerTrimmed,
    );

    if (existingRuleIndex != -1) {
      swapRules[existingRuleIndex].customSubject = customTrimmed;
    } else {
      final newRule = SubjectSwapRule(
        id: uuid.v4(),
        originalSubject: originalSubject.trim(),
        customSubject: customTrimmed,
      );
      swapRules.add(newRule);
    }
    await _saveSwapRules();
    swapRules.refresh();
  }

  Future<void> updateSwapRuleById(
    String id,
    String newOriginalSubject,
    String newCustomSubject,
  ) async {
    if (newOriginalSubject.trim().isEmpty || newCustomSubject.trim().isEmpty) {
      Get.snackbar(
        "입력 오류",
        "두 과목명을 모두 입력해주세요.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    final index = swapRules.indexWhere((rule) => rule.id == id);
    if (index != -1) {
      swapRules[index].originalSubject = newOriginalSubject.trim();
      swapRules[index].customSubject = newCustomSubject.trim();
      await _saveSwapRules();
      swapRules.refresh();
    } else {
      Get.snackbar(
        "오류",
        "수정할 규칙을 찾지 못했습니다.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> removeSwapRule(String id) async {
    swapRules.removeWhere((rule) => rule.id == id);
    await _saveSwapRules();
  }

  String getCustomSubject(String apiSubject) {
    if (apiSubject.trim().isEmpty) return "";
    final String apiSubjectLowerTrimmed = apiSubject.trim().toLowerCase();
    final matchedRule = swapRules.firstWhereOrNull(
      (rule) =>
          rule.originalSubject.trim().toLowerCase() == apiSubjectLowerTrimmed,
    );
    return matchedRule?.customSubject ?? apiSubject.trim();
  }

  List<DateTime> getCurrentWeekDates() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime monday = now.subtract(Duration(days: currentWeekday - 1));
    List<DateTime> weekDates = [];
    for (int i = 0; i < 5; i++) {
      weekDates.add(monday.add(Duration(days: i)));
    }
    return weekDates;
  }

  Future<void> fetchWeeklyTimetable({
    required int grade,
    required int classNum,
  }) async {
    _currentGradeForWeeklyView = grade;
    _currentClassNumForWeeklyView = classNum;

    isLoadingWeeklyTimetable.value = true;
    weeklyTimetableError.value = '';
    Map<String, List<String>> tempWeeklyTimetable = {};
    List<DateTime> weekDates = getCurrentWeekDates();

    try {
      for (DateTime date in weekDates) {
        String ymd = DateFormat('yyyyMMdd').format(date);
        try {
          String dailyTimetableString = await fetchTimetable(
            grade: grade,
            classNum: classNum,
            date: ymd,
          );
          tempWeeklyTimetable[ymd] =
              dailyTimetableString.isNotEmpty
                  ? dailyTimetableString.split('\n')
                  : List.generate(7, (i) => "${i + 1}교시: -");
        } catch (e) {
          print("개별 날짜($ymd) 시간표 로드 오류: $e");
          tempWeeklyTimetable[ymd] = List.generate(
            7,
            (i) => "${i + 1}교시: 로드실패",
          );
        }
      }
      weeklyTimetable.assignAll(tempWeeklyTimetable);
    } catch (e) {
      weeklyTimetableError.value = "주간 시간표를 불러오는 중 전체 오류가 발생했습니다.";
      print("주간 시간표 로드 전체 오류: $e");
    } finally {
      isLoadingWeeklyTimetable.value = false;
    }
  }
}

class SubjectSwapRule {
  String id;
  String originalSubject;
  String customSubject;

  SubjectSwapRule({
    required this.id,
    required this.originalSubject,
    required this.customSubject,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'originalSubject': originalSubject,
    'customSubject': customSubject,
  };

  factory SubjectSwapRule.fromJson(Map<String, dynamic> json) =>
      SubjectSwapRule(
        id: json['id'] as String,
        originalSubject: json['originalSubject'] as String,
        customSubject: json['customSubject'] as String,
      );
}
