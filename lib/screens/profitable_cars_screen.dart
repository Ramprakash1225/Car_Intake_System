import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profitable_cars_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/ai_disclaimer.dart';
import '../widgets/feature_image.dart';
import '../utils/language_helper.dart';
import '../utils/image_helper.dart';

class ProfitableCarsScreen extends StatefulWidget {
  const ProfitableCarsScreen({super.key});

  @override
  State<ProfitableCarsScreen> createState() => _ProfitableCarsScreenState();
}

class _ProfitableCarsScreenState extends State<ProfitableCarsScreen> {
  final Map<int, bool> _expandedCars = {};

  @override
  void initState() {
    super.initState();
    // Load profitable cars from Gemini AI when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfitableCarsProvider>(context, listen: false)
          .loadProfitableCars(forceRefresh: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profitableCarsProvider = Provider.of<ProfitableCarsProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(currentRoute: '/profitable-cars'),
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
                          Colors.amber.shade700,
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
                                Icons.attach_money,
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
                                            'Profitable Cars',
                                            'லாபகரமான கார்கள்',
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
                                      if (profitableCarsProvider
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
                                      'Top-Selling Cars in India - Business Report',
                                      'இந்தியாவில் மிகவும் விற்பனையாகும் கார்கள் - வணிக அறிக்கை',
                                    ),
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (profitableCarsProvider
                                      .isUsingFallbackData)
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
                              onPressed: () => profitableCarsProvider
                                  .loadProfitableCars(forceRefresh: true),
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
                  // Content
                  if (profitableCarsProvider.isLoading &&
                      profitableCarsProvider.threeYearsCars.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (profitableCarsProvider.error != null &&
                      profitableCarsProvider.threeYearsCars.isEmpty)
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
                              'Error loading profitable cars: ${profitableCarsProvider.error}',
                              'லாபகரமான கார்களை ஏற்றுவதில் பிழை: ${profitableCarsProvider.error}',
                            ),
                            style: TextStyle(color: Colors.red.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // 3 Years Traction Section
                    _SectionHeader(
                      title: languageProvider.translate(
                          '1. 3 Years Traction (Modern Gainers)',
                          '1. 3 ஆண்டுகள் ஈர்ப்பு (நவீன பெறுநர்கள்)'),
                      subtitle: languageProvider.translate(
                          'Modern Gainers', 'நவீன பெறுநர்கள்'),
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    ...profitableCarsProvider.threeYearsCars
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final car = entry.value;
                      return _ProfitableCarCard(
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
                    // 5 Years Traction Section
                    _SectionHeader(
                      title: languageProvider.translate(
                          '2. 5 Years Traction (Reliable Assets)',
                          '2. 5 ஆண்டுகள் ஈர்ப்பு (நம்பகமான சொத்துக்கள்)'),
                      subtitle: languageProvider.translate(
                          'Reliable Assets', 'நம்பகமான சொத்துக்கள்'),
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    ...profitableCarsProvider.fiveYearsCars
                        .asMap()
                        .entries
                        .map((entry) {
                      final index =
                          entry.key + 100; // Offset to avoid conflicts
                      final car = entry.value;
                      return _ProfitableCarCard(
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
                    // 10 Years Traction Section
                    _SectionHeader(
                      title: languageProvider.translate(
                          '3. 10 Years Traction (The Legends)',
                          '3. 10 ஆண்டுகள் ஈர்ப்பு (புராணங்கள்)'),
                      subtitle: languageProvider.translate(
                          'The Legends', 'புராணங்கள்'),
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 16),
                    ...profitableCarsProvider.tenYearsCars
                        .asMap()
                        .entries
                        .map((entry) {
                      final index =
                          entry.key + 200; // Offset to avoid conflicts
                      final car = entry.value;
                      return _ProfitableCarCard(
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
                    // Disclaimer
                    Container(
                      padding: const EdgeInsets.all(20),
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
                                  color: Colors.orange.shade700, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                languageProvider.translate(
                                    'Disclaimer:', 'மறுப்பு:'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            languageProvider.translate(
                              'This information is a guide based on market research. The value of the vehicle may vary depending on its current condition and documents.',
                              'இந்தத் தகவல் சந்தை ஆய்வுகளின் அடிப்படையிலான ஒரு வழிகாட்டுதலே. வாகனத்தின் தற்போதைய நிலை மற்றும் ஆவணங்களைப் பொறுத்து அதன் மதிப்பு மாறுபடும்.',
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // AI Disclaimer with Confidence Score
                    const SizedBox(height: 24),
                    AIDisclaimer(
                      confidenceScore:
                          profitableCarsProvider.isUsingFallbackData
                              ? 0.70
                              : 0.85,
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final MaterialColor color;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, color: color.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: color.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfitableCarCard extends StatelessWidget {
  final Map<String, dynamic> car;
  final int index;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ProfitableCarCard({
    required this.car,
    required this.index,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = car['imageUrl']?.toString() ?? '';
    final isMobile = MediaQuery.of(context).size.width < 768;

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
                  fallbackAsset: ImageHelper.profitableCarsFallback,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          // Content - Half width
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Brand Model | Traction Period
                    Text(
                      '### ${car['brand']} ${car['model']} | ${car['tractionPeriod']}',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
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
                    // Sales Data
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.analytics,
                              color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            car['salesData']?.toString() ??
                                Provider.of<LanguageProvider>(context)
                                    .translate('Sales: N/A', 'விற்பனை: N/A'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Key Metrics
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
                          _MetricItem(
                            label: Provider.of<LanguageProvider>(context)
                                .translate('Resale Value:', 'மறுவிற்பனை மதிப்பு:'),
                            value: car['resaleValue']?.toString() ?? 'High',
                          ),
                          const SizedBox(height: 8),
                          _MetricItem(
                            label: Provider.of<LanguageProvider>(context).translate(
                                'Maintenance Cost:', 'பராமரிப்புச் செலவு:'),
                            value: car['maintenanceCost']?.toString() ?? 'Medium',
                          ),
                          const SizedBox(height: 8),
                          _MetricItem(
                            label: Provider.of<LanguageProvider>(context)
                                .translate('Sales Speed:', 'விற்பனை வேகம்:'),
                            value: car['salesSpeed']?.toString() ?? 'Fast',
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

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetricItem({
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
