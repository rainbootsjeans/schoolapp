import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

final apiKey = dotenv.env['API_KEY'];
final scCode = 'J10';
final schulCode = '7531046';

Future<Map<String, dynamic>> fetchMealInfo({
  required String date, // MLSV_YMD (예: 20240501)
}) async {
  final url = Uri.parse(
    'https://open.neis.go.kr/hub/mealServiceDietInfo'
    '?KEY=$apiKey'
    '&Type=xml'
    '&ATPT_OFCDC_SC_CODE=$scCode'
    '&SD_SCHUL_CODE=$schulCode'
    '&MLSV_YMD=$date',
  );

  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('오류가 발생했습니다. 나중에 다시 시도해주세요.');
  }

  final document = XmlDocument.parse(response.body);
  final rows = document.findAllElements('row');

  if (rows.isEmpty) {
    throw Exception('오늘은 급식이 없어요.');
  }

  final row = rows.first;
  final dishNm = row.getElement('DDISH_NM')?.text ?? '';
  final calInfo = row.getElement('CAL_INFO')?.text ?? '';
  final ntrInfo = row.getElement('NTR_INFO')?.text ?? '';

  final menus = _parseMenus(dishNm);
  final nutrients = _parseNutrients(ntrInfo);

  return {'menus': menus, 'calorie': calInfo, 'nutrients': nutrients};
}

List<Map<String, dynamic>> _parseMenus(String dishNm) {
  final rawItems = dishNm.split('<br/>');
  return rawItems.map((item) {
    final nameMatch = RegExp(
      r'^(.*?)\(?([0-9.]+)?\)?$',
    ).firstMatch(item.trim());
    final name = nameMatch?.group(1)?.trim() ?? item.trim();
    final allergenStr = nameMatch?.group(2) ?? '';
    final allergens = allergenStr.isNotEmpty ? allergenStr.split('.') : [];
    return {
      'name': name,
      'allergens': allergens.where((e) => e.isNotEmpty).toList(),
    };
  }).toList();
}

Map<String, String> _parseNutrients(String ntrInfo) {
  final cleaned = ntrInfo.replaceAll('<br/>', '\n');
  final lines = cleaned.split('\n');

  String carbs = '', protein = '', fat = '';

  for (var line in lines) {
    if (line.contains('탄수화물')) {
      carbs = line.split(':').last.trim();
    } else if (line.contains('단백질')) {
      protein = line.split(':').last.trim();
    } else if (line.contains('지방')) {
      fat = line.split(':').last.trim();
    }
  }

  return {'carbo': carbs, 'protein': protein, 'fat': fat};
}
