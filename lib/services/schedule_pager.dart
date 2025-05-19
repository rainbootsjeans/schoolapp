import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:http/http.dart' as http;
import 'package:school_app/controllers/schedule_controller.dart';
import 'package:xml/xml.dart';

final apiKey = dotenv.env['API_KEY'];
final scCode = 'J10';

final ScheduleController customizationController = Get.put(
  ScheduleController(),
);

final schulCode = '7531046';
Future<String> fetchTimetable({
  // 반환 타입을 Future<String>으로 변경
  required int grade,
  required int classNum,
  required String date, // YYYYMMDD 형식 (예: 20240501)
}) async {
  final url = Uri.parse(
    'https://open.neis.go.kr/hub/hisTimetable'
    '?KEY=$apiKey'
    '&Type=xml'
    '&ATPT_OFCDC_SC_CODE=$scCode'
    '&SD_SCHUL_CODE=$schulCode'
    '&GRADE=$grade'
    '&CLASS_NM=$classNum'
    '&ALL_TI_YMD=$date',
  );

  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('시간표 정보를 가져오는데 실패했습니다. 잠시 후 다시 시도해주세요.');
  }

  final document = XmlDocument.parse(response.body);
  final rows = document.findAllElements('row');

  if (rows.isEmpty) {
    throw Exception('오늘은 시간표 정보가 없어요.');
  }

  Map<int, String> timetableMap = {};
  int maxPeriod = 0;

  for (var row in rows) {
    try {
      final String perioString =
          row.getElement('PERIO')?.innerText.trim() ?? "";

      final String apiSubject =
          row.getElement('ITRT_CNTNT')?.innerText.trim() ?? "";

      if (perioString.isNotEmpty) {
        final int period = int.parse(perioString);

        final String displaySubject = customizationController.getCustomSubject(
          apiSubject,
        );

        timetableMap[period] = displaySubject;
        if (period > maxPeriod) {
          maxPeriod = period;
        }
      }
    } catch (e) {
      // 특정 행 파싱 오류 시 무시 (사용자 코드 유지)
    }
  }
  if (maxPeriod == 0) {
    throw Exception('오늘은 시간표 정보가 없어요.');
  }

  List<String> periodStrings = [];
  for (int i = 1; i <= maxPeriod; i++) {
    String subjectForPeriod = timetableMap[i] ?? '';
    periodStrings.add('$i교시 : $subjectForPeriod');
  }
  return periodStrings.join('\n');
}
