import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_launches_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/ai_disclaimer.dart';
import '../widgets/modern_loader.dart';
import '../utils/language_helper.dart';
import 'dart:ui';

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
                                      'Top India | Top Global',
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
                              onPressed: () async {
                                showModernLoader(
                                  context,
                                  message: languageProvider.translate(
                                    'Refreshing car launches...',
                                    'கார் வெளியீடுகளை புதுப்பிக்கிறது...',
                                  ),
                                );
                                await carLaunchesProvider.loadLatestCarLaunches(
                                    forceRefresh: true);
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
                                'I. இந்தியச் சந்தை (இந்தியா முதல் 5)'),
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

class _CarLaunchCard extends StatefulWidget {
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
  State<_CarLaunchCard> createState() => _CarLaunchCardState();
}

class _CarLaunchCardState extends State<_CarLaunchCard>
    with SingleTickerProviderStateMixin {
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

  // Helper function to translate country names
  String _translateCountry(BuildContext context, String country) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    if (!languageProvider.isTamil) {
      return country;
    }

    final countryLower = country.toLowerCase().trim();
    switch (countryLower) {
      case 'india':
        return 'இந்தியா';
      case 'global':
        return 'உலகளாவிய';
      case 'n/a':
      case 'na':
        return 'இல்லை';
      default:
        return country; // Return as-is if not a known country
    }
  }

  // Helper function to translate status values
  String _translateStatus(BuildContext context, String status) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    if (!languageProvider.isTamil) {
      return status;
    }

    final statusLower = status.toLowerCase().trim();
    switch (statusLower) {
      case 'yes':
        return 'ஆம்';
      case 'no':
        return 'இல்லை';
      case 'trending':
        return 'பிரபலமான';
      default:
        return status; // Return as-is if not a known status
    }
  }

  // Helper function to translate other values like N/A
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
        return value; // Return as-is for dates and other values
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    // Teal gradient for car launches
    final gradientSets = [
      [Colors.teal.shade500, Colors.teal.shade800, Colors.cyan.shade700],
      [Colors.cyan.shade500, Colors.cyan.shade800, Colors.blue.shade700],
      [Colors.blue.shade500, Colors.blue.shade800, Colors.indigo.shade700],
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
              height: isMobile ? null : 340,
              constraints:
                  isMobile ? null : const BoxConstraints(minHeight: 340),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colors[0]
                        .withValues(alpha: 0.3 * _elevationAnimation.value),
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
        // Modern Gradient Side Panel
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
                        Icons.new_releases_rounded,
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
                          Icons.public_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _translateCountry(
                              context,
                              widget.car['primaryCountry']?.toString() ??
                                  'Global',
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
                      '${widget.car['brand']} | ${widget.car['model']} | ${_translateCountry(context, widget.car['primaryCountry']?.toString() ?? 'Global')}',
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
                    margin: const EdgeInsets.only(bottom: 20),
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
                    child: Text(
                      LanguageHelper.getAIContent(
                          context, widget.car, 'overview'),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.7,
                        letterSpacing: 0.2,
                      ),
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
                        _DataPoint(
                          label: Provider.of<LanguageProvider>(context)
                              .translate('Launch Date:', 'வெளியீட்டு தேதி:'),
                          value: _translateValue(
                            context,
                            widget.car['launchDate']?.toString() ?? 'N/A',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DataPoint(
                          label: Provider.of<LanguageProvider>(context)
                              .translate('Sales Status (Best Seller):',
                                  'விற்பனை நிலை (சிறந்த விற்பனையாளர்):'),
                          value: _translateStatus(
                            context,
                            widget.car['bestSellerStatus']?.toString() ?? 'No',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DataPoint(
                          label: Provider.of<LanguageProvider>(context)
                              .translate('Popular Country:',
                                  'அதிகம் விரும்பப்படும் நாடு:'),
                          value: _translateCountry(
                            context,
                            widget.car['popularCountry']?.toString() ?? 'N/A',
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
                              Text(
                                LanguageHelper.getAIContent(
                                    context, widget.car, 'detailedInsight'),
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
                                  '[${LanguageHelper.getAIContent(context, widget.car, 'contextLabel')}]',
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
                    Icons.new_releases_rounded,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _translateCountry(
                      context,
                      widget.car['primaryCountry']?.toString() ?? 'Global',
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
                '${widget.car['brand']} | ${widget.car['model']}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                LanguageHelper.getAIContent(context, widget.car, 'overview'),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.6,
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
                      context, widget.car, 'detailedInsight'),
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
