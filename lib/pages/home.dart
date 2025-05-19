import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:school_app/controllers/allergy_controller.dart';
import 'package:school_app/controllers/d_day_controller.dart';
import 'package:school_app/controllers/reminder_controller.dart';
import 'package:school_app/pages/d_day.dart';
import 'package:school_app/pages/detail_meal.dart';
import 'package:school_app/pages/detail_schedule.dart';
import 'package:school_app/pages/reminder.dart';
import 'package:school_app/services/date_checker.dart';
import 'package:school_app/services/meal_pager.dart';
import 'package:school_app/services/network_checker.dart';
import 'package:school_app/services/schedule_pager.dart';
import 'package:intl/intl.dart';

final DDayController dDayController = Get.put(DDayController());
final ReminderController reminderController = Get.put(ReminderController());

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double width;

  @override
  Widget build(BuildContext context) {
    AllergyController allergyController = Get.put(AllergyController());
    width = MediaQuery.of(context).size.width;
    RxList<String> myAllergy = allergyController.allergyModel().myAllergyList;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 사용자 프로필 정보 표시 영역 (예시, 현재는 고정 텍스트)
            Container(
              height: 180, // 높이 약간 조절
              padding: const EdgeInsets.all(16),
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              // TODO: AuthController와 UserProfile 연동 후 실제 사용자 정보 표시
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    // backgroundImage: NetworkImage(userProfile.profilePhotoUrl ?? '기본이미지URL'), // 예시
                    child: Icon(Icons.person, size: 30), // 기본 아이콘
                  ),
                  SizedBox(height: 8),
                  Text(
                    '홍길동님',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ), // 예시 이름
                  Text(
                    '3학년 4반 12번 (학생증: 1234567)',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ), // 예시 학번/학생증ID
                ],
              ),
            ),
            const SizedBox(height: 16), // 위젯 간 간격
            // D-Day 박스
            GestureDetector(
              onTap: () => Get.to(() => const DDay()),
              child: Container(
                height: 150, // 기존 높이 유지
                padding: const EdgeInsets.all(16),
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(() {
                  final List<DDayItem> allDDays =
                      dDayController.dDayModel.value.dDayList;
                  final DateTime now = DateTime.now();
                  final DateTime today = DateTime(now.year, now.month, now.day);

                  List<DDayItem> upcomingDDays =
                      allDDays.where((d) {
                        final eventDate = DateTime(
                          d.date.year,
                          d.date.month,
                          d.date.day,
                        );
                        return eventDate.isAtSameMomentAs(today) ||
                            eventDate.isAfter(today);
                      }).toList();
                  // D-Day는 날짜가 가까운 순으로 정렬 (컨트롤러에서 이미 정렬됨)
                  // upcomingDDays.sort((a, b) => a.date.compareTo(b.date));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'D-Day',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child:
                            upcomingDDays.isEmpty
                                ? Center(
                                  child: Text(
                                    allDDays.isEmpty
                                        ? 'D-Day를 추가해보세요!'
                                        : '다가오는 D-Day가 없습니다.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                )
                                : Column(
                                  // D-Day 항목들을 Column으로 표시
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      upcomingDDays.take(3).map((item) {
                                        // 최대 3개 표시
                                        final eventDate = DateTime(
                                          item.date.year,
                                          item.date.month,
                                          item.date.day,
                                        );
                                        final differenceInDays =
                                            eventDate.difference(today).inDays;
                                        String dDayText;
                                        Color dDayColor;

                                        if (differenceInDays == 0) {
                                          dDayText = 'D-DAY';
                                          dDayColor = Colors.red.shade600;
                                        } else if (differenceInDays > 0) {
                                          dDayText = 'D-$differenceInDays';
                                          dDayColor =
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary;
                                        } else {
                                          // 이 경우는 upcomingDDays 필터로 인해 발생하지 않아야 함
                                          dDayText =
                                              'D+${differenceInDays.abs()}';
                                          dDayColor = Colors.grey.shade600;
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 3.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.event_note_outlined,
                                                size: 18,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.title,
                                                      style: TextStyle(
                                                        fontSize: 13.5,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      DateFormat(
                                                        'MM.dd (E)',
                                                        'ko_KR',
                                                      ).format(item.date),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                dDayText,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: dDayColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // 리마인더 박스
            GestureDetector(
              onTap: () => Get.to(() => ReminderPage()),
              child: Container(
                height: 150,
                padding: const EdgeInsets.all(16),
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(() {
                  final List<ReminderItem> allReminders =
                      reminderController.reminderModel.value.reminderList;
                  final List<ReminderItem> pendingReminders =
                      allReminders.where((r) => !r.isCompleted).toList();
                  // 리마인더는 컨트롤러에서 이미 미완료+시간순으로 정렬됨

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '리마인더',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child:
                            pendingReminders.isEmpty
                                ? Center(
                                  child: Text(
                                    allReminders.isEmpty
                                        ? '새 리마인더를 추가해보세요!'
                                        : '모든 리마인더를 완료했어요! 🎉',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                )
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      pendingReminders.take(3).map((item) {
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
                                            (itemDate.isBefore(today) ||
                                                itemDate.isAtSameMomentAs(
                                                  today,
                                                ));
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 3.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isUrgentOrPastAndPending
                                                    ? Icons
                                                        .notification_important_rounded
                                                    : Icons.alarm_on_outlined,
                                                size: 18,
                                                color:
                                                    isUrgentOrPastAndPending
                                                        ? Colors.red.shade500
                                                        : Theme.of(
                                                          context,
                                                        ).colorScheme.secondary,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.title,
                                                      style: TextStyle(
                                                        fontSize: 13.5,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      // 설정된 날짜 및 시간 표시
                                                      DateFormat(
                                                        'MM.dd (E) HH:mm',
                                                        'ko_KR',
                                                      ).format(item.dateTime),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            isUrgentOrPastAndPending
                                                                ? Colors
                                                                    .red
                                                                    .shade500
                                                                : Colors
                                                                    .grey
                                                                    .shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // 리마인더는 D-Day 표시가 별도로 필요 없음
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 시간표
                GestureDetector(
                  onTap: () => Get.to(TimetableCustomizationPage()),
                  child: Container(
                    constraints: BoxConstraints(minHeight: 200),
                    width: width / 2 - 16,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FutureBuilder<bool>(
                      future: isConnectedToNetwork(),
                      builder: (context, networkSnapshot) {
                        if (networkSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!networkSnapshot.hasData ||
                            !networkSnapshot.data!) {
                          return const Center(child: Text('⚠️ 네트워크에 연결해주세요.'));
                        }

                        return FutureBuilder<String>(
                          future: fetchTimetable(
                            grade: 3,
                            classNum: 4,
                            date: getTodayDate(),
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              final errorMsg = snapshot.error
                                  .toString()
                                  .replaceFirst('Exception: ', '');
                              return Center(child: Text(errorMsg));
                            }

                            if (!snapshot.hasData || snapshot.data == null) {
                              return Center(child: Text('오늘은 시간표 정보가 없어요.'));
                            }
                            final data = snapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        '시간표 ⏰',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        '>',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(data.toString()),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                // 급식
                GestureDetector(
                  onTap: () => Get.to(MealDetail()),
                  child: Container(
                    constraints: BoxConstraints(minHeight: 200),
                    width: width / 2 - 16,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FutureBuilder<bool>(
                      future: isConnectedToNetwork(),
                      builder: (context, networkSnapshot) {
                        if (networkSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!networkSnapshot.hasData ||
                            !networkSnapshot.data!) {
                          return const Center(child: Text('⚠️ 네트워크에 연결해주세요.'));
                        }

                        return FutureBuilder<Map<String, dynamic>>(
                          future: fetchMealInfo(date: getTodayDate()),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              final errorMsg = snapshot.error
                                  .toString()
                                  .replaceFirst('Exception: ', '');
                              return Center(child: Text(errorMsg));
                            }

                            if (!snapshot.hasData || snapshot.data == null) {
                              return Center(child: Text('급식 정보가 없습니다.'));
                            }

                            final data = snapshot.data!;
                            final menus = data['menus'] as List<dynamic>;
                            final calorie = data['calorie'] as String;
                            final nutrients =
                                data['nutrients'] as Map<String, dynamic>;

                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        '급식 🍽️',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        '>',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...menus.map<Widget>((menu) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          child: Obx(() {
                                            final allergyIndexes =
                                                allergyController
                                                    .getAllergyIndexes(
                                                      myAllergy,
                                                    );
                                            final hasAllergen =
                                                (menu['allergens'] as List).any(
                                                  (id) =>
                                                      allergyIndexes.contains(
                                                        int.tryParse(
                                                          id.toString(),
                                                        ),
                                                      ),
                                                );

                                            return Text(
                                              '${menu['name']}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                backgroundColor:
                                                    hasAllergen
                                                        ? Colors.red
                                                            .withOpacity(0.3)
                                                        : Colors.transparent,
                                              ),
                                            );
                                          }),
                                        ),
                                        SizedBox(height: 4),
                                      ],
                                    );
                                  }),
                                  Divider(
                                    color: context.theme.colorScheme.onPrimary,
                                    thickness: 1,
                                  ),
                                  SizedBox(height: 4),
                                  Text('탄수화물 : ${nutrients['carbo']}g '),
                                  SizedBox(height: 2),
                                  Text('단백질: ${nutrients['protein']}g,'),
                                  SizedBox(height: 2),
                                  Text('지방: ${nutrients['fat']}g'),
                                  SizedBox(height: 6),
                                  Text(calorie),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40, width: 40),
          ],
        ),
      ),
    );
  }
}
