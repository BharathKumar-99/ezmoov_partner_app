// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EZMoov Partner';

  @override
  String get home => 'Home';

  @override
  String get earnings => 'Earnings';

  @override
  String get alerts => 'Alerts';

  @override
  String get profile => 'Profile';

  @override
  String get youAreOnline => 'You are Online';

  @override
  String get youAreOffline => 'You are Offline';

  @override
  String get readyToAcceptRides => 'Ready to accept nearby ride bookings';

  @override
  String get goOnlineToReceiveBookings =>
      'Go online to start receiving ride bookings';

  @override
  String get todaysEarnings => 'Today\'s Earnings';

  @override
  String get completedTrips => 'Completed Trips';

  @override
  String get acceptRide => 'Accept Ride';

  @override
  String get declineRide => 'Decline Ride';

  @override
  String get incomingRideRequest => 'Incoming Ride Request';

  @override
  String get pickupLocation => 'Pickup Location';

  @override
  String get dropoffLocation => 'Dropoff Location';

  @override
  String get vehicleAndEquipment => 'Vehicle & Equipment';

  @override
  String get vehicleRegistration => 'Vehicle Registration';

  @override
  String get vehicleDetailsVerified => 'Vehicle Details Verified';

  @override
  String get driverCertificates => 'Driver Certificates';

  @override
  String get certificatesSubtitle =>
      'PUC, Permit, Fitness, Police Clearance (Verified)';

  @override
  String get payoutsAndBanking => 'Payouts & Banking';

  @override
  String get bankAccount => 'Bank Account';

  @override
  String get bankDetailsVerified => 'Bank Details Verified';

  @override
  String get supportAndPreferences => 'Support & Preferences';

  @override
  String get appLanguage => 'App Language';

  @override
  String get currentLanguageName => 'English';

  @override
  String get selectLanguage => 'Select App Language';

  @override
  String get helpAndSupportDesk => 'Help & Support Desk';

  @override
  String get supportDeskSubtitle =>
      'FAQs, Account Assistance & 24/7 Driver Support';

  @override
  String get logOutOfAccount => 'Log Out of Account';

  @override
  String get confirmLogoutTitle => 'Confirm Logout';

  @override
  String get confirmLogoutMessage =>
      'Are you sure you want to log out of your partner account?';

  @override
  String get cancel => 'Cancel';

  @override
  String get logout => 'Log Out';

  @override
  String get howCanWeHelpYou => 'How can we help you?';

  @override
  String get getInTouchHelp =>
      'Please get in touch and we will be happy to help you.';

  @override
  String get updateAccountDetails => 'Update my account details';

  @override
  String get updateAccountSubtitle => 'Check & update account related info';

  @override
  String get knowMorePricing => 'Know more about the pricing';

  @override
  String get pricingSubtitle => 'Get details about fare, invoices, etc';

  @override
  String get learnMoreWallet => 'Learn more about my wallet';

  @override
  String get walletSubtitle => 'Get wallet & payment mode related info';

  @override
  String get learnEzmoovServices => 'Learn about EZMoov services';

  @override
  String get servicesSubtitle => 'Understand services offered by EZMoov';

  @override
  String get understandSafety => 'Understand safety procedures';

  @override
  String get safetySubtitle => 'Know more about safety & insurance';

  @override
  String get callSupportHotline => 'Call 24/7 Driver Support Hotline';

  @override
  String get speakToAgent => 'Speak to Support Agent';

  @override
  String get noActiveBookings => 'No active bookings right now.';

  @override
  String get stayOnlineAlerts =>
      'Stay online to receive instant notification alerts for nearby ride requests.';

  @override
  String get totalEarnings => 'Total Earnings';

  @override
  String get tripHistory => 'Trip History';

  @override
  String get recentTrips => 'Recent Trips';

  @override
  String get viewDetails => 'View Details';

  @override
  String get welcomeBack => 'Welcome back,';

  @override
  String get partnerDriver => 'Partner Driver';

  @override
  String get youAreOnlineCaps => 'YOU ARE ONLINE';

  @override
  String get youAreOfflineCaps => 'YOU ARE OFFLINE';

  @override
  String get readyToReceiveRideRequests => 'Ready to receive ride requests';

  @override
  String get switchOnlineToStartEarning => 'Switch online to start earning';

  @override
  String get gpsTrackingActive => 'GPS Tracking Active • Updating every 30s';

  @override
  String get todayTrips => 'Today Trips';

  @override
  String tripsCount(Object count) {
    return '$count Trips';
  }

  @override
  String get rating => 'Rating';

  @override
  String get todaysRecentTrips => 'Today\'s Recent Trips';

  @override
  String get recentCompletedTrips => 'Recent Completed Trips';

  @override
  String completedCount(Object count) {
    return '$count Completed';
  }

  @override
  String get noCompletedTripsYet => 'No completed trips yet';

  @override
  String get switchOnlineToAcceptRides =>
      'Switch online to start accepting rides!';

  @override
  String tripNumber(Object id) {
    return 'TRIP #$id';
  }

  @override
  String get earningsAndPayouts => 'Earnings & Payouts';

  @override
  String get instantBankPayout => 'INSTANT BANK PAYOUT';

  @override
  String get transferEarningsDirectly =>
      'Transfer earnings directly to your bank account';

  @override
  String get availablePayoutBalance => 'Available Payout Balance';

  @override
  String get connectedBankAccount => 'Connected Bank Account';

  @override
  String get primaryPayoutMethod => 'Primary Payout Method';

  @override
  String get confirmPayoutTransfer => 'CONFIRM PAYOUT TRANSFER';

  @override
  String get noBalanceToWithdraw => 'NO BALANCE TO WITHDRAW';

  @override
  String payoutTransferredSuccess(Object amount) {
    return '🎉 Instant payout of ₹ $amount transferred to your bank account!';
  }

  @override
  String get payoutFailed => 'Payout transfer failed. Please try again.';

  @override
  String get todayFilter => 'Today';

  @override
  String get thisWeekFilter => 'This Week';

  @override
  String get allTimeFilter => 'All Time';

  @override
  String totalEarningsFilter(Object filter) {
    return 'Total Earnings ($filter)';
  }

  @override
  String completedTripsSummary(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Trips',
      one: 'Trip',
    );
    return '$count Completed $_temp0';
  }

  @override
  String get tripsFare85 => 'Trips Fare (85%)';

  @override
  String get surgeAndIncentives => 'Surge & Incentives';

  @override
  String get payoutBankAccount => 'Payout Bank Account';

  @override
  String get bankAccountLinked => 'Bank Account Linked';

  @override
  String get verified => 'Verified';

  @override
  String get availableForPayout => 'Available for Payout:';

  @override
  String get withdraw => 'WITHDRAW';

  @override
  String get completedTripPayouts => 'Completed Trip Payouts';

  @override
  String totalCount(Object count) {
    return '$count Total';
  }

  @override
  String get noCompletedPayoutsYet => 'No Completed Trip Payouts Yet';

  @override
  String get acceptDeliveriesToEarn =>
      'Accept and complete delivery orders to earn and see your payouts here.';

  @override
  String get completed => 'Completed';

  @override
  String get partnerNotifications => 'Partner Notifications';

  @override
  String alertsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alerts',
      one: 'Alert',
    );
    return '$count $_temp0';
  }

  @override
  String get noNewNotifications => 'No New Notifications';

  @override
  String get caughtUpMessage =>
      'You are all caught up! High demand alerts and account updates will appear here.';

  @override
  String get accountFullyVerifiedTitle => '✅ Account Fully Verified';

  @override
  String get accountFullyVerifiedMsg =>
      'Your driver profile, vehicle documents, and bank details are active.';

  @override
  String get verificationInProgressTitle => '⏳ Verification In Progress';

  @override
  String get verificationInProgressMsg =>
      'Your driver documentation is under admin review.';
}
