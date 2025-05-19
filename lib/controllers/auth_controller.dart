// lib/controllers/auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart'; // For Get.snackbar styling

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  User? get currentUser => firebaseUser.value;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    // ever(firebaseUser, _handleAuthChanged); // Firestore 연동 시 이 부분 활성화 및 구현 필요
  }

  /*
  // Firestore 연동 시 _handleAuthChanged 예시 (현재는 주석 처리)
  // Firestore에서 UserProfile을 로드하는 UserProfileController가 있다고 가정
  void _handleAuthChanged(User? user) async {
    if (user != null) {
      print("AuthController: User signed in! UID: ${user.uid}");
      // isLoading.value = true; // UI에 로딩 표시가 필요하다면
      // try {
      //   await Get.find<UserProfileController>().loadUserProfile(user.uid);
      //   // 다른 사용자 데이터 로드 (Allergy, Schedule 등)
      // } catch (e) {
      //   print("Error loading user data after auth change: $e");
      //   Get.snackbar("데이터 로드 실패", "사용자 정보를 불러오는 중 오류가 발생했습니다.");
      //   // 심각한 경우 여기서 signOut()을 호출하여 로그인 페이지로 돌려보낼 수도 있음
      // } finally {
      //   // isLoading.value = false;
      // }
    } else {
      print("AuthController: User signed out!");
      // Get.find<UserProfileController>().clearUserProfile(); // 예시
      // 다른 사용자 데이터 클리어
    }
  }
  */

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      Get.snackbar(
        "로그인 정보 부족", // 제목 변경
        "이메일과 비밀번호를 모두 입력해주세요.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent, // 경고 색상으로 변경
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      print("로그인 시도: Email: ${email.trim()}"); // 비밀번호는 로그에 직접 찍지 않음

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // 로그인 성공 시, authStateChanges 리스너가 firebaseUser를 업데이트하고
      // main.dart의 AuthGate가 자동으로 HomePage로 전환합니다.
      // 따라서 여기서 별도의 성공 스낵바나 화면 전환 로직은 필요 없습니다.
      print("Firebase signInWithEmailAndPassword 호출 성공");
    } on FirebaseAuthException catch (e) {
      isLoading.value = false; // 오류 발생 시 로딩 상태 해제
      String errorMessage = "로그인 중 오류가 발생했습니다. 다시 시도해주세요."; // 기본 메시지

      switch (e.code) {
        case 'user-not-found':
        case 'INVALID_LOGIN_CREDENTIALS': // 일부 최신 SDK에서는 'invalid-credential' 또는 이 코드로 통합됨
          errorMessage = '등록되지 않은 이메일이거나 비밀번호가 일치하지 않습니다.';
          break;
        case 'wrong-password':
          errorMessage = '비밀번호가 일치하지 않습니다.';
          break;
        case 'invalid-email':
          errorMessage = '유효하지 않은 이메일 형식입니다.';
          break;
        case 'user-disabled':
          errorMessage = '이 계정은 비활성화되었습니다. 관리자에게 문의하세요.';
          break;
        case 'too-many-requests':
          errorMessage = '너무 많은 로그인 시도를 하였습니다. 잠시 후 다시 시도해주세요.';
          break;
        case 'network-request-failed':
          errorMessage = '네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.';
          break;
        // case 'internal-error': // Firebase 내부 오류도 'unknown-error'와 유사하게 처리될 수 있음
        // case 'unknown': // 명시적으로 'unknown' 코드가 올 수도 있음
        default:
          // 위에서 처리되지 않은 모든 FirebaseAuthException 코드
          // (사용자님이 겪고 계신 'unknown-error'도 여기에 해당될 수 있습니다)
          errorMessage = "로그인 서버 오류(${e.code}). 잠시 후 다시 시도해주세요.";
          break;
      }

      Get.snackbar(
        "로그인 실패",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent, // 오류 색상
        colorText: Colors.white,
      );
      print(
        'FirebaseAuthException (${e.code}): ${e.message}',
      ); // 실제 오류 코드와 메시지 확인이 중요!
    } catch (e, s) {
      // FirebaseAuthException 외의 다른 모든 예외 (예: 개발 중 로직 오류)
      isLoading.value = false;
      Get.snackbar(
        "로그인 시스템 오류", // 제목 변경
        "알 수 없는 오류가 발생했습니다. 앱을 재시작하거나 문의해주세요.", // 메시지 변경
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900, // 심각한 오류 색상
        colorText: Colors.white,
      );
      print('일반 로그인 오류: ${e.toString()}');
      print('스택 트레이스: $s');
    } finally {
      // try 블록에서 return 등으로 조기 종료되지 않는 한 항상 실행됨
      // isLoading.value = false; // 로그인 시도 후에는 항상 false로 설정 (성공/실패 무관)
      // --> 성공 시에는 화면 전환이 일어나므로, 여기서는 실패/오류 시에만 false로 설정되도록 위로 옮김.
      //     만약 성공 후에도 이 페이지에 남아있다면 여기서 false로 설정. 현재는 자동 전환됨.
    }
  }

  Future<void> signOut() async {
    // ... (기존 signOut 로직 유지) ...
    try {
      isLoading.value = true;
      await _auth.signOut();
    } catch (e) {
      Get.snackbar(
        "로그아웃 오류",
        "로그아웃 중 오류가 발생했습니다: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? getCurrentUserUID() {
    return _auth.currentUser?.uid;
  }
}
