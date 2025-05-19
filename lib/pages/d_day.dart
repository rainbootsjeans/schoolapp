import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:school_app/controllers/d_day_controller.dart';

final DDayController dDayController = Get.put(DDayController());

class DDay extends StatefulWidget {
  const DDay({super.key});

  @override
  State<DDay> createState() => _DDayState();
}

class _DDayState extends State<DDay> {
  DateTime _dialogSelectedDate = DateTime.now();
  final _dialogTitleController = TextEditingController();

  Future<void> _presentCustomDatePicker(
    StateSetter parentDialogSetState,
    DateTime currentDialogDate,
  ) async {
    DateTime dateInPicker = currentDialogDate;

    final DateTime? confirmedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext datePickerDialogContext) {
        return StatefulBuilder(
          builder: (
            BuildContext sbfContextInternal,
            StateSetter calendarDialogSetState,
          ) {
            return AlertDialog(
              backgroundColor:
                  Theme.of(datePickerDialogContext).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              content: SizedBox(
                width: MediaQuery.of(datePickerDialogContext).size.width * 0.75,
                height: 320,
                child: CalendarDatePicker(
                  initialDate: dateInPicker,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                  onDateChanged: (newDate) {
                    calendarDialogSetState(() {
                      dateInPicker = newDate;
                    });
                  },
                ),
              ),
              actionsAlignment: MainAxisAlignment.end,
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('취소'),
                  onPressed:
                      () => Navigator.of(datePickerDialogContext).pop(null),
                ),
                TextButton(
                  child: const Text('확인'),
                  onPressed:
                      () => Navigator.of(
                        datePickerDialogContext,
                      ).pop(dateInPicker),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmedDate != null) {
      parentDialogSetState(() {
        _dialogSelectedDate = confirmedDate;
      });
    }
  }

  void _showAddOrEditDDayDialog({DDayItem? existingDDayItem}) {
    final bool isEditing = existingDDayItem != null;

    _dialogTitleController.text = existingDDayItem?.title ?? '';
    _dialogSelectedDate = existingDDayItem?.date ?? DateTime.now();

    String? dDayTitleErrorTextForDialog;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, dialogSetState) {
            return Material(
              type: MaterialType.transparency,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'D-Day 수정하기' : 'D-Day 추가하기',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _dialogTitleController,
                              decoration: InputDecoration(
                                labelText: '디데이 제목을 입력해 주세요.',

                                labelStyle: TextStyle(
                                  color:
                                      dDayTitleErrorTextForDialog != null
                                          ? Theme.of(
                                            stfContext,
                                          ).colorScheme.error
                                          : Colors.grey[600],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        dDayTitleErrorTextForDialog != null
                                            ? Theme.of(
                                              stfContext,
                                            ).colorScheme.error
                                            : Theme.of(stfContext).primaryColor,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                errorText: dDayTitleErrorTextForDialog,
                                errorStyle: TextStyle(
                                  color: Theme.of(stfContext).colorScheme.error,
                                ),
                              ),
                              onChanged: (value) {
                                if (dDayTitleErrorTextForDialog != null &&
                                    value.trim().isNotEmpty) {
                                  dialogSetState(() {
                                    dDayTitleErrorTextForDialog = null;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            Divider(color: Colors.grey[300], height: 0.1),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '날짜',
                                  style: TextStyle(fontSize: 16),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _presentCustomDatePicker(
                                      dialogSetState,
                                      _dialogSelectedDate,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Text(
                                      DateFormat(
                                        'yyyy년 MM월 dd일 (E)',
                                        'ko_KR',
                                      ).format(_dialogSelectedDate),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color:
                                            Theme.of(
                                              stfContext,
                                            ).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(dialogContext).pop(),
                                  child: const Text('취소'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    final title =
                                        _dialogTitleController.text.trim();
                                    if (title.isEmpty) {
                                      dialogSetState(() {
                                        dDayTitleErrorTextForDialog =
                                            'D-Day 제목을 입력해주세요.';
                                      });
                                      return;
                                    }
                                    dialogSetState(() {
                                      dDayTitleErrorTextForDialog = null;
                                    });

                                    if (isEditing) {
                                      await dDayController.updateDDayItem(
                                        existingDDayItem.id,
                                        title,
                                        _dialogSelectedDate,
                                      );
                                    } else {
                                      await dDayController.addDDayItem(
                                        title,
                                        _dialogSelectedDate,
                                      );
                                    }
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: Text(isEditing ? '저장' : '추가'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _dialogTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('D-Day 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddOrEditDDayDialog();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (dDayController.dDayModel.value.dDayList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                '추가된 D-Day가 없습니다.\n오른쪽 상단의 + 버튼을 눌러 추가해보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            ),
          );
        }
        var displayedList = dDayController.dDayModel.value.dDayList;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: displayedList.length,
          itemBuilder: (context, index) {
            final item = displayedList[index];
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final eventDate = DateTime(
              item.date.year,
              item.date.month,
              item.date.day,
            );
            final differenceInDays = eventDate.difference(today).inDays;

            String dDayText;
            Color dDayColor;

            if (differenceInDays == 0) {
              dDayText = 'D-DAY';
              dDayColor = Colors.red.shade700;
            } else if (differenceInDays > 0) {
              dDayText = 'D-$differenceInDays';
              dDayColor = Theme.of(context).colorScheme.primary;
            } else {
              dDayText = 'D+${differenceInDays.abs()}';
              dDayColor = Colors.grey.shade600;
            }

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                onTap: () {
                  _showAddOrEditDDayDialog(existingDDayItem: item);
                },

                contentPadding: const EdgeInsets.fromLTRB(
                  20.0,
                  12.0,
                  12.0,
                  12.0,
                ),
                title: Text(item.title, style: const TextStyle(fontSize: 18.0)),
                subtitle: Text(
                  DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(item.date),
                  style: TextStyle(fontSize: 14.0, color: Colors.grey.shade700),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dDayText,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: dDayColor,
                      ),
                    ),
                    const SizedBox(width: 8),

                    IconButton(
                      icon: Icon(
                        Icons.delete_sweep_outlined,
                        size: 22,
                        color: Colors.grey.shade700,
                      ),
                      tooltip: '삭제',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Get.defaultDialog(
                          title: "",
                          titleStyle: const TextStyle(fontSize: 1),
                          middleText: "'${item.title}' D-Day를 삭제하시겠습니까?",
                          confirmTextColor:
                              Theme.of(context).colorScheme.onSurface,
                          textConfirm: "삭제",
                          onConfirm: () async {
                            await dDayController.removeDDayItem(item.id);
                            Get.back();
                          },
                          textCancel: "취소",
                          cancelTextColor:
                              Theme.of(context).colorScheme.onSecondary,
                          onCancel: () => Get.back(),
                          buttonColor: Colors.transparent,
                          radius: 10.0,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
