import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/top5_picks_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/ai_disclaimer.dart';
import '../widgets/modern_loader.dart';
import '../utils/language_helper.dart';
import 'dart:ui';

class Top5PicksScreen extends StatefulWidget {
  const Top5PicksScreen({super.key});

  @override
  State<Top5PicksScreen> createState() => _Top5PicksScreenState();
}

class _Top5PicksScreenState extends State<Top5PicksScreen> {
  final TextEditingController _locationFeedbackController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load top 5 picks from Gemini AI when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Top5PicksProvider>(context, listen: false)
          .loadTop5Picks(forceRefresh: false);
    });
  }

  @override
  void dispose() {
    _locationFeedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top5PicksProvider = Provider.of<Top5PicksProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(currentRoute: '/top-5-picks'),
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
                          Colors.red.shade700,
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
                                Icons.emoji_events,
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
                                            'Top 5 Business Picks',
                                            'டாப் 5 பிசினஸ் தேர்வுகள்',
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isMobile ? 24 : 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (top5PicksProvider.isUsingFallbackData)
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
                                      'AI-Driven Comparative Report',
                                      'AI-ஆதரவு ஒப்பீட்டு அறிக்கை',
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
                                    'Refreshing top picks...',
                                    'டாப் தேர்வுகளை புதுப்பிக்கிறது...',
                                  ),
                                );
                                await top5PicksProvider.loadTop5Picks(
                                    forceRefresh: true);
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      languageProvider.translate(
                          'Date: December 24, 2025', 'தேதி: டிசம்பர் 24, 2025'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Top 5 Picks List
                  if (top5PicksProvider.isLoading &&
                      top5PicksProvider.picks.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (top5PicksProvider.error != null &&
                      top5PicksProvider.picks.isEmpty)
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
                              'Error loading picks: ${top5PicksProvider.error}',
                              'தேர்வுகளை ஏற்றுவதில் பிழை: ${top5PicksProvider.error}',
                            ),
                            style: TextStyle(
                                color: Colors.red.shade700, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else if (top5PicksProvider.picks.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          languageProvider.translate(
                            'No picks found',
                            'தேர்வுகள் கிடைக்கவில்லை',
                          ),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ),
                    )
                  else
                    ...top5PicksProvider.picks.map((pick) {
                      return _PickCard(
                        pick: pick,
                        isMobile: isMobile,
                      );
                    }),
                  const SizedBox(height: 20),
                  // Observation & Analytics Block
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.analytics,
                                color: Colors.teal.shade700, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'ஆய்வு & பகுப்பாய்வு:',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Interaction Question
                        Text(
                          'இந்த டாப் 5 பட்டியலில் உங்களுக்கு மிகவும் பிடித்த மாடல் எது?',
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Consumer<LanguageProvider>(
                          builder: (context, languageProvider, _) {
                            return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: top5PicksProvider.picks.map((pick) {
                                final brand = languageProvider.isTamil
                                    ? (pick['brand_ta']?.toString() ?? pick['brand']?.toString() ?? 'Unknown')
                                    : (pick['brand_en']?.toString() ?? pick['brand']?.toString() ?? 'Unknown');
                                final model = languageProvider.isTamil
                                    ? (pick['model_ta']?.toString() ?? pick['model']?.toString() ?? 'Unknown')
                                    : (pick['model_en']?.toString() ?? pick['model']?.toString() ?? 'Unknown');
                                final modelName = '$brand $model';
                            return _ModelButton(
                              label: modelName,
                              isSelected:
                                  top5PicksProvider.favoriteModel == modelName,
                              onTap: () =>
                                  top5PicksProvider.setFavoriteModel(modelName),
                            );
                          }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        // Usage Track
                        Text(
                          'இந்தத் தகவல்களின் அடிப்படையில் ஏதேனும் காரை ஏலத்தில் (Auction) எடுக்கத் திட்டமிடுகிறீர்களா?',
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _UsageButton(
                              label: 'ஆம்',
                              isSelected:
                                  top5PicksProvider.auctionPlan == 'ஆம்',
                              onTap: () =>
                                  top5PicksProvider.setAuctionPlan('ஆம்'),
                            ),
                            const SizedBox(width: 12),
                            _UsageButton(
                              label: 'இல்லை',
                              isSelected:
                                  top5PicksProvider.auctionPlan == 'இல்லை',
                              onTap: () =>
                                  top5PicksProvider.setAuctionPlan('இல்லை'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Location Feedback
                        Text(
                          'உங்கள் ஊரில் (e.g., மதுரை) இந்த கார் வரிசை பொருந்துகிறதா?',
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _locationFeedbackController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText:
                                'உங்கள் பதிலை இங்கே தட்டச்சு செய்யவும்...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.teal.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: Colors.teal.shade600, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          style: TextStyle(fontSize: isMobile ? 13 : 14),
                          onChanged: (value) =>
                              top5PicksProvider.setLocationFeedback(value),
                        ),
                      ],
                    ),
                  ),
                  // AI Disclaimer with Confidence Score
                  const SizedBox(height: 24),
                  AIDisclaimer(
                    confidenceScore:
                        top5PicksProvider.isUsingFallbackData ? 0.70 : 0.85,
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

class _PickCard extends StatefulWidget {
  final Map<String, dynamic> pick;
  final bool isMobile;

  const _PickCard({
    required this.pick,
    required this.isMobile,
  });

  @override
  State<_PickCard> createState() => _PickCardState();
}

class _PickCardState extends State<_PickCard> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final salePotential =
        int.tryParse(widget.pick['salePotential']?.toString() ?? '80') ?? 80;
    final buyConfidence =
        int.tryParse(widget.pick['buyConfidence']?.toString() ?? '85') ?? 85;

    // Red gradient for Top 5 Picks
    final gradientSets = [
      [Colors.red.shade500, Colors.red.shade800, Colors.pink.shade700],
      [Colors.pink.shade500, Colors.pink.shade800, Colors.red.shade700],
      [Colors.pink.shade500, Colors.pink.shade800, Colors.red.shade700],
    ];
    final colors = gradientSets[widget.pick['rank'] != null 
        ? (int.tryParse(widget.pick['rank'].toString()) ?? 0) % gradientSets.length
        : 0];

    return MouseRegion(
      onEnter: (_) => _animationController.forward(),
      onExit: (_) => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: EdgeInsets.only(bottom: widget.isMobile ? 24 : 32),
              height: widget.isMobile ? null : 400,
              constraints: widget.isMobile ? null : const BoxConstraints(minHeight: 400),
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
                  child: widget.isMobile
                      ? _buildMobileLayout(context, colors, salePotential, buyConfidence)
                      : _buildDesktopLayout(context, colors, salePotential, buyConfidence),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, List<Color> colors, int salePotential, int buyConfidence) {
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
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
                            Icons.emoji_events_rounded,
                            size: 72,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '#${widget.pick['rank'] ?? '1'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      ],
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
                          Icons.emoji_events_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.pick['segment']?.toString() ?? 'Top Pick',
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
                    child: Consumer<LanguageProvider>(
                      builder: (context, languageProvider, _) {
                        final brand = languageProvider.isTamil
                            ? (widget.pick['brand_ta']?.toString() ?? widget.pick['brand']?.toString() ?? 'Unknown')
                            : (widget.pick['brand_en']?.toString() ?? widget.pick['brand']?.toString() ?? 'Unknown');
                        final model = languageProvider.isTamil
                            ? (widget.pick['model_ta']?.toString() ?? widget.pick['model']?.toString() ?? 'Unknown')
                            : (widget.pick['model_en']?.toString() ?? widget.pick['model']?.toString() ?? 'Unknown');
                        return Text(
                          '#${widget.pick['rank']} $brand $model | ${widget.pick['segment']}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade900,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                        );
                      },
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
                      LanguageHelper.getAIContent(
                          context, widget.pick, 'overviewRationale'),
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
                          Colors.purple.shade50,
                          Colors.purple.shade100,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.purple.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calculate_rounded,
                                color: Colors.purple.shade700, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              Provider.of<LanguageProvider>(context).translate(
                                  'Profit Calculation:', 'லாபக் கணிப்பு:'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Text(
                            Provider.of<LanguageProvider>(context).translate(
                              'Profit Margin = (Market Price - Procurement Cost) / Estimated Servicing × 100',
                              'லாப விளிம்பு = (சந்தை விலை - கொள்முதல் செலவு) / மதிப்பிடப்பட்ட சேவை × 100',
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple.shade900,
                              fontFamily: 'monospace',
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bar_chart_rounded,
                                color: Colors.green.shade700, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              Provider.of<LanguageProvider>(context).translate(
                                  'Business Performance:', 'வணிக செயல்திறன்:'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _ChartRow(
                          label: Provider.of<LanguageProvider>(context)
                              .translate('Sale Potential:', 'விற்பனை வாய்ப்பு:'),
                          percentage: salePotential,
                          isMobile: false,
                        ),
                        const SizedBox(height: 16),
                        _ChartRow(
                          label: Provider.of<LanguageProvider>(context).translate(
                              'Buy Confidence:', 'வாங்கும் நம்பிக்கை:'),
                          percentage: buyConfidence,
                          isMobile: false,
                        ),
                        const SizedBox(height: 16),
                        _LiquidityRow(
                          label: Provider.of<LanguageProvider>(context)
                              .translate('Liquidity:', 'பணப்புழக்க வேகம்:'),
                          value: widget.pick['liquidity']?.toString() ?? 'Fast',
                          isMobile: false,
                        ),
                      ],
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
                          Colors.orange.shade50,
                          Colors.orange.shade100,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.table_chart_rounded,
                                color: Colors.orange.shade700, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              Provider.of<LanguageProvider>(context).translate(
                                  'Key Statistics:', 'முக்கிய புள்ளிவிவரங்கள்:'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _TableRow(
                          metric: Provider.of<LanguageProvider>(context)
                              .translate('Indian Sales', 'இந்திய விற்பனை'),
                          detail: widget.pick['indianSales']?.toString() ?? 'N/A',
                          isMobile: false,
                        ),
                        const Divider(height: 1),
                        _TableRow(
                          metric: Provider.of<LanguageProvider>(context)
                              .translate(
                                  'Expected Profit', 'எதிர்பார்க்கும் லாபம்'),
                          detail: widget.pick['expectedProfit']?.toString() ?? 'N/A',
                          isMobile: false,
                        ),
                        const Divider(height: 1),
                        _TableRow(
                          metric: Provider.of<LanguageProvider>(context)
                              .translate('Resale Value', 'ரீசேல் மதிப்பு'),
                          detail: widget.pick['resaleValue']?.toString() ?? 'High',
                          isMobile: false,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.amber.shade50,
                          Colors.amber.shade100,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.amber.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_rounded,
                                color: Colors.amber.shade700, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              Provider.of<LanguageProvider>(context).translate(
                                  'Interesting Factor:', 'சுவாரஸ்யமான காரணி:'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Consumer<LanguageProvider>(
                          builder: (context, languageProvider, _) {
                            return Text(
                          LanguageHelper.getAIContent(
                              context, widget.pick, 'interestingFactor'),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade800,
                            height: 1.7,
                            letterSpacing: 0.1,
                          ),
                            );
                          },
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
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<Color> colors, int salePotential, int buyConfidence) {
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 56,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '#${widget.pick['rank'] ?? '1'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
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
                    widget.pick['segment']?.toString() ?? 'Top Pick',
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
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, _) {
                  final brand = languageProvider.isTamil
                      ? (widget.pick['brand_ta']?.toString() ?? widget.pick['brand']?.toString() ?? 'Unknown')
                      : (widget.pick['brand_en']?.toString() ?? widget.pick['brand']?.toString() ?? 'Unknown');
                  final model = languageProvider.isTamil
                      ? (widget.pick['model_ta']?.toString() ?? widget.pick['model']?.toString() ?? 'Unknown')
                      : (widget.pick['model_en']?.toString() ?? widget.pick['model']?.toString() ?? 'Unknown');
                  return Text(
                    '#${widget.pick['rank']} $brand $model',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, _) {
                  return Text(
                LanguageHelper.getAIContent(
                    context, widget.pick, 'overviewRationale'),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
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

class _ChartRow extends StatelessWidget {
  final String label;
  final int percentage;
  final bool isMobile;

  const _ChartRow({
    required this.label,
    required this.percentage,
    required this.isMobile,
  });

  String _generateProgressBar(int percentage) {
    final filled = (percentage / 10).round();
    final empty = 10 - filled;
    return '▓' * filled + '░' * empty;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                _generateProgressBar(percentage),
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  letterSpacing: 2,
                  color: Colors.green.shade700,
                ),
                overflow: TextOverflow.clip,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LiquidityRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMobile;

  const _LiquidityRow({
    required this.label,
    required this.value,
    required this.isMobile,
  });

  String _generateLiquidityBar(String liquidity) {
    if (liquidity.toLowerCase().contains('very fast')) {
      return '▓▓▓▓▓▓▓▓▓▓';
    } else if (liquidity.toLowerCase().contains('fast')) {
      return '▓▓▓▓▓▓▓▓░░';
    } else {
      return '▓▓▓▓▓▓░░░░';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                _generateLiquidityBar(value),
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  letterSpacing: 2,
                  color: Colors.green.shade700,
                ),
                overflow: TextOverflow.clip,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  final String metric;
  final String detail;
  final bool isMobile;

  const _TableRow({
    required this.metric,
    required this.detail,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              metric,
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              detail,
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                color: Colors.grey.shade900,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModelButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.teal.shade600 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _UsageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _UsageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.teal.shade600 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
