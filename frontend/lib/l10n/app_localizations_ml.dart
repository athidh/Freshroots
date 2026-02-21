// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get login_title => 'തിരികെ സ്വാഗതം!';

  @override
  String get signup_title => 'അക്കൗണ്ട് സൃഷ്ടിക്കുക';

  @override
  String get email_label => 'ഇമെയിൽ വിലാസം';

  @override
  String get password_label => 'പാസ്‌വേർഡ്';

  @override
  String get username_label => 'ഉപയോക്തൃനാമം';

  @override
  String get start_transit => 'ട്രാൻസിറ്റ് ആരംഭിക്കുക';

  @override
  String get freshness_score => 'പുതുമ സ്‌കോർ';

  @override
  String get forgot_password => 'പാസ്‌വേർഡ് മറന്നോ?';

  @override
  String get welcome_back => 'തിരികെ സ്വാഗതം!';

  @override
  String get sign_in_subtitle =>
      'നിങ്ങളുടെ ഡെലിവറികൾ നിയന്ത്രിക്കാൻ സൈൻ ഇൻ ചെയ്യുക';

  @override
  String get create_account_btn => 'അക്കൗണ്ട് സൃഷ്ടിക്കുക';

  @override
  String get login_btn => 'ലോഗിൻ';

  @override
  String get or_continue_with => 'അല്ലെങ്കിൽ ഇതുപയോഗിച്ച് തുടരുക';

  @override
  String get no_account => 'അക്കൗണ്ട് ഇല്ലേ? ';

  @override
  String get have_account => 'ഇതിനകം അക്കൗണ്ട് ഉണ്ടോ? ';

  @override
  String get sign_up => 'സൈൻ അപ്പ്';

  @override
  String get language => 'ഭാഷ';

  @override
  String get arrived => 'എത്തിച്ചേർന്നു';

  @override
  String get sos => 'അടിയന്തിരം';

  @override
  String get live => 'തത്സമയം';

  @override
  String get eta => 'എത്തുന്ന സമയം';

  @override
  String get tab_signup => 'സൈൻ അപ്പ്';

  @override
  String get tab_login => 'ലോഗിൻ';

  @override
  String get select_market => 'മാർക്കറ്റ് ലക്ഷ്യസ്ഥാനം തിരഞ്ഞെടുക്കുക';

  @override
  String start_transit_to(String market) {
    return '$market ലേക്ക് ട്രാൻസിറ്റ് ആരംഭിക്കുക';
  }

  @override
  String get choose_different => 'മറ്റൊന്ന് തിരഞ്ഞെടുക്കുക';

  @override
  String get getting_location => 'നിങ്ങളുടെ ലൊക്കേഷൻ കണ്ടെത്തുന്നു...';

  @override
  String get you_are_here => 'നിങ്ങൾ ഇവിടെയാണ്';

  @override
  String fresh_pct(String pct) {
    return '$pct% പുതുമ';
  }

  @override
  String get risk_label => 'അപകടസാധ്യത';

  @override
  String get weather_start => 'തുടക്കം';

  @override
  String get weather_dest => 'ലക്ഷ്യം';

  @override
  String get temperature => 'താപനില';

  @override
  String get freshness => 'പുതുമ';

  @override
  String get demand => 'ആവശ്യകത';

  @override
  String get demand_high => 'ഉയർന്നത്';

  @override
  String get demand_medium => 'മധ്യമം';

  @override
  String get demand_low => 'കുറവ്';

  @override
  String get custom_location => 'ഇഷ്ടാനുസൃത സ്ഥലം';

  @override
  String get custom_dest => 'ഇഷ്ടാനുസൃത ലക്ഷ്യം';

  @override
  String get dark_mode => 'ഇരുണ്ട മോഡ്';

  @override
  String get wind => 'കാറ്റ്';

  @override
  String get humidity => 'ഈർപ്പം';

  @override
  String get good_morning => 'സുപ്രഭാതം';

  @override
  String get good_afternoon => 'ഉച്ചയ്ക്ക് ശേഷം നമസ്കാരം';

  @override
  String get good_evening => 'ശുഭ സന്ധ്യ';

  @override
  String hi_user(String name) {
    return 'ഹായ്, $name 👋';
  }

  @override
  String get active_trips => 'സജീവ യാത്രകൾ';

  @override
  String get revenue => 'വരുമാനം';

  @override
  String get available_produce => 'ലഭ്യമായ ഉൽപ്പന്നങ്ങൾ';

  @override
  String get view_all => 'എല്ലാം കാണുക';

  @override
  String get fruits => '🍎 പഴങ്ങൾ';

  @override
  String get vegetables => '🥬 പച്ചക്കറികൾ';

  @override
  String get new_load_entry => 'പുതിയ ലോഡ് എൻട്രി';

  @override
  String get record_harvest =>
      'ട്രാൻസിറ്റിനായി വിളവെടുപ്പ് വിശദാംശങ്ങൾ രേഖപ്പെടുത്തുക';

  @override
  String get what_transporting => 'നിങ്ങൾ എന്താണ് കൊണ്ടുപോകുന്നത്?';

  @override
  String get quantity_label => 'അളവ് (ആകെ ലോഡ്)';

  @override
  String get select_produce => 'ഉൽപ്പന്ന തരം തിരഞ്ഞെടുക്കുക';

  @override
  String get origin_point => 'ആരംഭ സ്ഥലം';

  @override
  String get timestamp => 'സമയ മുദ്ര';

  @override
  String get destination => 'ലക്ഷ്യസ്ഥാനം';

  @override
  String get start_new_trip => 'പുതിയ യാത്ര ആരംഭിക്കുക';

  @override
  String get trip_failed => 'യാത്ര ആരംഭിക്കാൻ കഴിഞ്ഞില്ല. സെർവർ പരിശോധിക്കുക.';

  @override
  String decay_label(String value) {
    return 'ദ്രവിക്കൽ: $value';
  }
}
