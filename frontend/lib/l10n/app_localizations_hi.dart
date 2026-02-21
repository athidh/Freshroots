// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get login_title => 'वापस स्वागत है!';

  @override
  String get signup_title => 'खाता बनाएं';

  @override
  String get email_label => 'ईमेल पता';

  @override
  String get password_label => 'पासवर्ड';

  @override
  String get username_label => 'उपयोगकर्ता नाम';

  @override
  String get start_transit => 'ट्रांज़िट शुरू करें';

  @override
  String get freshness_score => 'ताज़गी स्कोर';

  @override
  String get forgot_password => 'पासवर्ड भूल गए?';

  @override
  String get welcome_back => 'वापस स्वागत है!';

  @override
  String get sign_in_subtitle =>
      'अपनी डिलीवरी प्रबंधित करने के लिए साइन इन करें';

  @override
  String get create_account_btn => 'खाता बनाएं';

  @override
  String get login_btn => 'लॉगिन';

  @override
  String get or_continue_with => 'या इसके साथ जारी रखें';

  @override
  String get no_account => 'खाता नहीं है? ';

  @override
  String get have_account => 'पहले से खाता है? ';

  @override
  String get sign_up => 'साइन अप';

  @override
  String get language => 'भाषा';

  @override
  String get arrived => 'पहुँच गए';

  @override
  String get sos => 'आपातकाल';

  @override
  String get live => 'लाइव';

  @override
  String get eta => 'अनुमानित समय';

  @override
  String get tab_signup => 'साइन अप';

  @override
  String get tab_login => 'लॉगिन';

  @override
  String get select_market => 'बाज़ार गंतव्य चुनें';

  @override
  String start_transit_to(String market) {
    return '$market के लिए ट्रांज़िट शुरू करें';
  }

  @override
  String get choose_different => 'दूसरा चुनें';

  @override
  String get getting_location => 'आपकी लोकेशन ढूंढ रहे हैं...';

  @override
  String get you_are_here => 'आप यहाँ हैं';

  @override
  String fresh_pct(String pct) {
    return '$pct% ताज़ा';
  }

  @override
  String get risk_label => 'जोखिम';

  @override
  String get weather_start => 'शुरू';

  @override
  String get weather_dest => 'गंतव्य';

  @override
  String get temperature => 'तापमान';

  @override
  String get freshness => 'ताज़गी';

  @override
  String get demand => 'मांग';

  @override
  String get demand_high => 'उच्च';

  @override
  String get demand_medium => 'मध्यम';

  @override
  String get demand_low => 'कम';

  @override
  String get custom_location => 'कस्टम लोकेशन';

  @override
  String get custom_dest => 'कस्टम गंतव्य';

  @override
  String get dark_mode => 'डार्क मोड';

  @override
  String get wind => 'हवा';

  @override
  String get humidity => 'नमी';

  @override
  String get good_morning => 'सुप्रभात';

  @override
  String get good_afternoon => 'नमस्कार';

  @override
  String get good_evening => 'शुभ संध्या';

  @override
  String hi_user(String name) {
    return 'नमस्ते, $name 👋';
  }

  @override
  String get active_trips => 'सक्रिय यात्राएं';

  @override
  String get revenue => 'राजस्व';

  @override
  String get available_produce => 'उपलब्ध उपज';

  @override
  String get view_all => 'सभी देखें';

  @override
  String get fruits => '🍎 फल';

  @override
  String get vegetables => '🥬 सब्ज़ियां';

  @override
  String get new_load_entry => 'नया लोड एंट्री';

  @override
  String get record_harvest => 'ट्रांज़िट के लिए फसल विवरण दर्ज करें';

  @override
  String get what_transporting => 'आप क्या ले जा रहे हैं?';

  @override
  String get quantity_label => 'मात्रा (कुल लोड)';

  @override
  String get select_produce => 'उपज प्रकार चुनें';

  @override
  String get origin_point => 'मूल बिंदु';

  @override
  String get timestamp => 'समय';

  @override
  String get destination => 'गंतव्य';

  @override
  String get start_new_trip => 'नई यात्रा शुरू करें';

  @override
  String get trip_failed => 'यात्रा शुरू करने में विफल। सर्वर जांचें।';

  @override
  String decay_label(String value) {
    return 'क्षय: $value';
  }
}
