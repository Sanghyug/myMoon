// lib/utils/moon_phase_names.dart

/// 30단계 한국어/영어 달 위상명 리스트
const List<Map<String, String>> moonPhaseNames = [
  {"ko": "신월", "en": "New Moon"},
  {"ko": "초승달", "en": "Waxing Crescent"},
  {"ko": "초승달", "en": "Waxing Crescent"},
  {"ko": "초승달", "en": "Waxing Crescent"},
  {"ko": "초승달", "en": "Waxing Crescent"},
  {"ko": "초승달", "en": "Waxing Crescent"},

  {"ko": "초승달→상현달", "en": "Crescent to First Quarter"},
  {"ko": "상현달", "en": "First Quarter"},
  {"ko": "상현달", "en": "First Quarter"},
  {"ko": "상현달", "en": "First Quarter"},

  {"ko": "상현달→보름", "en": "Waxing to Gibbous"},
  {"ko": "보름", "en": "Full Moon"},
  {"ko": "보름", "en": "Full Moon"},
  {"ko": "보름", "en": "Full Moon"},
  {"ko": "보름", "en": "Full Moon"},

  {"ko": "보름→하현달", "en": "Full to Waning Gibbous"},
  {"ko": "하현달", "en": "Last Quarter"},
  {"ko": "하현달", "en": "Last Quarter"},
  {"ko": "하현달", "en": "Last Quarter"},

  {"ko": "하현달→그믐", "en": "Waning Quarter to Crescent"},

  {"ko": "그믐달", "en": "Waning Crescent"},
  {"ko": "그믐달", "en": "Waning Crescent"},
  {"ko": "그믐달", "en": "Waning Crescent"},
  {"ko": "그믐달", "en": "Waning Crescent"},

  {"ko": "그믐달→신월", "en": "Crescent to New Moon"},
  {"ko": "신월직전", "en": "Dark Moon"},
  {"ko": "신월직전", "en": "Dark Moon"},
  {"ko": "삭전야", "en": "New Moon Eve"},
  {"ko": "삭", "en": "New Dark Moon"},

  {"ko": "신월", "en": "New Moon"},
];

/// 한국어 위상명
String moonPhaseKo(int idx) => moonPhaseNames[idx % 30]["ko"]!;

/// 영어 위상명
String moonPhaseEn(int idx) => moonPhaseNames[idx % 30]["en"]!;

