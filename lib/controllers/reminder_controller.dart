import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ReminderController extends GetxController {
  final reminderModel = ReminderModel().obs;
  static const _reminderListKey = 'reminderItemsList';
  var uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    loadReminders();
  }

  Future<void> _sortAndAssignReminders(List<ReminderItem> items) async {
    items.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.dateTime.compareTo(b.dateTime);
    });
    reminderModel.value.reminderList.assignAll(items);
  }

  Future<void> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? reminderJsonStringList = prefs.getStringList(
      _reminderListKey,
    );

    if (reminderJsonStringList != null && reminderJsonStringList.isNotEmpty) {
      final loadedItems =
          reminderJsonStringList.map((jsonString) {
            return ReminderItem.fromJson(
              jsonDecode(jsonString) as Map<String, dynamic>,
            );
          }).toList();
      await _sortAndAssignReminders(loadedItems);
    } else {
      reminderModel.value.reminderList.assignAll([]);
    }
  }

  Future<void> _saveReminders() async {
    List<ReminderItem> currentList = List<ReminderItem>.from(
      reminderModel.value.reminderList,
    );
    await _sortAndAssignReminders(currentList);
    final prefs = await SharedPreferences.getInstance();
    final List<String> reminderJsonStringList =
        reminderModel.value.reminderList.map((item) {
          return jsonEncode(item.toJson());
        }).toList();
    await prefs.setStringList(_reminderListKey, reminderJsonStringList);
  }

  Future<void> addReminder(
    String title,
    DateTime dateTime, {
    bool isCompleted = false,
  }) async {
    if (title.trim().isEmpty) {
      Get.snackbar(
        "오류",
        "리마인더 제목을 입력해주세요.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final newItem = ReminderItem(
      id: uuid.v4(),
      title: title.trim(),
      dateTime: dateTime,
      isCompleted: isCompleted,
    );

    List<ReminderItem> currentList = List<ReminderItem>.from(
      reminderModel.value.reminderList,
    );
    currentList.add(newItem);

    reminderModel.value.reminderList.add(newItem);
    await _saveReminders();
  }

  Future<void> removeReminder(String id) async {
    reminderModel.value.reminderList.removeWhere((item) => item.id == id);
    await _saveReminders();
  }

  Future<void> toggleReminderStatus(String id) async {
    final index = reminderModel.value.reminderList.indexWhere(
      (item) => item.id == id,
    );
    if (index != -1) {
      final item = reminderModel.value.reminderList[index];

      reminderModel.value.reminderList[index] = item.copyWith(
        isCompleted: !item.isCompleted,
      );
      await _saveReminders();
    }
  }

  Future<void> updateReminder(
    String id,
    String newTitle,
    DateTime newDateTime,
  ) async {
    if (newTitle.trim().isEmpty) {
      Get.snackbar(
        "오류",
        "리마인더 제목을 입력해주세요.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final index = reminderModel.value.reminderList.indexWhere(
      (item) => item.id == id,
    );
    if (index != -1) {
      final item = reminderModel.value.reminderList[index];
      reminderModel.value.reminderList[index] = item.copyWith(
        title: newTitle.trim(),
        dateTime: newDateTime,
      );
      await _saveReminders();
    }
  }
}

class ReminderItem {
  String id;
  String title;
  DateTime dateTime;
  bool isCompleted;

  ReminderItem({
    required this.id,
    required this.title,
    required this.dateTime,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dateTime': dateTime.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory ReminderItem.fromJson(Map<String, dynamic> json) => ReminderItem(
    id: json['id'] as String,
    title: json['title'] as String,
    dateTime: DateTime.parse(json['dateTime'] as String),
    isCompleted: json['isCompleted'] as bool? ?? false,
  );

  ReminderItem copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    bool? isCompleted,
  }) {
    return ReminderItem(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ReminderModel {
  RxList<ReminderItem> reminderList = <ReminderItem>[].obs;
}
