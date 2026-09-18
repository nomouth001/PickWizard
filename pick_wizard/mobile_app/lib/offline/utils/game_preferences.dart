import 'package:shared_preferences/shared_preferences.dart';
import 'package:pick_wizard/core/models/game_type.dart';

/// 오프라인 홈에서 선택한 복권 게임 유형 저장 키 (STEP 9 / D3)
const String _kSelectedGameTypeKey = 'selected_game_type';

Future<void> saveGameType(GameTypeId id) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kSelectedGameTypeKey, id.name);
}

Future<GameTypeId> loadGameType() async {
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString(_kSelectedGameTypeKey);
  if (name == null || name.isEmpty) {
    return GameTypeId.lotto645;
  }
  return GameTypeId.values.firstWhere(
    (e) => e.name == name,
    orElse: () => GameTypeId.lotto645,
  );
}
