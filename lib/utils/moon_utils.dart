import 'dart:math' as math;

/// 🌕 달의 위상 계산 (한국시간 기준)
/// 결과값: 0~29 (정수형 주기 인덱스)
int moonIndex(DateTime date) {
  const synodicMonth = 29.53058867; // 평균 삭망월
  final knownNewMoon = DateTime.utc(2000, 1, 6, 18, 14); // 기준 신월 (NASA)
  final kstDate = date.toUtc().add(const Duration(hours: 9));
  final daysSinceNew = kstDate
      .difference(knownNewMoon)
      .inDays
      .toDouble();
  int index = (daysSinceNew % synodicMonth).round();
  return index.clamp(0, 29);
}

/// 🌙 달 이미지 파일 경로
String localMoonImage(DateTime date) {
  final idx = moonIndex(date);
  return 'assets/moon_phases/moon_${idx.toString().padLeft(2, '0')}.png';
}

/// 💡 달 이름 (피선생 moon_00~29 배열 기준 완전 적용)
String moonPhaseName(int idx) {
  const phases = [
    '신월', // 00
    '초승달', // 01
    '초승달', // 02
    '초승달', // 03
    '초승달', // 04
    '상현달(반달)', // 05
    '상현달(반달)', // 06
    '상현망의 달', // 07
    '상현망의 달', // 08
    '상현망의 달', // 09
    '보름 전', // 10
    '보름 전', // 11
    '보름 전', // 12
    '보름', // 13
    '보름', // 14
    '보름 후', // 15
    '하현망의 달', // 16
    '하현망의 달', // 17
    '하현달(반달)', // 18
    '하현달(반달)', // 19
    '하현달(반달)', // 20
    '그믐달', // 21
    '그믐달', // 22
    '그믐달', // 23
    '그믐달', // 24
    '그믐달', // 25
    '삭 전야', // 26
    '삭', // 27
    '삭', // 28
    '신월 직전', // 29
  ];
  return phases[idx.clamp(0, 29)];
}

/// 🌕 아이콘 (UI용 심벌)
String moonIconSymbol(int idx) {
  final name = moonPhaseName(idx);
  if (name.contains('신월') || name.contains('삭')) return '🌑';
  if (name.contains('초승')) return '🌒';
  if (name.contains('상현달')) return '🌓';
  if (name.contains('상현망')) return '🌔';
  if (name.contains('보름')) return '🌕';
  if (name.contains('하현망')) return '🌖';
  if (name.contains('하현달')) return '🌗';
  if (name.contains('그믐')) return '🌘';
  return '🌑';
}

/// 💡 조도 계산 (대략적)
double illumination(int idx) {
  // idx 0~14까지 증가, 이후 감소
  double normalized = idx <= 14 ? idx / 14.0 : (29 - idx) / 15.0;
  return (normalized.clamp(0.0, 1.0) * 100);
}
