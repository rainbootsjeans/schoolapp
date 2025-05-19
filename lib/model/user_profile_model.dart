// lib/models/user_profile_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfile {
  final String uid;
  String name;
  String studentId; // 예: "10101" (1학년 1반 1번)
  String? cardIdNumber;
  String? profilePhotoUrl;
  final String email;
  final Timestamp createdAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.studentId,
    this.cardIdNumber,
    this.profilePhotoUrl,
    required this.email,
    required this.createdAt,
  });

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    // String uid, // uid는 snapshot.id로부터 가져올 수 있으므로 중복 파라미터 제거 가능
  ) {
    final data = snapshot.data();
    final String docId = snapshot.id; // 문서 ID를 uid로 사용

    return UserProfile(
      uid: docId, // snapshot.id 사용
      name: data?['name'] as String? ?? '',
      studentId:
          data?['studentId'] as String? ?? '10101', // --- 기본값 '10101'로 수정 ---
      cardIdNumber: data?['cardIdNumber'] as String?,
      profilePhotoUrl: data?['profilePhotoUrl'] as String?,
      email:
          data?['email'] as String? ??
          (FirebaseAuth.instance.currentUser?.email ??
              ''), // Firestore에 없다면 Auth에서 가져오기 (선택적)
      createdAt: data?['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'studentId': studentId,
      if (cardIdNumber != null && cardIdNumber!.isNotEmpty)
        'cardIdNumber': cardIdNumber,
      if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty)
        'profilePhotoUrl': profilePhotoUrl,
      'email': email, // 저장 시에는 Auth에서 가져온 email 사용
      'createdAt': createdAt, // 최초 생성 시 FieldValue.serverTimestamp() 권장
    };
  }

  UserProfile copyWith({
    String? name, // uid는 final이므로 copyWith에서 제외하거나 그대로 유지
    String? studentId,
    String? cardIdNumber,
    bool clearCardIdNumber = false,
    String? profilePhotoUrl,
    bool clearProfilePhotoUrl = false,
    // email, createdAt은 일반적으로 사용자가 직접 수정하지 않으므로 제외 가능
  }) {
    return UserProfile(
      uid: uid, // 기존 uid 사용
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      cardIdNumber:
          clearCardIdNumber ? null : (cardIdNumber ?? this.cardIdNumber),
      profilePhotoUrl:
          clearProfilePhotoUrl
              ? null
              : (profilePhotoUrl ?? this.profilePhotoUrl),
      email: email, // 기존 email 사용
      createdAt: createdAt, // 기존 createdAt 사용
    );
  }
}
