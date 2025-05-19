import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:school_app/controllers/schedule_controller.dart';

class TimetableCustomizationPage extends StatefulWidget {
  const TimetableCustomizationPage({super.key});

  @override
  State<TimetableCustomizationPage> createState() =>
      _TimetableCustomizationPageState();
}

class _TimetableCustomizationPageState
    extends State<TimetableCustomizationPage> {
  final ScheduleController controller = Get.put(ScheduleController());
  final _originalSubjectController = TextEditingController();
  final _customSubjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO:  학년, 반 정보 가져오기기

    controller.fetchWeeklyTimetable(grade: 3, classNum: 4);
  }

  void _showAddEditRuleDialog(
    BuildContext context, {
    SubjectSwapRule? existingRule,
    String? initialOriginalSubjectIfAdding,
  }) {
    final bool isEditing = existingRule != null;

    _originalSubjectController.text =
        existingRule?.originalSubject ?? initialOriginalSubjectIfAdding ?? '';
    _customSubjectController.text = existingRule?.customSubject ?? '';

    String? originalErrorText;
    String? customErrorText;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, dialogSetState) {
            return AlertDialog(
              title: Text(isEditing ? '과목 변경 규칙 수정' : '새 규칙 추가'),
              scrollable: true,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _originalSubjectController,
                    decoration: InputDecoration(
                      labelText: '원래 과목명',

                      border: const OutlineInputBorder(),
                      errorText: originalErrorText,
                    ),
                    onChanged: (_) {
                      if (originalErrorText != null) {
                        dialogSetState(() => originalErrorText = null);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _customSubjectController,
                    decoration: InputDecoration(
                      labelText: '표시할 과목명',

                      border: const OutlineInputBorder(),
                      errorText: customErrorText,
                    ),
                    onChanged: (_) {
                      if (customErrorText != null) {
                        dialogSetState(() => customErrorText = null);
                      }
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('취소'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  child: Text(isEditing ? '저장' : '추가'),
                  onPressed: () async {
                    final originalSubject =
                        _originalSubjectController.text.trim();
                    final customSubject = _customSubjectController.text.trim();
                    bool isValid = true;

                    if (originalSubject.isEmpty) {
                      dialogSetState(
                        () => originalErrorText = '원래 과목명을 입력해주세요.',
                      );
                      isValid = false;
                    } else {
                      dialogSetState(() => originalErrorText = null);
                    }

                    if (customSubject.isEmpty) {
                      dialogSetState(
                        () => customErrorText = '표시할 과목명을 입력해주세요.',
                      );
                      isValid = false;
                    } else {
                      dialogSetState(() => customErrorText = null);
                    }

                    if (isValid) {
                      if (isEditing) {
                        await controller.updateSwapRuleById(
                          existingRule.id,
                          originalSubject,
                          customSubject,
                        );
                      } else {
                        await controller.addOrUpdateSwapRule(
                          originalSubject,
                          customSubject,
                        );
                      }
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {});
  }

  List<Widget> _buildPeriodRowCells(
    List<DateTime> weekDates,
    Map<String, List<String>> weeklyData,
    String periodNumDisplay,
    int periodDataIndex,
    TextStyle cellTextStyle,
    EdgeInsets cellPadding,
    BoxDecoration commonCellDecoration,
  ) {
    return List.generate(5, (dayIndex) {
      String ymd = DateFormat('yyyyMMdd').format(weekDates[dayIndex]);
      List<String>? dailyPeriods = weeklyData[ymd];
      String subjectInCell = "-";

      if (dailyPeriods != null && periodDataIndex < dailyPeriods.length) {
        List<String> parts = dailyPeriods[periodDataIndex].split(':');
        if (parts.length > 1) {
          subjectInCell = parts[1].trim();
        } else if (parts[0].isNotEmpty && !parts[0].contains("교시")) {
          subjectInCell = parts[0].trim();
        } else if (parts[0].contains("교시") &&
            parts[0].trim() != "${periodDataIndex + 1}교시") {
          subjectInCell =
              parts[0]
                  .trim()
                  .replaceFirst("${periodDataIndex + 1}교시 :", "")
                  .trim();
          if (subjectInCell.isEmpty) subjectInCell = "-";
        }
      }
      final displaySubject = subjectInCell.isEmpty ? "-" : subjectInCell;

      return Expanded(
        flex: 2,
        child: GestureDetector(
          onTap: () {
            if (displaySubject != "-") {
              _customSubjectController.clear();
              _showAddEditRuleDialog(
                context,
                initialOriginalSubjectIfAdding: displaySubject,
              );
            }
          },
          child: Container(
            decoration: commonCellDecoration.copyWith(
              border: Border(
                left: BorderSide(color: Colors.grey.shade600, width: 0.5),
              ),
            ),
            padding: cellPadding,
            alignment: Alignment.center,
            constraints: const BoxConstraints(minHeight: 38),
            child: Text(
              displaySubject,
              style: cellTextStyle,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildWeeklyTimetableGrid(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingWeeklyTimetable.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (controller.weeklyTimetableError.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              controller.weeklyTimetableError.value,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        );
      }
      if (controller.weeklyTimetable.isEmpty &&
          !controller.isLoadingWeeklyTimetable.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              '주간 시간표 정보가 없습니다. ${controller.weeklyTimetableError.value.isNotEmpty ? "" : "\n(학년/반 설정을 확인하거나, 다시 시도해주세요.)"}',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      List<DateTime> weekDates = controller.getCurrentWeekDates();
      List<String> dayHeaders = ['월', '화', '수', '목', '금'];

      int maxPeriodsFound = 0;
      controller.weeklyTimetable.forEach((_, periods) {
        if (periods.length > maxPeriodsFound) maxPeriodsFound = periods.length;
      });

      final int part1Periods = 4;
      final int part2Periods =
          (maxPeriodsFound > 4) ? (maxPeriodsFound - 4) : 3;

      List<String> periodLabelsPart1 = List.generate(
        part1Periods,
        (i) => (i + 1).toString(),
      );
      List<String> periodLabelsPart2 = List.generate(
        part2Periods,
        (i) => (i + 1 + part1Periods).toString(),
      );

      BoxDecoration commonCellDecoration = BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade600, width: 0.5),
        ),
      );
      TextStyle cellTextStyle = TextStyle(
        fontSize: 11.5,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      );
      EdgeInsets cellPadding = const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 2,
      );

      List<Widget> tableContent = [];

      tableContent.add(
        Container(
          decoration: commonCellDecoration,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  padding: cellPadding,
                  alignment: Alignment.center,
                  child: const Text(
                    '교시',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              ...dayHeaders.map(
                (day) => Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Colors.grey.shade600,
                          width: 0.5,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      tableContent.addAll(
        periodLabelsPart1.map(
          (pNum) => Container(
            decoration: commonCellDecoration,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: cellPadding,
                    alignment: Alignment.center,
                    child: Text(pNum, style: cellTextStyle),
                  ),
                ),
                ..._buildPeriodRowCells(
                  weekDates,
                  controller.weeklyTimetable.value,
                  pNum,
                  int.parse(pNum) - 1,
                  cellTextStyle,
                  cellPadding,
                  commonCellDecoration,
                ),
              ],
            ),
          ),
        ),
      );

      tableContent.add(
        Container(
          height: 40,
          decoration: commonCellDecoration.copyWith(color: Colors.transparent),
          alignment: Alignment.center,
          child: const Text(
            '점심시간',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      );

      tableContent.addAll(
        periodLabelsPart2.map(
          (pNum) => Container(
            decoration: commonCellDecoration,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: cellPadding,
                    alignment: Alignment.center,
                    child: Text(pNum, style: cellTextStyle),
                  ),
                ),
                ..._buildPeriodRowCells(
                  weekDates,
                  controller.weeklyTimetable.value,
                  pNum,
                  int.parse(pNum) - 1,
                  cellTextStyle,
                  cellPadding,
                  commonCellDecoration,
                ),
              ],
            ),
          ),
        ),
      );

      return Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 0),

        child: Column(children: tableContent),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('시간표')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWeeklyTimetableGrid(context),
            const Divider(height: 30, thickness: 1, indent: 16, endIndent: 16),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 0.0, bottom: 12.0),
            ),
            Obx(() {
              if (controller.swapRules.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                  child: Center(
                    child: Text(
                      '설정된 과목 변경 규칙이 없습니다.\n시간표 또는 아래 버튼을 눌러 새 규칙을 추가해보세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0, color: Colors.grey),
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.swapRules.length,
                itemBuilder: (ctx, index) {
                  final rule = controller.swapRules[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(
                        "'${rule.originalSubject}'",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        " →  '${rule.customSubject}' 으로 표시",
                        style: TextStyle(
                          fontSize: 14,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: Colors.grey.shade600,
                              size: 26,
                            ),
                            tooltip: '규칙 수정',
                            onPressed:
                                () => _showAddEditRuleDialog(
                                  context,
                                  existingRule: rule,
                                ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_sweep_outlined,
                              color: Colors.grey.shade600,
                              size: 26,
                            ),
                            tooltip: '규칙 삭제',
                            onPressed: () {
                              Get.defaultDialog(
                                title: "",
                                titleStyle: const TextStyle(fontSize: 0),
                                middleText:
                                    "'${rule.originalSubject}' → '${rule.customSubject}' 규칙을 삭제하시겠습니까?",
                                textConfirm: "삭제",
                                confirmTextColor:
                                    Theme.of(context).colorScheme.onSurface,

                                onConfirm: () async {
                                  controller.removeSwapRule(rule.id);
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
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditRuleDialog(context),
        tooltip: '새 규칙 추가',
        child: const Icon(Icons.add_chart_outlined),
      ),
    );
  }
}
