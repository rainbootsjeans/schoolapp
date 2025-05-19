import 'package:flutter/material.dart';
import 'package:school_app/controllers/allergy_controller.dart';
import 'package:school_app/controllers/auth_controller.dart';
import 'package:school_app/controllers/theme_controller.dart';
import 'package:get/get.dart';
import 'package:school_app/widgets/allergy_selector.dart';
import 'package:school_app/widgets/setting_bar.dart';
import 'package:school_app/widgets/setting_divider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late double width;
  AllergyController allergyController = Get.put(AllergyController());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            SettingBar(
              children: [
                const Text('다크모드'),
                Flexible(child: SizedBox(width: double.maxFinite)),
                Switch(
                  inactiveTrackColor: context.theme.colorScheme.onPrimary,
                  thumbColor: WidgetStateProperty.all(Colors.white),
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  trackOutlineColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                  value: isLightTheme != true,

                  onChanged: (value) {
                    setThemeMode();
                  },
                ),
              ],
            ),
            SettingDivider(title: '내 정보'),
            SettingBar(
              onTap: () {
                // showDialog(
                //   context: context,
                //   builder: (context) {
                //     return AllergySelector();
                //   },
                // );
              },
              children: [
                const Text('내 학번 관리하기'),
                Flexible(child: SizedBox(width: double.maxFinite)),
                Text('>'),
              ],
            ),
            SettingDivider(title: '급식'),
            SettingBar(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AllergySelector();
                  },
                );
              },
              children: [
                const Text('내 알러지 설정하기'),
                Flexible(child: SizedBox(width: double.maxFinite)),
                Text('>'),
              ],
            ),
            const SettingDivider(title: '계정'), // 새로운 섹션 구분선
            SettingBar(
              onTap: () {
                // 로그아웃 확인 다이얼로그 표시
                Get.defaultDialog(
                  title: "로그아웃",
                  middleText: "정말로 로그아웃 하시겠습니까?",
                  textConfirm: "로그아웃",
                  textCancel: "취소",
                  confirmTextColor: Colors.white,
                  buttonColor:
                      Theme.of(context).colorScheme.error, // 오류/경고 색상 사용
                  onConfirm: () async {
                    Get.back(); // 다이얼로그 닫기
                    await AuthController().signOut();
                    // 로그아웃 후 AuthGate에 의해 자동으로 로그인 페이지로 이동됩니다.
                  },
                  onCancel: () {
                    Get.back(); // 다이얼로그 닫기
                  },
                  radius: 10.0,
                );
              },
              children: [
                Text(
                  '로그아웃',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ), // 로그아웃 텍스트 강조
                ),
                const Flexible(child: SizedBox(width: double.maxFinite)),
                Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error, // 아이콘 색상 강조
                ),
              ],
            ),

            // --- 로그아웃 기능 추가 끝 ---
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

void setThemeMode() {
  if (isLightTheme) {
    Get.changeThemeMode(ThemeMode.dark);
    isLightTheme = false;
    saveTheme();
  } else {
    Get.changeThemeMode(ThemeMode.light);
    isLightTheme = true;
    saveTheme();
  }
}
