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
  String get pickupLocation => 'PICKUP LOCATION';

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
  String get iAgreeTo => 'I agree to the ';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get and => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get driverPartnerAgreement => 'Driver Partner Agreement';

  @override
  String get platformTermsOfUse => 'Platform Terms of Use';

  @override
  String get acceptTermsToContinue =>
      'Please accept the Terms & Conditions to continue.';

  @override
  String get partnerTermsAndConditionsTitle => 'Terms & Conditions';

  @override
  String get partnerAgreement => 'EZMoov Partner Agreement';

  @override
  String get acceptAndContinue => 'Accept & Continue';

  @override
  String get acceptTerms => 'Accept Terms';

  @override
  String get decline => 'Decline';

  @override
  String get pleaseReadAndAcceptTerms =>
      'Please review and accept our Partner Terms & Conditions to complete your registration.';

  @override
  String get termsSection1Title => '1. Driver Partner Agreement';

  @override
  String get termsSection1Desc =>
      'By registering, you agree to provide transportation services safely and professionally according to EZMoov standards.';

  @override
  String get termsSection2Title => '2. Documents & Verification';

  @override
  String get termsSection2Desc =>
      'You agree to provide valid driver\'s license, vehicle registration, and permits. False information may lead to account termination.';

  @override
  String get termsSection3Title => '3. Fares & Platform Payments';

  @override
  String get termsSection3Desc =>
      'Payouts and service fees follow the EZMoov platform policy. Earnings will be credited to your verified bank account.';

  @override
  String get termsSection4Title => '4. Safety & Conduct';

  @override
  String get termsSection4Desc =>
      'Drivers must follow all traffic regulations, maintain vehicle fitness, and treat customers with respect.';

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
  String get callAmbulance108 => 'CALL AMBULANCE (108)';

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

  @override
  String get performance => 'Performance';

  @override
  String get todayLoginHours => 'Today Login Hours';

  @override
  String get viewPerformanceHistory =>
      'Tap to view login hours and session breakdown';

  @override
  String get totalLoginHours => 'Total Login Hours';

  @override
  String get loginSessions => 'Login Sessions';

  @override
  String get noLoginSessions => 'No login sessions recorded for this date';

  @override
  String get session => 'Session';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get selectDate => 'Select Date';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get systemStatus => 'System Status';

  @override
  String get scheduledDowntime => 'SCHEDULED DOWNTIME';

  @override
  String get appUnderMaintenance => 'App Under Maintenance';

  @override
  String get maintenanceInProgressDesc =>
      'We are currently performing scheduled maintenance to upgrade our partner systems. Driver services and bookings are temporarily paused. We will be back shortly!';

  @override
  String get whatYouNeedToKnow => 'WHAT YOU NEED TO KNOW';

  @override
  String get walletAndEarningsSafe => 'Wallet & Earnings are 100% Safe';

  @override
  String get walletAndEarningsSafeDesc =>
      'All balance, payouts, and trips remain secure.';

  @override
  String get autoServiceResumption => 'Automatic Service Resumption';

  @override
  String get autoServiceResumptionDesc =>
      'You will be able to go online as soon as maintenance ends.';

  @override
  String get realtimeReconnection => 'Realtime Reconnection';

  @override
  String get realtimeReconnectionDesc =>
      'Tap refresh below to test your connection to our servers.';

  @override
  String get checkServerStatus => 'CHECK SERVER STATUS';

  @override
  String get contactPartnerHelpline => 'Contact Partner Helpline';

  @override
  String get maintenanceCompleteMsg => '🎉 Maintenance complete! Welcome back.';

  @override
  String get maintenanceStillOngoingMsg =>
      'System is still undergoing scheduled maintenance. Please retry in a few moments.';

  @override
  String get appUpdate => 'App Update';

  @override
  String get mandatoryUpdate => 'MANDATORY UPDATE';

  @override
  String get newVersionAvailable => 'NEW VERSION AVAILABLE';

  @override
  String currentVersionLabel(Object version) {
    return 'Current: $version';
  }

  @override
  String latestVersionLabel(Object version) {
    return 'Latest: $version';
  }

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get updateAvailableDesc =>
      'A new and improved version of EZMoov Partner is available. Update now to enjoy enhanced ride allocations, battery optimizations, and performance improvements.';

  @override
  String get whatsNewInThisVersion => 'WHAT\'S NEW IN THIS VERSION';

  @override
  String get fasterOrderMatching => 'Faster Order Matching Speed';

  @override
  String get fasterOrderMatchingDesc =>
      'Get instantly assigned to nearby rides with zero lag.';

  @override
  String get batteryGpsOptimization => 'Battery & GPS Optimization';

  @override
  String get batteryGpsOptimizationDesc =>
      'Smarter background tracking uses 35% less battery.';

  @override
  String get realtimeEarningUpdates => 'Realtime Earning Updates';

  @override
  String get realtimeEarningUpdatesDesc =>
      'Direct calculations and instant payout status.';

  @override
  String get performanceStabilityPatches => 'Performance & Stability Patches';

  @override
  String get performanceStabilityPatchesDesc =>
      'Smooth navigation and enhanced reliability.';

  @override
  String get updateNow => 'UPDATE NOW';

  @override
  String get remindMeLater => 'Remind Me Later';

  @override
  String get mandatoryUpdateNotice =>
      '⚠️ This update is required to continue receiving orders.';

  @override
  String get registrationFeeRequired => 'Registration Fee Required';

  @override
  String get partnerAccountPending => 'PARTNER ACCOUNT PENDING';

  @override
  String get registrationFeeExplanation =>
      'Welcome to EZMoov Partner! To activate your driver profile, go online, and start receiving ride requests, please pay the one-time registration fee.';

  @override
  String get verifiedPartnerBadge => 'Verified EZMoov Partner Badge';

  @override
  String get instantRideDeliveryAllocation =>
      'Instant Ride & Delivery Allocation';

  @override
  String get fullDailyEarningsPayouts => 'Full Daily Earnings & Direct Payouts';

  @override
  String get payRegistrationFee => 'PAY REGISTRATION FEE';

  @override
  String payRegistrationFeeAmount(Object amount) {
    return 'PAY REGISTRATION FEE (₹$amount)';
  }

  @override
  String get refreshStatus => 'Refresh Status';

  @override
  String get registrationFeePaidSuccess =>
      '🎉 Registration fee paid successfully! Partner account is active.';

  @override
  String get registrationFeePaidFailed =>
      'Failed to pay registration fee. Please try again.';

  @override
  String get myPerformance => 'My Performance';

  @override
  String get completionScore => 'Completion Score';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get ordersOverview => 'Orders Overview';

  @override
  String get accepted => 'Accepted';

  @override
  String get declined => 'Declined';

  @override
  String get timeout => 'Timeout';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get totalOffered => 'Total Offered';

  @override
  String get loginHours => 'Login Hours';

  @override
  String get live => 'LIVE';

  @override
  String get dailyPassRequiredTitle => 'Daily Pass Required ⚠️';

  @override
  String dailyPassRequiredDesc(Object fee) {
    return 'Your 24-hour daily pass is expired or unpaid. Pay ₹$fee to activate your pass and go online for 24 hours.';
  }

  @override
  String payDailyFee(Object fee) {
    return 'Pay Daily Fee (₹$fee)';
  }

  @override
  String get activatingPass => 'Activating Pass...';

  @override
  String get ordersPausedTitle => 'Orders Paused for Today ⛔';

  @override
  String get ordersPausedDesc =>
      'You rejected 2 order requests today. Order allocation is paused for the remainder of today.';

  @override
  String get viewWallet => 'View Wallet';

  @override
  String get viewWalletDetails => 'View Wallet Details';

  @override
  String get updatingStatus => 'UPDATING STATUS...';

  @override
  String get updatingOnlineStatus => 'Updating online status...';

  @override
  String get previousDay => 'Previous Day';

  @override
  String get nextDay => 'Next Day';

  @override
  String sessionsRecorded(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sessions',
      one: 'Session',
    );
    return '$count $_temp0 Recorded';
  }

  @override
  String get excellentAcceptance => 'Excellent Acceptance';

  @override
  String get goodPerformance => 'Good Performance';

  @override
  String get highDeclineRate => 'High Decline Rate';

  @override
  String acceptedOfOrders(Object accepted, Object total) {
    return '($accepted accepted of $total orders offered)';
  }

  @override
  String get baselineNoOrders => '(Baseline 100% • No orders offered)';

  @override
  String get startTime => 'START TIME';

  @override
  String get endTime => 'END TIME';

  @override
  String get rideRequestHistory => 'Ride Request History';

  @override
  String requestsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Requests',
      one: 'Request',
    );
    return '$count $_temp0';
  }

  @override
  String get rideAccepted => 'Ride Accepted';

  @override
  String get rideDeclined => 'Ride Declined';

  @override
  String reasonLabel(Object reason) {
    return 'Reason: $reason';
  }

  @override
  String get goOnlineToTrackHours =>
      'Go online from the Home dashboard to track your active login hours.';

  @override
  String get myWallet => 'My Wallet';

  @override
  String get walletBalance => 'Wallet Balance';

  @override
  String get addMoney => 'Add Money';

  @override
  String get addMoneyToWallet => 'Add Money to Wallet';

  @override
  String get addMoneySubtitle =>
      'Recharge your wallet to pay daily vehicle fees and stay active for orders.';

  @override
  String get enterAmount => 'Enter Amount';

  @override
  String get rechargeWallet => 'Recharge Wallet';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get noTransactionsYet => 'No Transactions Yet';

  @override
  String get noTransactionsSubtitle =>
      'Your wallet recharges and daily fee deductions will appear here.';

  @override
  String get dailyPassActive => 'Daily Pass Active';

  @override
  String get dailyPassExpired => 'Daily Pass Inactive';

  @override
  String passValidUntil(Object time) {
    return 'Valid until $time';
  }

  @override
  String get dailyVehicleFee => 'Daily Vehicle Fee';

  @override
  String payFromWallet(Object amount) {
    return 'Pay from Wallet (₹$amount)';
  }

  @override
  String payDirectlyRazorpay(Object amount) {
    return 'Pay with UPI / Razorpay (₹$amount)';
  }

  @override
  String get invitePartnersBannerTitle => 'Invite Partners & Earn ₹25!';

  @override
  String get invitePartnersBannerDesc =>
      'Earn ₹25 wallet cash for every driver partner who registers with your code!';

  @override
  String get yourUniqueReferralCode => 'YOUR UNIQUE REFERRAL CODE';

  @override
  String get shareOnWhatsApp => 'Share on WhatsApp';

  @override
  String get wereYouReferred => 'Were you referred by a partner?';

  @override
  String get enterCodeToLink => 'Enter their code to link your accounts.';

  @override
  String get redeem => 'Redeem';

  @override
  String get referredPartners => 'Referred Partners';

  @override
  String partnersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Partners',
      one: 'Partner',
    );
    return '$count $_temp0';
  }

  @override
  String get noReferralsYet => 'No referrals yet';

  @override
  String get noReferralsDesc =>
      'Share your referral code with fellow drivers to start earning bonuses!';

  @override
  String rewardedStatus(Object amount) {
    return '₹$amount Rewarded';
  }

  @override
  String get pendingVerificationStatus => 'Pending Verification';

  @override
  String get enterReferralCodeDialogDesc =>
      'Enter the referral code given to you by another partner driver to link your accounts.';

  @override
  String get referralCodeFieldLabel => 'Referral Code (e.g. EZM9876)';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changeProfilePicture => 'Change Profile Picture 📸';

  @override
  String get choosePhotoSource =>
      'Choose how you want to update your profile photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';

  @override
  String get customerDeliveryRequest => 'Customer Delivery Request';

  @override
  String withinDistance(Object distance) {
    return 'Within $distance';
  }

  @override
  String get outstationBidding => 'Outstation Bidding';

  @override
  String get biddingStatus => 'Bidding Status';

  @override
  String get customerIsDeciding => 'CUSTOMER IS DECIDING';

  @override
  String get activeTrip => 'Active Trip';

  @override
  String get arrivedAtPickup => 'ARRIVED AT PICKUP';

  @override
  String get startTripCaps => 'START TRIP';

  @override
  String get arrivedAtDropoff => 'ARRIVED AT DROPOFF';

  @override
  String get completeTripCaps => 'COMPLETE TRIP';

  @override
  String get callCustomer => 'Call Customer';

  @override
  String get navigation => 'Navigation';

  @override
  String get rideCancelledByCustomer => '⚠️ Ride was cancelled by customer';

  @override
  String get noActivePendingBidFound => 'No active pending bid found.';

  @override
  String get returnToHome => 'Return to Home';

  @override
  String get customerDecidingDesc =>
      'Your bid is being reviewed by the customer. You can update your bid below at any time.';

  @override
  String get outstationCustomer => 'Outstation Customer';

  @override
  String get baseRate => 'Base Rate';

  @override
  String get yourActiveBid => 'Your Active Bid';

  @override
  String get pickupAddressCaps => 'PICKUP ADDRESS';

  @override
  String get dropAddressCaps => 'DROP ADDRESS';

  @override
  String get submitNewBidAmount => 'SUBMIT A NEW BID AMOUNT (₹)';

  @override
  String get submitLowerPriceDesc =>
      'Submit a lower or competitive price to increase your chances.';

  @override
  String get enterNewBidAmountHint => 'Enter new bid amount';

  @override
  String get pleaseEnterBidAmount => 'Please enter a bid amount';

  @override
  String get enterValidPositiveBid => 'Enter a valid positive bid amount';

  @override
  String get updateBid => 'UPDATE BID';

  @override
  String get withdrawCancelBid => 'Withdraw / Cancel Bid';

  @override
  String get incomingRideRequestCaps => 'INCOMING RIDE REQUEST';

  @override
  String get within3km => 'Within 3 km';

  @override
  String get within10km => 'Within 10 km';

  @override
  String get standardDeliveryOrder => 'Standard Delivery Order';

  @override
  String inclIncentive(Object amount) {
    return 'Incl. ₹$amount incentive 🎁';
  }

  @override
  String intermediateStopsBadge(Object charge, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Stops',
      one: 'Stop',
    );
    return '$count Intermediate $_temp0 (+₹$charge)';
  }

  @override
  String get acceptRideCaps => 'ACCEPT RIDE';

  @override
  String get outstationBiddingRideCaps => 'OUTSTATION BIDDING RIDE';

  @override
  String get outstationBooking => 'Outstation Booking';

  @override
  String get enterYourBidAmountCaps => 'ENTER YOUR BID AMOUNT (₹)';

  @override
  String get bidAmountHint => 'e.g. 1500';

  @override
  String get submitBidCaps => 'SUBMIT BID';

  @override
  String reachedStop(Object stop) {
    return 'REACHED STOP $stop';
  }

  @override
  String completedStop(Object stop) {
    return 'COMPLETED STOP $stop';
  }

  @override
  String get atIntermediateStop => 'AT INTERMEDIATE STOP';

  @override
  String get paymentConfirmedCaps => 'PAYMENT CONFIRMED';

  @override
  String get unloadedAwaitingPayment => 'UNLOADED / AWAITING PAYMENT';

  @override
  String get inTransitToDropoff => 'IN TRANSIT TO DROPOFF';

  @override
  String get headingToPickup => 'HEADING TO PICKUP';

  @override
  String get resumeCaps => 'RESUME';

  @override
  String bidPendingWithAmount(Object amount) {
    return 'BID PENDING • ₹ $amount';
  }

  @override
  String get customerDecidingTapUpdate =>
      'Customer deciding... Tap to update bid';

  @override
  String get viewBidCaps => 'VIEW BID';

  @override
  String stopsBadgeCount(Object count) {
    return '+$count STOPS';
  }

  @override
  String get tripFareBreakdown => 'TRIP FARE BREAKDOWN';

  @override
  String get baseFareIncludes1km => 'Base Fare (Includes 1st KM)';

  @override
  String get distanceChargesBeyond1km => 'Distance Charges (beyond 1 KM)';

  @override
  String stopsChargeLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'stops',
      one: 'stop',
    );
    return 'Stops Charge ($count $_temp0 @ ₹25 each)';
  }

  @override
  String get waitingCharges => 'Waiting Charges';

  @override
  String get taxesAndGst => 'Taxes & GST';

  @override
  String get totalDeliveryFee => 'Total Delivery Fee';

  @override
  String get closeCaps => 'CLOSE';

  @override
  String get onlinePaymentPending => 'Online Payment Pending';

  @override
  String get onlinePaymentPendingDesc =>
      'The customer selected Online Payment (Razorpay). The payment has not been confirmed yet.\n\nPlease ask the customer to complete payment on their phone. The status will automatically update to \"Payment Received\" once paid.';

  @override
  String get waitForPaymentCaps => 'WAIT FOR PAYMENT';

  @override
  String get receivedCashInsteadCaps => 'RECEIVED CASH INSTEAD';

  @override
  String didYouCollectCash(Object amount) {
    return 'Did you collect ₹$amount cash directly from the customer?';
  }

  @override
  String get tripFare => 'Trip Fare';

  @override
  String get farDriverIncentive => 'Far Driver Incentive 🎁';

  @override
  String get totalToCollect => 'Total to Collect';

  @override
  String get cancelCaps => 'CANCEL';

  @override
  String get cancelTripRequest => 'CANCEL TRIP REQUEST';

  @override
  String get selectCancellationReason => 'Please select a cancellation reason';

  @override
  String get reasonNoShow => 'Customer No-Show at Pickup';

  @override
  String get reasonOversized => 'Oversized Goods';

  @override
  String get reasonBreakdown => 'Vehicle Breakdown';

  @override
  String get reasonCustomerRequested => 'Customer Requested Cancellation';

  @override
  String get reasonOther => 'Other Issue';

  @override
  String get confirmCancellationCaps => 'CONFIRM CANCELLATION';

  @override
  String get tripCancelled => 'Trip cancelled.';

  @override
  String get addExtraChargesCaps => 'ADD EXTRA CHARGES';

  @override
  String get addExtraExpensesDesc =>
      'Add extra trip expenses (e.g. Toll, Gas, Parking):';

  @override
  String get chargeName => 'Charge Name';

  @override
  String get chargeNameHint => 'e.g. toll';

  @override
  String get chargeAmount => 'Charge Number / Amount (₹)';

  @override
  String get chargeAmountHint => 'e.g. 55';

  @override
  String get addCaps => 'ADD';

  @override
  String get addedChargesList => 'Added Charges List:';

  @override
  String get submitCaps => 'SUBMIT';

  @override
  String get tapCameraOrGalleryPickup =>
      'Tap Camera or Gallery below to capture pickup photo';

  @override
  String get confirmPhotoAndStartTrip => 'CONFIRM PHOTO & START TRIP';

  @override
  String get pickupPhotoMandatoryAlert =>
      'Please capture or select a pickup photo first!';

  @override
  String get proofOfDeliveryMandatory =>
      'Proof of delivery (POD) photo/signature is MANDATORY to complete trip';

  @override
  String get tapCameraOrGalleryPod =>
      'Tap Camera or Gallery below to capture POD photo';

  @override
  String get customerSignature => 'Customer Signature';

  @override
  String get clearSignature => 'Clear Signature';

  @override
  String get confirmPodAndCompleteTrip => 'CONFIRM POD & COMPLETE TRIP';

  @override
  String get podMandatoryAlert =>
      'Please capture a POD photo or get customer signature first!';

  @override
  String get rateCustomer => 'RATE CUSTOMER';

  @override
  String get howWasExperienceWithCustomer =>
      'How was your experience with the customer?';

  @override
  String get submitRatingCaps => 'SUBMIT RATING';

  @override
  String get customerPhoneNotAvailable => 'Customer phone number not available';

  @override
  String reachedStopMsg(Object stop) {
    return 'Reached Stop $stop!';
  }

  @override
  String completedStopMsg(Object stop) {
    return 'Completed Stop $stop!';
  }

  @override
  String get collectPaymentAndComplete => 'COLLECT PAYMENT & COMPLETE';

  @override
  String get paymentSuccessful => 'Payment Successful! 🎉';

  @override
  String get paymentFailed => 'Payment Failed ❌';

  @override
  String get paymentProcessedDesc =>
      'Your payment was processed successfully! Please note: It may take up to 30 minutes for the updated balance to reflect in your wallet depending on bank/UPI confirmation.';

  @override
  String get gotIt => 'Got it!';

  @override
  String get ok => 'OK';

  @override
  String get waitingTime => 'Waiting Time';

  @override
  String get minShort => 'MIN';

  @override
  String get secShort => 'SEC';

  @override
  String get startNavigation => 'Start Navigation';

  @override
  String get pickupOtpVerified => 'Pickup OTP Verified';

  @override
  String get enterPickupOtp => 'Enter 4-digit Pickup OTP';

  @override
  String get verifyPickupOtp => 'VERIFY OTP';

  @override
  String get invalidOtp => 'Invalid OTP. Please try again.';

  @override
  String couldNotMakeCall(Object error) {
    return 'Could not make call: $error';
  }

  @override
  String couldNotLaunchDialer(Object error) {
    return 'Could not launch dialer for 108: $error';
  }

  @override
  String couldNotOpenSms(Object error) {
    return 'Could not open SMS: $error';
  }

  @override
  String get locationCoordsNotAvailable =>
      'Location coordinates or address not available';

  @override
  String couldNotOpenGoogleMaps(Object error) {
    return 'Could not open Google Maps: $error';
  }

  @override
  String failedToUpdateStatus(Object error) {
    return 'Failed to update status: $error';
  }

  @override
  String errorUpdatingStopStatus(Object error) {
    return 'Error updating stop status: $error';
  }

  @override
  String errorCancellingTrip(Object error) {
    return 'Error cancelling trip: $error';
  }

  @override
  String get enterChargeNameAlert => 'Please enter a charge name (e.g., toll)';

  @override
  String get enterValidChargeAmountAlert =>
      'Please enter a valid numeric charge amount';

  @override
  String failedToUploadPickupPhoto(Object error) {
    return 'Failed to upload pickup photo: $error';
  }

  @override
  String get arrivedPickupNotify =>
      'Customer notified: Driver arrived at pickup location! Loading timer started.';

  @override
  String get cargoPickupSavedTripStarted =>
      'Cargo pickup photo saved! Trip started.';

  @override
  String get arrivedDropoffNotify =>
      'Arrived at final drop-off location! Unloading timer started.';

  @override
  String get cargoUnloadedPodSubmitted =>
      '📦 Cargo unloaded & POD submitted! Awaiting payment.';

  @override
  String get cashPaymentReceivedNotify =>
      'Cash Payment Received! Please confirm trip completion.';

  @override
  String get deliveryCompletedSuccessfully =>
      '🎉 Delivery Completed Successfully!';

  @override
  String get emergencyQuestion => 'Are you in an emergency situation?';

  @override
  String get emergencyAmbulanceDesc =>
      'Tapping \"Call Ambulance 108\" will open your phone dialer to directly call Emergency Ambulance Services (108).';

  @override
  String get tapToCallAmbulanceDesc =>
      'Tap to call Ambulance (108) from dialer';

  @override
  String get sosButtonLabel => 'SOS (108)';

  @override
  String get pickupPhotoMandatory =>
      'Photo of loaded cargo is MANDATORY to start trip';

  @override
  String get proofOfDeliveryPod => 'PROOF OF DELIVERY (POD)';

  @override
  String get podPhotoMandatoryDesc =>
      'Take a photo of delivered goods (MANDATORY)';

  @override
  String get driverExtraCharges => 'Driver Extra Charges:';

  @override
  String get submitPodAndUnloadCargo => 'SUBMIT POD & UNLOAD CARGO';

  @override
  String get podPhotoMandatoryBeforeComplete =>
      'Proof of Delivery photo is MANDATORY before completing delivery.';

  @override
  String get rateTheCustomer => 'RATE THE CUSTOMER';

  @override
  String get howWasExperienceWithTrip =>
      'How was your experience with this trip?';

  @override
  String get addOptionalCommentHint => 'Add optional comment...';

  @override
  String get skipCaps => 'SKIP';

  @override
  String get paymentConfirmedTitle => 'Payment Confirmed';

  @override
  String get awaitingPaymentTitle => 'Awaiting Payment';

  @override
  String get tripInTransitTitle => 'Trip in Transit';

  @override
  String get arrivedAtPickupTitle => 'Arrived at Pickup';

  @override
  String get pickupNavigationTitle => 'Pickup Navigation';

  @override
  String get cancelTripTooltip => 'Cancel Trip';

  @override
  String get paymentReceivedCaps => 'PAYMENT RECEIVED';

  @override
  String get arrivedAtDropoffCaps => 'ARRIVED AT DROP-OFF LOCATION';

  @override
  String get arrivedAtPickupCaps => 'ARRIVED AT PICKUP LOCATION';

  @override
  String get tripInTransitToDropPoint => 'TRIP IN TRANSIT TO DROP POINT';

  @override
  String get paymentConfirmedSubtitle =>
      'Payment confirmed! Tap below to finalize trip completion.';

  @override
  String get collectCashOrWaitOnlineSubtitle =>
      'Collect cash payment or wait for customer online payment.';

  @override
  String get unloadingTimerActiveSubtitle =>
      'Unloading timer active! Submit POD once unloading is complete.';

  @override
  String get loadingTimerActiveSubtitle =>
      'Loading timer active! Tap START TRIP once loaded.';

  @override
  String get onTheWayToDropoffSubtitle => 'On the way to dropoff destination';

  @override
  String get followGpsRouteSubtitle => 'Follow GPS route to customer location';

  @override
  String get customer => 'Customer';

  @override
  String get sendSms => 'Send SMS';

  @override
  String get openGoogleMapsCaps => 'OPEN GOOGLE MAPS';

  @override
  String navigateToTarget(Object target) {
    return 'Navigate to $target';
  }

  @override
  String get customerPickupLocation => 'Customer Pickup Location';

  @override
  String get goCaps => 'GO';

  @override
  String bookingIdWithNumber(Object id) {
    return 'BOOKING #$id';
  }

  @override
  String get customerPickupPoint => 'Customer Pickup Point';

  @override
  String get navigateToPickupGmaps => 'Navigate to Pickup in GMaps';

  @override
  String intermediateStopNumber(Object index) {
    return 'Intermediate Stop $index';
  }

  @override
  String navigateToStopGmaps(Object index) {
    return 'Navigate to Stop $index in GMaps';
  }

  @override
  String stopCompletedCaps(Object index) {
    return '✓ STOP $index COMPLETED';
  }

  @override
  String completeStopNumber(Object index) {
    return 'Complete Stop $index';
  }

  @override
  String reachedStopNumber(Object index) {
    return 'Reached Stop $index';
  }

  @override
  String get customerDropoffPoint => 'Customer Dropoff Point';

  @override
  String get navigateToDropoffGmaps => 'Navigate to Dropoff in GMaps';

  @override
  String get totalDeliveryFareLabel => 'Total Delivery Fare:';

  @override
  String get viewFareBreakdown => 'View Fare Breakdown';

  @override
  String inclFarDriverIncentive(Object amount) {
    return 'Incl. ₹$amount far driver incentive 🎁';
  }

  @override
  String get takePickupPhotoAndStartTrip => 'TAKE PICKUP PHOTO & START TRIP';

  @override
  String completeStopCaps(Object index) {
    return 'COMPLETE STOP $index';
  }

  @override
  String reachedStopCaps(Object index) {
    return 'REACHED STOP $index';
  }

  @override
  String get reachedFinalDestination => 'REACHED FINAL DESTINATION';

  @override
  String get unloadCargoAndSubmitPod => 'UNLOAD CARGO & SUBMIT POD';

  @override
  String collectCashPaymentWithAmount(Object amount) {
    return 'Collect Cash Payment (₹$amount)';
  }

  @override
  String get confirmTripCompleted => 'Confirm Trip Completed';

  @override
  String get backToHome => 'BACK TO HOME';

  @override
  String get dashboard => 'Dashboard';

  @override
  String stopLocationWithIndex(Object index) {
    return 'STOP $index LOCATION';
  }

  @override
  String get intermediateStop => 'INTERMEDIATE STOP';

  @override
  String get finalDropLocation => 'FINAL DROP LOCATION';

  @override
  String get addressDetailsUnavailable => 'Address details unavailable';

  @override
  String get edit => 'Edit';

  @override
  String get freeDriverLoginActive => 'Free Driver Login Active 🎉';

  @override
  String get freeDriverLoginDesc =>
      'Free driver login enabled • No daily fee required to go online';

  @override
  String get freePassBadge => 'FREE PASS';
}
