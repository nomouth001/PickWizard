/// PickWizard 게임 타입 카테고리.
enum GameCategory { ballPick, serial }

/// PickWizard에서 지원하는 볼 픽 방식 복권 게임 타입.
enum GameTypeId {
  lotto645,
  powerball,
  megaMillions,
  winForLife,
  annuity720,
}

/// 게임별 번호 범위, 선택 개수, 보너스 볼, 색상 구간 정의.
class GameType {
  const GameType({
    required this.id,
    required this.mainMin,
    required this.mainMax,
    required this.mainCount,
    this.bonusMin,
    this.bonusMax,
    this.bonusCount = 0,
    this.bonusBallColorArgb = 0,
    required this.colorZoneBounds,
    this.category = GameCategory.ballPick,
  });

  final GameTypeId id;
  final int mainMin;
  final int mainMax;
  final int mainCount;
  final int? bonusMin;
  final int? bonusMax;
  final int bonusCount;
  final int bonusBallColorArgb;
  final List<int> colorZoneBounds;
  final GameCategory category;

  bool get hasBonus => bonusCount > 0;
  bool get isSerial => category == GameCategory.serial;
  bool get isBallPick => category == GameCategory.ballPick;

  int get mainPoolSize => mainMax - mainMin + 1;

  int? get bonusPoolSize {
    final min = bonusMin;
    final max = bonusMax;
    if (min == null || max == null) return null;
    return max - min + 1;
  }

  /// 메인 번호의 색상 구간 인덱스(0~4)를 반환한다.
  int colorZoneFor(int number) {
    if (number < mainMin || number > mainMax) {
      throw RangeError.range(number, mainMin, mainMax, 'number');
    }

    for (var i = 0; i < colorZoneBounds.length; i++) {
      if (number <= colorZoneBounds[i]) return i;
    }
    return colorZoneBounds.length - 1;
  }
}

/// 지원 게임 타입 목록과 조회 헬퍼.
class GameTypes {
  const GameTypes._();

  static const lotto645 = GameType(
    id: GameTypeId.lotto645,
    mainMin: 1,
    mainMax: 45,
    mainCount: 6,
    colorZoneBounds: [10, 20, 30, 40, 45],
  );

  static const powerball = GameType(
    id: GameTypeId.powerball,
    mainMin: 1,
    mainMax: 69,
    mainCount: 5,
    bonusMin: 1,
    bonusMax: 26,
    bonusCount: 1,
    bonusBallColorArgb: 0xFFE53935,
    colorZoneBounds: [14, 28, 42, 56, 69],
  );

  static const megaMillions = GameType(
    id: GameTypeId.megaMillions,
    mainMin: 1,
    mainMax: 70,
    mainCount: 5,
    bonusMin: 1,
    bonusMax: 25,
    bonusCount: 1,
    bonusBallColorArgb: 0xFFFFB300,
    colorZoneBounds: [14, 28, 42, 56, 70],
  );

  static const winForLife = GameType(
    id: GameTypeId.winForLife,
    mainMin: 1,
    mainMax: 48,
    mainCount: 5,
    bonusMin: 1,
    bonusMax: 18,
    bonusCount: 1,
    bonusBallColorArgb: 0xFFFDD835,
    colorZoneBounds: [10, 20, 30, 40, 48],
  );

  static const annuity720 = GameType(
    id: GameTypeId.annuity720,
    mainMin: 0,
    mainMax: 9,
    mainCount: 6,
    bonusMin: 1,
    bonusMax: 5,
    bonusCount: 1,
    bonusBallColorArgb: 0xFF7B1FA2,
    colorZoneBounds: [1, 3, 5, 7, 9],
    category: GameCategory.serial,
  );

  static const all = [
    lotto645,
    powerball,
    megaMillions,
    winForLife,
    annuity720,
  ];

  static GameType fromId(GameTypeId id) {
    return all.firstWhere((gameType) => gameType.id == id);
  }
}
