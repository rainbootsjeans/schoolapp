import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:school_app/controllers/reminder_controller.dart';

class ReminderPage extends StatelessWidget {
  ReminderPage({super.key});

  final ReminderController reminderController = Get.find<ReminderController>();

  Future<DateTime?> _showCustomScrollTimePickerInDialog(
    BuildContext parentContext,
    DateTime initialTime,
  ) async {
    DateTime tempPickedTime = initialTime;

    return await showDialog<DateTime>(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext sbfContext, StateSetter dialogSetState) {
            return AlertDialog(
              title: const Center(
                child: Text(
                  '시간 선택',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              contentPadding: const EdgeInsets.only(top: 20.0, bottom: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              backgroundColor: Theme.of(dialogContext).colorScheme.surface,
              content: SizedBox(
                height: 200,
                width: double.maxFinite,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Theme.of(dialogContext).brightness,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 19,
                        color: Theme.of(dialogContext).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: tempPickedTime,
                    onDateTimeChanged: (newDateTime) {
                      dialogSetState(() {
                        tempPickedTime = newDateTime;
                      });
                    },
                    use24hFormat: false,
                    minuteInterval: 5,
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 10.0,
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('취소', style: TextStyle(fontSize: 16)),
                  onPressed: () => Navigator.of(dialogContext).pop(null),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('확인', style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(tempPickedTime);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddEditReminderDialog(
    BuildContext context, {
    ReminderItem? existingReminder,
  }) {
    final titleController = TextEditingController(
      text: existingReminder?.title ?? '',
    );
    DateTime initialDateTime = existingReminder?.dateTime ?? DateTime.now();
    if (existingReminder == null) {
      int currentMinute = initialDateTime.minute;
      if (currentMinute != 0 && currentMinute != 30) {
        initialDateTime =
            initialDateTime.minute < 30
                ? initialDateTime.copyWith(
                  minute: 30,
                  second: 0,
                  millisecond: 0,
                  microsecond: 0,
                )
                : initialDateTime
                    .add(const Duration(hours: 1))
                    .copyWith(
                      minute: 0,
                      second: 0,
                      millisecond: 0,
                      microsecond: 0,
                    );
      }
    }
    DateTime selectedDateTime = initialDateTime;
    final isEditing = existingReminder != null;

    String? titleErrorText;

    showDialog(
      context: context,
      builder: (mainDialogContext) {
        return StatefulBuilder(
          builder: (stfContext, dialogSetStateAddEdit) {
            Future<void> pickDate() async {
              DateTime tempPickedDateInCalendar = selectedDateTime;
              final DateTime? pickedDateResult = await showDialog<DateTime>(
                context: stfContext,
                builder: (BuildContext datePickerDialogContext) {
                  return StatefulBuilder(
                    builder: (
                      BuildContext sbfContextInternal,
                      StateSetter calendarDialogSetState,
                    ) {
                      return AlertDialog(
                        backgroundColor:
                            Theme.of(
                              datePickerDialogContext,
                            ).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        content: SizedBox(
                          width:
                              MediaQuery.of(
                                datePickerDialogContext,
                              ).size.width *
                              0.75,
                          height: 320,
                          child: CalendarDatePicker(
                            initialDate: tempPickedDateInCalendar,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 5),
                            ),
                            onDateChanged: (newDate) {
                              calendarDialogSetState(() {
                                tempPickedDateInCalendar = newDate;
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
                                () => Navigator.of(
                                  datePickerDialogContext,
                                ).pop(null),
                          ),
                          TextButton(
                            child: const Text('확인'),
                            onPressed:
                                () => Navigator.of(
                                  datePickerDialogContext,
                                ).pop(tempPickedDateInCalendar),
                          ),
                        ],
                      );
                    },
                  );
                },
              );

              if (pickedDateResult != null) {
                dialogSetStateAddEdit(() {
                  selectedDateTime = DateTime(
                    pickedDateResult.year,
                    pickedDateResult.month,
                    pickedDateResult.day,
                    selectedDateTime.hour,
                    selectedDateTime.minute,
                  );
                });
              }
            }

            Future<void> pickTime() async {
              final DateTime? pickedTimeResult =
                  await _showCustomScrollTimePickerInDialog(
                    stfContext,
                    selectedDateTime,
                  );
              if (pickedTimeResult != null) {
                dialogSetStateAddEdit(() {
                  selectedDateTime = DateTime(
                    selectedDateTime.year,
                    selectedDateTime.month,
                    selectedDateTime.day,
                    pickedTimeResult.hour,
                    pickedTimeResult.minute,
                  );
                });
              }
            }

            return AlertDialog(
              title: Text(isEditing ? '리마인더 수정' : '새 리마인더'),
              contentPadding: const EdgeInsets.all(16.0),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: '무엇을 기억할까요?',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),

                        errorText: titleErrorText,
                      ),
                      textCapitalization: TextCapitalization.sentences,

                      onChanged: (value) {
                        if (titleErrorText != null && value.trim().isNotEmpty) {
                          dialogSetStateAddEdit(() {
                            titleErrorText = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '날짜 및 시간:',
                      style: Theme.of(stfContext).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            DateFormat(
                              'yyyy.MM.dd (E)',
                              'ko_KR',
                            ).format(selectedDateTime),
                          ),
                          onPressed: pickDate,
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.access_time_outlined),
                          label: Text(
                            DateFormat(
                              'HH:mm',
                              'ko_KR',
                            ).format(selectedDateTime),
                          ),
                          onPressed: pickTime,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('취소'),
                  onPressed: () => Navigator.of(mainDialogContext).pop(),
                ),
                ElevatedButton(
                  child: Text(isEditing ? '저장' : '추가'),

                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) {
                      dialogSetStateAddEdit(() {
                        titleErrorText = '제목을 입력해주세요.';
                      });
                      return;
                    }

                    dialogSetStateAddEdit(() {
                      titleErrorText = null;
                    });

                    if (isEditing) {
                      await reminderController.updateReminder(
                        existingReminder.id,
                        title,
                        selectedDateTime,
                      );
                    } else {
                      await reminderController.addReminder(
                        title,
                        selectedDateTime,
                      );
                    }
                    Navigator.of(mainDialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('리마인더'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alarm_outlined),
            tooltip: '리마인더 추가',
            onPressed: () => _showAddEditReminderDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        final reminders = reminderController.reminderModel.value.reminderList;
        if (reminders.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                '저장된 리마인더가 없습니다.\n우측 상단의 알람 아이콘을 눌러 추가해보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: reminders.length,
          itemBuilder: (ctx, index) {
            final item = reminders[index];
            final DateTime now = DateTime.now();
            final DateTime today = DateTime(
              now.year,
              now.month,
              now.day,
            ); // 오늘 날짜 (시간은 00:00)
            final DateTime itemDate = DateTime(
              item.dateTime.year,
              item.dateTime.month,
              item.dateTime.day,
            ); // 리마인더 날짜 (시간은 00:00)

            // 오늘이거나 이미 지난 미완료 리마인더인지 확인
            final bool isUrgentOrPastAndPending =
                !item.isCompleted &&
                (itemDate.isBefore(today) || itemDate.isAtSameMomentAs(today));

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: item.isCompleted ? 0.5 : 2.5,
              color:
                  item.isCompleted
                      ? Colors.grey.shade200
                      : Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                leading: Checkbox(
                  value: item.isCompleted,
                  onChanged: (bool? value) {
                    reminderController.toggleReminderStatus(item.id);
                  },
                  activeColor: Theme.of(context).primaryColor,
                  visualDensity: VisualDensity.compact,
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    decoration:
                        item.isCompleted ? TextDecoration.lineThrough : null,
                    color:
                        item.isCompleted
                            ? Colors.grey.shade600
                            : Theme.of(context).textTheme.titleMedium?.color,
                    fontWeight:
                        item.isCompleted ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  DateFormat('MM.dd (E) HH:mm', 'ko_KR').format(item.dateTime),
                  style: TextStyle(
                    fontSize: 13,
                    decoration:
                        item.isCompleted ? TextDecoration.lineThrough : null,
                    color:
                        isUrgentOrPastAndPending
                            ? Colors.red.shade700
                            : (item.isCompleted
                                ? Colors.grey.shade500
                                : Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 22,
                        color: Colors.grey.shade600,
                      ),
                      tooltip: '수정',
                      visualDensity: VisualDensity.compact,
                      onPressed:
                          () => _showAddEditReminderDialog(
                            context,
                            existingReminder: item,
                          ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_sweep_outlined,
                        size: 22,
                        color: Colors.grey.shade600,
                      ),
                      tooltip: '삭제',
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        Get.defaultDialog(
                          title: "",
                          titleStyle: const TextStyle(fontSize: 1),
                          middleText: "'${item.title}' 리마인더를 삭제하시겠습니까?",
                          textConfirm: "삭제",
                          confirmTextColor:
                              Theme.of(context).colorScheme.onSurface,
                          onConfirm: () async {
                            await reminderController.removeReminder(item.id);
                            Get.back();
                          },
                          textCancel: "취소",
                          cancelTextColor:
                              Theme.of(context).colorScheme.onSecondary,
                          onCancel: () => Get.back(),
                          buttonColor: Colors.transparent,
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
