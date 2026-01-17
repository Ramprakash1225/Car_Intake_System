import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/car_provider.dart';
import '../providers/language_provider.dart';
import '../providers/ai_usage_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/ai_disclaimer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(currentRoute: '/dashboard'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Section with Car Image
                  Container(
                    height: MediaQuery.of(context).size.width < 768 ? 300 : 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      image: DecorationImage(
                        image:
                            const AssetImage('assets/images/dashboard_car.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.blue.shade900.withValues(alpha: 0.8),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width < 768 ? 20 : 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            languageProvider.translate(
                                'Dashboard', 'டாஷ்போர்டு'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width < 768
                                  ? 32
                                  : 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            languageProvider.translate(
                              'Overview of your car inventory',
                              'உங்கள் கார் சரக்கு கண்ணோட்டம்',
                            ),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: MediaQuery.of(context).size.width < 768
                                  ? 14
                                  : 18,
                            ),
                          ),
                          if (MediaQuery.of(context).size.width < 768) ...[
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () => DashboardScreen._showFeaturesDialog(
                                  context, languageProvider),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.grid_view,
                                      color: Colors.grey.shade700,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      languageProvider.translate(
                                        'View All Features',
                                        'அனைத்து அம்சங்களையும் காண்க',
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 32),
                          ],
                          // Only show feature buttons on desktop
                          if (MediaQuery.of(context).size.width >= 768)
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                // ElevatedButton.icon(
                                //   onPressed: () => context.go('/analyze'),
                                //   icon: const Icon(Icons.search),
                                //   label: Text(
                                //     languageProvider.translate('Analyze Car', 'கார் பகுப்பாய்வு'),
                                //   ),
                                //   style: ElevatedButton.styleFrom(
                                //     backgroundColor: Colors.white,
                                //     foregroundColor: const Color(0xFF1E3A8A),
                                //     padding: EdgeInsets.symmetric(
                                //       horizontal: MediaQuery.of(context).size.width < 768 ? 16 : 24,
                                //       vertical: 16,
                                //     ),
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(8),
                                //     ),
                                //   ),
                                // ),
                                // ElevatedButton.icon(
                                //   onPressed: () => context.go('/popular-cars'),
                                //   icon: const Icon(Icons.trending_up),
                                //   label: Flexible(
                                //     child: Text(
                                //       languageProvider.translate('Popular Cars', 'பிரபலமான கார்கள்'),
                                //       maxLines: 2,
                                //       overflow: TextOverflow.ellipsis,
                                //       textAlign: TextAlign.center,
                                //     ),
                                //   ),
                                //   style: ElevatedButton.styleFrom(
                                //     backgroundColor: Colors.green.shade600,
                                //     foregroundColor: Colors.white,
                                //     padding: EdgeInsets.symmetric(
                                //       horizontal: MediaQuery.of(context).size.width < 768 ? 16 : 24,
                                //       vertical: 16,
                                //     ),
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(8),
                                //     ),
                                //   ),
                                // ),
                                ElevatedButton.icon(
                                  onPressed: () => context.go('/trends'),
                                  icon: const Icon(Icons.insights),
                                  label: Text(
                                    languageProvider.translate(
                                        'Latest Trends',
                                        'சமீபத்திய போக்குகள்'),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple.shade600,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width <
                                                  768
                                              ? 16
                                              : 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => context.go('/car-launches'),
                                  icon: const Icon(Icons.new_releases),
                                  label: Text(
                                    languageProvider.translate(
                                        'Latest Car Launches',
                                        'சமீபத்திய கார் வெளியீடுகள்'),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal.shade600,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width <
                                                  768
                                              ? 16
                                              : 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      context.go('/profitable-cars'),
                                  icon: const Icon(Icons.attach_money),
                                  label: Text(
                                    languageProvider.translate(
                                        'Profitable Cars',
                                        'லாபகரமான கார்கள்'),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber.shade600,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width <
                                                  768
                                              ? 16
                                              : 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      context.go('/tn-market-kings'),
                                  icon: const Icon(Icons.king_bed),
                                  label: Text(
                                    languageProvider.translate(
                                        'TN Market Kings',
                                        'தமிழக மார்க்கெட் கிங்ஸ்'),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrange.shade600,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width <
                                                  768
                                              ? 16
                                              : 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      context.go('/daily-strategy'),
                                  icon: const Icon(Icons.lightbulb),
                                  label: Text(
                                    languageProvider.translate(
                                        'Daily Strategy',
                                        'இன்றைய லாப வியூகம்'),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo.shade600,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width <
                                                  768
                                              ? 16
                                              : 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => context.go('/todays-choice'),
                                  icon: const Icon(Icons.star),
                                  label: Text(
                                    languageProvider.translate(
                                        'Today\'s Choice', 'இன்றைய சாய்ஸ்'),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber.shade600,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width <
                                                  768
                                              ? 16
                                              : 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => context.go('/top-5-picks'),
                                  icon: const Icon(Icons.emoji_events),
                                  label: Text(
                                    languageProvider.translate('Top 5 Picks',
                                        'டாப் 5 பிசினஸ் தேர்வுகள்'),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width <
                                                  768
                                              ? 16
                                              : 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                // ElevatedButton.icon(
                                //   onPressed: () => context.go('/inventory'),
                                //   icon: const Icon(Icons.check_circle),
                                //   label: Text(
                                //     languageProvider.translate('Inventory', 'சரக்கு'),
                                //   ),
                                //   style: ElevatedButton.styleFrom(
                                //     backgroundColor: const Color(0xFF1E3A8A),
                                //     foregroundColor: Colors.white,
                                //     padding: EdgeInsets.symmetric(
                                //       horizontal: MediaQuery.of(context).size.width < 768 ? 16 : 24,
                                //       vertical: 16,
                                //     ),
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(8),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Metrics Cards
                  Container(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width < 768 ? 16 : 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 768;
                        final crossAxisCount = isMobile ? 2 : 4;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: isMobile
                                ? 150
                                : 190, // Adjusted height to prevent overflow
                          ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            final cards = [
                              _MetricCard(
                                icon: Icons.directions_car,
                                label: languageProvider.translate(
                                    'Total Cars', 'மொத்த கார்கள்'),
                                value: carProvider.totalCars.toString(),
                                color: const Color(0xFF1E3A8A),
                              ),
                              _MetricCard(
                                icon: Icons.access_time,
                                label: languageProvider.translate(
                                    'Pending', 'நிலுவையில்'),
                                value: carProvider.pendingCars.toString(),
                                color: Colors.orange,
                              ),
                              _MetricCard(
                                icon: Icons.check_circle,
                                label: languageProvider.translate(
                                    'Approved', 'அனுமதிக்கப்பட்டது'),
                                value: carProvider.approvedCars.toString(),
                                color: Colors.green,
                              ),
                              _MetricCard(
                                icon: Icons.eco,
                                label: languageProvider.translate(
                                  'Avg. Sustainability Score',
                                  'சராசரி நிலைத்தன்மை மதிப்பெண்',
                                ),
                                value: carProvider.avgSustainabilityScore
                                    .toStringAsFixed(1),
                                color: Colors.green,
                              ),
                            ];

                            return cards[index];
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Only show disclaimer if AI feature has been used
          Consumer<AIUsageProvider>(
            builder: (context, aiUsageProvider, _) {
              return aiUsageProvider.hasUsedAIFeature
                  ? const AIDisclaimer()
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  static void _showFeaturesDialog(
      BuildContext context, LanguageProvider languageProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              languageProvider.translate('All Features', 'அனைத்து அம்சங்கள்'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                _FeatureButton(
                  icon: Icons.insights,
                  label: languageProvider.translate(
                      'Latest Trends', 'சமீபத்திய போக்குகள்'),
                  color: Colors.purple.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/trends');
                  },
                ),
                _FeatureButton(
                  icon: Icons.new_releases,
                  label: languageProvider.translate(
                      'Latest Car Launches', 'சமீபத்திய கார் வெளியீடுகள்'),
                  color: Colors.teal.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/car-launches');
                  },
                ),
                _FeatureButton(
                  icon: Icons.attach_money,
                  label: languageProvider.translate(
                      'Profitable Cars', 'லாபகரமான கார்கள்'),
                  color: Colors.amber.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/profitable-cars');
                  },
                ),
                _FeatureButton(
                  icon: Icons.king_bed,
                  label: languageProvider.translate(
                      'TN Market Kings', 'தமிழக மார்க்கெட் கிங்ஸ்'),
                  color: Colors.deepOrange.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/tn-market-kings');
                  },
                ),
                _FeatureButton(
                  icon: Icons.lightbulb,
                  label: languageProvider.translate(
                      'Daily Strategy', 'இன்றைய லாப வியூகம்'),
                  color: Colors.indigo.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/daily-strategy');
                  },
                ),
                _FeatureButton(
                  icon: Icons.star,
                  label: languageProvider.translate(
                      'Today\'s Choice', 'இன்றைய சாய்ஸ்'),
                  color: Colors.amber.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/todays-choice');
                  },
                ),
                _FeatureButton(
                  icon: Icons.emoji_events,
                  label: languageProvider.translate(
                      'Top 5 Picks', 'டாப் 5 பிசினஸ் தேர்வுகள்'),
                  color: Colors.red.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/top-5-picks');
                  },
                ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          ],
        ),
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeatureButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 64) / 2,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 6 : 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: isMobile ? 20 : 24),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 11 : 13,
              color: Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isMobile ? 4 : 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 28 : 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
