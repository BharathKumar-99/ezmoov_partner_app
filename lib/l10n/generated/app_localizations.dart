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
  /// **'Call Ambulance (108)'**
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
