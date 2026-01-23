import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profitable_cars_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/ai_disclaimer.dart';
import '../widgets/modern_loader.dart';
import '../utils/language_helper.dart';
import 'dart:ui';

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
                              onPressed: () async {
                                showModernLoader(
                                  context,
                                  message: languageProvider.translate(
                                    'Refreshing profitable cars...',
                                    'லாபகரமான கார்களை புதுப்பிக்கிறது...',
                                  ),
                                );
                                await profitableCarsProvider
                                    .loadProfitableCars(forceRefresh: true);
                                if (context.mounted) {
                                  hideModernLoader(context);
                                }
                              },
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

class _ProfitableCarCard extends StatefulWidget {
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
  State<_ProfitableCarCard> createState() => _ProfitableCarCardState();
}

class _ProfitableCarCardState extends State<_ProfitableCarCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper function to translate traction period
  String _translateTractionPeriod(BuildContext context, String period) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    if (!languageProvider.isTamil) {
      return period;
    }

    final periodLower = period.toLowerCase().trim();
    if (periodLower.contains('3') && periodLower.contains('year')) {
      return '3 ஆண்டுகள்';
    } else if (periodLower.contains('5') && periodLower.contains('year')) {
      return '5 ஆண்டுகள்';
    } else if (periodLower.contains('10') && periodLower.contains('year')) {
      return '10 ஆண்டுகள்';
    }
    return period; // Return as-is if not recognized
  }

  // Helper function to translate resale value
  String _translateResaleValue(BuildContext context, String value) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    if (!languageProvider.isTamil) {
      return value;
    }

    final valueLower = value.toLowerCase().trim();
    switch (valueLower) {
      case 'excellent':
        return 'சிறந்த';
      case 'high':
        return 'உயர்';
      case 'medium':
        return 'நடுத்தர';
      case 'low':
        return 'குறைந்த';
      default:
        return value;
    }
  }

  // Helper function to translate maintenance cost
  String _translateMaintenanceCost(BuildContext context, String cost) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    if (!languageProvider.isTamil) {
      return cost;
    }

    final costLower = cost.toLowerCase().trim();
    switch (costLower) {
      case 'low':
        return 'குறைந்த';
      case 'medium':
        return 'நடுத்தர';
      case 'high':
        return 'உயர்';
      default:
        return cost;
    }
  }

  // Helper function to translate sales speed
  String _translateSalesSpeed(BuildContext context, String speed) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    if (!languageProvider.isTamil) {
      return speed;
    }

    final speedLower = speed.toLowerCase().trim();
    switch (speedLower) {
      case 'very fast':
        return 'மிக வேகமான';
      case 'fast':
        return 'வேகமான';
      case 'medium':
        return 'நடுத்தர';
      case 'slow':
        return 'மெதுவான';
      default:
        return speed;
    }
  }

  // Helper function to extract language-specific content from bilingual sales data
  String _translateSalesData(BuildContext context, String salesData) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    if (!languageProvider.isTamil) {
      // For English, return the English part (before /) or the whole string
      if (salesData.contains(' / ')) {
        return salesData.split(' / ')[0].trim();
      }
      return salesData;
    }

    // For Tamil, return the Tamil part (after /) or the whole string if no separator
    if (salesData.contains(' / ')) {
      final parts = salesData.split(' / ');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }
    // If no separator, check if it contains Tamil characters
    if (salesData.contains(RegExp(r'[\u0B80-\u0BFF]'))) {
      return salesData; // Already in Tamil
    }
    return salesData;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    // Amber/Gold gradient for profitable cars
    final gradientSets = [
      [Colors.amber.shade500, Colors.amber.shade800, Colors.orange.shade700],
      [Colors.orange.shade500, Colors.orange.shade800, Colors.deepOrange.shade700],
    ];
    final colors = gradientSets[widget.index % gradientSets.length];

    return MouseRegion(
      onEnter: (_) => _animationController.forward(),
      onExit: (_) => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: EdgeInsets.only(bottom: isMobile ? 24 : 32),
              height: isMobile ? null : 360,
              constraints: isMobile ? null : const BoxConstraints(minHeight: 360),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withValues(alpha: 0.3 * _elevationAnimation.value),
                    blurRadius: 20 + (10 * _elevationAnimation.value),
                    offset: Offset(0, 8 + (4 * _elevationAnimation.value)),
                    spreadRadius: 2 * _elevationAnimation.value,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  color: Colors.white,
                  child: isMobile
                      ? _buildMobileLayout(context, colors)
                      : _buildDesktopLayout(context, colors),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, List<Color> colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DottedPatternPainter(
                      color: Colors.white.withValues(alpha: 0.15),
                      dotRadius: 3,
                      spacing: 20,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.1),
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.attach_money_rounded,
                        size: 72,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _translateTractionPeriod(
                              context,
                              widget.car['tractionPeriod']?.toString() ?? '3 Years',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: colors[0].withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      '${widget.car['brand']} ${widget.car['model']} | ${_translateTractionPeriod(context, widget.car['tractionPeriod']?.toString() ?? '3 Years')}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade900,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Consumer<LanguageProvider>(
                      builder: (context, languageProvider, _) {
                        return Text(
                      LanguageHelper.getAIContent(context, widget.car, 'overview'),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.7,
                        letterSpacing: 0.2,
                      ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade50,
                          Colors.blue.shade100,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.analytics_rounded,
                            color: Colors.blue.shade700, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _translateSalesData(
                              context,
                              widget.car['salesData']?.toString() ??
                                  Provider.of<LanguageProvider>(context)
                                      .translate('Sales: N/A', 'விற்பனை: N/A'),
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors[0].withValues(alpha: 0.1),
                          colors[1].withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors[0].withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MetricItem(
                          label: Provider.of<LanguageProvider>(context)
                              .translate('Resale Value:', 'மறுவிற்பனை மதிப்பு:'),
                          value: _translateResaleValue(
                            context,
                            widget.car['resaleValue']?.toString() ?? 'High',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _MetricItem(
                          label: Provider.of<LanguageProvider>(context).translate(
                              'Maintenance Cost:', 'பராமரிப்புச் செலவு:'),
                          value: _translateMaintenanceCost(
                            context,
                            widget.car['maintenanceCost']?.toString() ?? 'Medium',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _MetricItem(
                          label: Provider.of<LanguageProvider>(context)
                              .translate('Sales Speed:', 'விற்பனை வேகம்:'),
                          value: _translateSalesSpeed(
                            context,
                            widget.car['salesSpeed']?.toString() ?? 'Fast',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!widget.isExpanded)
                    _buildModernButton(
                      context,
                      'Read More',
                      'மேலும் படிக்க',
                      Icons.arrow_downward_rounded,
                      widget.onToggle,
                      colors[0],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colors[0].withValues(alpha: 0.1),
                                colors[1].withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors[0].withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer<LanguageProvider>(
                                builder: (context, languageProvider, _) {
                                  return Text(
                                LanguageHelper.getAIContent(
                                    context, widget.car, 'detailedInsight'),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade800,
                                  height: 1.8,
                                  letterSpacing: 0.1,
                                ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Consumer<LanguageProvider>(
                                builder: (context, languageProvider, _) {
                                  return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: colors[0].withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: colors[0].withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  '[${LanguageHelper.getAIContent(context, widget.car, 'contextLabel')}]',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colors[0],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        _buildModernButton(
                          context,
                          'Read Less',
                          'குறைவாக படிக்க',
                          Icons.arrow_upward_rounded,
                          widget.onToggle,
                          colors[0],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _DottedPatternPainter(
                    color: Colors.white.withValues(alpha: 0.15),
                    dotRadius: 2,
                    spacing: 15,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Icon(
                    Icons.attach_money_rounded,
                    size: 56,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _translateTractionPeriod(
                      context,
                      widget.car['tractionPeriod']?.toString() ?? '3 Years',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.car['brand']} ${widget.car['model']}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, _) {
                  return Text(
                LanguageHelper.getAIContent(context, widget.car, 'overview'),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
                  );
                },
              ),
              if (!widget.isExpanded) ...[
                const SizedBox(height: 16),
                _buildModernButton(
                  context,
                  'Read More',
                  'மேலும் படிக்க',
                  Icons.arrow_downward_rounded,
                  widget.onToggle,
                  colors[0],
                ),
              ] else ...[
                const SizedBox(height: 16),
                Consumer<LanguageProvider>(
                  builder: (context, languageProvider, _) {
                    return Text(
                  LanguageHelper.getAIContent(
                      context, widget.car, 'detailedInsight'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.7,
                  ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildModernButton(
                  context,
                  'Read Less',
                  'குறைவாக படிக்க',
                  Icons.arrow_upward_rounded,
                  widget.onToggle,
                  colors[0],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernButton(
    BuildContext context,
    String enText,
    String taText,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  languageProvider.translate(enText, taText),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, color: Colors.white, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DottedPatternPainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double spacing;

  _DottedPatternPainter({
    required this.color,
    required this.dotRadius,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
