import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trends_provider.dart';
import '../providers/language_provider.dart';
import '../providers/ai_usage_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/ai_disclaimer.dart';
import '../widgets/modern_loader.dart';
import '../utils/language_helper.dart';
import 'dart:ui';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  final Map<int, bool> _expandedTrends = {};

  @override
  void initState() {
    super.initState();
    // Load trends from Gemini AI when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trendsProvider =
          Provider.of<TrendsProvider>(context, listen: false);
      final aiUsageProvider =
          Provider.of<AIUsageProvider>(context, listen: false);
      trendsProvider.setAIUsageProvider(aiUsageProvider);
      trendsProvider.loadLatestTrends(forceRefresh: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final trendsProvider = Provider.of<TrendsProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(currentRoute: '/trends'),
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
                          Colors.purple.shade700,
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
                                Icons.trending_up,
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
                                            'Latest Trends',
                                            'சமீபத்திய போக்குகள்',
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
                                      if (trendsProvider.isUsingFallbackData)
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
                                      'Automotive Industry Insights',
                                      'வாகனத் தொழில் நுண்ணறிவுகள்',
                                    ),
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (trendsProvider.isUsingFallbackData)
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
                                    'Refreshing trends...',
                                    'போக்குகளை புதுப்பிக்கிறது...',
                                  ),
                                );
                                await trendsProvider.loadLatestTrends(
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
                  // Trends List
                  if (trendsProvider.isLoading && trendsProvider.trends.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (trendsProvider.error != null &&
                      trendsProvider.trends.isEmpty)
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
                              'Error loading trends: ${trendsProvider.error}',
                              'போக்குகளை ஏற்றுவதில் பிழை: ${trendsProvider.error}',
                            ),
                            style: TextStyle(color: Colors.red.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else if (trendsProvider.trends.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          languageProvider.translate(
                            'No trends found',
                            'போக்குகள் கிடைக்கவில்லை',
                          ),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  else
                    ...trendsProvider.trends.asMap().entries.map((entry) {
                      final index = entry.key;
                      final trend = entry.value;
                      return _TrendCard(
                        trend: trend,
                        index: index,
                        isExpanded: _expandedTrends[index] ?? false,
                        onToggle: () {
                          setState(() {
                            _expandedTrends[index] =
                                !(_expandedTrends[index] ?? false);
                          });
                        },
                      );
                    }),
                  // AI Disclaimer with Confidence Score
                  const SizedBox(height: 24),
                  AIDisclaimer(
                    confidenceScore:
                        trendsProvider.isUsingFallbackData ? 0.70 : 0.85,
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

class _TrendCard extends StatefulWidget {
  final Map<String, dynamic> trend;
  final int index;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _TrendCard({
    required this.trend,
    required this.index,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<_TrendCard> createState() => _TrendCardState();
}

class _TrendCardState extends State<_TrendCard>
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    // Different gradient colors for variety
    final gradientSets = [
      [Colors.purple.shade500, Colors.purple.shade800, Colors.indigo.shade700],
      [Colors.blue.shade500, Colors.blue.shade800, Colors.cyan.shade700],
      [Colors.teal.shade500, Colors.teal.shade800, Colors.green.shade700],
      [Colors.orange.shade500, Colors.orange.shade800, Colors.red.shade700],
      [Colors.pink.shade500, Colors.pink.shade800, Colors.purple.shade700],
      [Colors.indigo.shade500, Colors.indigo.shade800, Colors.blue.shade700],
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
              height: isMobile ? null : 320,
              constraints:
                  isMobile ? null : const BoxConstraints(minHeight: 320),
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
        // Modern Gradient Side Panel with Enhanced Design
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
                // Animated Background Pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DottedPatternPainter(
                      color: Colors.white.withValues(alpha: 0.15),
                      dotRadius: 3,
                      spacing: 20,
                    ),
                  ),
                ),
                // Shimmer Effect Overlay
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
                // Large Icon with Glow Effect
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
                        Icons.trending_up_rounded,
                        size: 72,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                ),
                // Domain Label with Modern Design
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
                          Icons.label_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            LanguageHelper.getAIContent(
                                context, widget.trend, 'domainLabel'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
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
        // Enhanced Content Panel
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
                  // Header with Modern Typography
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
                      LanguageHelper.getAIContent(
                          context, widget.trend, 'header'),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade900,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // Overview with Enhanced Styling
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 24),
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
                          context, widget.trend, 'overview'),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.7,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  // Read More Button with Modern Design
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
                          child: Text(
                            LanguageHelper.getAIContent(
                                context, widget.trend, 'detailedInsight'),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade800,
                              height: 1.8,
                              letterSpacing: 0.1,
                            ),
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
        // Gradient Header
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
                    Icons.trending_up_rounded,
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
                    LanguageHelper.getAIContent(
                        context, widget.trend, 'domainLabel'),
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
        // Content
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LanguageHelper.getAIContent(context, widget.trend, 'header'),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                LanguageHelper.getAIContent(context, widget.trend, 'overview'),
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
                      context, widget.trend, 'detailedInsight'),
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
