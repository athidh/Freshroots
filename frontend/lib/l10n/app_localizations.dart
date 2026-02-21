import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ml'),
    Locale('ta'),
  ];

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get login_title;

  /// No description provided for @signup_title.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signup_title;

  /// No description provided for @email_label.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email_label;

  /// No description provided for @password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password_label;

  /// No description provided for @username_label.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username_label;

  /// No description provided for @start_transit.
  ///
  /// In en, this message translates to:
  /// **'Start Transit'**
  String get start_transit;

  /// No description provided for @freshness_score.
  ///
  /// In en, this message translates to:
  /// **'Freshness Score'**
  String get freshness_score;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgot_password;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcome_back;

  /// No description provided for @sign_in_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your deliveries'**
  String get sign_in_subtitle;

  /// No description provided for @create_account_btn.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get create_account_btn;

  /// No description provided for @login_btn.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_btn;

  /// No description provided for @or_continue_with.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get or_continue_with;

  /// No description provided for @no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get no_account;

  /// No description provided for @have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get have_account;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arrived.
  ///
  /// In en, this message translates to:
  /// **'ARRIVED'**
  String get arrived;

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @eta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get eta;

  /// No description provided for @tab_signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get tab_signup;

  /// No description provided for @tab_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get tab_login;

  /// No description provided for @select_market.
  ///
  /// In en, this message translates to:
  /// **'Select Market Destination'**
  String get select_market;

  /// No description provided for @start_transit_to.
  ///
  /// In en, this message translates to:
  /// **'START TRANSIT TO {market}'**
  String start_transit_to(String market);

  /// No description provided for @choose_different.
  ///
  /// In en, this message translates to:
  /// **'Choose Different'**
  String get choose_different;

  /// No description provided for @getting_location.
  ///
  /// In en, this message translates to:
  /// **'Getting your location...'**
  String get getting_location;

  /// No description provided for @you_are_here.
  ///
  /// In en, this message translates to:
  /// **'You are here'**
  String get you_are_here;

  /// No description provided for @fresh_pct.
  ///
  /// In en, this message translates to:
  /// **'{pct}% fresh'**
  String fresh_pct(String pct);

  /// No description provided for @risk_label.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get risk_label;

  /// No description provided for @weather_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get weather_start;

  /// No description provided for @weather_dest.
  ///
  /// In en, this message translates to:
  /// **'Dest'**
  String get weather_dest;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @freshness.
  ///
  /// In en, this message translates to:
  /// **'Freshness'**
  String get freshness;

  /// No description provided for @demand.
  ///
  /// In en, this message translates to:
  /// **'Demand'**
  String get demand;

  /// No description provided for @demand_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get demand_high;

  /// No description provided for @demand_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get demand_medium;

  /// No description provided for @demand_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get demand_low;

  /// No description provided for @custom_location.
  ///
  /// In en, this message translates to:
  /// **'Custom Location'**
  String get custom_location;

  /// No description provided for @custom_dest.
  ///
  /// In en, this message translates to:
  /// **'Custom Destination'**
  String get custom_dest;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_mode;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @good_morning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get good_morning;

  /// No description provided for @good_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get good_afternoon;

  /// No description provided for @good_evening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get good_evening;

  /// No description provided for @hi_user.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name} 👋'**
  String hi_user(String name);

  /// No description provided for @active_trips.
  ///
  /// In en, this message translates to:
  /// **'Active Trips'**
  String get active_trips;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @available_produce.
  ///
  /// In en, this message translates to:
  /// **'Available Produce'**
  String get available_produce;

  /// No description provided for @view_all.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get view_all;

  /// No description provided for @fruits.
  ///
  /// In en, this message translates to:
  /// **'🍎 Fruits'**
  String get fruits;

  /// No description provided for @vegetables.
  ///
  /// In en, this message translates to:
  /// **'🥬 Vegetables'**
  String get vegetables;

  /// No description provided for @new_load_entry.
  ///
  /// In en, this message translates to:
  /// **'New Load Entry'**
  String get new_load_entry;

  /// No description provided for @record_harvest.
  ///
  /// In en, this message translates to:
  /// **'Record harvest details for transit'**
  String get record_harvest;

  /// No description provided for @what_transporting.
  ///
  /// In en, this message translates to:
  /// **'What are you transporting?'**
  String get what_transporting;

  /// No description provided for @quantity_label.
  ///
  /// In en, this message translates to:
  /// **'Quantity (Total Load)'**
  String get quantity_label;

  /// No description provided for @select_produce.
  ///
  /// In en, this message translates to:
  /// **'Select Produce Type'**
  String get select_produce;

  /// No description provided for @origin_point.
  ///
  /// In en, this message translates to:
  /// **'Origin Point'**
  String get origin_point;

  /// No description provided for @timestamp.
  ///
  /// In en, this message translates to:
  /// **'Timestamp'**
  String get timestamp;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @start_new_trip.
  ///
  /// In en, this message translates to:
  /// **'START NEW TRIP'**
  String get start_new_trip;

  /// No description provided for @trip_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start trip. Check server.'**
  String get trip_failed;

  /// No description provided for @decay_label.
  ///
  /// In en, this message translates to:
  /// **'Decay: {value}'**
  String decay_label(String value);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ml', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ml':
      return AppLocalizationsMl();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
