import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('te')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'EZMoov Partner'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @youAreOnline.
  ///
  /// In en, this message translates to:
  /// **'You are Online'**
  String get youAreOnline;

  /// No description provided for @youAreOffline.
  ///
  /// In en, this message translates to:
  /// **'You are Offline'**
  String get youAreOffline;

  /// No description provided for @readyToAcceptRides.
  ///
  /// In en, this message translates to:
  /// **'Ready to accept nearby ride bookings'**
  String get readyToAcceptRides;

  /// No description provided for @goOnlineToReceiveBookings.
  ///
  /// In en, this message translates to:
  /// **'Go online to start receiving ride bookings'**
  String get goOnlineToReceiveBookings;

  /// No description provided for @todaysEarnings.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Earnings'**
  String get todaysEarnings;

  /// No description provided for @completedTrips.
  ///
  /// In en, this message translates to:
  /// **'Completed Trips'**
  String get completedTrips;

  /// No description provided for @acceptRide.
  ///
  /// In en, this message translates to:
  /// **'Accept Ride'**
  String get acceptRide;

  /// No description provided for @declineRide.
  ///
  /// In en, this message translates to:
  /// **'Decline Ride'**
  String get declineRide;

  /// No description provided for @incomingRideRequest.
  ///
  /// In en, this message translates to:
  /// **'Incoming Ride Request'**
  String get incomingRideRequest;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickupLocation;

  /// No description provided for @dropoffLocation.
  ///
  /// In en, this message translates to:
  /// **'Dropoff Location'**
  String get dropoffLocation;

  /// No description provided for @vehicleAndEquipment.
  ///
  /// In en, this message translates to:
  /// **'Vehicle & Equipment'**
  String get vehicleAndEquipment;

  /// No description provided for @vehicleRegistration.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Registration'**
  String get vehicleRegistration;

  /// No description provided for @vehicleDetailsVerified.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details Verified'**
  String get vehicleDetailsVerified;

  /// No description provided for @driverCertificates.
  ///
  /// In en, this message translates to:
  /// **'Driver Certificates'**
  String get driverCertificates;

  /// No description provided for @certificatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PUC, Permit, Fitness, Police Clearance (Verified)'**
  String get certificatesSubtitle;

  /// No description provided for @payoutsAndBanking.
  ///
  /// In en, this message translates to:
  /// **'Payouts & Banking'**
  String get payoutsAndBanking;

  /// No description provided for @bankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank Account'**
  String get bankAccount;

  /// No description provided for @bankDetailsVerified.
  ///
  /// In en, this message translates to:
  /// **'Bank Details Verified'**
  String get bankDetailsVerified;

  /// No description provided for @supportAndPreferences.
  ///
  /// In en, this message translates to:
  /// **'Support & Preferences'**
  String get supportAndPreferences;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @currentLanguageName.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get currentLanguageName;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select App Language'**
  String get selectLanguage;

  /// No description provided for @helpAndSupportDesk.
  ///
  /// In en, this message translates to:
  /// **'Help & Support Desk'**
  String get helpAndSupportDesk;

  /// No description provided for @supportDeskSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FAQs, Account Assistance & 24/7 Driver Support'**
  String get supportDeskSubtitle;

  /// No description provided for @logOutOfAccount.
  ///
  /// In en, this message translates to:
  /// **'Log Out of Account'**
  String get logOutOfAccount;

  /// No description provided for @confirmLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogoutTitle;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your partner account?'**
  String get confirmLogoutMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @howCanWeHelpYou.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get howCanWeHelpYou;

  /// No description provided for @getInTouchHelp.
  ///
  /// In en, this message translates to:
  /// **'Please get in touch and we will be happy to help you.'**
  String get getInTouchHelp;

  /// No description provided for @updateAccountDetails.
  ///
  /// In en, this message translates to:
  /// **'Update my account details'**
  String get updateAccountDetails;

  /// No description provided for @updateAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check & update account related info'**
  String get updateAccountSubtitle;

  /// No description provided for @knowMorePricing.
  ///
  /// In en, this message translates to:
  /// **'Know more about the pricing'**
  String get knowMorePricing;

  /// No description provided for @pricingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get details about fare, invoices, etc'**
  String get pricingSubtitle;

  /// No description provided for @learnMoreWallet.
  ///
  /// In en, this message translates to:
  /// **'Learn more about my wallet'**
  String get learnMoreWallet;

  /// No description provided for @walletSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get wallet & payment mode related info'**
  String get walletSubtitle;

  /// No description provided for @learnEzmoovServices.
  ///
  /// In en, this message translates to:
  /// **'Learn about EZMoov services'**
  String get learnEzmoovServices;

  /// No description provided for @servicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Understand services offered by EZMoov'**
  String get servicesSubtitle;

  /// No description provided for @understandSafety.
  ///
  /// In en, this message translates to:
  /// **'Understand safety procedures'**
  String get understandSafety;

  /// No description provided for @safetySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Know more about safety & insurance'**
  String get safetySubtitle;

  /// No description provided for @callSupportHotline.
  ///
  /// In en, this message translates to:
  /// **'Call 24/7 Driver Support Hotline'**
  String get callSupportHotline;

  /// No description provided for @speakToAgent.
  ///
  /// In en, this message translates to:
  /// **'Speak to Support Agent'**
  String get speakToAgent;

  /// No description provided for @noActiveBookings.
  ///
  /// In en, this message translates to:
  /// **'No active bookings right now.'**
  String get noActiveBookings;

  /// No description provided for @stayOnlineAlerts.
  ///
  /// In en, this message translates to:
  /// **'Stay online to receive instant notification alerts for nearby ride requests.'**
  String get stayOnlineAlerts;

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// No description provided for @tripHistory.
  ///
  /// In en, this message translates to:
  /// **'Trip History'**
  String get tripHistory;

  /// No description provided for @recentTrips.
  ///
  /// In en, this message translates to:
  /// **'Recent Trips'**
  String get recentTrips;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @partnerDriver.
  ///
  /// In en, this message translates to:
  /// **'Partner Driver'**
  String get partnerDriver;

  /// No description provided for @youAreOnlineCaps.
  ///
  /// In en, this message translates to:
  /// **'YOU ARE ONLINE'**
  String get youAreOnlineCaps;

  /// No description provided for @youAreOfflineCaps.
  ///
  /// In en, this message translates to:
  /// **'YOU ARE OFFLINE'**
  String get youAreOfflineCaps;

  /// No description provided for @readyToReceiveRideRequests.
  ///
  /// In en, this message translates to:
  /// **'Ready to receive ride requests'**
  String get readyToReceiveRideRequests;

  /// No description provided for @switchOnlineToStartEarning.
  ///
  /// In en, this message translates to:
  /// **'Switch online to start earning'**
  String get switchOnlineToStartEarning;

  /// No description provided for @gpsTrackingActive.
  ///
  /// In en, this message translates to:
  /// **'GPS Tracking Active • Updating every 30s'**
  String get gpsTrackingActive;

  /// No description provided for @todayTrips.
  ///
  /// In en, this message translates to:
  /// **'Today Trips'**
  String get todayTrips;

  /// No description provided for @tripsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Trips'**
  String tripsCount(Object count);

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @todaysRecentTrips.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Recent Trips'**
  String get todaysRecentTrips;

  /// No description provided for @recentCompletedTrips.
  ///
  /// In en, this message translates to:
  /// **'Recent Completed Trips'**
  String get recentCompletedTrips;

  /// No description provided for @completedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Completed'**
  String completedCount(Object count);

  /// No description provided for @noCompletedTripsYet.
  ///
  /// In en, this message translates to:
  /// **'No completed trips yet'**
  String get noCompletedTripsYet;

  /// No description provided for @switchOnlineToAcceptRides.
  ///
  /// In en, this message translates to:
  /// **'Switch online to start accepting rides!'**
  String get switchOnlineToAcceptRides;

  /// No description provided for @tripNumber.
  ///
  /// In en, this message translates to:
  /// **'TRIP #{id}'**
  String tripNumber(Object id);

  /// No description provided for @earningsAndPayouts.
  ///
  /// In en, this message translates to:
  /// **'Earnings & Payouts'**
  String get earningsAndPayouts;

  /// No description provided for @instantBankPayout.
  ///
  /// In en, this message translates to:
  /// **'INSTANT BANK PAYOUT'**
  String get instantBankPayout;

  /// No description provided for @transferEarningsDirectly.
  ///
  /// In en, this message translates to:
  /// **'Transfer earnings directly to your bank account'**
  String get transferEarningsDirectly;

  /// No description provided for @availablePayoutBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Payout Balance'**
  String get availablePayoutBalance;

  /// No description provided for @connectedBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Connected Bank Account'**
  String get connectedBankAccount;

  /// No description provided for @primaryPayoutMethod.
  ///
  /// In en, this message translates to:
  /// **'Primary Payout Method'**
  String get primaryPayoutMethod;

  /// No description provided for @confirmPayoutTransfer.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PAYOUT TRANSFER'**
  String get confirmPayoutTransfer;

  /// No description provided for @noBalanceToWithdraw.
  ///
  /// In en, this message translates to:
  /// **'NO BALANCE TO WITHDRAW'**
  String get noBalanceToWithdraw;

  /// No description provided for @payoutTransferredSuccess.
  ///
  /// In en, this message translates to:
  /// **'🎉 Instant payout of ₹ {amount} transferred to your bank account!'**
  String payoutTransferredSuccess(Object amount);

  /// No description provided for @payoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Payout transfer failed. Please try again.'**
  String get payoutFailed;

  /// No description provided for @todayFilter.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayFilter;

  /// No description provided for @thisWeekFilter.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeekFilter;

  /// No description provided for @allTimeFilter.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTimeFilter;

  /// No description provided for @totalEarningsFilter.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings ({filter})'**
  String totalEarningsFilter(Object filter);

  /// No description provided for @completedTripsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} Completed {count, plural, =1{Trip} other{Trips}}'**
  String completedTripsSummary(num count);

  /// No description provided for @tripsFare85.
  ///
  /// In en, this message translates to:
  /// **'Trips Fare (85%)'**
  String get tripsFare85;

  /// No description provided for @surgeAndIncentives.
  ///
  /// In en, this message translates to:
  /// **'Surge & Incentives'**
  String get surgeAndIncentives;

  /// No description provided for @payoutBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Payout Bank Account'**
  String get payoutBankAccount;

  /// No description provided for @bankAccountLinked.
  ///
  /// In en, this message translates to:
  /// **'Bank Account Linked'**
  String get bankAccountLinked;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @availableForPayout.
  ///
  /// In en, this message translates to:
  /// **'Available for Payout:'**
  String get availableForPayout;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'WITHDRAW'**
  String get withdraw;

  /// No description provided for @completedTripPayouts.
  ///
  /// In en, this message translates to:
  /// **'Completed Trip Payouts'**
  String get completedTripPayouts;

  /// No description provided for @totalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Total'**
  String totalCount(Object count);

  /// No description provided for @noCompletedPayoutsYet.
  ///
  /// In en, this message translates to:
  /// **'No Completed Trip Payouts Yet'**
  String get noCompletedPayoutsYet;

  /// No description provided for @acceptDeliveriesToEarn.
  ///
  /// In en, this message translates to:
  /// **'Accept and complete delivery orders to earn and see your payouts here.'**
  String get acceptDeliveriesToEarn;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @partnerNotifications.
  ///
  /// In en, this message translates to:
  /// **'Partner Notifications'**
  String get partnerNotifications;

  /// No description provided for @alertsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{Alert} other{Alerts}}'**
  String alertsCount(num count);

  /// No description provided for @noNewNotifications.
  ///
  /// In en, this message translates to:
  /// **'No New Notifications'**
  String get noNewNotifications;

  /// No description provided for @caughtUpMessage.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up! High demand alerts and account updates will appear here.'**
  String get caughtUpMessage;

  /// No description provided for @accountFullyVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'✅ Account Fully Verified'**
  String get accountFullyVerifiedTitle;

  /// No description provided for @accountFullyVerifiedMsg.
  ///
  /// In en, this message translates to:
  /// **'Your driver profile, vehicle documents, and bank details are active.'**
  String get accountFullyVerifiedMsg;

  /// No description provided for @verificationInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'⏳ Verification In Progress'**
  String get verificationInProgressTitle;

  /// No description provided for @verificationInProgressMsg.
  ///
  /// In en, this message translates to:
  /// **'Your driver documentation is under admin review.'**
  String get verificationInProgressMsg;
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
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

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
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
