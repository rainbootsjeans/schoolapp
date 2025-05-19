import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DDayController extends GetxController {
  final dDayModel = DDayModel().obs;
  static const _dDayListKey = 'dDayItemsList';
  var uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    loadDDayItems();
  }

  Future<void> _sortAndAssignDDayItems(List<DDayItem> items) async {
    items.sort((a, b) => a.date.compareTo(b.date));
    dDayModel.value.dDayList.assignAll(items);
  }

  Future<void> loadDDayItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedDDayJsonList = prefs.getStringList(_dDayListKey);

    if (savedDDayJsonList != null && savedDDayJsonList.isNotEmpty) {
      final List<DDayItem> loadedItems =
          savedDDayJsonList.map((jsonString) {
            return DDayItem.fromJson(
              jsonDecode(jsonString) as Map<String, dynamic>,
            );
          }).toList();
      await _sortAndAssignDDayItems(loadedItems);
    } else {
      dDayModel.value.dDayList.assignAll([]);
    }
  }

  Future<void> _saveDDayItemsToPrefs() async {
    List<DDayItem> currentList = List<DDayItem>.from(dDayModel.value.dDayList);

    await _sortAndAssignDDayItems(currentList);

    final prefs = await SharedPreferences.getInstance();
    final List<String> dDayJsonList =
        dDayModel.value.dDayList.map((item) {
          return jsonEncode(item.toJson());
        }).toList();
    await prefs.setStringList(_dDayListKey, dDayJsonList);
  }

  Future<void> addDDayItem(String title, DateTime date) async {
    if (title.trim().isEmpty) {
      return;
    }
    final newItem = DDayItem(id: uuid.v4(), title: title.trim(), date: date);
    dDayModel.value.dDayList.add(newItem);
    await _saveDDayItemsToPrefs();
  }

  Future<void> removeDDayItem(String id) async {
    dDayModel.value.dDayList.removeWhere((item) => item.id == id);
    await _saveDDayItemsToPrefs();
  }

  Future<void> updateDDayItem(
    String id,
    String newTitle,
    DateTime newDate,
  ) async {
    if (newTitle.trim().isEmpty) {
      return;
    }
    final index = dDayModel.value.dDayList.indexWhere((item) => item.id == id);
    if (index != -1) {
      dDayModel.value.dDayList[index].title = newTitle.trim();
      dDayModel.value.dDayList[index].date = newDate;

      await _saveDDayItemsToPrefs();
      dDayModel.refresh();
    }
  }
}

class DDayItem {
  String id;
  String title;
  DateTime date;

  DDayItem({required this.id, required this.title, required this.date});

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
  };

  factory DDayItem.fromJson(Map<String, dynamic> json) => DDayItem(
    id: json['id'] as String,
    title: json['title'] as String,
    date: DateTime.parse(json['date'] as String),
  );
}

class DDayModel {
  RxList<DDayItem> dDayList = <DDayItem>[].obs;
}
