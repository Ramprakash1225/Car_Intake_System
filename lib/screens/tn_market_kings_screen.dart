import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tn_market_kings_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/ai_disclaimer.dart';
import '../widgets/modern_loader.dart';
import '../utils/language_helper.dart';
import 'dart:ui';

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
                              onPressed: () async {
                                showModernLoader(
                                  context,
                                  message: languageProvider.translate(
                                    'Refreshing market kings...',
                                    'மார்க்கெட் கிங்ஸை புதுப்பிக்கிறது...',
                                  ),
                                );
                                await tnMarketKingsProvider
                                    .loadTNMarketKings(forceRefresh: true);
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

class _VehicleCard extends StatefulWidget {
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
  State<_VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<_VehicleCard> with SingleTickerProviderStateMixin {
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

  // Helper function to translate TN Market King text
  String _translateTNMarketKing(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return languageProvider.translate('TN Market King', 'தமிழக மார்க்கெட் கிங்');
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
      case 'legendary':
        return 'புராணங்கள்';
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

  // Helper function to translate maintenance
  String _translateMaintenance(BuildContext context, String maintenance) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    if (!languageProvider.isTamil) {
      return maintenance;
    }

    final maintenanceLower = maintenance.toLowerCase().trim();
    switch (maintenanceLower) {
      case 'low':
        return 'குறைந்த';
      case 'medium':
        return 'நடுத்தர';
      case 'high':
        return 'உயர்';
      default:
        return maintenance;
    }
  }

  // Helper function to translate value (for N/A and other fallbacks)
  String _translateValue(BuildContext context, String value) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    if (!languageProvider.isTamil) {
      return value;
    }

    final valueLower = value.toLowerCase().trim();
    switch (valueLower) {
      case 'n/a':
      case 'na':
        return 'இல்லை';
      default:
        return value; // Return as-is for sales numbers which might already be bilingual
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
      case 'instant':
        return 'உடனடி';
      case 'very fast':
        return 'மிக வேகமான';
      case 'fast':
        return 'வேகமான';
      case '3-5 days':
        return '3-5 நாட்கள்';
      default:
        // Check if it contains "days" pattern
        if (speedLower.contains('days') || speedLower.contains('day')) {
          final match = RegExp(r'(\d+)[-\s]*(\d+)?\s*days?', caseSensitive: false).firstMatch(speedLower);
          if (match != null) {
            final firstNum = match.group(1);
            final secondNum = match.group(2);
            if (secondNum != null) {
              return '$firstNum-$secondNum நாட்கள்';
            } else {
              return '$firstNum நாட்கள்';
            }
          }
        }
        return speed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    // Deep Orange gradient for TN Market Kings
    final gradientSets = [
      [Colors.deepOrange.shade500, Colors.deepOrange.shade800, Colors.red.shade700],
      [Colors.orange.shade500, Colors.orange.shade800, Colors.deepOrange.shade700],
      [Colors.red.shade500, Colors.red.shade800, Colors.orange.shade700],
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
                        Icons.king_bed_rounded,
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
                          Icons.flag_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _translateTNMarketKing(context),
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
                      '${widget.vehicle['brand']} ${widget.vehicle['model']} | ${_translateTNMarketKing(context)}',
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
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.shade50,
                          Colors.green.shade100,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: Colors.green.shade700, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Consumer<LanguageProvider>(
                            builder: (context, languageProvider, _) {
                              return Text(
                                LanguageHelper.getAIContent(
                                    context, widget.vehicle, 'wowFactor'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade900,
                                  height: 1.4,
                                ),
                              );
                            },
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
                      children: [
                        _MetricRow(
                          label: Provider.of<LanguageProvider>(context)
                              .translate('Indian Sales:', 'இந்திய விற்பனை:'),
                          value: _translateValue(
                            context,
                            widget.vehicle['indianSales']?.toString() ?? 'N/A',
                          ),
                          isMobile: false,
                        ),
                        const SizedBox(height: 12),
                        _MetricRow(
                          label: Provider.of<LanguageProvider>(context)
                              .translate('Resale Value:', 'மறுவிற்பனை மதிப்பு:'),
                          value: _translateResaleValue(
                            context,
                            widget.vehicle['resaleValue']?.toString() ?? 'High',
                          ),
                          isMobile: false,
                        ),
                        const SizedBox(height: 12),
                        _MetricRow(
                          label: Provider.of<LanguageProvider>(context)
                              .translate('Maintenance:', 'பராமரிப்பு:'),
                          value: _translateMaintenance(
                            context,
                            widget.vehicle['maintenance']?.toString() ?? 'Medium',
                          ),
                          isMobile: false,
                        ),
                        const SizedBox(height: 12),
                        _MetricRow(
                          label: Provider.of<LanguageProvider>(context)
                              .translate('Sales Speed:', 'விற்பனை வேகம்:'),
                          value: _translateSalesSpeed(
                            context,
                            widget.vehicle['salesSpeed']?.toString() ?? '3-5 Days',
                          ),
                          isMobile: false,
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
                              Text(
                                LanguageHelper.getAIContent(
                                    context, widget.vehicle, 'tnBusinessInsight'),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade800,
                                  height: 1.8,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
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
                                  Provider.of<LanguageProvider>(context).translate(
                                      '[TN Business Insights]',
                                      '[தமிழக பிசினஸ் இன்சைட்ஸ்]'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colors[0],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
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
                    Icons.king_bed_rounded,
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
                    _translateTNMarketKing(context),
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
                '${widget.vehicle['brand']} ${widget.vehicle['model']}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded,
                        color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Consumer<LanguageProvider>(
                        builder: (context, languageProvider, _) {
                          return Text(
                            LanguageHelper.getAIContent(
                                context, widget.vehicle, 'wowFactor'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade900,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
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
                Text(
                  LanguageHelper.getAIContent(
                      context, widget.vehicle, 'tnBusinessInsight'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.7,
                  ),
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
