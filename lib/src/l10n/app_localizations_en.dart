// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Redsaldo';

  @override
  String get unexpectedError => 'Unexpected error';

  @override
  String get loginBrand => 'Redsaldo';

  @override
  String get loginSubtitle => 'Track your Ticket Restaurant weekly allowance.';

  @override
  String get loginButton => 'LOG IN WITH EDENRED';

  @override
  String get loginSecurityNote =>
      'We never store your card numbers or login credentials. Your data remains secure.';

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get logoutTooltip => 'Logout';

  @override
  String get selectedProductFallback => 'Selected product';

  @override
  String get availableBalance => 'Available balance';

  @override
  String get weeklyLimit => 'Weekly limit';

  @override
  String get spentThisWeek => 'Spent this week';

  @override
  String get remainingThisWeek => 'Remaining this week';

  @override
  String get editWeeklyLimit => 'Edit weekly limit';

  @override
  String get changeSelectedProduct => 'Change selected product';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get saveAction => 'Save';

  @override
  String get chooseProduct => 'Choose product';

  @override
  String get noProducts => 'No Edenred products were returned.';

  @override
  String ticketLabel(int idTicket) {
    return 'Ticket $idTicket';
  }

  @override
  String ticketLabelWithStatus(int idTicket, String status) {
    return 'Ticket $idTicket - $status';
  }

  @override
  String get edenredLogin => 'Edenred login';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get chooseCardTitle => 'Choose a card to track';

  @override
  String get chooseCardSubtitle =>
      'Select the primary account you want to manage today.';

  @override
  String get selectedBadge => 'SELECTED';

  @override
  String get inactiveBadge => 'INACTIVE';

  @override
  String get logoutButton => 'LOGOUT';
}
