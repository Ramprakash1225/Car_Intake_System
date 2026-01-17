import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tn_market_kings_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/ai_disclaimer.dart';
import '../widgets/feature_image.dart';
import '../utils/language_helper.dart';
import '../utils/image_helper.dart';

class TNMarketKingsScreen extends StatefulWidget {
  const TNMarketKingsScreen({super.key});

  @override
  State<TNMarketKingsScreen> createState() => _TNMarketKingsScreenState();
}

class _TNMarketKingsScreenState extends State<TNMarketKingsScreen> {
  final Map<int, bool> _expandedVehicles = {};

  @override
  void initState() {
    super.initState();
    // Load TN market kings from Gemini AI when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TNMarketKingsProvider>(context, listen: false)
          .loadTNMarketKings(forceRefresh: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tnMarketKingsProvider = Provider.of<TNMarketKingsProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(currentRoute: '/tn-market-kings'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width < 768 ? 12 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width < 768 ? 16 : 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1E3A8A),
                          Colors.deepOrange.shade700,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.king_bed,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          languageProvider.translate(
                                            'TN Market Kings',
                                            'தமிழக மார்க்கெட் கிங்ஸ்',
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    768
                                                ? 24
                                                : 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (tnMarketKingsProvider
                                          .isUsingFallbackData)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade700,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.info_outline,
                                                  size: 12,
                                                  color: Colors.white),
                                              const SizedBox(width: 3),
                                              Text(
                                                languageProvider.translate(
                                                    'Sample', 'மாதிரி'),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    languageProvider.translate(
                                      'Top 5 Pre-Owned Market Leaders',
                                      'முதல் 5 பயன்படுத்தப்பட்ட சந்தை தலைவர்கள்',
                                    ),
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  768
                                              ? 12
                                              : 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => tnMarketKingsProvider
                                  .loadTNMarketKings(forceRefresh: true),
                              icon: const Icon(Icons.refresh,
                                  color: Colors.white, size: 20),
                              tooltip: languageProvider.translate(
                                  'Refresh', 'புதுப்பிக்க'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 16),
                  // // Date Header
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 16, vertical: 12),
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey.shade100,
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(color: Colors.grey.shade300),
                  //   ),
                  //   child: Text(
                  //     languageProvider.translate(
                  //         'Date: December 24, 2025', 'தேதி: டிசம்பர் 24, 2025'),
                  //     style: TextStyle(
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.grey.shade800,
                  //     ),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  // Vehicles List
                  if (tnMarketKingsProvider.isLoading &&
                      tnMarketKingsProvider.marketKings.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (tnMarketKingsProvider.error != null &&
                      tnMarketKingsProvider.marketKings.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade700, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            languageProvider.translate(
                              'Error loading data: ${tnMarketKingsProvider.error}',
                              'தரவை ஏற்றுவதில் பிழை: ${tnMarketKingsProvider.error}',
                            ),
                            style: TextStyle(
                                color: Colors.red.shade700, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else if (tnMarketKingsProvider.marketKings.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          languageProvider.translate(
                            'No data found',
                            'தரவு கிடைக்கவில்லை',
                          ),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ),
                    )
                  else
                    ...tnMarketKingsProvider.marketKings
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final vehicle = entry.value;
                      return _VehicleCard(
                        vehicle: vehicle,
                        index: index,
                        isExpanded: _expandedVehicles[index] ?? false,
                        onToggle: () {
                          setState(() {
                            _expandedVehicles[index] =
                                !(_expandedVehicles[index] ?? false);
                          });
                        },
                      );
                    }),
                  const SizedBox(height: 20),
                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.orange.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              languageProvider.translate(
                                  'Disclaimer:', 'மறுப்பு:'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          languageProvider.translate(
                            'This is a guide based on market research. Profit may vary depending on the vehicle\'s condition and documents.',
                            'இது சந்தை ஆய்வுகளின் அடிப்படையிலான வழிகாட்டுதலே. வாகனத்தின் நிலை மற்றும் ஆவணங்களைப் பொறுத்து லாபம் மாறுபடும்.',
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // AI Disclaimer with Confidence Score
                  const SizedBox(height: 24),
                  AIDisclaimer(
                    confidenceScore:
                        tnMarketKingsProvider.isUsingFallbackData ? 0.70 : 0.85,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final int index;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _VehicleCard({
    required this.vehicle,
    required this.index,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = vehicle['imageUrl']?.toString() ?? '';
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image - Half width
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: FeatureImage(
                imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                fallbackAsset: ImageHelper.tnMarketKingsFallback,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          // Content - Half width
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 14 : 18),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title: Brand Model | TN Market King
                    Text(
                      '### ${vehicle['brand']} ${vehicle['model']} | TN Market King',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // The 'Wow' Factor (2 lines)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star,
                              color: Colors.green.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              vehicle['wowFactor']?.toString() ?? '',
                              style: TextStyle(
                                fontSize: isMobile ? 13 : 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade900,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Business Metrics (Short Labels for Mobile)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          _MetricRow(
                            label: Provider.of<LanguageProvider>(context)
                                .translate('Indian Sales:', 'இந்திய விற்பனை:'),
                            value: vehicle['indianSales']?.toString() ?? 'N/A',
                            isMobile: isMobile,
                          ),
                          const SizedBox(height: 8),
                          _MetricRow(
                            label: Provider.of<LanguageProvider>(context)
                                .translate(
                                    'Resale Value:', 'மறுவிற்பனை மதிப்பு:'),
                            value: vehicle['resaleValue']?.toString() ?? 'High',
                            isMobile: isMobile,
                          ),
                          const SizedBox(height: 8),
                          _MetricRow(
                            label: Provider.of<LanguageProvider>(context)
                                .translate('Maintenance:', 'பராமரிப்பு:'),
                            value:
                                vehicle['maintenance']?.toString() ?? 'Medium',
                            isMobile: isMobile,
                          ),
                          const SizedBox(height: 8),
                          _MetricRow(
                            label: Provider.of<LanguageProvider>(context)
                                .translate('Sales Speed:', 'விற்பனை வேகம்:'),
                            value:
                                vehicle['salesSpeed']?.toString() ?? '3-5 Days',
                            isMobile: isMobile,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Read More Button
                    if (!isExpanded)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: onToggle,
                          icon: const Icon(Icons.arrow_downward, size: 16),
                          label: Text(
                            Provider.of<LanguageProvider>(context)
                                .translate('Read More', 'மேலும் படிக்க'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TN Business Insight (5-6 short lines)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              LanguageHelper.getAIContent(
                                  context, vehicle, 'tnBusinessInsight'),
                              style: TextStyle(
                                fontSize: isMobile ? 13 : 14,
                                color: Colors.grey.shade800,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Context Label
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: Colors.deepOrange.shade200),
                            ),
                            child: Text(
                              Provider.of<LanguageProvider>(context).translate(
                                  '[TN Business Insights]',
                                  '[தமிழக பிசினஸ் இன்சைட்ஸ்]'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: onToggle,
                              icon: const Icon(Icons.arrow_upward, size: 16),
                              label: Text(
                                Provider.of<LanguageProvider>(context)
                                    .translate('Read Less', 'குறைவாக படிக்க'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMobile;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              color: Colors.grey.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
