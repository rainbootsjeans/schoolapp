import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

// Firebase 관련 import
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // FlutterFire CLI로 자동 생성된 파일

// 컨트롤러 import (경로는 실제 프로젝트 구조에 맞게 수정해주세요)
import 'package:school_app/controllers/theme_controller.dart';
import 'package:school_app/controllers/allergy_controller.dart';
import 'package:school_app/controllers/d_day_controller.dart'; // DDayController 추가
import 'package:school_app/controllers/reminder_controller.dart'; // ReminderController 추가
import 'package:school_app/controllers/schedule_controller.dart'; // ScheduleController 추가
import 'package:school_app/controllers/auth_controller.dart'; // AuthController 추가
// StudentNumberController도 사용한다면 import 및 Get.put() 필요

// 페이지 import
import 'package:school_app/pages/home.dart';
import 'package:school_app/pages/setting.dart';
import 'package:school_app/pages/student_id.dart';
import 'package:school_app/pages/login.dart'; // LoginPage 추가

// 테마 import
import 'package:school_app/themes/themes.dart';

// 기존 전역 컨트롤러 인스턴스화 방식 대신 main 함수 내에서 Get.put 사용 권장
// AllergyController allergyController = Get.put(AllergyController()); // 이 줄은 제거 또는 주석 처리

void main() async {
  // Flutter 엔진 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 테마 초기화 (기존 로직 유지)
  await initTheme();

  // GetX 컨트롤러 등록 (AuthController를 다른 컨트롤러보다 먼저 등록하는 것이 좋을 수 있음)
  Get.put(AuthController());

  final allergyController = Get.put(
    AllergyController(),
  ); // 인스턴스를 받아 initAllergy 호출
  Get.put(DDayController());
  Get.put(ReminderController());
  Get.put(ScheduleController());
  // Get.put(StudentNumberController()); // 필요하다면 등록

  // AllergyController 초기화 (Get.put 이후에 find하여 호출)
  await allergyController.initAllergy();
  // StudentNumberController도 초기화가 필요하다면 유사하게 호출

  runApp(const MyApp()); // GetMaterialApp을 포함하는 MyApp 실행
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // themeMode는 theme_controller.dart에서 가져온다고 가정
    // 만약 ThemeController가 GetxController라면 Get.find<ThemeController>().themeMode처럼 접근 가능
    // 현재는 전역 변수 themeMode를 그대로 사용
    return GetMaterialApp(
      title: '세교고등학교 앱', // 앱 제목
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
      locale: const Locale('ko', 'KR'),
      theme: lightTheme, // themes.dart에서 정의
      darkTheme: darkTheme, // themes.dart에서 정의
      themeMode: themeMode, // theme_controller.dart의 전역 변수
      debugShowCheckedModeBanner: false,
      home: const AuthGate(), // 초기 라우팅을 AuthGate에서 처리
    );
  }
}

// 인증 상태에 따라 적절한 페이지로 안내하는 위젯
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthController 인스턴스를 GetX를 통해 찾습니다.
    final AuthController authController = Get.find<AuthController>();

    // Obx를 사용하여 authController.firebaseUser의 변경 사항을 실시간으로 감지합니다.
    return Obx(() {
      // AuthController의 firebaseUser 스트림이 첫 값을 가져올 때까지 (또는 로딩 중일 때)
      // 잠시 로딩 화면을 보여줄 수 있습니다.
      // 현재 AuthController는 isLoading 플래그를 가지고 있으므로 이를 활용할 수도 있습니다.
      // 여기서는 firebaseUser.value가 null인지 여부로만 간단히 판단합니다.
      if (authController.firebaseUser.value == null) {
        // 사용자가 로그인하지 않은 상태이면 LoginPage를 보여줍니다.
        return const LoginPage();
      } else {
        // 사용자가 로그인한 상태이면 MainPage를 보여줍니다.
        return const MainPage(); // 기존 앱의 메인 화면
      }
    });
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPageIndex = 0;
  static const List<Widget> pages = [HomePage(), SettingPage()];
  bool heart = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('세교고등학교'),
        scrolledUnderElevation: 100000,
        surfaceTintColor:
            context.theme.bottomNavigationBarTheme.backgroundColor,
      ),
      body: SafeArea(child: pages[currentPageIndex]),
      bottomNavigationBar: StylishBottomBar(
        elevation: 1,
        backgroundColor: context.theme.bottomNavigationBarTheme.backgroundColor,
        option: AnimatedBarOptions(iconStyle: IconStyle.Default),
        items: [
          BottomBarItem(
            icon: const Icon(Icons.house_outlined),
            selectedIcon: const Icon(Icons.house_rounded),

            unSelectedColor: Colors.grey,
            title: Text('홈', style: TextStyle(fontWeight: FontWeight.w100)),
          ),
          BottomBarItem(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            unSelectedColor: Colors.grey,

            title: const Text(
              '설정',
              style: TextStyle(fontWeight: FontWeight.w100),
            ),
          ),
        ],
        hasNotch: true,
        fabLocation: StylishBarFabLocation.end,
        currentIndex: currentPageIndex,
        notchStyle: NotchStyle.circle,
        onTap: (index) {
          if (index == currentPageIndex) return;
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          Get.to(StudentIdPage());
        },

        child: Icon(Icons.assignment_ind, color: context.theme.focusColor),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
