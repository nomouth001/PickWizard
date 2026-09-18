// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'PickWizard: Trợ lý chọn số xổ số';

  @override
  String get appSubtitle => 'Ứng dụng hỗ trợ chọn số xổ số';

  @override
  String get disclaimerDialogTitle => 'Thông báo';

  @override
  String get disclaimerDialogMessage =>
      'Ứng dụng này là công cụ hỗ trợ quay số dành cho những ai muốn chọn số xổ số theo cách khác ngoài chọn nhanh tại máy khi mua vé. Ứng dụng không làm tăng xác suất trúng thưởng. Chỉ nên sử dụng với mục đích giải trí.';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get cancel => 'Hủy';

  @override
  String get close => 'Đóng';

  @override
  String get save => 'Lưu';

  @override
  String get delete => 'Xóa';

  @override
  String get deleteSavedNumberTitle => 'Xóa số đã lưu';

  @override
  String get deleteSavedNumberMessage => 'Bạn có chắc xóa bản ghi này?';

  @override
  String get offlineDrawCheckHint =>
      'Tra cứu trúng thưởng tại kênh chính thức.';

  @override
  String get edit => 'Sửa';

  @override
  String get view => 'Xem';

  @override
  String get loading => 'Đang tải...';

  @override
  String get error => 'Lỗi';

  @override
  String get success => 'Thành công';

  @override
  String get warning => 'Cảnh báo';

  @override
  String get info => 'Thông tin';

  @override
  String get home => 'Trang chủ';

  @override
  String get homeTitle => 'Tạo số xổ số';

  @override
  String get generate => 'Tạo';

  @override
  String get generateNumbers => 'Tạo số';

  @override
  String get history => 'Lịch sử';

  @override
  String get myNumbers => 'Số của tôi';

  @override
  String get settings => 'Cài đặt';

  @override
  String get statistics => 'Thống kê';

  @override
  String get statisticsComingSoon => 'Tính năng thống kê sắp ra mắt';

  @override
  String get latestDraw => 'Kỳ mới nhất';

  @override
  String get latestWinningNumbers => 'Số trúng thưởng mới nhất';

  @override
  String drawNumber(int number) {
    return 'Kỳ #$number';
  }

  @override
  String get bonusNumber => 'Số đặc biệt';

  @override
  String get drawDate => 'Ngày quay';

  @override
  String get selectAlgorithm => 'Chọn thuật toán';

  @override
  String get algorithmSelection => 'Chọn thuật toán';

  @override
  String get changeOptions => 'Đổi tùy chọn';

  @override
  String get numberOfSets => 'Số bộ tạo';

  @override
  String numberOfSetsCount(int count) {
    return '$count bộ';
  }

  @override
  String get quickButton5 => '5 bộ';

  @override
  String get quickButton10 => '10 bộ';

  @override
  String get fiveSets => '5 bộ';

  @override
  String get tenSets => '10 bộ';

  @override
  String get directInput => 'Tùy chỉnh';

  @override
  String get enterNumberOfSets => 'Nhập số bộ cần tạo';

  @override
  String get range1To100 => '1~100';

  @override
  String get rangeHint => '1~100';

  @override
  String get setsUnit => 'bộ';

  @override
  String get generateButton => 'Tạo số';

  @override
  String get generating => 'Đang tạo...';

  @override
  String get algorithm1Name => 'Chọn nhanh (Quick Pick)';

  @override
  String get algorithm1Desc =>
      'Chọn ngẫu nhiên 6 số từ 1–45. Công bằng và không thiên lệch.';

  @override
  String algorithm1DescDynamic(int min, int max, int count) {
    return 'Chọn ngẫu nhiên $count số từ $min–$max. Công bằng và không thiên lệch.';
  }

  @override
  String get algorithm2Name => 'Tần suất nâng cao';

  @override
  String get algorithm2Desc => 'Phân tích tần suất quay trước đây để chọn số.';

  @override
  String get algorithm3Name => 'Chọn bằng Deep Learning';

  @override
  String get algorithm3Desc =>
      'Chọn số dựa trên quy luật do deep learning học được.';

  @override
  String get algorithm4Name => 'Chọn theo quy luật';

  @override
  String get algorithm4Desc =>
      'Phân tích quy luật thống kê như tỷ lệ chẵn/lẻ, số liên tiếp.';

  @override
  String get algorithm5Name => 'Chọn có trọng số';

  @override
  String get algorithm5Desc =>
      'Áp trọng số cho tần suất, độ gần, vùng, đa dạng để chọn số.';

  @override
  String get algorithm6Name => 'Chọn theo tần suất';

  @override
  String get algorithm6Desc => 'Ưu tiên số có tần suất quay cao.';

  @override
  String get algorithm7Name => 'Số nóng/lạnh';

  @override
  String get algorithm7Desc =>
      'Kết hợp số nóng (ra gần đây) và số lạnh (lâu không ra).';

  @override
  String get algorithm8Name => 'Chọn bằng AI';

  @override
  String get algorithm8Desc =>
      'AI phân tích số trúng thưởng trước đây và đề xuất số.';

  @override
  String get free => 'Miễn phí';

  @override
  String coinsPerSet(int coins) {
    return '$coins xu';
  }

  @override
  String get generatedNumbers => 'Số đã tạo';

  @override
  String get generationResult => 'Kết quả tạo';

  @override
  String generatedCount(int count) {
    return 'Đã tạo tổng $count bộ';
  }

  @override
  String setsGenerated(int count) {
    return 'Đã tạo $count bộ';
  }

  @override
  String setNumber(int number) {
    return 'Bộ $number';
  }

  @override
  String get saveToMyNumbers => 'Lưu vào Số của tôi';

  @override
  String get saveAsMyNumbers => 'Lưu thành Số của tôi';

  @override
  String saveSetsMessage(int count) {
    return 'Sẽ lưu $count bộ số';
  }

  @override
  String numbersSaved(int count) {
    return 'Đã lưu $count bộ số';
  }

  @override
  String saveFailed(String error) {
    return 'Lưu thất bại: $error';
  }

  @override
  String get memoOptional => 'Ghi chú (tùy chọn)';

  @override
  String get memoExample => 'VD: Số mua hàng tuần';

  @override
  String get share => 'Chia sẻ';

  @override
  String get generateAgain => 'Tạo lại';

  @override
  String get backToHome => 'Về trang chủ';

  @override
  String get maxLimitTitle => 'Giới hạn số bộ';

  @override
  String get maxLimitMessage => 'Chỉ được tạo tối đa 100 bộ.';

  @override
  String get requirementTitle => 'Cần nhập';

  @override
  String get requirementSelectAlgorithm => 'Vui lòng chọn thuật toán.';

  @override
  String get requirementSelectCount => 'Vui lòng chọn hoặc nhập số bộ. (1~100)';

  @override
  String get requirementSelectBoth => 'Vui lòng chọn thuật toán và nhập số bộ.';

  @override
  String get errorLoadAlgorithms => 'Không tải được thuật toán';

  @override
  String get errorLoadingData => 'Không tải được dữ liệu';

  @override
  String errorFormat(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get errorOccurred => 'Đã xảy ra lỗi';

  @override
  String get initializationError => 'Lỗi khởi tạo';

  @override
  String errorGenerateFailed(String message) {
    return 'Tạo số thất bại: $message';
  }

  @override
  String get errorNetwork => 'Vui lòng kiểm tra kết nối mạng';

  @override
  String get errorServer => 'Đã xảy ra lỗi máy chủ';

  @override
  String get errorUnknown => 'Đã xảy ra lỗi không xác định';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get gameLabel => 'Trò chơi';

  @override
  String get selectGame => 'Chọn trò chơi';

  @override
  String get gameLotto645 => 'Lotto 6/45';

  @override
  String get gamePowerball => 'Powerball';

  @override
  String get gameMegaMillions => 'Mega Millions';

  @override
  String get gameWinForLife => 'Win for Life';

  @override
  String get gameAnnuity720 => 'Xổ số hưu trí 720+';

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
  String get bonusBallLabel => 'Bi bonus';

  @override
  String get bonusBallNamePowerball => 'Powerball (bi đỏ)';

  @override
  String get gameTypeChangedClearNumbers =>
      'Đã đổi trò chơi. Các số bao gồm và loại trừ đã được đặt lại.';

  @override
  String get selectLanguage => 'Chọn ngôn ngữ';

  @override
  String languageChanged(String language) {
    return 'Đã đổi sang $language';
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
  String get appNameOffline => 'PickWizard: Trợ lý chọn số xổ số';

  @override
  String get includeNumbersLabel => 'Số cần bao gồm';

  @override
  String get excludeNumbersLabel => 'Số cần loại trừ';

  @override
  String get includeNumbersHint =>
      'VD: 1, 3, 7 (phân cách bằng dấu phẩy hoặc khoảng trắng, tối đa 6)';

  @override
  String mainNumberRange(int min, int max) {
    return 'Dải số chính: $min~$max';
  }

  @override
  String includeNumbersHintDynamic(int min, int max, int maxCount) {
    return 'VD: 1, 3, 7 (phẩy hoặc cách trắng, dải $min~$max, tối đa $maxCount)';
  }

  @override
  String excludeNumbersHintDynamic(int min, int max, int maxExclude) {
    return 'VD: 2, 5, 10 (phẩy hoặc cách trắng, dải $min~$max, tối đa $maxExclude)';
  }

  @override
  String get excludeNumbersHint =>
      'VD: 2, 5, 10 (phân cách bằng dấu phẩy hoặc khoảng trắng, tối đa 39)';

  @override
  String get mainNumbers => 'Số chính';

  @override
  String bonusBallSection(String name) {
    return 'Bi bonus ($name)';
  }

  @override
  String includeBonusNumbersLabel(String name) {
    return 'Số $name cần bao gồm';
  }

  @override
  String excludeBonusNumbersLabel(String name) {
    return 'Số $name cần loại trừ';
  }

  @override
  String includeBonusHint(int max) {
    return '1~$max, tối đa 1';
  }

  @override
  String excludeBonusHint(int max, int limit) {
    return '1~$max, tối đa $limit';
  }

  @override
  String get bonusBallNameMegaBall => 'Mega Ball (bi vàng)';

  @override
  String get bonusBallNameLuckyBall => 'Lucky Ball (bi vàng chanh)';

  @override
  String bonusNumberRange(int max) {
    return 'Dải số bonus: 1~$max';
  }

  @override
  String get filterAll => 'Tất cả';

  @override
  String get numberOfSetsHint => 'Số bộ số cần tạo (1~100)';

  @override
  String get checkIncludeExclude =>
      'Vui lòng kiểm tra điều kiện bao gồm/loại trừ.';

  @override
  String copySetsCopied(int start, int end) {
    return 'Đã sao chép bộ $start~$end vào clipboard.';
  }

  @override
  String get copyBy5SetsSection => 'Sao chép theo 5 bộ';

  @override
  String copySetsRangeButton(int start, int end) {
    return 'Sao chép bộ $start~$end';
  }

  @override
  String get algorithm9NameDisplay => 'Rút 10.000 lần chọn 6 số';

  @override
  String get algorithm9Desc =>
      'Rút ngẫu nhiên 10.000 lần, chọn 6 số có tần suất cao nhất làm một bộ.';

  @override
  String algorithm9DescDynamic(int count) {
    return 'Rút ngẫu nhiên 10.000 lần, chọn $count số có tần suất cao nhất làm một bộ.';
  }

  @override
  String get algorithm1HelpOverview =>
      'Tạo số hoàn toàn ngẫu nhiên. Mỗi số có xác suất được chọn như nhau.';

  @override
  String get algorithm1HelpHowItWorks =>
      'Chọn 6 số ngẫu nhiên từ 1 đến 45. Không xét thống kê hay quy luật; mỗi số được chọn độc lập.';

  @override
  String get algorithm1HelpWhenToUse =>
      'Dùng khi bạn muốn hoàn toàn dựa vào may mắn, không chiến lược đặc biệt. Miễn phí và tạo số nhanh nhất.';

  @override
  String get algorithm9HelpOverview =>
      'Rút ngẫu nhiên từ 1 đến 45 tổng cộng 10.000 lần, lấy 6 số xuất hiện nhiều nhất làm một bộ. Cách mô phỏng thuần, không dùng dữ liệu quá khứ.';

  @override
  String get algorithm9HelpHowItWorks =>
      '1. Lặp 10.000 lần: rút ngẫu nhiên một số từ 1 đến 45.\n2. Đếm số lần mỗi số xuất hiện.\n3. Chọn 6 số xuất hiện nhiều nhất làm một bộ.\n4. Nếu bằng nhau thì ưu tiên số nhỏ hơn.';

  @override
  String get algorithm9HelpWhenToUse =>
      'Dùng khi bạn tin vào kết quả mô phỏng ngẫu nhiên lặp lại thay vì thống kê hay dữ liệu quá khứ. Miễn phí, không cần cài đặt thêm.';

  @override
  String get serialAlgorithm1Name => 'Chọn số sê-ri ngẫu nhiên';

  @override
  String get serialAlgorithm1HelpHowItWorks =>
      'Với mỗi trong sáu vị trí, rút ngẫu nhiên một chữ số từ 0 đến 9. Không dùng thống kê hay mẫu, mỗi vị trí được chọn độc lập.';

  @override
  String get serialAlgorithm9Name =>
      'Mỗi chữ số: 3.000 lần, chọn tần suất cao nhất';

  @override
  String get serialAlgorithm9Desc =>
      'Với mỗi trong sáu vị trí, rút ngẫu nhiên 0–9 trong 3.000 lần rồi chọn chữ số xuất hiện nhiều nhất ở vị trí đó.';

  @override
  String get serialAlgorithm9HelpOverview =>
      'Với mỗi vị trí của Annuity 720+, rút ngẫu nhiên 0–9 trong 3.000 lần và chọn chữ số có tần suất cao nhất tại vị trí đó. Mô phỏng thuần túy, không dùng dữ liệu quay thưởng trong quá khứ.';

  @override
  String get serialAlgorithm9HelpHowItWorks =>
      '1. Với mỗi trong sáu vị trí (trái sang phải), thực hiện các bước sau.\n2. Lặp 3.000 lần: chọn ngẫu nhiên một chữ số từ 0 đến 9.\n3. Đếm số lần xuất hiện và chọn chữ số có số lần cao nhất tại vị trí đó.\n4. Nếu hòa, ưu tiên chữ số nhỏ hơn.\n5. Sau khi đủ sáu vị trí, hoàn thành một bộ.';

  @override
  String get serialAlgorithm9HelpWhenToUse =>
      'Dùng khi muốn cách chọn theo tần suất tương tự Monte Carlo kiểu chọn bóng, nhưng vẫn giữ ý nghĩa thứ tự các chữ số kiểu serial.';

  @override
  String get unsupportedAlgorithm => 'Thuật toán không được hỗ trợ.';

  @override
  String includeSelectedLabel(int count, int max) {
    return 'Đã chọn $count (tối đa $max)';
  }

  @override
  String excludeSelectedLabel(int count, int max) {
    return 'Đã chọn $count (tối đa $max)';
  }

  @override
  String get myNumbersEmptyTitle => 'Chưa có số đã lưu';

  @override
  String get myNumbersEmptyHint =>
      'Tạo số xong, nhấn \'Lưu thành Số của tôi\' ở màn hình kết quả để lưu vào đây.';

  @override
  String get dbResetDialogTitle => 'Thông báo';

  @override
  String get dbResetDialogMessage =>
      'Các số đã lưu đã được xóa do cập nhật ứng dụng.';
}
