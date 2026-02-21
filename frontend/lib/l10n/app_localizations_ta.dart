// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get login_title => 'மீண்டும் வரவேற்கிறோம்!';

  @override
  String get signup_title => 'கணக்கை உருவாக்கு';

  @override
  String get email_label => 'மின்னஞ்சல் முகவரி';

  @override
  String get password_label => 'கடவுச்சொல்';

  @override
  String get username_label => 'பயனர் பெயர்';

  @override
  String get start_transit => 'போக்குவரத்து தொடங்கு';

  @override
  String get freshness_score => 'புத்துணர்ச்சி மதிப்பெண்';

  @override
  String get forgot_password => 'கடவுச்சொல் மறந்துவிட்டதா?';

  @override
  String get welcome_back => 'மீண்டும் வரவேற்கிறோம்!';

  @override
  String get sign_in_subtitle => 'உங்கள் டெலிவரிகளை நிர்வகிக்க உள்நுழையவும்';

  @override
  String get create_account_btn => 'கணக்கை உருவாக்கு';

  @override
  String get login_btn => 'உள்நுழை';

  @override
  String get or_continue_with => 'அல்லது இதனுடன் தொடரவும்';

  @override
  String get no_account => 'கணக்கு இல்லையா? ';

  @override
  String get have_account => 'ஏற்கனவே கணக்கு உள்ளதா? ';

  @override
  String get sign_up => 'பதிவு செய்';

  @override
  String get language => 'மொழி';

  @override
  String get arrived => 'வந்துவிட்டோம்';

  @override
  String get sos => 'அவசரம்';

  @override
  String get live => 'நேரடி';

  @override
  String get eta => 'வரவிருக்கும் நேரம்';

  @override
  String get tab_signup => 'பதிவு செய்';

  @override
  String get tab_login => 'உள்நுழை';

  @override
  String get select_market => 'சந்தை இலக்கை தேர்வு செய்யவும்';

  @override
  String start_transit_to(String market) {
    return '$market க்கு போக்குவரத்து தொடங்கு';
  }

  @override
  String get choose_different => 'வேறொன்றை தேர்வு செய்';

  @override
  String get getting_location => 'உங்கள் இருப்பிடத்தை பெறுகிறோம்...';

  @override
  String get you_are_here => 'நீங்கள் இங்கே இருக்கிறீர்கள்';

  @override
  String fresh_pct(String pct) {
    return '$pct% புத்துணர்ச்சி';
  }

  @override
  String get risk_label => 'ஆபத்து';

  @override
  String get weather_start => 'தொடக்கம்';

  @override
  String get weather_dest => 'இலக்கு';

  @override
  String get temperature => 'வெப்பநிலை';

  @override
  String get freshness => 'புத்துணர்ச்சி';

  @override
  String get demand => 'தேவை';

  @override
  String get demand_high => 'அதிகம்';

  @override
  String get demand_medium => 'நடுத்தரம்';

  @override
  String get demand_low => 'குறைவு';

  @override
  String get custom_location => 'தனிப்பயன் இடம்';

  @override
  String get custom_dest => 'தனிப்பயன் இலக்கு';

  @override
  String get dark_mode => 'இருண்ட பயன்முறை';

  @override
  String get wind => 'காற்று';

  @override
  String get humidity => 'ஈரப்பதம்';

  @override
  String get good_morning => 'காலை வணக்கம்';

  @override
  String get good_afternoon => 'மதிய வணக்கம்';

  @override
  String get good_evening => 'மாலை வணக்கம்';

  @override
  String hi_user(String name) {
    return 'வணக்கம், $name 👋';
  }

  @override
  String get active_trips => 'நடப்பு பயணங்கள்';

  @override
  String get revenue => 'வருவாய்';

  @override
  String get available_produce => 'கிடைக்கும் விளைபொருள்';

  @override
  String get view_all => 'அனைத்தும் காண';

  @override
  String get fruits => '🍎 பழங்கள்';

  @override
  String get vegetables => '🥬 காய்கறிகள்';

  @override
  String get new_load_entry => 'புதிய சுமை பதிவு';

  @override
  String get record_harvest => 'போக்குவரத்துக்கான அறுவடை விவரங்களை பதிவு செய்';

  @override
  String get what_transporting => 'என்ன கொண்டு செல்கிறீர்கள்?';

  @override
  String get quantity_label => 'அளவு (மொத்த சுமை)';

  @override
  String get select_produce => 'விளைபொருள் வகையை தேர்வு செய்';

  @override
  String get origin_point => 'தொடக்க புள்ளி';

  @override
  String get timestamp => 'நேர முத்திரை';

  @override
  String get destination => 'இலக்கு';

  @override
  String get start_new_trip => 'புதிய பயணம் தொடங்கு';

  @override
  String get trip_failed =>
      'பயணத்தை தொடங்க முடியவில்லை. சேவையகத்தை சரிபாருங்கள்.';

  @override
  String decay_label(String value) {
    return 'சிதைவு: $value';
  }
}
