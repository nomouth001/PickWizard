import 'package:pick_wizard/core/localization/generated/app_localizations.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';

/// 오프라인 결과·내 번호 등에서 알고리즘 라벨을 표시할 때 사용한다.
/// - 시리얼 + 알고리즘 1 → [AppLocalizations.serialAlgorithm1Name]
/// - 시리얼 + 알고리즘 9 → [AppLocalizations.serialAlgorithm9Name]
/// - 볼픽 알고리즘 9    → [AppLocalizations.algorithm9NameDisplay]
String offlineAlgorithmDisplayLabel(
  AppLocalizations l10n,
  GeneratedNumbers generated,
) {
  final gameType = GameTypes.fromId(generated.gameTypeId);
  return offlineAlgorithmDisplayLabelFor(
    l10n,
    gameType,
    algorithmId: generated.algorithmId,
    fallbackName: generated.algorithmName,
  );
}

/// [gameType] · [algorithmId] 기준 표시명. 그 외 id는 비어 있지 않으면 [fallbackName].
String offlineAlgorithmDisplayLabelFor(
  AppLocalizations l10n,
  GameType gameType, {
  required int algorithmId,
  String fallbackName = '',
}) {
  if (algorithmId == 1) {
    return gameType.isSerial ? l10n.serialAlgorithm1Name : l10n.algorithm1Name;
  }
  if (algorithmId == 9) {
    return gameType.isSerial
        ? l10n.serialAlgorithm9Name
        : l10n.algorithm9NameDisplay;
  }
  if (fallbackName.isNotEmpty) return fallbackName;
  return l10n.algorithm9NameDisplay;
}
