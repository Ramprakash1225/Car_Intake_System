import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todays_choice_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/ai_disclaimer.dart';
import '../widgets/modern_loader.dart';
import '../utils/language_helper.dart';
import 'dart:ui';

class TodaysChoiceScreen extends StatefulWidget {
  const TodaysChoiceScreen({super.key});

  @override
  State<TodaysChoiceScreen> createState() => _TodaysChoiceScreenState();
}

class _TodaysChoiceScreenState extends State<TodaysChoiceScreen> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load today's choice from Gemini AI when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TodaysChoiceProvider>(context, listen: false)
          .loadTodaysChoice(forceRefresh: false);
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todaysChoiceProvider = Provider.of<TodaysChoiceProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(currentRoute: '/todays-choice'),
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.star,
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
                                            'Today\'s Choice',
                                            'இன்றைய சாய்ஸ்',
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isMobile ? 24 : 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (todaysChoiceProvider
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
                                      'Highest Profit Potential Vehicle',
                                      'அதிக லாப திறன் கொண்ட வாகனம்',
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
                                    'Refreshing today\'s choice...',
                                    'இன்றைய சாய்ஸை புதுப்பிக்கிறது...',
                                  ),
                                );
                                await todaysChoiceProvider
                                    .loadTodaysChoice(forceRefresh: true);
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
                  // // Date Header - Show current date
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
                  //     languageProvider.isTamil
                  //         ? 'தேதி: ${DateFormat('MMMM d, yyyy', 'ta_IN').format(DateTime.now())}'
                  //         : 'Date: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
                  //     style: TextStyle(
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.grey.shade800,
                  //     ),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  // Choice Content
                  if (todaysChoiceProvider.isLoading &&
                      todaysChoiceProvider.choice.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (todaysChoiceProvider.error != null &&
                      todaysChoiceProvider.choice.isEmpty)
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
                              'Error loading choice: ${todaysChoiceProvider.error}',
                              'சாய்ஸை ஏற்றுவதில் பிழை: ${todaysChoiceProvider.error}',
                            ),
                            style: TextStyle(
                                color: Colors.red.shade700, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else if (todaysChoiceProvider.choice.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          languageProvider.translate(
                            'No choice found',
                            'சாய்ஸ் கிடைக்கவில்லை',
                          ),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ),
                    )
                  else
                    _ChoiceCard(
                      choice: todaysChoiceProvider.choice,
                      isMobile: isMobile,
                      provider: todaysChoiceProvider,
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
                            'This is an AI guide based on market research. Profit may vary depending on the vehicle\'s current condition and documents.',
                            'இது சந்தை ஆய்வுகளின் அடிப்படையிலான AI வழிகாட்டுதலே. வாகனத்தின் தற்போதைய நிலை மற்றும் ஆவணங்களைப் பொறுத்து லாபம் மாறுபடும்.',
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
                        todaysChoiceProvider.isUsingFallbackData ? 0.70 : 0.85,
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

class _ChoiceCard extends StatefulWidget {
  final Map<String, dynamic> choice;
  final bool isMobile;
  final TodaysChoiceProvider provider;

  const _ChoiceCard({
    required this.choice,
    required this.isMobile,
    required this.provider,
  });

  @override
  State<_ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<_ChoiceCard> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Amber gradient for Today's Choice
    final colors = [
      Colors.amber.shade500,
      Colors.amber.shade800,
      Colors.orange.shade700,
    ];
    
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.8;
    final minHeight = 400.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: widget.isMobile ? 24 : 32),
      constraints: BoxConstraints(
        minHeight: minHeight,
        maxHeight: maxHeight > minHeight ? maxHeight : minHeight + 100,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
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
              ? _buildMobileLayout(context, colors)
              : _buildDesktopLayout(context, colors),
        ),
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
                        Icons.star_rounded,
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
                          Icons.today_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            Provider.of<LanguageProvider>(context)
                                .translate("Today's Choice", "இன்றைய சாய்ஸ்"),
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
                mainAxisSize: MainAxisSize.min,
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
                        return Text(
                          '${languageProvider.translate("Today's Choice:", "இன்றைய சாய்ஸ்:")} ${widget.choice['brand']} ${widget.choice['model']}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade900,
                        height: 1.2,
                        letterSpacing: -0.5,
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
                            Icon(Icons.psychology_rounded,
                                color: Colors.amber.shade700, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              Provider.of<LanguageProvider>(context)
                                  .translate('Why Today?', 'ஏன் இன்று?'),
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
                              context, widget.choice, 'hiddenRationale'),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calculate_rounded,
                                color: Colors.blue.shade700, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              Provider.of<LanguageProvider>(context)
                                  .translate('Profit Calculation:',
                                      'லாபக் கணிப்பு:'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Consumer<LanguageProvider>(
                          builder: (context, languageProvider, _) {
                            return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            LanguageHelper.getAIContent(
                                context, widget.choice, 'profitFormula'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                              fontFamily: 'monospace',
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                            );
                          },
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
                            Icon(Icons.business_center_rounded,
                                color: Colors.green.shade700, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              Provider.of<LanguageProvider>(context)
                                  .translate('Business Deep-Dive',
                                      'வணிக ஆழமான பார்வை'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Consumer<LanguageProvider>(
                          builder: (context, languageProvider, _) {
                            return Text(
                          LanguageHelper.getAIContent(
                              context, widget.choice, 'businessDeepDive'),
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
                            Icon(Icons.analytics_rounded,
                                color: Colors.purple.shade700, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              Provider.of<LanguageProvider>(context)
                                  .translate('Business Metrics', 'வணிக அளவீடுகள்'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _MetricRow(
                          label: Provider.of<LanguageProvider>(context)
                              .translate('Indian Sales:', 'இந்திய விற்பனை:'),
                          value: widget.choice['indianSales']?.toString() ?? 'N/A',
                          isMobile: false,
                        ),
                        const SizedBox(height: 12),
                        _MetricRow(
                          label: Provider.of<LanguageProvider>(context)
                              .translate('TN Resale Value:',
                                  'தமிழக மறுவிற்பனை மவுசு:'),
                          value: widget.choice['tnResaleValue']?.toString() ?? 'High',
                          isMobile: false,
                        ),
                        const SizedBox(height: 12),
                        _MetricRow(
                          label: Provider.of<LanguageProvider>(context)
                              .translate('Sales Speed:', 'விற்பனை வேகம்:'),
                          value: widget.choice['salesSpeed']?.toString() ?? '3-5 Days',
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
                          Colors.teal.shade50,
                          Colors.teal.shade100,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.teal.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.feedback_rounded,
                                color: Colors.teal.shade700, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              Provider.of<LanguageProvider>(context)
                                  .translate('Usage & Feedback',
                                      'எங்கள் ஆய்வுக்காக'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          Provider.of<LanguageProvider>(context).translate(
                            'Was this prediction useful to you?',
                            'இந்தக் கணிப்பு உங்களுக்குப் பயனுள்ளதாக இருந்ததா?',
                          ),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _ReactionButton(
                              emoji: '👍',
                              isSelected: widget.provider.reaction == '👍',
                              onTap: () {
                                widget.provider.setReaction(
                                    widget.provider.reaction == '👍'
                                        ? null
                                        : '👍');
                              },
                            ),
                            const SizedBox(width: 12),
                            _ReactionButton(
                              emoji: '👎',
                              isSelected: widget.provider.reaction == '👎',
                              onTap: () {
                                widget.provider.setReaction(
                                    widget.provider.reaction == '👎'
                                        ? null
                                        : '👎');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          Provider.of<LanguageProvider>(context).translate(
                            'Will you try to add this car to your inventory today?',
                            'இந்த காரை உங்கள் இன்வென்டரியில் சேர்க்க இன்று முயற்சி செய்வீர்களா?',
                          ),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _UsageButton(
                                label: Provider.of<LanguageProvider>(context)
                                    .translate('Yes', 'ஆம்'),
                                isSelected:
                                    widget.provider.usageTracker == 'ஆம்',
                                onTap: () {
                                  widget.provider.setUsageTracker(
                                      widget.provider.usageTracker == 'ஆம்'
                                          ? null
                                          : 'ஆம்');
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _UsageButton(
                                label: Provider.of<LanguageProvider>(context)
                                    .translate('No', 'இல்லை'),
                                isSelected:
                                    widget.provider.usageTracker == 'இல்லை',
                                onTap: () {
                                  widget.provider.setUsageTracker(
                                      widget.provider.usageTracker == 'இல்லை'
                                          ? null
                                          : 'இல்லை');
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _feedbackController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: Provider.of<LanguageProvider>(context)
                                .translate(
                              'Optional feedback...',
                              'விருப்பமான கருத்து...',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.teal.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.teal.shade600,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              widget.provider.setFeedback(_feedbackController.text);
                              _feedbackController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    Provider.of<LanguageProvider>(context)
                                        .translate(
                                      'Thank you for your feedback!',
                                      'உங்கள் கருத்துக்கு நன்றி!',
                                    ),
                                  ),
                                  backgroundColor: Colors.teal,
                                ),
                              );
                            },
                            icon: const Icon(Icons.send_rounded),
                            label: Text(
                              Provider.of<LanguageProvider>(context).translate(
                                'Submit Feedback',
                                'கருத்தை சமர்ப்பிக்க',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
                    Icons.star_rounded,
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
                    Provider.of<LanguageProvider>(context)
                        .translate("Today's Choice", "இன்றைய சாய்ஸ்"),
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
                '${widget.choice['brand']} ${widget.choice['model']}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology_rounded,
                            color: Colors.amber.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          Provider.of<LanguageProvider>(context)
                              .translate('Why Today?', 'ஏன் இன்று?'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Consumer<LanguageProvider>(
                      builder: (context, languageProvider, _) {
                        return Text(
                      LanguageHelper.getAIContent(
                          context, widget.choice, 'hiddenRationale'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.6,
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

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.emoji,
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
          emoji,
          style: const TextStyle(fontSize: 24),
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
