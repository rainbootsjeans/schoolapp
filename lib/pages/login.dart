// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// AuthController 경로를 실제 프로젝트 구조에 맞게 수정해주세요.
// 예: import '../controllers/auth_controller.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // TextEditingController는 State 내에서 관리하는 것이 일반적입니다.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController authController =
      Get.find<AuthController>(); // 이미 put 되었다고 가정

  // 비밀번호 표시 여부 상태
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _performLogin() {
    // 키보드 숨기기
    FocusScope.of(context).unfocus();
    authController.signInWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar는 선택 사항입니다. 앱의 디자인에 따라 추가하거나 제거할 수 있습니다.
      // appBar: AppBar(
      //   title: const Text('로그인'),
      //   automaticallyImplyLeading: false, // 뒤로가기 버튼 숨김 (로그인 페이지이므로)
      // ),
      body: Center(
        child: SingleChildScrollView(
          // 키보드가 올라올 때 UI가 밀리는 것을 방지
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 앱 로고 또는 제목 (선택 사항)
              Icon(
                Icons.school_outlined, // 앱 로고 또는 관련 아이콘
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '학교 생활 앱 로그인', // 앱 이름 또는 환영 메시지
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 40),

              // 이메일 입력 필드
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: '이메일',
                  hintText: '학교 이메일 주소를 입력하세요',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onSubmitted: (_) => _performLogin(), // 엔터키로 로그인 시도
              ),
              const SizedBox(height: 16),

              // 비밀번호 입력 필드
              Obx(
                () => TextField(
                  // Obx로 감싸서 authController.isLoading 상태에 따라 UI 변경 가능
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible, // 비밀번호 가리기
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: '비밀번호를 입력하세요',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  onSubmitted: (_) => _performLogin(), // 엔터키로 로그인 시도
                  enabled: !authController.isLoading.value, // 로딩 중일 때 입력 비활성화
                ),
              ),
              const SizedBox(height: 32),

              // 로그인 버튼
              Obx(() {
                // AuthController의 isLoading 상태를 감지하여 버튼 UI 변경
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  // 로딩 중이면 버튼 비활성화, 아니면 _performLogin 호출
                  onPressed:
                      authController.isLoading.value ? null : _performLogin,
                  child:
                      authController.isLoading.value
                          ? const SizedBox(
                            // 로딩 인디케이터
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text('로그인'),
                );
              }),
              const SizedBox(height: 20),
              // 회원가입 기능은 현재 만들지 않으므로 관련 UI는 생략합니다.
              // 필요시 여기에 "계정이 없으신가요? 회원가입" 등의 텍스트 버튼 추가 가능
            ],
          ),
        ),
      ),
    );
  }
}
