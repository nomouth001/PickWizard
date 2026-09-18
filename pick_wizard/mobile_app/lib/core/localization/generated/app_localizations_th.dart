// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'PickWizard: ตัวช่วยเลือกเลขหวย';

  @override
  String get appSubtitle => 'แอปช่วยเลือกเลขหวย';

  @override
  String get disclaimerDialogTitle => 'แจ้งให้ทราบ';

  @override
  String get disclaimerDialogMessage =>
      'แอปนี้เป็นเครื่องมือช่วยจับสลากเลข สำหรับผู้ที่ต้องการเลือกหมายเลขในวิธีอื่นนอกจากตัวเลือกด่วนที่เครื่องเมื่อซื้อสลาก แอปไม่เพิ่มโอกาสถูกรางวัล กรุณาใช้เพื่อความบันเทิงเท่านั้น';

  @override
  String get confirm => 'ตกลง';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get close => 'ปิด';

  @override
  String get save => 'บันทึก';

  @override
  String get delete => 'ลบ';

  @override
  String get deleteSavedNumberTitle => 'ลบหมายเลขที่บันทึก';

  @override
  String get deleteSavedNumberMessage => 'ลบชุดนี้ใช่หรือไม่?';

  @override
  String get offlineDrawCheckHint => 'ตรวจผลรางวัลได้ที่ช่องทางทางการ';

  @override
  String get edit => 'แก้ไข';

  @override
  String get view => 'ดู';

  @override
  String get loading => 'กำลังโหลด...';

  @override
  String get error => 'ข้อผิดพลาด';

  @override
  String get success => 'สำเร็จ';

  @override
  String get warning => 'คำเตือน';

  @override
  String get info => 'ข้อมูล';

  @override
  String get home => 'หน้าหลัก';

  @override
  String get homeTitle => 'สร้างเลขหวย';

  @override
  String get generate => 'สร้าง';

  @override
  String get generateNumbers => 'สร้างเลข';

  @override
  String get history => 'ประวัติ';

  @override
  String get myNumbers => 'เลขของฉัน';

  @override
  String get settings => 'ตั้งค่า';

  @override
  String get statistics => 'สถิติ';

  @override
  String get statisticsComingSoon => 'ฟีเจอร์สถิติเร็วๆ นี้';

  @override
  String get latestDraw => 'งวดล่าสุด';

  @override
  String get latestWinningNumbers => 'เลขที่ถูกล่าสุด';

  @override
  String drawNumber(int number) {
    return 'งวดที่ $number';
  }

  @override
  String get bonusNumber => 'เลขเสริม';

  @override
  String get drawDate => 'วันออกรางวัล';

  @override
  String get selectAlgorithm => 'เลือกอัลกอริทึม';

  @override
  String get algorithmSelection => 'เลือกอัลกอริทึม';

  @override
  String get changeOptions => 'เปลี่ยนตัวเลือก';

  @override
  String get numberOfSets => 'จำนวนชุด';

  @override
  String numberOfSetsCount(int count) {
    return '$count ชุด';
  }

  @override
  String get quickButton5 => '5 ชุด';

  @override
  String get quickButton10 => '10 ชุด';

  @override
  String get fiveSets => '5 ชุด';

  @override
  String get tenSets => '10 ชุด';

  @override
  String get directInput => 'กำหนดเอง';

  @override
  String get enterNumberOfSets => 'กรอกจำนวนชุดที่ต้องการสร้าง';

  @override
  String get range1To100 => '1~100';

  @override
  String get rangeHint => '1~100';

  @override
  String get setsUnit => 'ชุด';

  @override
  String get generateButton => 'สร้างเลข';

  @override
  String get generating => 'กำลังสร้าง...';

  @override
  String get algorithm1Name => 'เลือกด่วน (Quick Pick)';

  @override
  String get algorithm1Desc =>
      'สุ่มเลือก 6 หมายเลขจาก 1–45 ยุติธรรมและไม่เอนเอียง';

  @override
  String algorithm1DescDynamic(int min, int max, int count) {
    return 'สุ่มเลือก $count หมายเลขจาก $min–$max ยุติธรรมและไม่เอนเอียง';
  }

  @override
  String get algorithm2Name => 'ความถี่ขั้นสูง';

  @override
  String get algorithm2Desc => 'วิเคราะห์ความถี่งวดก่อนเพื่อเลือกหมายเลข';

  @override
  String get algorithm3Name => 'Deep Learning';

  @override
  String get algorithm3Desc =>
      'เลือกหมายเลขจากรูปแบบที่ deep learning เรียนรู้';

  @override
  String get algorithm4Name => 'วิเคราะห์รูปแบบ';

  @override
  String get algorithm4Desc =>
      'วิเคราะห์รูปแบบทางสถิติ เช่น คู่/คี่ หมายเลขติดกัน';

  @override
  String get algorithm5Name => 'เลือกแบบถ่วงน้ำหนัก';

  @override
  String get algorithm5Desc => 'ใส่น้ำหนักความถี่ ความใหม่ โซน ความหลากหลาย';

  @override
  String get algorithm6Name => 'ตามความถี่';

  @override
  String get algorithm6Desc => 'เน้นหมายเลขที่ออกบ่อย';

  @override
  String get algorithm7Name => 'เลขร้อน/เย็น';

  @override
  String get algorithm7Desc => 'ผสมเลขร้อน (ออกล่าสุด) กับเลขเย็น (นานไม่ออก)';

  @override
  String get algorithm8Name => 'เลือกด้วย AI';

  @override
  String get algorithm8Desc =>
      'AI วิเคราะห์เลขที่ถูกรางวัลในอดีตและแนะนำหมายเลข';

  @override
  String get free => 'ฟรี';

  @override
  String coinsPerSet(int coins) {
    return '$coins เหรียญ';
  }

  @override
  String get generatedNumbers => 'เลขที่สร้างแล้ว';

  @override
  String get generationResult => 'ผลการสร้าง';

  @override
  String generatedCount(int count) {
    return 'สร้างทั้งหมด $count ชุด';
  }

  @override
  String setsGenerated(int count) {
    return 'สร้างแล้ว $count ชุด';
  }

  @override
  String setNumber(int number) {
    return 'ชุดที่ $number';
  }

  @override
  String get saveToMyNumbers => 'บันทึกไปที่เลขของฉัน';

  @override
  String get saveAsMyNumbers => 'บันทึกเป็นเลขของฉัน';

  @override
  String saveSetsMessage(int count) {
    return 'จะบันทึก $count ชุดเลข';
  }

  @override
  String numbersSaved(int count) {
    return 'บันทึก $count ชุดแล้ว';
  }

  @override
  String saveFailed(String error) {
    return 'บันทึกไม่สำเร็จ: $error';
  }

  @override
  String get memoOptional => 'หมายเหตุ (ไม่บังคับ)';

  @override
  String get memoExample => 'เช่น เลขซื้อรายสัปดาห์';

  @override
  String get share => 'แชร์';

  @override
  String get generateAgain => 'สร้างอีกครั้ง';

  @override
  String get backToHome => 'กลับหน้าหลัก';

  @override
  String get maxLimitTitle => 'จำกัดจำนวนชุด';

  @override
  String get maxLimitMessage => 'สร้างได้สูงสุด 100 ชุด';

  @override
  String get requirementTitle => 'กรุณากรอก';

  @override
  String get requirementSelectAlgorithm => 'กรุณาเลือกอัลกอริทึม';

  @override
  String get requirementSelectCount => 'กรุณาเลือกหรือกรอกจำนวนชุด (1~100)';

  @override
  String get requirementSelectBoth => 'กรุณาเลือกอัลกอริทึมและกรอกจำนวนชุด';

  @override
  String get errorLoadAlgorithms => 'โหลดอัลกอริทึมไม่สำเร็จ';

  @override
  String get errorLoadingData => 'โหลดข้อมูลไม่สำเร็จ';

  @override
  String errorFormat(String error) {
    return 'ข้อผิดพลาด: $error';
  }

  @override
  String get errorOccurred => 'เกิดข้อผิดพลาด';

  @override
  String get initializationError => 'ข้อผิดพลาดในการเริ่มต้น';

  @override
  String errorGenerateFailed(String message) {
    return 'สร้างเลขไม่สำเร็จ: $message';
  }

  @override
  String get errorNetwork => 'กรุณาตรวจสอบการเชื่อมต่อเครือข่าย';

  @override
  String get errorServer => 'เกิดข้อผิดพลาดเซิร์ฟเวอร์';

  @override
  String get errorUnknown => 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ';

  @override
  String get language => 'ภาษา';

  @override
  String get gameLabel => 'เกม';

  @override
  String get selectGame => 'เลือกเกม';

  @override
  String get gameLotto645 => 'ล็อตโต้ 6/45';

  @override
  String get gamePowerball => 'พาวเวอร์บอล';

  @override
  String get gameMegaMillions => 'เมกะมิลเลียนส์';

  @override
  String get gameWinForLife => 'Win for Life';

  @override
  String get gameAnnuity720 => 'ลอตเตอรี่บำนาญ720+';

  @override
  String annuity720GroupBadge(int group) {
    return 'Group $group';
  }

  @override
  String annuity720FullFormat(int group, String digits) {
    return 'Group $group: $digits';
  }

  @override
  String get serialFixedGroupLabel => 'Fix Group';

  @override
  String get serialFixedGroupHint => '1–5, blank = random';

  @override
  String get serialExcludeGroupsLabel => 'Exclude Groups';

  @override
  String get serialExcludeGroupsHint => '1–5, up to 4';

  @override
  String get serialGroupRange => 'Group range: 1–5';

  @override
  String get serialDigitRange => 'Each digit: 0–9';

  @override
  String get bonusBallLabel => 'ลูกโบนัส';

  @override
  String get bonusBallNamePowerball => 'พาวเวอร์บอล (ลูกแดง)';

  @override
  String get gameTypeChangedClearNumbers =>
      'เปลี่ยนเกมแล้ว หมายเลขที่รวม/ยกเว้นถูกรีเซ็ต';

  @override
  String get selectLanguage => 'เลือกภาษา';

  @override
  String languageChanged(String language) {
    return 'เปลี่ยนเป็น $language แล้ว';
  }

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageThai => 'ภาษาไทย';

  @override
  String get languageJapanese => '日本語';

  @override
  String get appNameOffline => 'PickWizard: ตัวช่วยเลือกเลขหวย';

  @override
  String get includeNumbersLabel => 'หมายเลขที่รวม';

  @override
  String get excludeNumbersLabel => 'หมายเลขที่ไม่รวม';

  @override
  String get includeNumbersHint =>
      'เช่น 1, 3, 7 (คั่นด้วยจุลภาคหรือเว้นวรรค สูงสุด 6)';

  @override
  String mainNumberRange(int min, int max) {
    return 'ช่วงหมายเลขหลัก: $min~$max';
  }

  @override
  String includeNumbersHintDynamic(int min, int max, int maxCount) {
    return 'เช่น 1, 3, 7 (จุลภาคหรือเว้นวรรค ช่วง $min~$max สูงสุด $maxCount)';
  }

  @override
  String excludeNumbersHintDynamic(int min, int max, int maxExclude) {
    return 'เช่น 2, 5, 10 (จุลภาคหรือเว้นวรรค ช่วง $min~$max สูงสุด $maxExclude)';
  }

  @override
  String get excludeNumbersHint =>
      'เช่น 2, 5, 10 (คั่นด้วยจุลภาคหรือเว้นวรรค สูงสุด 39)';

  @override
  String get mainNumbers => 'หมายเลขหลัก';

  @override
  String bonusBallSection(String name) {
    return 'ลูกโบนัส ($name)';
  }

  @override
  String includeBonusNumbersLabel(String name) {
    return 'หมายเลข $name ที่รวม';
  }

  @override
  String excludeBonusNumbersLabel(String name) {
    return 'หมายเลข $name ที่ยกเว้น';
  }

  @override
  String includeBonusHint(int max) {
    return '1~$max สูงสุด 1';
  }

  @override
  String excludeBonusHint(int max, int limit) {
    return '1~$max สูงสุด $limit';
  }

  @override
  String get bonusBallNameMegaBall => 'เมกะบอล (ลูกทอง)';

  @override
  String get bonusBallNameLuckyBall => 'ลัคกี้บอล (ลูกเหลือง)';

  @override
  String bonusNumberRange(int max) {
    return 'ช่วงหมายเลขโบนัส: 1~$max';
  }

  @override
  String get filterAll => 'ทั้งหมด';

  @override
  String get numberOfSetsHint => 'จำนวนชุดที่สร้าง (1~100)';

  @override
  String get checkIncludeExclude => 'กรุณาตรวจสอบเงื่อนไขการรวม/ยกเว้น';

  @override
  String copySetsCopied(int start, int end) {
    return 'คัดลอกชุดที่ $start~$end ไปยังคลิปบอร์ดแล้ว';
  }

  @override
  String get copyBy5SetsSection => 'คัดลอกทีละ 5 ชุด';

  @override
  String copySetsRangeButton(int start, int end) {
    return 'คัดลอกชุดที่ $start~$end';
  }

  @override
  String get algorithm9NameDisplay => 'สุ่ม 10,000 ครั้ง เลือก 6 หมายเลข';

  @override
  String get algorithm9Desc =>
      'สุ่ม 10,000 ครั้ง แล้วเลือก 6 หมายเลขที่ออกบ่อยที่สุดเป็นหนึ่งชุด';

  @override
  String algorithm9DescDynamic(int count) {
    return 'สุ่ม 10,000 ครั้ง แล้วเลือก $count หมายเลขที่ออกบ่อยที่สุดเป็นหนึ่งชุด';
  }

  @override
  String get algorithm1HelpOverview =>
      'สร้างหมายเลขแบบสุ่มทั้งหมด ทุกหมายเลขมีโอกาสถูกเลือกเท่ากัน';

  @override
  String get algorithm1HelpHowItWorks =>
      'เลือก 6 หมายเลขแบบสุ่มจาก 1 ถึง 45 ไม่พิจารณาสถิติหรือรูปแบบ แต่ละหมายเลขถูกเลือกแยกกัน';

  @override
  String get algorithm1HelpWhenToUse =>
      'ใช้เมื่อต้องการพึ่งพาโชคโดยไม่มีกลยุทธ์พิเศษ ฟรีและสร้างหมายเลขได้เร็วที่สุด';

  @override
  String get algorithm9HelpOverview =>
      'สุ่มจาก 1 ถึง 45 ทั้งหมด 10,000 ครั้ง แล้วนำ 6 หมายเลขที่ออกบ่อยที่สุดเป็นหนึ่งชุด เป็นการจำลองล้วนๆ ไม่ใช้ข้อมูลอดีต';

  @override
  String get algorithm9HelpHowItWorks =>
      '1. ทำซ้ำ 10,000 ครั้ง: สุ่มเลือกหนึ่งหมายเลขจาก 1 ถึง 45\n2. นับว่าหมายเลขแต่ละตัวออกกี่ครั้ง\n3. เลือก 6 หมายเลขที่ออกบ่อยที่สุดเป็นหนึ่งชุด\n4. ถ้าเท่ากัน ให้หมายเลขที่น้อยกว่ามาก่อน';

  @override
  String get algorithm9HelpWhenToUse =>
      'ใช้เมื่อเชื่อผลการสุ่มซ้ำมากกว่าสถิติหรือข้อมูลอดีต ฟรีและไม่ต้องตั้งค่าเพิ่ม';

  @override
  String get serialAlgorithm1Name => 'ซีเรียลสุ่มอัตโนมัติ';

  @override
  String get serialAlgorithm1HelpHowItWorks =>
      'สำหรับแต่ละหลักใน 6 หลัก จะสุ่มตัวเลขจาก 0 ถึง 9 โดยไม่ใช้สถิติหรือรูปแบบ และแต่ละหลักเลือกอิสระจากกัน';

  @override
  String get serialAlgorithm9Name =>
      'แต่ละหลักสุ่ม 3,000 ครั้ง เลือกที่บ่อยสุด';

  @override
  String get serialAlgorithm9Desc =>
      'ในแต่ละตำแหน่ง 6 หลัก สุ่ม 0–9 แบบสุ่ม 3,000 ครั้ง แล้วเลือกตัวเลขที่ออกบ่อยที่สุดในแต่ละหลัก';

  @override
  String get serialAlgorithm9HelpOverview =>
      'สำหรับแต่ละหลักของ Annuity 720+ สุ่ม 0–9 แบบสุ่ม 3,000 ครั้ง แล้วเลือกตัวเลขที่ออกบ่อยที่สุดในหลักนั้น เป็นการจำลองล้วนๆ ไม่ใช้ข้อมูลผลรางวัลย้อนหลัง';

  @override
  String get serialAlgorithm9HelpHowItWorks =>
      '1. ทำแต่ละหลักจากซ้ายไปขวา 6 หลักดังนี้\n2. ทำซ้ำ 3,000 ครั้ง: สุ่มเลือกหนึ่งหลักจาก 0 ถึง 9\n3. นับว่าหลักแต่ละตัวออกกี่ครั้ง แล้วเลือกหลักที่ออกบ่อยที่สุดในตำแหน่งนั้น\n4. ถ้าเท่ากัน ให้หลักที่น้อยกว่ามาก่อน\n5. เมื่อครบ 6 หลัก จะได้หนึ่งชุด';

  @override
  String get serialAlgorithm9HelpWhenToUse =>
      'ใช้เมื่อต้องการแนวคิดแบบความถี่คล้าย Monte Carlo ของบอลพิค แต่ยังให้ความหมายของลำดับหลักแบบสายเลขหวยบำนาญ';

  @override
  String get unsupportedAlgorithm => 'ไม่รองรับอัลกอริทึมนี้';

  @override
  String includeSelectedLabel(int count, int max) {
    return 'เลือกแล้ว $count (สูงสุด $max)';
  }

  @override
  String excludeSelectedLabel(int count, int max) {
    return 'เลือกแล้ว $count (สูงสุด $max)';
  }

  @override
  String get myNumbersEmptyTitle => 'ยังไม่มีหมายเลขที่บันทึก';

  @override
  String get myNumbersEmptyHint =>
      'สร้างเลขแล้ว กด \'บันทึกเป็นเลขของฉัน\' ในหน้าผลลัพธ์เพื่อบันทึกมาที่นี่';

  @override
  String get dbResetDialogTitle => 'แจ้งเตือน';

  @override
  String get dbResetDialogMessage =>
      'หมายเลขที่บันทึกไว้ถูกรีเซ็ตเนื่องจากอัปเดตแอป';
}
