import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Redsaldo'**
  String get appTitle;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error'**
  String get unexpectedError;

  /// No description provided for @loginBrand.
  ///
  /// In en, this message translates to:
  /// **'Redsaldo'**
  String get loginBrand;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your Ticket Restaurant weekly allowance.'**
  String get loginSubtitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'LOG IN WITH EDENRED'**
  String get loginButton;

  /// No description provided for @loginSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'We never store your card numbers or login credentials. Your data remains secure.'**
  String get loginSecurityNote;

  /// No description provided for @refreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshTooltip;

  /// No description provided for @logoutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTooltip;

  /// No description provided for @selectedProductFallback.
  ///
  /// In en, this message translates to:
  /// **'Selected product'**
  String get selectedProductFallback;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get availableBalance;

  /// No description provided for @weeklyLimit.
  ///
  /// In en, this message translates to:
  /// **'Weekly limit'**
  String get weeklyLimit;

  /// No description provided for @spentThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Spent this week'**
  String get spentThisWeek;

  /// No description provided for @remainingThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Remaining this week'**
  String get remainingThisWeek;

  /// No description provided for @editWeeklyLimit.
  ///
  /// In en, this message translates to:
  /// **'Edit weekly limit'**
  String get editWeeklyLimit;

  /// No description provided for @changeSelectedProduct.
  ///
  /// In en, this message translates to:
  /// **'Change selected product'**
  String get changeSelectedProduct;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @chooseProduct.
  ///
  /// In en, this message translates to:
  /// **'Choose product'**
  String get chooseProduct;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No Edenred products were returned.'**
  String get noProducts;

  /// No description provided for @ticketLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket {idTicket}'**
  String ticketLabel(int idTicket);

  /// No description provided for @ticketLabelWithStatus.
  ///
  /// In en, this message translates to:
  /// **'Ticket {idTicket} - {status}'**
  String ticketLabelWithStatus(int idTicket, String status);

  /// No description provided for @edenredLogin.
  ///
  /// In en, this message translates to:
  /// **'Edenred login'**
  String get edenredLogin;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @chooseCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a card to track'**
  String get chooseCardTitle;

  /// No description provided for @chooseCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the primary account you want to manage today.'**
  String get chooseCardSubtitle;

  /// No description provided for @selectedBadge.
  ///
  /// In en, this message translates to:
  /// **'SELECTED'**
  String get selectedBadge;

  /// No description provided for @inactiveBadge.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get inactiveBadge;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'LOGOUT'**
  String get logoutButton;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get homeTitle;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @recentSpending.
  ///
  /// In en, this message translates to:
  /// **'Recent spending'**
  String get recentSpending;

  /// No description provided for @showingThisWeekOnly.
  ///
  /// In en, this message translates to:
  /// **'Showing this week\'s transactions only'**
  String get showingThisWeekOnly;

  /// No description provided for @notCounted.
  ///
  /// In en, this message translates to:
  /// **'NOT COUNTED'**
  String get notCounted;

  /// No description provided for @noTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsTitle;

  /// No description provided for @noTransactionsBody.
  ///
  /// In en, this message translates to:
  /// **'Your spending history will appear here.'**
  String get noTransactionsBody;

  /// No description provided for @cardStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get cardStatusActive;

  /// No description provided for @cardStatusIssued.
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get cardStatusIssued;

  /// No description provided for @logoutConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutConfirmationTitle;

  /// No description provided for @logoutConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmationMessage;

  /// No description provided for @logoutConfirmationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutConfirmationConfirm;

  /// No description provided for @syncingAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Syncing your account'**
  String get syncingAccountTitle;

  /// No description provided for @syncingAccountStatus.
  ///
  /// In en, this message translates to:
  /// **'Fetching your balance...'**
  String get syncingAccountStatus;

  /// No description provided for @syncingAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'This should only take a moment. Securely connecting to your meal allowance provider.'**
  String get syncingAccountDescription;

  /// No description provided for @cardBalance.
  ///
  /// In en, this message translates to:
  /// **'CARD BALANCE'**
  String get cardBalance;

  /// No description provided for @changeCardAction.
  ///
  /// In en, this message translates to:
  /// **'Change Card'**
  String get changeCardAction;

  /// No description provided for @editLimitAction.
  ///
  /// In en, this message translates to:
  /// **'Edit Limit'**
  String get editLimitAction;

  /// No description provided for @lastUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdatedLabel;

  /// No description provided for @lastUpdatedToday.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String lastUpdatedToday(String time);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @suggestedLimitText.
  ///
  /// In en, this message translates to:
  /// **'Suggested limit based on 5 working days'**
  String get suggestedLimitText;

  /// No description provided for @spentOfLimitText.
  ///
  /// In en, this message translates to:
  /// **'{spent} EUR spent of {limit} EUR limit'**
  String spentOfLimitText(String spent, String limit);

  /// No description provided for @zeroBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'0.00 EUR'**
  String get zeroBalanceTitle;

  /// No description provided for @zeroBalanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly budget fully utilized. Wait until next week for the reset.'**
  String get zeroBalanceSubtitle;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
