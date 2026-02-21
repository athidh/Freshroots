// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login_title => 'Welcome back!';

  @override
  String get signup_title => 'Create Account';

  @override
  String get email_label => 'Email Address';

  @override
  String get password_label => 'Password';

  @override
  String get username_label => 'Username';

  @override
  String get start_transit => 'Start Transit';

  @override
  String get freshness_score => 'Freshness Score';

  @override
  String get forgot_password => 'Forgot Password?';

  @override
  String get welcome_back => 'Welcome back!';

  @override
  String get sign_in_subtitle => 'Sign in to manage your deliveries';

  @override
  String get create_account_btn => 'Create Account';

  @override
  String get login_btn => 'Login';

  @override
  String get or_continue_with => 'or continue with';

  @override
  String get no_account => 'Don\'t have an account? ';

  @override
  String get have_account => 'Already have an account? ';

  @override
  String get sign_up => 'Sign Up';

  @override
  String get language => 'Language';

  @override
  String get arrived => 'ARRIVED';

  @override
  String get sos => 'SOS';

  @override
  String get live => 'LIVE';

  @override
  String get eta => 'ETA';

  @override
  String get tab_signup => 'Sign Up';

  @override
  String get tab_login => 'Login';

  @override
  String get select_market => 'Select Market Destination';

  @override
  String start_transit_to(String market) {
    return 'START TRANSIT TO $market';
  }

  @override
  String get choose_different => 'Choose Different';

  @override
  String get getting_location => 'Getting your location...';

  @override
  String get you_are_here => 'You are here';

  @override
  String fresh_pct(String pct) {
    return '$pct% fresh';
  }

  @override
  String get risk_label => 'Risk';

  @override
  String get weather_start => 'Start';

  @override
  String get weather_dest => 'Dest';

  @override
  String get temperature => 'Temperature';

  @override
  String get freshness => 'Freshness';

  @override
  String get demand => 'Demand';

  @override
  String get demand_high => 'High';

  @override
  String get demand_medium => 'Medium';

  @override
  String get demand_low => 'Low';

  @override
  String get custom_location => 'Custom Location';

  @override
  String get custom_dest => 'Custom Destination';

  @override
  String get dark_mode => 'Dark Mode';

  @override
  String get wind => 'Wind';

  @override
  String get humidity => 'Humidity';

  @override
  String get good_morning => 'Good Morning';

  @override
  String get good_afternoon => 'Good Afternoon';

  @override
  String get good_evening => 'Good Evening';

  @override
  String hi_user(String name) {
    return 'Hi, $name 👋';
  }

  @override
  String get active_trips => 'Active Trips';

  @override
  String get revenue => 'Revenue';

  @override
  String get available_produce => 'Available Produce';

  @override
  String get view_all => 'View All';

  @override
  String get fruits => '🍎 Fruits';

  @override
  String get vegetables => '🥬 Vegetables';

  @override
  String get new_load_entry => 'New Load Entry';

  @override
  String get record_harvest => 'Record harvest details for transit';

  @override
  String get what_transporting => 'What are you transporting?';

  @override
  String get quantity_label => 'Quantity (Total Load)';

  @override
  String get select_produce => 'Select Produce Type';

  @override
  String get origin_point => 'Origin Point';

  @override
  String get timestamp => 'Timestamp';

  @override
  String get destination => 'Destination';

  @override
  String get start_new_trip => 'START NEW TRIP';

  @override
  String get trip_failed => 'Failed to start trip. Check server.';

  @override
  String decay_label(String value) {
    return 'Decay: $value';
  }
}
