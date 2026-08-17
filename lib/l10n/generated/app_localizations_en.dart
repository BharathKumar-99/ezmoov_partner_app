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

  @override
  String get vehicleDetails => 'Vehicle Details';

  @override
  String get vehicleOwnerName => 'Vehicle Owner Name (Optional)';

  @override
  String get vehicleOwnerHint =>
      'Enter owner name if vehicle is registered to someone else';

  @override
  String get uploadRcPicture => 'Upload RC Picture *';

  @override
  String get vehicleRcPhoto => 'Vehicle RC Photo';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get tapToAttachRc => 'Tap to attach clear photo of RC';

  @override
  String get selectCityOfOperation => 'Select the city of operation';

  @override
  String get selectVehicleType => 'Select Vehicle Type';

  @override
  String get selectVehicleBodyDetails => 'Select Vehicle Body Details';

  @override
  String get selectVehicleBodyType => 'Select the vehicle body type';

  @override
  String get openBody => 'Open';

  @override
  String get closedBody => 'Closed';

  @override
  String get selectVehicleFuelType => 'Select the vehicle fuel type';

  @override
  String get saveAndContinue => 'Save & Continue';

  @override
  String get partnerPayoutBankAccount => 'Partner Payout Bank Account';

  @override
  String get addBankAccountDetails => 'Add your bank account details.';

  @override
  String get accountHolderName => 'Account Holder Name *';

  @override
  String get bankName => 'Bank Name *';

  @override
  String get accountNumber => 'Account Number *';

  @override
  String get ifscCode => 'IFSC Code *';

  @override
  String get upiIdOptional => 'UPI ID (Optional)';

  @override
  String get uploadPassbook => 'Upload Passbook / Cancelled Cheque (Optional)';

  @override
  String get passbookPhoto => 'Passbook / Cheque Photo';

  @override
  String get tapToAttachPassbook =>
      'Tap to attach clear photo of passbook/cheque';

  @override
  String get submitBankDetails => 'Submit Bank Details';

  @override
  String get loginDescription =>
      'Welcome back! Enter your registered mobile number to continue.';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get continueText => 'Continue';

  @override
  String get driverRegistration => 'Driver Registration';

  @override
  String get joinEzmoovFleet => 'Join EZMoov Fleet';

  @override
  String get createYourPartnerProfile =>
      'Create your partner profile to start taking trips.';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get referralCodeOptional => 'Referral Code (Optional)';

  @override
  String get signUpAndContinue => 'Sign Up & Continue';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get dontHaveAccount => 'Don\'t have a partner account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get login => 'Login';

  @override
  String get otpVerification => 'OTP Verification';

  @override
  String get enterVerificationCode => 'Enter Verification Code';

  @override
  String get weHaveSentOtpTo => 'We have sent a 6-digit OTP code to ';

  @override
  String get verifyAndContinue => 'Verify & Continue';

  @override
  String get didntReceiveCode => 'Didn\'t receive code? ';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get fullOperationalAddress => 'Full Operational Address *';

  @override
  String get tcRcPermitNumber => 'TC / RC Permit Number *';

  @override
  String get truck => 'Truck';

  @override
  String get threeWheeler => '3W';

  @override
  String get vehiclePermit => 'Vehicle Permit';

  @override
  String get uploadVehiclePermit => 'Upload Vehicle Permit';

  @override
  String get documentVerification => 'Document Verification';

  @override
  String get uploadRequiredDocumentsSubtitle =>
      'Upload required documentation for verification';

  @override
  String get aadhaarCard => 'Aadhaar Card';

  @override
  String get uploadAadhaarCard => 'Upload Aadhaar Card';

  @override
  String get drivingLicense => 'Driving License';

  @override
  String get uploadDrivingLicense => 'Upload Driving License';

  @override
  String get vehicleRc => 'Vehicle RC';

  @override
  String get uploadVehicleRc => 'Upload Vehicle RC';

  @override
  String get panCard => 'PAN Card';

  @override
  String get uploadPanCard => 'Upload PAN Card';

  @override
  String get vehicleInsurance => 'Vehicle Insurance';

  @override
  String get uploadVehicleInsurance => 'Upload Vehicle Insurance';

  @override
  String get pucCertificate => 'PUC Certificate';

  @override
  String get uploadPucCertificate => 'Upload PUC Certificate';

  @override
  String get fitnessCertificate => 'Fitness Certificate';

  @override
  String get uploadFitnessCertificate => 'Upload Fitness Certificate';

  @override
  String get policeClearanceCertificate => 'Police Clearance Certificate';

  @override
  String get uploadPoliceClearance => 'Upload Police Clearance Certificate';

  @override
  String get selfieWithVehicle => 'Selfie with Vehicle';

  @override
  String get uploadSelfieWithVehicle => 'Upload Selfie with Vehicle';

  @override
  String get autoVerifiedDigilocker => 'Auto-Verified via DigiLocker API';

  @override
  String get autoVerifiedApi => 'Auto-Verified via API';

  @override
  String get autoVerifiedVahan => 'Auto-Verified via Vahan API';

  @override
  String get certificateUpload => 'Certificate Upload';

  @override
  String get officialCitizenPortal => 'Official state citizen portal';

  @override
  String get selfieWithVehicleSubtitle =>
      'Clear photo of driver standing with vehicle';

  @override
  String get submitDocuments => 'Submit Documents';

  @override
  String get attached => 'Attached';

  @override
  String get required => 'Required';

  @override
  String get changeDocument => 'Change Document';

  @override
  String get takePhotoCamera => 'Take Photo with Camera';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get accountVerification => 'Account Verification';

  @override
  String get verificationUnderReview => 'Verification Under Review';

  @override
  String get verificationUnderReviewDesc =>
      'Your vehicle and document submissions have been received. Access to the driver home dashboard will be unlocked once approved by our verification team.';

  @override
  String get mobilePhoneAndIdentity => 'Mobile Phone & Identity';

  @override
  String get phoneOtpVerified => 'Phone OTP Verified';

  @override
  String get vehicleRegistrationAndRc => 'Vehicle Registration & RC';

  @override
  String get vehicleVerifiedByAdmin => 'Vehicle Verified by Admin';

  @override
  String get rcSubmittedReviewing => 'RC Photo Submitted - Reviewing';

  @override
  String get certificatesVerifiedByAdmin => 'Certificates Verified by Admin';

  @override
  String get certificatesSubmittedReviewing =>
      'PUC, Permit, Fitness, PCC Submitted - Reviewing';

  @override
  String get bankAccountPayouts => 'Bank Account Payouts';

  @override
  String get bankAccountVerified => 'Bank Account Verified';

  @override
  String get bankDetailsSubmittedReviewing =>
      'Bank Details Submitted - Reviewing';

  @override
  String get checkVerificationStatus => 'Check Verification Status';

  @override
  String get logOutAndExit => 'Log Out & Exit';

  @override
  String get verificationApprovedMsg =>
      '🎉 Verification Approved! Welcome to EZMoov Fleet.';

  @override
  String get verificationStillPendingMsg =>
      'Verification still pending admin review. Please check back shortly.';

  @override
  String get emergencySos => 'EMERGENCY SOS';

  @override
  String get callAmbulance108 => 'Call Ambulance (108)';

  @override
  String get sosButtonText => 'SOS (108)';

  @override
  String get tapToCallAmbulance => 'Tap to call Ambulance (108) from dialer';

  @override
  String get cancelTrip => 'Cancel Trip';

  @override
  String get confirmCashPayment => 'Confirm Cash Payment';

  @override
  String get yesReceivedCash => 'YES, RECEIVED CASH';

  @override
  String get cargoPickupPhoto => 'CARGO PICKUP PHOTO';

  @override
  String get cargoPhotoMandatory =>
      'Photo of loaded cargo is MANDATORY to start trip';

  @override
  String get proofOfDelivery => 'PROOF OF DELIVERY (POD)';

  @override
  String get startTrip => 'START TRIP';

  @override
  String get completeTrip => 'COMPLETE TRIP';

  @override
  String get referAndEarnPartnerBonus => 'Refer & Earn Partner Bonus';

  @override
  String get yourReferralCode => 'YOUR REFERRAL CODE';

  @override
  String get copyCode => 'Copy Code';

  @override
  String get codeCopied => 'Referral code copied to clipboard!';

  @override
  String get shareCodeWithDrivers =>
      'Share your code with fellow drivers to earn bonus rewards when they complete their first 5 trips.';

  @override
  String get redeemReferralCode => 'Redeem Referral Code';

  @override
  String get haveReferralCode => 'Have a Referral Code?';

  @override
  String get applyCode => 'Apply Code';
}
