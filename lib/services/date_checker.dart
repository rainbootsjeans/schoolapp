// 이거 GPT가 기기시간 상관없이 오늘 날짜 구하는 코드라고 했는데
// 지금보니까 첫 줄부터 DateTime.now()로 기기시간을 가져오고 있네

String getTodayDate() {
  final nowUtc = DateTime.now().toUtc();
  final kst = nowUtc.add(Duration(hours: 9)); // KST = UTC + 9
  final year = kst.year.toString().padLeft(4, '0');
  final month = kst.month.toString().padLeft(2, '0');
  final day = kst.day.toString().padLeft(2, '0');
  return '$year$month$day';
}
