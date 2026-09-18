import 'package:hive/hive.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';

/// GeneratedNumbers Hive Adapter
/// 
/// 2026-01-05 16:00:00 EST - 초기 생성
/// 2026-01-08 06:37:00 EST - 새 모델 구조에 맞게 수정 (results, timestamp)
class GeneratedNumbersAdapter extends TypeAdapter<GeneratedNumbers> {
  @override
  final int typeId = 0;  // ⚠️ 주의: typeId는 고유해야 함
  
  @override
  GeneratedNumbers read(BinaryReader reader) {
    final id = reader.readString();
    final algorithmId = reader.readInt();
    final algorithmName = reader.readString();
    
    // results 리스트 읽기
    final rawResults = List<Map>.from(reader.readList());
    final resultsList = rawResults.map((map) {
      return NumberSetResult(
        setNo: map['setNo'] as int,
        numbers: (map['numbers'] as List).cast<int>(),
      );
    }).toList();
    
    final timestamp = DateTime.parse(reader.readString());
    final cost = reader.readInt();
    final isSaved = reader.readBool();
    final gameTypeIndex = reader.readInt();
    final gameTypeId = GameTypeId.values[gameTypeIndex];
    final bonusBalls = List<int>.from(reader.readList());
    
    return GeneratedNumbers(
      gameTypeId: gameTypeId,
      bonusBalls: bonusBalls,
      algorithmId: algorithmId,
      algorithmName: algorithmName,
      results: resultsList,
      timestamp: timestamp,
      cost: cost,
      isSaved: isSaved,
      id: id,
    );
  }
  
  @override
  void write(BinaryWriter writer, GeneratedNumbers obj) {
    writer.writeString(obj.id ?? '');
    writer.writeInt(obj.algorithmId);
    writer.writeString(obj.algorithmName);
    
    // results 리스트 쓰기
    writer.writeList(
      obj.results.map((r) => {
        'setNo': r.setNo,
        'numbers': r.numbers,
      }).toList()
    );
    
    writer.writeString(obj.timestamp.toIso8601String());
    writer.writeInt(obj.cost);
    writer.writeBool(obj.isSaved);
    writer.writeInt(obj.gameTypeId.index);
    writer.writeList(obj.bonusBalls);
  }
}

// Adapter TypeId 목록 (중복 방지)
// 0: GeneratedNumbers
// 1: LottoDraw (예약)
// 2: UserSettings (예약)
// 3-9: 확장용

