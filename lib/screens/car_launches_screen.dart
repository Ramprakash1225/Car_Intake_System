import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_launches_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/ai_disclaimer.dart';
import '../widgets/feature_image.dart';
import '../utils/language_helper.dart';
import '../utils/image_helper.dart';

class CarLaunchesScreen extends StatefulWidget {
  const CarLaunchesScreen({super.key});

  @override
  State<CarLaunchesScreen> createState() => _CarLaunchesScreenState();
}

class _CarLaunchesScreenState extends State<CarLaunchesScreen> {
  final Map<int, bool> _expandedCars = {};

  @override
  void initState() {
    super.initState();
    // Load car launches from Gemini AI when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CarLaunchesProvider>(context, listen: false)
          .loadLatestCarLaunches(forceRefresh: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final carLaunchesProvider = Provider.of<CarLaunchesProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(currentRoute: '/car-launches'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width < 768 ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width < 768 ? 20 : 40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1E3A8A),
                          Colors.teal.shade700,
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.new_releases,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          languageProvider.translate(
                                            'Latest Car Launches',
                                            'சமீபத்திய கார் வெளியீடுகள்',
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    768
                                                ? 24
                                                : 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (carLaunchesProvider
                                          .isUsingFallbackData)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade700,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.info_outline,
                                                  size: 14,
                                                  color: Colors.white),
                                              const SizedBox(width: 4),
                                              Text(
                                                languageProvider.translate(
                                                    'Sample', 'மாதிரி'),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    languageProvider.translate(
                                      'Top 5 India | Top 5 Global (December 2025)',
                                      'முதல் 5 இந்தியா | முதல் 5 உலகளாவிய (டிசம்பர் 2025)',
                                    ),
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (carLaunchesProvider.isUsingFallbackData)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          Icon(Icons.refresh,
                                              size: 14,
                                              color: Colors.white
                                                  .withValues(alpha: 0.8)),
                                          const SizedBox(width: 4),
                                          Text(
                                            languageProvider.translate(
                                              'Loading AI data...',
                                              'AI தரவை ஏற்றுகிறது...',
                                            ),
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.8),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => carLaunchesProvider
                                  .loadLatestCarLaunches(forceRefresh: true),
                              icon: const Icon(Icons.refresh,
                                  color: Colors.white),
                              tooltip: languageProvider.translate(
                                  'Refresh', 'புதுப்பிக்க'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // India Section
                  if (carLaunchesProvider.isLoading &&
                      carLaunchesProvider.indiaCars.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (carLaunchesProvider.error != null &&
                      carLaunchesProvider.indiaCars.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade700, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            languageProvider.translate(
                              'Error loading car launches: ${carLaunchesProvider.error}',
                              'கார் வெளியீடுகளை ஏற்றுவதில் பிழை: ${carLaunchesProvider.error}',
                            ),
                            style: TextStyle(color: Colors.red.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // India Section Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.flag,
                              color: Colors.orange.shade700, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            languageProvider.translate(
                                'I. India Market (India Top 5)',
                                'I. இந்தியச் சந்தை (India Top 5)'),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // India Cars List
                    ...carLaunchesProvider.indiaCars
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final car = entry.value;
                      return _CarLaunchCard(
                        car: car,
                        index: index,
                        isExpanded: _expandedCars[index] ?? false,
                        onToggle: () {
                          setState(() {
                            _expandedCars[index] =
                                !(_expandedCars[index] ?? false);
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 32),
                    // Global Section Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.public,
                              color: Colors.blue.shade700, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            languageProvider.translate(
                                'II. Global Market (Global Top 5)',
                                'II. உலகளாவியச் சந்தை (Global Top 5)'),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Global Cars List
                    ...carLaunchesProvider.globalCars
                        .asMap()
                        .entries
                        .map((entry) {
                      final index =
                          entry.key + 100; // Offset to avoid conflicts
                      final car = entry.value;
                      return _CarLaunchCard(
                        car: car,
                        index: index,
                        isExpanded: _expandedCars[index] ?? false,
                        onToggle: () {
                          setState(() {
                            _expandedCars[index] =
                                !(_expandedCars[index] ?? false);
                          });
                        },
                      );
                    }),
                    // AI Disclaimer with Confidence Score
                    const SizedBox(height: 24),
                    AIDisclaimer(
                      confidenceScore:
                          carLaunchesProvider.isUsingFallbackData ? 0.70 : 0.85,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarLaunchCard extends StatelessWidget {
  final Map<String, dynamic> car;
  final int index;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _CarLaunchCard({
    required this.car,
    required this.index,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = car['imageUrl']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image - Half width (if available)
          if (imageUrl.isNotEmpty)
            Expanded(
              child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
              ),
                child: FeatureImage(
                  imageUrl: imageUrl,
                  fallbackAsset: ImageHelper.carLaunchesFallback,
                width: double.infinity,
                  height: double.infinity,
                      ),
                    ),
            ),
          // Content - Half width
          Expanded(
            child: Padding(
            padding: EdgeInsets.all(
                MediaQuery.of(context).size.width < 768 ? 16 : 20),
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Brand | Model | Country
                Text(
                  '### ${car['brand']} | ${car['model']} | ${car['primaryCountry']}',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 768 ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                // Overview (2 crisp lines)
                Text(
                  LanguageHelper.getAIContent(context, car, 'overview'),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                // Key Data Points
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DataPoint(
                        label: Provider.of<LanguageProvider>(context)
                            .translate('Launch Date:', 'வெளியீட்டு தேதி:'),
                        value: car['launchDate']?.toString() ?? 'N/A',
                      ),
                      const SizedBox(height: 8),
                      _DataPoint(
                        label: Provider.of<LanguageProvider>(context).translate(
                            'Sales Status (Best Seller):',
                            'விற்பனை நிலை (Best Seller):'),
                        value: car['bestSellerStatus']?.toString() ?? 'No',
                      ),
                      const SizedBox(height: 8),
                      _DataPoint(
                        label: Provider.of<LanguageProvider>(context).translate(
                            'Popular Country:', 'அதிகம் விரும்பப்படும் நாடு:'),
                        value: car['popularCountry']?.toString() ?? 'N/A',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Read More Button
                if (!isExpanded)
                  TextButton.icon(
                    onPressed: onToggle,
                    icon: const Icon(Icons.arrow_downward, size: 18),
                    label: Text(
                      Provider.of<LanguageProvider>(context)
                          .translate('Read More', 'மேலும் படிக்க'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Detailed Insight (6 lines)
                      Text(
                        LanguageHelper.getAIContent(
                            context, car, 'detailedInsight'),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Context Label
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          '[${LanguageHelper.getAIContent(context, car, 'contextLabel')}]',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: onToggle,
                        icon: const Icon(Icons.arrow_upward, size: 18),
                        label: Text(
                          Provider.of<LanguageProvider>(context)
                              .translate('Read Less', 'குறைவாக படிக்க'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
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

class _DataPoint extends StatelessWidget {
  final String label;
  final String value;

  const _DataPoint({
    required this.label,
    required this.value,
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
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
