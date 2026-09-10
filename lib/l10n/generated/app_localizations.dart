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
  /// **'PICKUP LOCATION'**
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

  /// No description provided for @vehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get vehicleDetails;

  /// No description provided for @vehicleOwnerName.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Owner Name (Optional)'**
  String get vehicleOwnerName;

  /// No description provided for @vehicleOwnerHint.
  ///
  /// In en, this message translates to:
  /// **'Enter owner name if vehicle is registered to someone else'**
  String get vehicleOwnerHint;

  /// No description provided for @uploadRcPicture.
  ///
  /// In en, this message translates to:
  /// **'Upload RC Picture *'**
  String get uploadRcPicture;

  /// No description provided for @vehicleRcPhoto.
  ///
  /// In en, this message translates to:
  /// **'Vehicle RC Photo'**
  String get vehicleRcPhoto;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @tapToAttachRc.
  ///
  /// In en, this message translates to:
  /// **'Tap to attach clear photo of RC'**
  String get tapToAttachRc;

  /// No description provided for @selectCityOfOperation.
  ///
  /// In en, this message translates to:
  /// **'Select the city of operation'**
  String get selectCityOfOperation;

  /// No description provided for @selectVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle Type'**
  String get selectVehicleType;

  /// No description provided for @selectVehicleBodyDetails.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle Body Details'**
  String get selectVehicleBodyDetails;

  /// No description provided for @selectVehicleBodyType.
  ///
  /// In en, this message translates to:
  /// **'Select the vehicle body type'**
  String get selectVehicleBodyType;

  /// No description provided for @openBody.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openBody;

  /// No description provided for @closedBody.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closedBody;

  /// No description provided for @selectVehicleFuelType.
  ///
  /// In en, this message translates to:
  /// **'Select the vehicle fuel type'**
  String get selectVehicleFuelType;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveAndContinue;

  /// No description provided for @partnerPayoutBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Partner Payout Bank Account'**
  String get partnerPayoutBankAccount;

  /// No description provided for @addBankAccountDetails.
  ///
  /// In en, this message translates to:
  /// **'Add your bank account details.'**
  String get addBankAccountDetails;

  /// No description provided for @accountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name *'**
  String get accountHolderName;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name *'**
  String get bankName;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number *'**
  String get accountNumber;

  /// No description provided for @ifscCode.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code *'**
  String get ifscCode;

  /// No description provided for @upiIdOptional.
  ///
  /// In en, this message translates to:
  /// **'UPI ID (Optional)'**
  String get upiIdOptional;

  /// No description provided for @uploadPassbook.
  ///
  /// In en, this message translates to:
  /// **'Upload Passbook / Cancelled Cheque (Optional)'**
  String get uploadPassbook;

  /// No description provided for @passbookPhoto.
  ///
  /// In en, this message translates to:
  /// **'Passbook / Cheque Photo'**
  String get passbookPhoto;

  /// No description provided for @tapToAttachPassbook.
  ///
  /// In en, this message translates to:
  /// **'Tap to attach clear photo of passbook/cheque'**
  String get tapToAttachPassbook;

  /// No description provided for @submitBankDetails.
  ///
  /// In en, this message translates to:
  /// **'Submit Bank Details'**
  String get submitBankDetails;

  /// No description provided for @loginDescription.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Enter your registered mobile number to continue.'**
  String get loginDescription;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @driverRegistration.
  ///
  /// In en, this message translates to:
  /// **'Driver Registration'**
  String get driverRegistration;

  /// No description provided for @joinEzmoovFleet.
  ///
  /// In en, this message translates to:
  /// **'Join EZMoov Fleet'**
  String get joinEzmoovFleet;

  /// No description provided for @createYourPartnerProfile.
  ///
  /// In en, this message translates to:
  /// **'Create your partner profile to start taking trips.'**
  String get createYourPartnerProfile;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @referralCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Referral Code (Optional)'**
  String get referralCodeOptional;

  /// No description provided for @signUpAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign Up & Continue'**
  String get signUpAndContinue;

  /// No description provided for @iAgreeTo.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get iAgreeTo;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @driverPartnerAgreement.
  ///
  /// In en, this message translates to:
  /// **'Driver Partner Agreement'**
  String get driverPartnerAgreement;

  /// No description provided for @platformTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Platform Terms of Use'**
  String get platformTermsOfUse;

  /// No description provided for @acceptTermsToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms & Conditions to continue.'**
  String get acceptTermsToContinue;

  /// No description provided for @partnerTermsAndConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get partnerTermsAndConditionsTitle;

  /// No description provided for @partnerAgreement.
  ///
  /// In en, this message translates to:
  /// **'EZMoov Partner Agreement'**
  String get partnerAgreement;

  /// No description provided for @acceptAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Accept & Continue'**
  String get acceptAndContinue;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Accept Terms'**
  String get acceptTerms;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @pleaseReadAndAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Please review and accept our Partner Terms & Conditions to complete your registration.'**
  String get pleaseReadAndAcceptTerms;

  /// No description provided for @termsSection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Driver Partner Agreement'**
  String get termsSection1Title;

  /// No description provided for @termsSection1Desc.
  ///
  /// In en, this message translates to:
  /// **'By registering, you agree to provide transportation services safely and professionally according to EZMoov standards.'**
  String get termsSection1Desc;

  /// No description provided for @termsSection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Documents & Verification'**
  String get termsSection2Title;

  /// No description provided for @termsSection2Desc.
  ///
  /// In en, this message translates to:
  /// **'You agree to provide valid driver\'s license, vehicle registration, and permits. False information may lead to account termination.'**
  String get termsSection2Desc;

  /// No description provided for @termsSection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Fares & Platform Payments'**
  String get termsSection3Title;

  /// No description provided for @termsSection3Desc.
  ///
  /// In en, this message translates to:
  /// **'Payouts and service fees follow the EZMoov platform policy. Earnings will be credited to your verified bank account.'**
  String get termsSection3Desc;

  /// No description provided for @termsSection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Safety & Conduct'**
  String get termsSection4Title;

  /// No description provided for @termsSection4Desc.
  ///
  /// In en, this message translates to:
  /// **'Drivers must follow all traffic regulations, maintain vehicle fitness, and treat customers with respect.'**
  String get termsSection4Desc;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have a partner account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @otpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterVerificationCode;

  /// No description provided for @weHaveSentOtpTo.
  ///
  /// In en, this message translates to:
  /// **'We have sent a 6-digit OTP code to '**
  String get weHaveSentOtpTo;

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get verifyAndContinue;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive code? '**
  String get didntReceiveCode;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @fullOperationalAddress.
  ///
  /// In en, this message translates to:
  /// **'Full Operational Address *'**
  String get fullOperationalAddress;

  /// No description provided for @tcRcPermitNumber.
  ///
  /// In en, this message translates to:
  /// **'TC / RC Permit Number *'**
  String get tcRcPermitNumber;

  /// No description provided for @truck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get truck;

  /// No description provided for @threeWheeler.
  ///
  /// In en, this message translates to:
  /// **'3W'**
  String get threeWheeler;

  /// No description provided for @vehiclePermit.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Permit'**
  String get vehiclePermit;

  /// No description provided for @uploadVehiclePermit.
  ///
  /// In en, this message translates to:
  /// **'Upload Vehicle Permit'**
  String get uploadVehiclePermit;

  /// No description provided for @documentVerification.
  ///
  /// In en, this message translates to:
  /// **'Document Verification'**
  String get documentVerification;

  /// No description provided for @uploadRequiredDocumentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload required documentation for verification'**
  String get uploadRequiredDocumentsSubtitle;

  /// No description provided for @aadhaarCard.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar Card'**
  String get aadhaarCard;

  /// No description provided for @uploadAadhaarCard.
  ///
  /// In en, this message translates to:
  /// **'Upload Aadhaar Card'**
  String get uploadAadhaarCard;

  /// No description provided for @drivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driving License'**
  String get drivingLicense;

  /// No description provided for @uploadDrivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Upload Driving License'**
  String get uploadDrivingLicense;

  /// No description provided for @vehicleRc.
  ///
  /// In en, this message translates to:
  /// **'Vehicle RC'**
  String get vehicleRc;

  /// No description provided for @uploadVehicleRc.
  ///
  /// In en, this message translates to:
  /// **'Upload Vehicle RC'**
  String get uploadVehicleRc;

  /// No description provided for @panCard.
  ///
  /// In en, this message translates to:
  /// **'PAN Card'**
  String get panCard;

  /// No description provided for @uploadPanCard.
  ///
  /// In en, this message translates to:
  /// **'Upload PAN Card'**
  String get uploadPanCard;

  /// No description provided for @vehicleInsurance.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Insurance'**
  String get vehicleInsurance;

  /// No description provided for @uploadVehicleInsurance.
  ///
  /// In en, this message translates to:
  /// **'Upload Vehicle Insurance'**
  String get uploadVehicleInsurance;

  /// No description provided for @pucCertificate.
  ///
  /// In en, this message translates to:
  /// **'PUC Certificate'**
  String get pucCertificate;

  /// No description provided for @uploadPucCertificate.
  ///
  /// In en, this message translates to:
  /// **'Upload PUC Certificate'**
  String get uploadPucCertificate;

  /// No description provided for @fitnessCertificate.
  ///
  /// In en, this message translates to:
  /// **'Fitness Certificate'**
  String get fitnessCertificate;

  /// No description provided for @uploadFitnessCertificate.
  ///
  /// In en, this message translates to:
  /// **'Upload Fitness Certificate'**
  String get uploadFitnessCertificate;

  /// No description provided for @policeClearanceCertificate.
  ///
  /// In en, this message translates to:
  /// **'Police Clearance Certificate'**
  String get policeClearanceCertificate;

  /// No description provided for @uploadPoliceClearance.
  ///
  /// In en, this message translates to:
  /// **'Upload Police Clearance Certificate'**
  String get uploadPoliceClearance;

  /// No description provided for @selfieWithVehicle.
  ///
  /// In en, this message translates to:
  /// **'Selfie with Vehicle'**
  String get selfieWithVehicle;

  /// No description provided for @uploadSelfieWithVehicle.
  ///
  /// In en, this message translates to:
  /// **'Upload Selfie with Vehicle'**
  String get uploadSelfieWithVehicle;

  /// No description provided for @autoVerifiedDigilocker.
  ///
  /// In en, this message translates to:
  /// **'Auto-Verified via DigiLocker API'**
  String get autoVerifiedDigilocker;

  /// No description provided for @autoVerifiedApi.
  ///
  /// In en, this message translates to:
  /// **'Auto-Verified via API'**
  String get autoVerifiedApi;

  /// No description provided for @autoVerifiedVahan.
  ///
  /// In en, this message translates to:
  /// **'Auto-Verified via Vahan API'**
  String get autoVerifiedVahan;

  /// No description provided for @certificateUpload.
  ///
  /// In en, this message translates to:
  /// **'Certificate Upload'**
  String get certificateUpload;

  /// No description provided for @officialCitizenPortal.
  ///
  /// In en, this message translates to:
  /// **'Official state citizen portal'**
  String get officialCitizenPortal;

  /// No description provided for @selfieWithVehicleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear photo of driver standing with vehicle'**
  String get selfieWithVehicleSubtitle;

  /// No description provided for @submitDocuments.
  ///
  /// In en, this message translates to:
  /// **'Submit Documents'**
  String get submitDocuments;

  /// No description provided for @attached.
  ///
  /// In en, this message translates to:
  /// **'Attached'**
  String get attached;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @changeDocument.
  ///
  /// In en, this message translates to:
  /// **'Change Document'**
  String get changeDocument;

  /// No description provided for @takePhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Take Photo with Camera'**
  String get takePhotoCamera;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @accountVerification.
  ///
  /// In en, this message translates to:
  /// **'Account Verification'**
  String get accountVerification;

  /// No description provided for @verificationUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Verification Under Review'**
  String get verificationUnderReview;

  /// No description provided for @verificationUnderReviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle and document submissions have been received. Access to the driver home dashboard will be unlocked once approved by our verification team.'**
  String get verificationUnderReviewDesc;

  /// No description provided for @mobilePhoneAndIdentity.
  ///
  /// In en, this message translates to:
  /// **'Mobile Phone & Identity'**
  String get mobilePhoneAndIdentity;

  /// No description provided for @phoneOtpVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone OTP Verified'**
  String get phoneOtpVerified;

  /// No description provided for @vehicleRegistrationAndRc.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Registration & RC'**
  String get vehicleRegistrationAndRc;

  /// No description provided for @vehicleVerifiedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Verified by Admin'**
  String get vehicleVerifiedByAdmin;

  /// No description provided for @rcSubmittedReviewing.
  ///
  /// In en, this message translates to:
  /// **'RC Photo Submitted - Reviewing'**
  String get rcSubmittedReviewing;

  /// No description provided for @certificatesVerifiedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Certificates Verified by Admin'**
  String get certificatesVerifiedByAdmin;

  /// No description provided for @certificatesSubmittedReviewing.
  ///
  /// In en, this message translates to:
  /// **'PUC, Permit, Fitness, PCC Submitted - Reviewing'**
  String get certificatesSubmittedReviewing;

  /// No description provided for @bankAccountPayouts.
  ///
  /// In en, this message translates to:
  /// **'Bank Account Payouts'**
  String get bankAccountPayouts;

  /// No description provided for @bankAccountVerified.
  ///
  /// In en, this message translates to:
  /// **'Bank Account Verified'**
  String get bankAccountVerified;

  /// No description provided for @bankDetailsSubmittedReviewing.
  ///
  /// In en, this message translates to:
  /// **'Bank Details Submitted - Reviewing'**
  String get bankDetailsSubmittedReviewing;

  /// No description provided for @checkVerificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Check Verification Status'**
  String get checkVerificationStatus;

  /// No description provided for @logOutAndExit.
  ///
  /// In en, this message translates to:
  /// **'Log Out & Exit'**
  String get logOutAndExit;

  /// No description provided for @verificationApprovedMsg.
  ///
  /// In en, this message translates to:
  /// **'🎉 Verification Approved! Welcome to EZMoov Fleet.'**
  String get verificationApprovedMsg;

  /// No description provided for @verificationStillPendingMsg.
  ///
  /// In en, this message translates to:
  /// **'Verification still pending admin review. Please check back shortly.'**
  String get verificationStillPendingMsg;

  /// No description provided for @emergencySos.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY SOS'**
  String get emergencySos;

  /// No description provided for @callAmbulance108.
  ///
  /// In en, this message translates to:
  /// **'CALL AMBULANCE (108)'**
  String get callAmbulance108;

  /// No description provided for @sosButtonText.
  ///
  /// In en, this message translates to:
  /// **'SOS (108)'**
  String get sosButtonText;

  /// No description provided for @tapToCallAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Tap to call Ambulance (108) from dialer'**
  String get tapToCallAmbulance;

  /// No description provided for @cancelTrip.
  ///
  /// In en, this message translates to:
  /// **'Cancel Trip'**
  String get cancelTrip;

  /// No description provided for @confirmCashPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cash Payment'**
  String get confirmCashPayment;

  /// No description provided for @yesReceivedCash.
  ///
  /// In en, this message translates to:
  /// **'YES, RECEIVED CASH'**
  String get yesReceivedCash;

  /// No description provided for @cargoPickupPhoto.
  ///
  /// In en, this message translates to:
  /// **'CARGO PICKUP PHOTO'**
  String get cargoPickupPhoto;

  /// No description provided for @cargoPhotoMandatory.
  ///
  /// In en, this message translates to:
  /// **'Photo of loaded cargo is MANDATORY to start trip'**
  String get cargoPhotoMandatory;

  /// No description provided for @proofOfDelivery.
  ///
  /// In en, this message translates to:
  /// **'PROOF OF DELIVERY (POD)'**
  String get proofOfDelivery;

  /// No description provided for @startTrip.
  ///
  /// In en, this message translates to:
  /// **'START TRIP'**
  String get startTrip;

  /// No description provided for @completeTrip.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE TRIP'**
  String get completeTrip;

  /// No description provided for @referAndEarnPartnerBonus.
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn Partner Bonus'**
  String get referAndEarnPartnerBonus;

  /// No description provided for @yourReferralCode.
  ///
  /// In en, this message translates to:
  /// **'YOUR REFERRAL CODE'**
  String get yourReferralCode;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Referral code copied to clipboard!'**
  String get codeCopied;

  /// No description provided for @shareCodeWithDrivers.
  ///
  /// In en, this message translates to:
  /// **'Share your code with fellow drivers to earn bonus rewards when they complete their first 5 trips.'**
  String get shareCodeWithDrivers;

  /// No description provided for @redeemReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Redeem Referral Code'**
  String get redeemReferralCode;

  /// No description provided for @haveReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Have a Referral Code?'**
  String get haveReferralCode;

  /// No description provided for @applyCode.
  ///
  /// In en, this message translates to:
  /// **'Apply Code'**
  String get applyCode;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @todayLoginHours.
  ///
  /// In en, this message translates to:
  /// **'Today Login Hours'**
  String get todayLoginHours;

  /// No description provided for @viewPerformanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Tap to view login hours and session breakdown'**
  String get viewPerformanceHistory;

  /// No description provided for @totalLoginHours.
  ///
  /// In en, this message translates to:
  /// **'Total Login Hours'**
  String get totalLoginHours;

  /// No description provided for @loginSessions.
  ///
  /// In en, this message translates to:
  /// **'Login Sessions'**
  String get loginSessions;

  /// No description provided for @noLoginSessions.
  ///
  /// In en, this message translates to:
  /// **'No login sessions recorded for this date'**
  String get noLoginSessions;

  /// No description provided for @session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @systemStatus.
  ///
  /// In en, this message translates to:
  /// **'System Status'**
  String get systemStatus;

  /// No description provided for @scheduledDowntime.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULED DOWNTIME'**
  String get scheduledDowntime;

  /// No description provided for @appUnderMaintenance.
  ///
  /// In en, this message translates to:
  /// **'App Under Maintenance'**
  String get appUnderMaintenance;

  /// No description provided for @maintenanceInProgressDesc.
  ///
  /// In en, this message translates to:
  /// **'We are currently performing scheduled maintenance to upgrade our partner systems. Driver services and bookings are temporarily paused. We will be back shortly!'**
  String get maintenanceInProgressDesc;

  /// No description provided for @whatYouNeedToKnow.
  ///
  /// In en, this message translates to:
  /// **'WHAT YOU NEED TO KNOW'**
  String get whatYouNeedToKnow;

  /// No description provided for @walletAndEarningsSafe.
  ///
  /// In en, this message translates to:
  /// **'Wallet & Earnings are 100% Safe'**
  String get walletAndEarningsSafe;

  /// No description provided for @walletAndEarningsSafeDesc.
  ///
  /// In en, this message translates to:
  /// **'All balance, payouts, and trips remain secure.'**
  String get walletAndEarningsSafeDesc;

  /// No description provided for @autoServiceResumption.
  ///
  /// In en, this message translates to:
  /// **'Automatic Service Resumption'**
  String get autoServiceResumption;

  /// No description provided for @autoServiceResumptionDesc.
  ///
  /// In en, this message translates to:
  /// **'You will be able to go online as soon as maintenance ends.'**
  String get autoServiceResumptionDesc;

  /// No description provided for @realtimeReconnection.
  ///
  /// In en, this message translates to:
  /// **'Realtime Reconnection'**
  String get realtimeReconnection;

  /// No description provided for @realtimeReconnectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap refresh below to test your connection to our servers.'**
  String get realtimeReconnectionDesc;

  /// No description provided for @checkServerStatus.
  ///
  /// In en, this message translates to:
  /// **'CHECK SERVER STATUS'**
  String get checkServerStatus;

  /// No description provided for @contactPartnerHelpline.
  ///
  /// In en, this message translates to:
  /// **'Contact Partner Helpline'**
  String get contactPartnerHelpline;

  /// No description provided for @maintenanceCompleteMsg.
  ///
  /// In en, this message translates to:
  /// **'🎉 Maintenance complete! Welcome back.'**
  String get maintenanceCompleteMsg;

  /// No description provided for @maintenanceStillOngoingMsg.
  ///
  /// In en, this message translates to:
  /// **'System is still undergoing scheduled maintenance. Please retry in a few moments.'**
  String get maintenanceStillOngoingMsg;

  /// No description provided for @appUpdate.
  ///
  /// In en, this message translates to:
  /// **'App Update'**
  String get appUpdate;

  /// No description provided for @mandatoryUpdate.
  ///
  /// In en, this message translates to:
  /// **'MANDATORY UPDATE'**
  String get mandatoryUpdate;

  /// No description provided for @newVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'NEW VERSION AVAILABLE'**
  String get newVersionAvailable;

  /// No description provided for @currentVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Current: {version}'**
  String currentVersionLabel(Object version);

  /// No description provided for @latestVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Latest: {version}'**
  String latestVersionLabel(Object version);

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @updateAvailableDesc.
  ///
  /// In en, this message translates to:
  /// **'A new and improved version of EZMoov Partner is available. Update now to enjoy enhanced ride allocations, battery optimizations, and performance improvements.'**
  String get updateAvailableDesc;

  /// No description provided for @whatsNewInThisVersion.
  ///
  /// In en, this message translates to:
  /// **'WHAT\'S NEW IN THIS VERSION'**
  String get whatsNewInThisVersion;

  /// No description provided for @fasterOrderMatching.
  ///
  /// In en, this message translates to:
  /// **'Faster Order Matching Speed'**
  String get fasterOrderMatching;

  /// No description provided for @fasterOrderMatchingDesc.
  ///
  /// In en, this message translates to:
  /// **'Get instantly assigned to nearby rides with zero lag.'**
  String get fasterOrderMatchingDesc;

  /// No description provided for @batteryGpsOptimization.
  ///
  /// In en, this message translates to:
  /// **'Battery & GPS Optimization'**
  String get batteryGpsOptimization;

  /// No description provided for @batteryGpsOptimizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Smarter background tracking uses 35% less battery.'**
  String get batteryGpsOptimizationDesc;

  /// No description provided for @realtimeEarningUpdates.
  ///
  /// In en, this message translates to:
  /// **'Realtime Earning Updates'**
  String get realtimeEarningUpdates;

  /// No description provided for @realtimeEarningUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Direct calculations and instant payout status.'**
  String get realtimeEarningUpdatesDesc;

  /// No description provided for @performanceStabilityPatches.
  ///
  /// In en, this message translates to:
  /// **'Performance & Stability Patches'**
  String get performanceStabilityPatches;

  /// No description provided for @performanceStabilityPatchesDesc.
  ///
  /// In en, this message translates to:
  /// **'Smooth navigation and enhanced reliability.'**
  String get performanceStabilityPatchesDesc;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'UPDATE NOW'**
  String get updateNow;

  /// No description provided for @remindMeLater.
  ///
  /// In en, this message translates to:
  /// **'Remind Me Later'**
  String get remindMeLater;

  /// No description provided for @mandatoryUpdateNotice.
  ///
  /// In en, this message translates to:
  /// **'⚠️ This update is required to continue receiving orders.'**
  String get mandatoryUpdateNotice;

  /// No description provided for @registrationFeeRequired.
  ///
  /// In en, this message translates to:
  /// **'Registration Fee Required'**
  String get registrationFeeRequired;

  /// No description provided for @partnerAccountPending.
  ///
  /// In en, this message translates to:
  /// **'PARTNER ACCOUNT PENDING'**
  String get partnerAccountPending;

  /// No description provided for @registrationFeeExplanation.
  ///
  /// In en, this message translates to:
  /// **'Welcome to EZMoov Partner! To activate your driver profile, go online, and start receiving ride requests, please pay the one-time registration fee.'**
  String get registrationFeeExplanation;

  /// No description provided for @verifiedPartnerBadge.
  ///
  /// In en, this message translates to:
  /// **'Verified EZMoov Partner Badge'**
  String get verifiedPartnerBadge;

  /// No description provided for @instantRideDeliveryAllocation.
  ///
  /// In en, this message translates to:
  /// **'Instant Ride & Delivery Allocation'**
  String get instantRideDeliveryAllocation;

  /// No description provided for @fullDailyEarningsPayouts.
  ///
  /// In en, this message translates to:
  /// **'Full Daily Earnings & Direct Payouts'**
  String get fullDailyEarningsPayouts;

  /// No description provided for @payRegistrationFee.
  ///
  /// In en, this message translates to:
  /// **'PAY REGISTRATION FEE'**
  String get payRegistrationFee;

  /// No description provided for @payRegistrationFeeAmount.
  ///
  /// In en, this message translates to:
  /// **'PAY REGISTRATION FEE (₹{amount})'**
  String payRegistrationFeeAmount(Object amount);

  /// No description provided for @refreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get refreshStatus;

  /// No description provided for @registrationFeePaidSuccess.
  ///
  /// In en, this message translates to:
  /// **'🎉 Registration fee paid successfully! Partner account is active.'**
  String get registrationFeePaidSuccess;

  /// No description provided for @registrationFeePaidFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pay registration fee. Please try again.'**
  String get registrationFeePaidFailed;

  /// No description provided for @myPerformance.
  ///
  /// In en, this message translates to:
  /// **'My Performance'**
  String get myPerformance;

  /// No description provided for @completionScore.
  ///
  /// In en, this message translates to:
  /// **'Completion Score'**
  String get completionScore;

  /// No description provided for @completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  /// No description provided for @ordersOverview.
  ///
  /// In en, this message translates to:
  /// **'Orders Overview'**
  String get ordersOverview;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// No description provided for @timeout.
  ///
  /// In en, this message translates to:
  /// **'Timeout'**
  String get timeout;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @totalOffered.
  ///
  /// In en, this message translates to:
  /// **'Total Offered'**
  String get totalOffered;

  /// No description provided for @loginHours.
  ///
  /// In en, this message translates to:
  /// **'Login Hours'**
  String get loginHours;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @dailyPassRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Pass Required ⚠️'**
  String get dailyPassRequiredTitle;

  /// No description provided for @dailyPassRequiredDesc.
  ///
  /// In en, this message translates to:
  /// **'Your 24-hour daily pass is expired or unpaid. Pay ₹{fee} to activate your pass and go online for 24 hours.'**
  String dailyPassRequiredDesc(Object fee);

  /// No description provided for @payDailyFee.
  ///
  /// In en, this message translates to:
  /// **'Pay Daily Fee (₹{fee})'**
  String payDailyFee(Object fee);

  /// No description provided for @activatingPass.
  ///
  /// In en, this message translates to:
  /// **'Activating Pass...'**
  String get activatingPass;

  /// No description provided for @ordersPausedTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders Paused for Today ⛔'**
  String get ordersPausedTitle;

  /// No description provided for @ordersPausedDesc.
  ///
  /// In en, this message translates to:
  /// **'You rejected 2 order requests today. Order allocation is paused for the remainder of today.'**
  String get ordersPausedDesc;

  /// No description provided for @viewWallet.
  ///
  /// In en, this message translates to:
  /// **'View Wallet'**
  String get viewWallet;

  /// No description provided for @viewWalletDetails.
  ///
  /// In en, this message translates to:
  /// **'View Wallet Details'**
  String get viewWalletDetails;

  /// No description provided for @updatingStatus.
  ///
  /// In en, this message translates to:
  /// **'UPDATING STATUS...'**
  String get updatingStatus;

  /// No description provided for @updatingOnlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Updating online status...'**
  String get updatingOnlineStatus;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous Day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next Day'**
  String get nextDay;

  /// No description provided for @sessionsRecorded.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{Session} other{Sessions}} Recorded'**
  String sessionsRecorded(num count);

  /// No description provided for @excellentAcceptance.
  ///
  /// In en, this message translates to:
  /// **'Excellent Acceptance'**
  String get excellentAcceptance;

  /// No description provided for @goodPerformance.
  ///
  /// In en, this message translates to:
  /// **'Good Performance'**
  String get goodPerformance;

  /// No description provided for @highDeclineRate.
  ///
  /// In en, this message translates to:
  /// **'High Decline Rate'**
  String get highDeclineRate;

  /// No description provided for @acceptedOfOrders.
  ///
  /// In en, this message translates to:
  /// **'({accepted} accepted of {total} orders offered)'**
  String acceptedOfOrders(Object accepted, Object total);

  /// No description provided for @baselineNoOrders.
  ///
  /// In en, this message translates to:
  /// **'(Baseline 100% • No orders offered)'**
  String get baselineNoOrders;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'START TIME'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'END TIME'**
  String get endTime;

  /// No description provided for @rideRequestHistory.
  ///
  /// In en, this message translates to:
  /// **'Ride Request History'**
  String get rideRequestHistory;

  /// No description provided for @requestsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{Request} other{Requests}}'**
  String requestsCount(num count);

  /// No description provided for @rideAccepted.
  ///
  /// In en, this message translates to:
  /// **'Ride Accepted'**
  String get rideAccepted;

  /// No description provided for @rideDeclined.
  ///
  /// In en, this message translates to:
  /// **'Ride Declined'**
  String get rideDeclined;

  /// No description provided for @reasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String reasonLabel(Object reason);

  /// No description provided for @goOnlineToTrackHours.
  ///
  /// In en, this message translates to:
  /// **'Go online from the Home dashboard to track your active login hours.'**
  String get goOnlineToTrackHours;

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get walletBalance;

  /// No description provided for @addMoney.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get addMoney;

  /// No description provided for @addMoneyToWallet.
  ///
  /// In en, this message translates to:
  /// **'Add Money to Wallet'**
  String get addMoneyToWallet;

  /// No description provided for @addMoneySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recharge your wallet to pay daily vehicle fees and stay active for orders.'**
  String get addMoneySubtitle;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enterAmount;

  /// No description provided for @rechargeWallet.
  ///
  /// In en, this message translates to:
  /// **'Recharge Wallet'**
  String get rechargeWallet;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No Transactions Yet'**
  String get noTransactionsYet;

  /// No description provided for @noTransactionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your wallet recharges and daily fee deductions will appear here.'**
  String get noTransactionsSubtitle;

  /// No description provided for @dailyPassActive.
  ///
  /// In en, this message translates to:
  /// **'Daily Pass Active'**
  String get dailyPassActive;

  /// No description provided for @dailyPassExpired.
  ///
  /// In en, this message translates to:
  /// **'Daily Pass Inactive'**
  String get dailyPassExpired;

  /// No description provided for @passValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until {time}'**
  String passValidUntil(Object time);

  /// No description provided for @dailyVehicleFee.
  ///
  /// In en, this message translates to:
  /// **'Daily Vehicle Fee'**
  String get dailyVehicleFee;

  /// No description provided for @payFromWallet.
  ///
  /// In en, this message translates to:
  /// **'Pay from Wallet (₹{amount})'**
  String payFromWallet(Object amount);

  /// No description provided for @payDirectlyRazorpay.
  ///
  /// In en, this message translates to:
  /// **'Pay with UPI / Razorpay (₹{amount})'**
  String payDirectlyRazorpay(Object amount);

  /// No description provided for @invitePartnersBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite Partners & Earn ₹25!'**
  String get invitePartnersBannerTitle;

  /// No description provided for @invitePartnersBannerDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn ₹25 wallet cash for every driver partner who registers with your code!'**
  String get invitePartnersBannerDesc;

  /// No description provided for @yourUniqueReferralCode.
  ///
  /// In en, this message translates to:
  /// **'YOUR UNIQUE REFERRAL CODE'**
  String get yourUniqueReferralCode;

  /// No description provided for @shareOnWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Share on WhatsApp'**
  String get shareOnWhatsApp;

  /// No description provided for @wereYouReferred.
  ///
  /// In en, this message translates to:
  /// **'Were you referred by a partner?'**
  String get wereYouReferred;

  /// No description provided for @enterCodeToLink.
  ///
  /// In en, this message translates to:
  /// **'Enter their code to link your accounts.'**
  String get enterCodeToLink;

  /// No description provided for @redeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get redeem;

  /// No description provided for @referredPartners.
  ///
  /// In en, this message translates to:
  /// **'Referred Partners'**
  String get referredPartners;

  /// No description provided for @partnersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{Partner} other{Partners}}'**
  String partnersCount(num count);

  /// No description provided for @noReferralsYet.
  ///
  /// In en, this message translates to:
  /// **'No referrals yet'**
  String get noReferralsYet;

  /// No description provided for @noReferralsDesc.
  ///
  /// In en, this message translates to:
  /// **'Share your referral code with fellow drivers to start earning bonuses!'**
  String get noReferralsDesc;

  /// No description provided for @rewardedStatus.
  ///
  /// In en, this message translates to:
  /// **'₹{amount} Rewarded'**
  String rewardedStatus(Object amount);

  /// No description provided for @pendingVerificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending Verification'**
  String get pendingVerificationStatus;

  /// No description provided for @enterReferralCodeDialogDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the referral code given to you by another partner driver to link your accounts.'**
  String get enterReferralCodeDialogDesc;

  /// No description provided for @referralCodeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Referral Code (e.g. EZM9876)'**
  String get referralCodeFieldLabel;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changeProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Picture 📸'**
  String get changeProfilePicture;

  /// No description provided for @choosePhotoSource.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to update your profile photo'**
  String get choosePhotoSource;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccess;

  /// No description provided for @customerDeliveryRequest.
  ///
  /// In en, this message translates to:
  /// **'Customer Delivery Request'**
  String get customerDeliveryRequest;

  /// No description provided for @withinDistance.
  ///
  /// In en, this message translates to:
  /// **'Within {distance}'**
  String withinDistance(Object distance);

  /// No description provided for @outstationBidding.
  ///
  /// In en, this message translates to:
  /// **'Outstation Bidding'**
  String get outstationBidding;

  /// No description provided for @biddingStatus.
  ///
  /// In en, this message translates to:
  /// **'Bidding Status'**
  String get biddingStatus;

  /// No description provided for @customerIsDeciding.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER IS DECIDING'**
  String get customerIsDeciding;

  /// No description provided for @activeTrip.
  ///
  /// In en, this message translates to:
  /// **'Active Trip'**
  String get activeTrip;

  /// No description provided for @arrivedAtPickup.
  ///
  /// In en, this message translates to:
  /// **'ARRIVED AT PICKUP'**
  String get arrivedAtPickup;

  /// No description provided for @startTripCaps.
  ///
  /// In en, this message translates to:
  /// **'START TRIP'**
  String get startTripCaps;

  /// No description provided for @arrivedAtDropoff.
  ///
  /// In en, this message translates to:
  /// **'ARRIVED AT DROPOFF'**
  String get arrivedAtDropoff;

  /// No description provided for @completeTripCaps.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE TRIP'**
  String get completeTripCaps;

  /// No description provided for @callCustomer.
  ///
  /// In en, this message translates to:
  /// **'Call Customer'**
  String get callCustomer;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @rideCancelledByCustomer.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Ride was cancelled by customer'**
  String get rideCancelledByCustomer;

  /// No description provided for @noActivePendingBidFound.
  ///
  /// In en, this message translates to:
  /// **'No active pending bid found.'**
  String get noActivePendingBidFound;

  /// No description provided for @returnToHome.
  ///
  /// In en, this message translates to:
  /// **'Return to Home'**
  String get returnToHome;

  /// No description provided for @customerDecidingDesc.
  ///
  /// In en, this message translates to:
  /// **'Your bid is being reviewed by the customer. You can update your bid below at any time.'**
  String get customerDecidingDesc;

  /// No description provided for @outstationCustomer.
  ///
  /// In en, this message translates to:
  /// **'Outstation Customer'**
  String get outstationCustomer;

  /// No description provided for @baseRate.
  ///
  /// In en, this message translates to:
  /// **'Base Rate'**
  String get baseRate;

  /// No description provided for @yourActiveBid.
  ///
  /// In en, this message translates to:
  /// **'Your Active Bid'**
  String get yourActiveBid;

  /// No description provided for @pickupAddressCaps.
  ///
  /// In en, this message translates to:
  /// **'PICKUP ADDRESS'**
  String get pickupAddressCaps;

  /// No description provided for @dropAddressCaps.
  ///
  /// In en, this message translates to:
  /// **'DROP ADDRESS'**
  String get dropAddressCaps;

  /// No description provided for @submitNewBidAmount.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT A NEW BID AMOUNT (₹)'**
  String get submitNewBidAmount;

  /// No description provided for @submitLowerPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'Submit a lower or competitive price to increase your chances.'**
  String get submitLowerPriceDesc;

  /// No description provided for @enterNewBidAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new bid amount'**
  String get enterNewBidAmountHint;

  /// No description provided for @pleaseEnterBidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a bid amount'**
  String get pleaseEnterBidAmount;

  /// No description provided for @enterValidPositiveBid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive bid amount'**
  String get enterValidPositiveBid;

  /// No description provided for @updateBid.
  ///
  /// In en, this message translates to:
  /// **'UPDATE BID'**
  String get updateBid;

  /// No description provided for @withdrawCancelBid.
  ///
  /// In en, this message translates to:
  /// **'Withdraw / Cancel Bid'**
  String get withdrawCancelBid;

  /// No description provided for @incomingRideRequestCaps.
  ///
  /// In en, this message translates to:
  /// **'INCOMING RIDE REQUEST'**
  String get incomingRideRequestCaps;

  /// No description provided for @within3km.
  ///
  /// In en, this message translates to:
  /// **'Within 3 km'**
  String get within3km;

  /// No description provided for @within10km.
  ///
  /// In en, this message translates to:
  /// **'Within 10 km'**
  String get within10km;

  /// No description provided for @standardDeliveryOrder.
  ///
  /// In en, this message translates to:
  /// **'Standard Delivery Order'**
  String get standardDeliveryOrder;

  /// No description provided for @inclIncentive.
  ///
  /// In en, this message translates to:
  /// **'Incl. ₹{amount} incentive 🎁'**
  String inclIncentive(Object amount);

  /// No description provided for @intermediateStopsBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} Intermediate {count, plural, =1{Stop} other{Stops}} (+₹{charge})'**
  String intermediateStopsBadge(Object charge, num count);

  /// No description provided for @acceptRideCaps.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT RIDE'**
  String get acceptRideCaps;

  /// No description provided for @outstationBiddingRideCaps.
  ///
  /// In en, this message translates to:
  /// **'OUTSTATION BIDDING RIDE'**
  String get outstationBiddingRideCaps;

  /// No description provided for @outstationBooking.
  ///
  /// In en, this message translates to:
  /// **'Outstation Booking'**
  String get outstationBooking;

  /// No description provided for @enterYourBidAmountCaps.
  ///
  /// In en, this message translates to:
  /// **'ENTER YOUR BID AMOUNT (₹)'**
  String get enterYourBidAmountCaps;

  /// No description provided for @bidAmountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1500'**
  String get bidAmountHint;

  /// No description provided for @submitBidCaps.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT BID'**
  String get submitBidCaps;

  /// No description provided for @reachedStop.
  ///
  /// In en, this message translates to:
  /// **'REACHED STOP {stop}'**
  String reachedStop(Object stop);

  /// No description provided for @completedStop.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED STOP {stop}'**
  String completedStop(Object stop);

  /// No description provided for @atIntermediateStop.
  ///
  /// In en, this message translates to:
  /// **'AT INTERMEDIATE STOP'**
  String get atIntermediateStop;

  /// No description provided for @paymentConfirmedCaps.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT CONFIRMED'**
  String get paymentConfirmedCaps;

  /// No description provided for @unloadedAwaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'UNLOADED / AWAITING PAYMENT'**
  String get unloadedAwaitingPayment;

  /// No description provided for @inTransitToDropoff.
  ///
  /// In en, this message translates to:
  /// **'IN TRANSIT TO DROPOFF'**
  String get inTransitToDropoff;

  /// No description provided for @headingToPickup.
  ///
  /// In en, this message translates to:
  /// **'HEADING TO PICKUP'**
  String get headingToPickup;

  /// No description provided for @resumeCaps.
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get resumeCaps;

  /// No description provided for @bidPendingWithAmount.
  ///
  /// In en, this message translates to:
  /// **'BID PENDING • ₹ {amount}'**
  String bidPendingWithAmount(Object amount);

  /// No description provided for @customerDecidingTapUpdate.
  ///
  /// In en, this message translates to:
  /// **'Customer deciding... Tap to update bid'**
  String get customerDecidingTapUpdate;

  /// No description provided for @viewBidCaps.
  ///
  /// In en, this message translates to:
  /// **'VIEW BID'**
  String get viewBidCaps;

  /// No description provided for @stopsBadgeCount.
  ///
  /// In en, this message translates to:
  /// **'+{count} STOPS'**
  String stopsBadgeCount(Object count);

  /// No description provided for @tripFareBreakdown.
  ///
  /// In en, this message translates to:
  /// **'TRIP FARE BREAKDOWN'**
  String get tripFareBreakdown;

  /// No description provided for @baseFareIncludes1km.
  ///
  /// In en, this message translates to:
  /// **'Base Fare (Includes 1st KM)'**
  String get baseFareIncludes1km;

  /// No description provided for @distanceChargesBeyond1km.
  ///
  /// In en, this message translates to:
  /// **'Distance Charges (beyond 1 KM)'**
  String get distanceChargesBeyond1km;

  /// No description provided for @stopsChargeLabel.
  ///
  /// In en, this message translates to:
  /// **'Stops Charge ({count} {count, plural, =1{stop} other{stops}} @ ₹25 each)'**
  String stopsChargeLabel(num count);

  /// No description provided for @waitingCharges.
  ///
  /// In en, this message translates to:
  /// **'Waiting Charges'**
  String get waitingCharges;

  /// No description provided for @taxesAndGst.
  ///
  /// In en, this message translates to:
  /// **'Taxes & GST'**
  String get taxesAndGst;

  /// No description provided for @totalDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Total Delivery Fee'**
  String get totalDeliveryFee;

  /// No description provided for @closeCaps.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get closeCaps;

  /// No description provided for @onlinePaymentPending.
  ///
  /// In en, this message translates to:
  /// **'Online Payment Pending'**
  String get onlinePaymentPending;

  /// No description provided for @onlinePaymentPendingDesc.
  ///
  /// In en, this message translates to:
  /// **'The customer selected Online Payment (Razorpay). The payment has not been confirmed yet.\n\nPlease ask the customer to complete payment on their phone. The status will automatically update to \"Payment Received\" once paid.'**
  String get onlinePaymentPendingDesc;

  /// No description provided for @waitForPaymentCaps.
  ///
  /// In en, this message translates to:
  /// **'WAIT FOR PAYMENT'**
  String get waitForPaymentCaps;

  /// No description provided for @receivedCashInsteadCaps.
  ///
  /// In en, this message translates to:
  /// **'RECEIVED CASH INSTEAD'**
  String get receivedCashInsteadCaps;

  /// No description provided for @didYouCollectCash.
  ///
  /// In en, this message translates to:
  /// **'Did you collect ₹{amount} cash directly from the customer?'**
  String didYouCollectCash(Object amount);

  /// No description provided for @tripFare.
  ///
  /// In en, this message translates to:
  /// **'Trip Fare'**
  String get tripFare;

  /// No description provided for @farDriverIncentive.
  ///
  /// In en, this message translates to:
  /// **'Far Driver Incentive 🎁'**
  String get farDriverIncentive;

  /// No description provided for @totalToCollect.
  ///
  /// In en, this message translates to:
  /// **'Total to Collect'**
  String get totalToCollect;

  /// No description provided for @cancelCaps.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelCaps;

  /// No description provided for @cancelTripRequest.
  ///
  /// In en, this message translates to:
  /// **'CANCEL TRIP REQUEST'**
  String get cancelTripRequest;

  /// No description provided for @selectCancellationReason.
  ///
  /// In en, this message translates to:
  /// **'Please select a cancellation reason'**
  String get selectCancellationReason;

  /// No description provided for @reasonNoShow.
  ///
  /// In en, this message translates to:
  /// **'Customer No-Show at Pickup'**
  String get reasonNoShow;

  /// No description provided for @reasonOversized.
  ///
  /// In en, this message translates to:
  /// **'Oversized Goods'**
  String get reasonOversized;

  /// No description provided for @reasonBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Breakdown'**
  String get reasonBreakdown;

  /// No description provided for @reasonCustomerRequested.
  ///
  /// In en, this message translates to:
  /// **'Customer Requested Cancellation'**
  String get reasonCustomerRequested;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other Issue'**
  String get reasonOther;

  /// No description provided for @confirmCancellationCaps.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM CANCELLATION'**
  String get confirmCancellationCaps;

  /// No description provided for @tripCancelled.
  ///
  /// In en, this message translates to:
  /// **'Trip cancelled.'**
  String get tripCancelled;

  /// No description provided for @addExtraChargesCaps.
  ///
  /// In en, this message translates to:
  /// **'ADD EXTRA CHARGES'**
  String get addExtraChargesCaps;

  /// No description provided for @addExtraExpensesDesc.
  ///
  /// In en, this message translates to:
  /// **'Add extra trip expenses (e.g. Toll, Gas, Parking):'**
  String get addExtraExpensesDesc;

  /// No description provided for @chargeName.
  ///
  /// In en, this message translates to:
  /// **'Charge Name'**
  String get chargeName;

  /// No description provided for @chargeNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. toll'**
  String get chargeNameHint;

  /// No description provided for @chargeAmount.
  ///
  /// In en, this message translates to:
  /// **'Charge Number / Amount (₹)'**
  String get chargeAmount;

  /// No description provided for @chargeAmountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 55'**
  String get chargeAmountHint;

  /// No description provided for @addCaps.
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get addCaps;

  /// No description provided for @addedChargesList.
  ///
  /// In en, this message translates to:
  /// **'Added Charges List:'**
  String get addedChargesList;

  /// No description provided for @submitCaps.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT'**
  String get submitCaps;

  /// No description provided for @tapCameraOrGalleryPickup.
  ///
  /// In en, this message translates to:
  /// **'Tap Camera or Gallery below to capture pickup photo'**
  String get tapCameraOrGalleryPickup;

  /// No description provided for @confirmPhotoAndStartTrip.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PHOTO & START TRIP'**
  String get confirmPhotoAndStartTrip;

  /// No description provided for @pickupPhotoMandatoryAlert.
  ///
  /// In en, this message translates to:
  /// **'Please capture or select a pickup photo first!'**
  String get pickupPhotoMandatoryAlert;

  /// No description provided for @proofOfDeliveryMandatory.
  ///
  /// In en, this message translates to:
  /// **'Proof of delivery (POD) photo/signature is MANDATORY to complete trip'**
  String get proofOfDeliveryMandatory;

  /// No description provided for @tapCameraOrGalleryPod.
  ///
  /// In en, this message translates to:
  /// **'Tap Camera or Gallery below to capture POD photo'**
  String get tapCameraOrGalleryPod;

  /// No description provided for @customerSignature.
  ///
  /// In en, this message translates to:
  /// **'Customer Signature'**
  String get customerSignature;

  /// No description provided for @clearSignature.
  ///
  /// In en, this message translates to:
  /// **'Clear Signature'**
  String get clearSignature;

  /// No description provided for @confirmPodAndCompleteTrip.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM POD & COMPLETE TRIP'**
  String get confirmPodAndCompleteTrip;

  /// No description provided for @podMandatoryAlert.
  ///
  /// In en, this message translates to:
  /// **'Please capture a POD photo or get customer signature first!'**
  String get podMandatoryAlert;

  /// No description provided for @rateCustomer.
  ///
  /// In en, this message translates to:
  /// **'RATE CUSTOMER'**
  String get rateCustomer;

  /// No description provided for @howWasExperienceWithCustomer.
  ///
  /// In en, this message translates to:
  /// **'How was your experience with the customer?'**
  String get howWasExperienceWithCustomer;

  /// No description provided for @submitRatingCaps.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT RATING'**
  String get submitRatingCaps;

  /// No description provided for @customerPhoneNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Customer phone number not available'**
  String get customerPhoneNotAvailable;

  /// No description provided for @reachedStopMsg.
  ///
  /// In en, this message translates to:
  /// **'Reached Stop {stop}!'**
  String reachedStopMsg(Object stop);

  /// No description provided for @completedStopMsg.
  ///
  /// In en, this message translates to:
  /// **'Completed Stop {stop}!'**
  String completedStopMsg(Object stop);

  /// No description provided for @collectPaymentAndComplete.
  ///
  /// In en, this message translates to:
  /// **'COLLECT PAYMENT & COMPLETE'**
  String get collectPaymentAndComplete;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful! 🎉'**
  String get paymentSuccessful;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed ❌'**
  String get paymentFailed;

  /// No description provided for @paymentProcessedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your payment was processed successfully! Please note: It may take up to 30 minutes for the updated balance to reflect in your wallet depending on bank/UPI confirmation.'**
  String get paymentProcessedDesc;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @waitingTime.
  ///
  /// In en, this message translates to:
  /// **'Waiting Time'**
  String get waitingTime;

  /// No description provided for @minShort.
  ///
  /// In en, this message translates to:
  /// **'MIN'**
  String get minShort;

  /// No description provided for @secShort.
  ///
  /// In en, this message translates to:
  /// **'SEC'**
  String get secShort;

  /// No description provided for @startNavigation.
  ///
  /// In en, this message translates to:
  /// **'Start Navigation'**
  String get startNavigation;

  /// No description provided for @pickupOtpVerified.
  ///
  /// In en, this message translates to:
  /// **'Pickup OTP Verified'**
  String get pickupOtpVerified;

  /// No description provided for @enterPickupOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter 4-digit Pickup OTP'**
  String get enterPickupOtp;

  /// No description provided for @verifyPickupOtp.
  ///
  /// In en, this message translates to:
  /// **'VERIFY OTP'**
  String get verifyPickupOtp;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Please try again.'**
  String get invalidOtp;

  /// No description provided for @couldNotMakeCall.
  ///
  /// In en, this message translates to:
  /// **'Could not make call: {error}'**
  String couldNotMakeCall(Object error);

  /// No description provided for @couldNotLaunchDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not launch dialer for 108: {error}'**
  String couldNotLaunchDialer(Object error);

  /// No description provided for @couldNotOpenSms.
  ///
  /// In en, this message translates to:
  /// **'Could not open SMS: {error}'**
  String couldNotOpenSms(Object error);

  /// No description provided for @locationCoordsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Location coordinates or address not available'**
  String get locationCoordsNotAvailable;

  /// No description provided for @couldNotOpenGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Maps: {error}'**
  String couldNotOpenGoogleMaps(Object error);

  /// No description provided for @failedToUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update status: {error}'**
  String failedToUpdateStatus(Object error);

  /// No description provided for @errorUpdatingStopStatus.
  ///
  /// In en, this message translates to:
  /// **'Error updating stop status: {error}'**
  String errorUpdatingStopStatus(Object error);

  /// No description provided for @errorCancellingTrip.
  ///
  /// In en, this message translates to:
  /// **'Error cancelling trip: {error}'**
  String errorCancellingTrip(Object error);

  /// No description provided for @enterChargeNameAlert.
  ///
  /// In en, this message translates to:
  /// **'Please enter a charge name (e.g., toll)'**
  String get enterChargeNameAlert;

  /// No description provided for @enterValidChargeAmountAlert.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid numeric charge amount'**
  String get enterValidChargeAmountAlert;

  /// No description provided for @failedToUploadPickupPhoto.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload pickup photo: {error}'**
  String failedToUploadPickupPhoto(Object error);

  /// No description provided for @arrivedPickupNotify.
  ///
  /// In en, this message translates to:
  /// **'Customer notified: Driver arrived at pickup location! Loading timer started.'**
  String get arrivedPickupNotify;

  /// No description provided for @cargoPickupSavedTripStarted.
  ///
  /// In en, this message translates to:
  /// **'Cargo pickup photo saved! Trip started.'**
  String get cargoPickupSavedTripStarted;

  /// No description provided for @arrivedDropoffNotify.
  ///
  /// In en, this message translates to:
  /// **'Arrived at final drop-off location! Unloading timer started.'**
  String get arrivedDropoffNotify;

  /// No description provided for @cargoUnloadedPodSubmitted.
  ///
  /// In en, this message translates to:
  /// **'📦 Cargo unloaded & POD submitted! Awaiting payment.'**
  String get cargoUnloadedPodSubmitted;

  /// No description provided for @cashPaymentReceivedNotify.
  ///
  /// In en, this message translates to:
  /// **'Cash Payment Received! Please confirm trip completion.'**
  String get cashPaymentReceivedNotify;

  /// No description provided for @deliveryCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'🎉 Delivery Completed Successfully!'**
  String get deliveryCompletedSuccessfully;

  /// No description provided for @emergencyQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you in an emergency situation?'**
  String get emergencyQuestion;

  /// No description provided for @emergencyAmbulanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Tapping \"Call Ambulance 108\" will open your phone dialer to directly call Emergency Ambulance Services (108).'**
  String get emergencyAmbulanceDesc;

  /// No description provided for @tapToCallAmbulanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap to call Ambulance (108) from dialer'**
  String get tapToCallAmbulanceDesc;

  /// No description provided for @sosButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'SOS (108)'**
  String get sosButtonLabel;

  /// No description provided for @pickupPhotoMandatory.
  ///
  /// In en, this message translates to:
  /// **'Photo of loaded cargo is MANDATORY to start trip'**
  String get pickupPhotoMandatory;

  /// No description provided for @proofOfDeliveryPod.
  ///
  /// In en, this message translates to:
  /// **'PROOF OF DELIVERY (POD)'**
  String get proofOfDeliveryPod;

  /// No description provided for @podPhotoMandatoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of delivered goods (MANDATORY)'**
  String get podPhotoMandatoryDesc;

  /// No description provided for @driverExtraCharges.
  ///
  /// In en, this message translates to:
  /// **'Driver Extra Charges:'**
  String get driverExtraCharges;

  /// No description provided for @submitPodAndUnloadCargo.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT POD & UNLOAD CARGO'**
  String get submitPodAndUnloadCargo;

  /// No description provided for @podPhotoMandatoryBeforeComplete.
  ///
  /// In en, this message translates to:
  /// **'Proof of Delivery photo is MANDATORY before completing delivery.'**
  String get podPhotoMandatoryBeforeComplete;

  /// No description provided for @rateTheCustomer.
  ///
  /// In en, this message translates to:
  /// **'RATE THE CUSTOMER'**
  String get rateTheCustomer;

  /// No description provided for @howWasExperienceWithTrip.
  ///
  /// In en, this message translates to:
  /// **'How was your experience with this trip?'**
  String get howWasExperienceWithTrip;

  /// No description provided for @addOptionalCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add optional comment...'**
  String get addOptionalCommentHint;

  /// No description provided for @skipCaps.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get skipCaps;

  /// No description provided for @paymentConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Confirmed'**
  String get paymentConfirmedTitle;

  /// No description provided for @awaitingPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Payment'**
  String get awaitingPaymentTitle;

  /// No description provided for @tripInTransitTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip in Transit'**
  String get tripInTransitTitle;

  /// No description provided for @arrivedAtPickupTitle.
  ///
  /// In en, this message translates to:
  /// **'Arrived at Pickup'**
  String get arrivedAtPickupTitle;

  /// No description provided for @pickupNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickup Navigation'**
  String get pickupNavigationTitle;

  /// No description provided for @cancelTripTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel Trip'**
  String get cancelTripTooltip;

  /// No description provided for @paymentReceivedCaps.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT RECEIVED'**
  String get paymentReceivedCaps;

  /// No description provided for @arrivedAtDropoffCaps.
  ///
  /// In en, this message translates to:
  /// **'ARRIVED AT DROP-OFF LOCATION'**
  String get arrivedAtDropoffCaps;

  /// No description provided for @arrivedAtPickupCaps.
  ///
  /// In en, this message translates to:
  /// **'ARRIVED AT PICKUP LOCATION'**
  String get arrivedAtPickupCaps;

  /// No description provided for @tripInTransitToDropPoint.
  ///
  /// In en, this message translates to:
  /// **'TRIP IN TRANSIT TO DROP POINT'**
  String get tripInTransitToDropPoint;

  /// No description provided for @paymentConfirmedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed! Tap below to finalize trip completion.'**
  String get paymentConfirmedSubtitle;

  /// No description provided for @collectCashOrWaitOnlineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Collect cash payment or wait for customer online payment.'**
  String get collectCashOrWaitOnlineSubtitle;

  /// No description provided for @unloadingTimerActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unloading timer active! Submit POD once unloading is complete.'**
  String get unloadingTimerActiveSubtitle;

  /// No description provided for @loadingTimerActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Loading timer active! Tap START TRIP once loaded.'**
  String get loadingTimerActiveSubtitle;

  /// No description provided for @onTheWayToDropoffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On the way to dropoff destination'**
  String get onTheWayToDropoffSubtitle;

  /// No description provided for @followGpsRouteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow GPS route to customer location'**
  String get followGpsRouteSubtitle;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @sendSms.
  ///
  /// In en, this message translates to:
  /// **'Send SMS'**
  String get sendSms;

  /// No description provided for @openGoogleMapsCaps.
  ///
  /// In en, this message translates to:
  /// **'OPEN GOOGLE MAPS'**
  String get openGoogleMapsCaps;

  /// No description provided for @navigateToTarget.
  ///
  /// In en, this message translates to:
  /// **'Navigate to {target}'**
  String navigateToTarget(Object target);

  /// No description provided for @customerPickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Customer Pickup Location'**
  String get customerPickupLocation;

  /// No description provided for @goCaps.
  ///
  /// In en, this message translates to:
  /// **'GO'**
  String get goCaps;

  /// No description provided for @bookingIdWithNumber.
  ///
  /// In en, this message translates to:
  /// **'BOOKING #{id}'**
  String bookingIdWithNumber(Object id);

  /// No description provided for @customerPickupPoint.
  ///
  /// In en, this message translates to:
  /// **'Customer Pickup Point'**
  String get customerPickupPoint;

  /// No description provided for @navigateToPickupGmaps.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Pickup in GMaps'**
  String get navigateToPickupGmaps;

  /// No description provided for @intermediateStopNumber.
  ///
  /// In en, this message translates to:
  /// **'Intermediate Stop {index}'**
  String intermediateStopNumber(Object index);

  /// No description provided for @navigateToStopGmaps.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Stop {index} in GMaps'**
  String navigateToStopGmaps(Object index);

  /// No description provided for @stopCompletedCaps.
  ///
  /// In en, this message translates to:
  /// **'✓ STOP {index} COMPLETED'**
  String stopCompletedCaps(Object index);

  /// No description provided for @completeStopNumber.
  ///
  /// In en, this message translates to:
  /// **'Complete Stop {index}'**
  String completeStopNumber(Object index);

  /// No description provided for @reachedStopNumber.
  ///
  /// In en, this message translates to:
  /// **'Reached Stop {index}'**
  String reachedStopNumber(Object index);

  /// No description provided for @customerDropoffPoint.
  ///
  /// In en, this message translates to:
  /// **'Customer Dropoff Point'**
  String get customerDropoffPoint;

  /// No description provided for @navigateToDropoffGmaps.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Dropoff in GMaps'**
  String get navigateToDropoffGmaps;

  /// No description provided for @totalDeliveryFareLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Delivery Fare:'**
  String get totalDeliveryFareLabel;

  /// No description provided for @viewFareBreakdown.
  ///
  /// In en, this message translates to:
  /// **'View Fare Breakdown'**
  String get viewFareBreakdown;

  /// No description provided for @inclFarDriverIncentive.
  ///
  /// In en, this message translates to:
  /// **'Incl. ₹{amount} far driver incentive 🎁'**
  String inclFarDriverIncentive(Object amount);

  /// No description provided for @takePickupPhotoAndStartTrip.
  ///
  /// In en, this message translates to:
  /// **'TAKE PICKUP PHOTO & START TRIP'**
  String get takePickupPhotoAndStartTrip;

  /// No description provided for @completeStopCaps.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE STOP {index}'**
  String completeStopCaps(Object index);

  /// No description provided for @reachedStopCaps.
  ///
  /// In en, this message translates to:
  /// **'REACHED STOP {index}'**
  String reachedStopCaps(Object index);

  /// No description provided for @reachedFinalDestination.
  ///
  /// In en, this message translates to:
  /// **'REACHED FINAL DESTINATION'**
  String get reachedFinalDestination;

  /// No description provided for @unloadCargoAndSubmitPod.
  ///
  /// In en, this message translates to:
  /// **'UNLOAD CARGO & SUBMIT POD'**
  String get unloadCargoAndSubmitPod;

  /// No description provided for @collectCashPaymentWithAmount.
  ///
  /// In en, this message translates to:
  /// **'Collect Cash Payment (₹{amount})'**
  String collectCashPaymentWithAmount(Object amount);

  /// No description provided for @confirmTripCompleted.
  ///
  /// In en, this message translates to:
  /// **'Confirm Trip Completed'**
  String get confirmTripCompleted;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'BACK TO HOME'**
  String get backToHome;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @stopLocationWithIndex.
  ///
  /// In en, this message translates to:
  /// **'STOP {index} LOCATION'**
  String stopLocationWithIndex(Object index);

  /// No description provided for @intermediateStop.
  ///
  /// In en, this message translates to:
  /// **'INTERMEDIATE STOP'**
  String get intermediateStop;

  /// No description provided for @finalDropLocation.
  ///
  /// In en, this message translates to:
  /// **'FINAL DROP LOCATION'**
  String get finalDropLocation;

  /// No description provided for @addressDetailsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Address details unavailable'**
  String get addressDetailsUnavailable;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @freeDriverLoginActive.
  ///
  /// In en, this message translates to:
  /// **'Free Driver Login Active 🎉'**
  String get freeDriverLoginActive;

  /// No description provided for @freeDriverLoginDesc.
  ///
  /// In en, this message translates to:
  /// **'Free driver login enabled • No daily fee required to go online'**
  String get freeDriverLoginDesc;

  /// No description provided for @freePassBadge.
  ///
  /// In en, this message translates to:
  /// **'FREE PASS'**
  String get freePassBadge;
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
