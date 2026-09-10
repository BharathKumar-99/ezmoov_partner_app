import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../widgets/gradient_button.dart';

/// Shows a dialog displaying the EZMoov Driver Partner Agreement & Platform Terms of Use
/// and allows the driver partner to accept or decline.
Future<bool?> showTermsAndConditionsDialog(
  BuildContext context, {
  int initialTabIndex = 0,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogCtx) =>
        TermsAndConditionsDialog(initialTabIndex: initialTabIndex),
  );
}

class TermsAndConditionsDialog extends StatefulWidget {
  final int initialTabIndex;

  const TermsAndConditionsDialog({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<TermsAndConditionsDialog> createState() =>
      _TermsAndConditionsDialogState();
}

class _TermsAndConditionsDialogState extends State<TermsAndConditionsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
          maxWidth: 620,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Fixed Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.primaryDark,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EZMoov Partner Legal Terms',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'EZMOOV AGGREGATORS SOLUTIONS INDIA PVT LTD',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textMuted, size: 22),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Segmented Tab Selector
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: AppColors.primaryDark,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: [
                        Tab(text: l10n.driverPartnerAgreement),
                        Tab(text: l10n.platformTermsOfUse),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Tab Views with Full Legal Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDriverPartnerAgreementView(context),
                  _buildPlatformTermsOfUseView(context),
                ],
              ),
            ),

            // 3. Fixed Footer with Acceptance CTA
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GradientButton(
                    text: l10n.acceptTerms,
                    icon: Icons.check_circle_rounded,
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(
                      l10n.decline,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// -------------------------------------------------------------
  /// TAB 1: DRIVER PARTNER TECHNOLOGY ACCESS AGREEMENT
  /// -------------------------------------------------------------
  Widget _buildDriverPartnerAgreementView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildCorporateBox(
            title: 'DRIVER PARTNER TECHNOLOGY ACCESS AGREEMENT',
            effectiveDate: 'Effective Date: 22/08/2026',
          ),

          const SizedBox(height: 14),

          // Key Highlights
          _buildHighlightBadge(
            icon: Icons.handshake_rounded,
            color: const Color(0xFF059669),
            title: 'Independent Contractor with Gig Worker Protections',
            body:
                'You operate your own business with full freedom over your hours and loads. You are protected under the Telangana Platform Based Gig Workers Act 2026. EZMoov takes 0% commission on your trips.',
          ),
          const SizedBox(height: 10),
          _buildHighlightBadge(
            icon: Icons.assignment_rounded,
            color: const Color(0xFF0284C7),
            title: 'Carrier Status & Goods Forwarding Note (GFN)',
            body:
                'You are the carrier. The customer is strictly responsible for loading & unloading. Always complete the Goods Forwarding Note (GFN) to protect your liability under Rule 12 Carriage by Road Rules 2011.',
          ),

          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),

          _buildClauseItem(
            number: '1',
            title: 'Parties, and what this is',
            content:
                'This Agreement is between EZmoov Aggregators Solutions India Private Limited (“Company”, “we”, “us”, “our”) and you, the registered Driver Partner (“you”, “your”).\n\n'
                'This is a technology access agreement. You are buying access to software. It is a schedule to our Platform Terms of Use and forms a binding electronic contract under section 10A of the Information Technology Act 2000.',
          ),

          _buildClauseItem(
            number: '2',
            title: 'What each of us does',
            content:
                '2.1 What we do:\n'
                'We give you access to software showing loads posted by Customers with computed Fares. We verify statutory documents, provide GFN forms, and assist with disputes.\n\n'
                '2.2 What you do:\n'
                'You are the carrier. You decide which loads to take, contract directly with the Customer, carry the goods, and receive payment directly including Waiting Charges. Customer handles loading/unloading (clause 5A).\n\n'
                '2.3 What we are NOT:\n'
                '• We do not pay you or take any commission from your earnings.\n'
                '• We compute the Fare but do not compel acceptance — declining carries zero cost or penalty.\n'
                '• We do not take custody of goods and issue no consignment notes.',
          ),

          _buildClauseItem(
            number: '3',
            title: 'Your status & Gig Worker rights',
            content:
                '3.1 Independent Contractor:\n'
                'You run your own business, choose when to work, and are free to use other platforms or serve personal clients.\n\n'
                '3.2 Gig Worker Protections:\n'
                'The Telangana Platform Based Gig Workers (Registration, Social Security and Welfare) Act 2026 applies to you in logistics services. Rights under this Act, the Code on Social Security 2020, and Consumer Protection Act 2019 remain fully protected.\n\n'
                '3.3 Customer Status:\n'
                'You pay for software access, making you our customer with rights against unfair deactivations or system failures.',
          ),

          _buildClauseItem(
            number: '4',
            title: 'Documents & Verification',
            content:
                'Mandatory statutory documents:\n'
                '1. Certificate of Registration (RC with GVW)\n'
                '2. Certificate of Fitness (MV Act s.56)\n'
                '3. Goods Carriage Permit (MV Act s.66/79)\n'
                '4. National Permit / Countersignature for Telangana & AP interstate travel\n'
                '5. Certificate of Insurance (MV Act s.146)\n'
                '6. Pollution Under Control (PUC) Certificate\n'
                '7. Road Tax / MV Tax receipts\n'
                '8. Vehicle Location Tracking Device (where required)\n'
                '9. PAN Card (Mandatory for 0.1% TDS vs 5% default rate)\n\n'
                'We verify via DigiLocker, Parivahan and Sarathi. Reminders are sent 30, 15, and 7 days before expiry. Lapsed documents result in automatic deactivation until updated.',
          ),

          _buildClauseItem(
            number: '5 & 5.3',
            title: 'Loads, Quoting & Overloading Rules',
            content:
                '• Free Choice: You may decline any load without penalty or rating impact.\n'
                '• Overloading strictly prohibited: Never exceed registered GVW. Overload fine is ₹20,000 + ₹2,000/tonne under MV Act section 194(1).\n'
                '• If load tendered is heavier than declared, refuse or report in-app immediately before loading to protect yourself against penalties.\n'
                '• Valid-reason cancellations (unreachable customer, wrong address, overloaded cargo, unsafe packing, breakdown) incur NO penalty.',
          ),

          _buildClauseItem(
            number: '5A & 5B',
            title: 'Loading & Waiting Charges',
            content:
                '• 5A. Loading/Unloading: Strictly the Customer’s responsibility. Driver Partner is not required to handle cargo.\n\n'
                '• 5B. Waiting Charges (100% to Driver):\n'
                '  - 2W Bike/Moped (20kg): 20 mins free · ₹1.00 - ₹1.50/min thereafter\n'
                '  - 3W (500kg): 40 mins free · ₹3.00/min thereafter\n'
                '  - 4W (750kg): 50 mins free · ₹3.50/min thereafter\n'
                '  - 4W (1,200kg): 80 mins free · ₹4.00/min thereafter\n'
                '  - 4W (1,700-2,000kg): 110 mins free · ₹7.00 - ₹7.50/min thereafter\n'
                'Mark arrival in app to start the official timer.',
          ),

          _buildClauseItem(
            number: '5C',
            title: 'Vehicle Breakdown & Transhipment Protocol',
            content:
                '• Breakdown costs (towing/repairs) are borne by driver.\n'
                '• Responsibility for goods continues during transit.\n'
                '• Transhipment requires 4 conditions: (1) Customer consent in-app, (2) verified replacement driver, (3) app record of transfer, (4) GFN amendment.\n'
                '• EZMoov re-opens the load for the remaining distance at no extra charge to assist.',
          ),

          _buildClauseItem(
            number: '6',
            title: 'Carrier Position & Goods Forwarding Note (GFN)',
            content:
                'Section 8 & Rule 12 Carriage by Road Rules 2011:\n'
                'Total loss liability is capped at 10x freight or declared value in GFN. Without a GFN, liability may be uncapped.\n'
                'Always complete the GFN form in the app before loading!',
          ),

          _buildClauseItem(
            number: '7 & 8',
            title: 'Fare Transparency & Daily Access Fee',
            content:
                '• Zero Commission: EZMoov takes 0% commission on trip fares.\n'
                '• Daily Access Fee: ₹30 (2W), ₹150 (3W), ₹175 (4W 750kg), ₹236 (4W 1200-2000kg). Fully voluntary daily access with no subscription, lock-in, or auto-debit.\n'
                '• Full refunds granted if the app is unavailable or deactivation occurs in error.',
          ),

          _buildClauseItem(
            number: '9',
            title: 'TDS Withholding & Tax Compliance',
            content:
                'Under Section 393 of the Income-tax Act 2025 (formerly Sec 194-O), 0.1% TDS is collected and remitted to the Government on your behalf with Form 16A issued. PAN is mandatory to prevent statutory 5% withholding rate.',
          ),

          _buildClauseItem(
            number: '11',
            title: 'Driving Hours & Fatigue Management',
            content:
                '• Maximum 5 hours continuous driving without 30 mins rest\n'
                '• Maximum 8 hours driving in 24 hours / 48 hours in a week\n'
                '• Minimum 9 hours rest between duty shifts\n'
                '• Drivers are NEVER penalised or de-prioritised for taking rest.',
          ),

          _buildClauseItem(
            number: '12 - 18',
            title: 'System Dispatch, Termination & Dispute Resolution',
            content:
                '• No algorithmic bias or paid ranking preference.\n'
                '• 7 days prior written notice with reasons before termination (except immediate suspension for grave safety threats).\n'
                '• Appeal to Internal Dispute Resolution Committee within 30 days (decision within 15 days).\n'
                '• Point of Contact: Prashanth Kumar Pippari (Director, driverpartners@ezmoov.in, 78935-49745).\n'
                '• Grievance Officer: Prashanth Kumar Pippari (grievance@ezmoov.in, Hyderabad – 500081, Telangana).',
          ),

          _buildClauseItem(
            number: '19 - 21',
            title: 'Gig Worker Welfare & Legal Jurisdiction',
            content:
                '• Aggregator registered under Telangana Platform Based Gig Workers Act 2026. EZMoov bears all welfare board fees without deducting from drivers.\n'
                '• Indian Law applies with jurisdiction of courts at Hyderabad, Telangana.\n\n'
                'By tapping "Accept Terms" below, you confirm full electronic acceptance of this Driver Partner Agreement.',
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// -------------------------------------------------------------
  /// TAB 2: PLATFORM TERMS OF USE
  /// -------------------------------------------------------------
  Widget _buildPlatformTermsOfUseView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildCorporateBox(
            title: 'PLATFORM TERMS OF USE',
            effectiveDate: 'Version 3.0 · Effective: 22/08/2026',
          ),

          const SizedBox(height: 14),

          _buildHighlightBadge(
            icon: Icons.shield_outlined,
            color: const Color(0xFF4F46E5),
            title: 'General Platform Terms & Intermediary Role',
            body:
                'Applies to all users of EZMoov. EZMoov is an intermediary software platform under IT Act 2000. Carriage contracts are formed directly between customer and carrier.',
          ),

          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),

          _buildClauseItem(
            number: '1 - 3',
            title: 'Who We Are & What We Do',
            content:
                'EZMOOV AGGREGATORS SOLUTIONS INDIA PVT LTD (CIN: U52290TS2026PTC220130), Madhapur, Shaikpet, Hyderabad – 500081, Telangana.\n\n'
                'We operate software matching logistics load requests with independent drivers in Telangana & AP. We do not transport goods, own vehicles, or collect freight. Customers pay drivers directly with 0% platform commission.',
          ),

          _buildClauseItem(
            number: '4 - 5B',
            title: 'Booking Flow, Fares & Waiting Charges',
            content:
                '• 11-step Booking workflow connecting customer and driver.\n'
                '• Published fare computation from category and distance.\n'
                '• Free waiting periods (20m 2W, 40m 3W, 50-110m 4W) with subsequent per-minute charges going 100% to driver partner.',
          ),

          _buildClauseItem(
            number: '6 - 10',
            title: 'Verification, GFN & Insurance Notice',
            content:
                '• Document verification via DigiLocker / Sarathi / Parivahan.\n'
                '• Goods Forwarding Note under Section 8 Carriage by Road Act 2007 limits loss liability under Rule 12.\n'
                '• Customer is responsible for loading/unloading.\n'
                '• Motor insurance covers 3rd party liability only; cargo insurance is separate.',
          ),

          _buildClauseItem(
            number: '11 - 18',
            title: 'Prohibited Items, Intermediary Diligence & Liability',
            content:
                '• Prohibited items: LPG/petroleum, explosives, narcotics, contraband, unpermitted cargo.\n'
                '• IT Rules 2021/2026 intermediary due diligence with CERT-In reporting.\n'
                '• Fair placement based on distance and rating without sold placement.\n'
                '• Company liability capped at preceding 3 months access fees.',
          ),

          _buildClauseItem(
            number: '19 - 23',
            title: 'Statutory Info, Grievance Officers & Acknowledgement',
            content:
                '• Grievance Officer: Prashanth Kumar Pippari (Director, grievance@ezmoov.in)\n'
                '• Nodal Officer: Sabitha Pippari (Director, nodal@ezmoov.in)\n'
                '• Support: support@ezmoov.in · 040-35699710\n'
                '• Exclusive Jurisdiction: Hyderabad, Telangana.',
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildCorporateBox({
    required String title,
    required String effectiveDate,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'EZMOOV AGGREGATORS SOLUTIONS INDIA PVT LTD (CIN: U52290TS2026PTC220130)',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Sy No. 17, Unit No. 701, 7th Floor, Tower 1, Madhapur, Shaikpet, Hyderabad – 500081, Telangana',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            effectiveDate,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFFB45309),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBadge({
    required IconData icon,
    required Color color,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClauseItem({
    required String number,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Clause $number',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
