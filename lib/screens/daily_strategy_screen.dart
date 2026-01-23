import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/daily_strategy_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/ai_disclaimer.dart';
import '../widgets/feature_image.dart';
import '../widgets/modern_loader.dart';
import '../utils/language_helper.dart';
import '../utils/image_helper.dart';

class DailyStrategyScreen extends StatefulWidget {
  const DailyStrategyScreen({super.key});

  @override
  State<DailyStrategyScreen> createState() => _DailyStrategyScreenState();
}

class _DailyStrategyScreenState extends State<DailyStrategyScreen> {
  @override
  void initState() {
    super.initState();
    // Load daily strategy from Gemini AI when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DailyStrategyProvider>(context, listen: false)
          .loadDailyStrategy(forceRefresh: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dailyStrategyProvider = Provider.of<DailyStrategyProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(currentRoute: '/daily-strategy'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 12 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1E3A8A),
                          Colors.indigo.shade700,
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
                                Icons.lightbulb,
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
                                            'Daily Strategy',
                                            'இன்றைய லாப வியூகம்',
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isMobile ? 24 : 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (dailyStrategyProvider
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
                                      'High-Impact Business Recommendation',
                                      'உயர் தாக்கம் வணிக பரிந்துரை',
                                    ),
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      fontSize: isMobile ? 12 : 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                showModernLoader(
                                  context,
                                  message: languageProvider.translate(
                                    'Refreshing daily strategy...',
                                    'இன்றைய வியூகத்தை புதுப்பிக்கிறது...',
                                  ),
                                );
                                await dailyStrategyProvider
                                    .loadDailyStrategy(forceRefresh: true);
                                if (context.mounted) {
                                  hideModernLoader(context);
                                }
                              },
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
                  const SizedBox(height: 16),
                  // Date Header
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
                  // Strategy Content
                  if (dailyStrategyProvider.isLoading &&
                      dailyStrategyProvider.strategy.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (dailyStrategyProvider.error != null &&
                      dailyStrategyProvider.strategy.isEmpty)
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
                              'Error loading strategy: ${dailyStrategyProvider.error}',
                              'வியூகத்தை ஏற்றுவதில் பிழை: ${dailyStrategyProvider.error}',
                            ),
                            style: TextStyle(
                                color: Colors.red.shade700, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else if (dailyStrategyProvider.strategy.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          languageProvider.translate(
                            'No strategy found',
                            'வியூகம் கிடைக்கவில்லை',
                          ),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ),
                    )
                  else
                    _StrategyCard(
                      strategy: dailyStrategyProvider.strategy,
                      isMobile: isMobile,
                    ),
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
                            'This is only a business guide. Make decisions based on your area\'s market conditions.',
                            'இது ஒரு வணிக வழிகாட்டுதல் மட்டுமே. உங்கள் பகுதியின் சந்தை நிலவரத்தைப் பொறுத்து முடிவுகளை எடுக்கவும்.',
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
                        dailyStrategyProvider.isUsingFallbackData ? 0.70 : 0.85,
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

class _StrategyCard extends StatelessWidget {
  final Map<String, dynamic> strategy;
  final bool isMobile;

  const _StrategyCard({
    required this.strategy,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = strategy['imageUrl']?.toString() ??
        'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=800';

    return Container(
      constraints: BoxConstraints(
        minHeight: 350,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: FeatureImage(
                imageUrl: imageUrl,
                fallbackAsset: ImageHelper.dailyStrategyFallback,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title: இன்றைய லாப வியூகம்: [Strategy Title]
                    Text(
                      '### ${Provider.of<LanguageProvider>(context).translate('Today\'s Profit Strategy:', 'இன்றைய லாப வியூகம்:')} ${LanguageHelper.getAIContent(context, strategy, 'strategyTitle')}',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // The Strategy (4-5 crisp lines)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.trending_up,
                                  color: Colors.blue.shade700, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                Provider.of<LanguageProvider>(context)
                                    .translate('Strategy:', 'வியூகம்:'),
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            LanguageHelper.getAIContent(
                                context, strategy, 'strategy'),
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 14,
                              color: Colors.grey.shade800,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Business Benefit (1 line)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.monetization_on,
                              color: Colors.green.shade700, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              LanguageHelper.getAIContent(
                                  context, strategy, 'businessBenefit'),
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Today's Task (Bold, actionable step)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.shade600,
                            Colors.indigo.shade800,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.indigo.shade300.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.task_alt,
                                  color: Colors.white, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                Provider.of<LanguageProvider>(context)
                                    .translate('Today\'s Task:', 'இன்றைய பணி:'),
                                style: TextStyle(
                                  fontSize: isMobile ? 15 : 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            LanguageHelper.getAIContent(
                                context, strategy, 'todaysTask'),
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
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
