import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/popular_cars_provider.dart';
import '../providers/language_provider.dart';
import '../providers/ai_usage_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/ai_disclaimer.dart';
import '../widgets/modern_loader.dart';
import '../utils/language_helper.dart';

class PopularCarsScreen extends StatefulWidget {
  const PopularCarsScreen({super.key});

  @override
  State<PopularCarsScreen> createState() => _PopularCarsScreenState();
}

class _PopularCarsScreenState extends State<PopularCarsScreen> {
  @override
  void initState() {
    super.initState();
    // Load popular cars from Gemini AI when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PopularCarsProvider>(context, listen: false);
      final aiUsageProvider = Provider.of<AIUsageProvider>(context, listen: false);
      provider.setAIUsageProvider(aiUsageProvider);
      provider.loadPopularCars(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final popularCarsProvider = Provider.of<PopularCarsProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(currentRoute: '/popular-cars'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width < 768 ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width < 768 ? 20 : 40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1E3A8A),
                          Colors.blue.shade700,
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
                                            'Popular Cars Analysis',
                                            'பிரபலமான கார்கள் பகுப்பாய்வு',
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: MediaQuery.of(context).size.width < 768 ? 24 : 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (popularCarsProvider.isUsingFallbackData)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade700,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.info_outline, size: 14, color: Colors.white),
                                              const SizedBox(width: 4),
                                              Text(
                                                languageProvider.translate('Sample', 'மாதிரி'),
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
                                      'Worldwide & Indian Best Sellers',
                                      'உலகளாவிய மற்றும் இந்திய சிறந்த விற்பனையாளர்கள்',
                                    ),
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (popularCarsProvider.isUsingFallbackData)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          Icon(Icons.refresh, size: 14, color: Colors.white.withValues(alpha: 0.8)),
                                          const SizedBox(width: 4),
                                          Text(
                                            languageProvider.translate(
                                              'Loading AI data...',
                                              'AI தரவை ஏற்றுகிறது...',
                                            ),
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.8),
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
                                    'Refreshing popular cars...',
                                    'பிரபலமான கார்களை புதுப்பிக்கிறது...',
                                  ),
                                );
                                await popularCarsProvider.loadPopularCars(forceRefresh: true);
                                if (context.mounted) {
                                  hideModernLoader(context);
                                }
                              },
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              tooltip: languageProvider.translate('Refresh', 'புதுப்பிக்க'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Region Filter
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.public, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Text(
                          languageProvider.translate('Filter by Region:', 'பிராந்தியத்தால் வடிகட்டு:'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        _RegionFilterButton(
                          label: languageProvider.translate('All', 'அனைத்தும்'),
                          value: 'all',
                          currentValue: popularCarsProvider.selectedRegion,
                          onTap: () => popularCarsProvider.loadPopularCars(region: 'all', forceRefresh: true),
                        ),
                        const SizedBox(width: 8),
                        _RegionFilterButton(
                          label: languageProvider.translate('Worldwide', 'உலகளாவிய'),
                          value: 'worldwide',
                          currentValue: popularCarsProvider.selectedRegion,
                          onTap: () => popularCarsProvider.loadPopularCars(region: 'worldwide', forceRefresh: true),
                        ),
                        const SizedBox(width: 8),
                        _RegionFilterButton(
                          label: languageProvider.translate('India', 'இந்தியா'),
                          value: 'india',
                          currentValue: popularCarsProvider.selectedRegion,
                          onTap: () => popularCarsProvider.loadPopularCars(region: 'india', forceRefresh: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Cars List
                  if (popularCarsProvider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (popularCarsProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            languageProvider.translate(
                              'Error loading cars: ${popularCarsProvider.error}',
                              'கார்களை ஏற்றுவதில் பிழை: ${popularCarsProvider.error}',
                            ),
                            style: TextStyle(color: Colors.red.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else if (popularCarsProvider.popularCars.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          languageProvider.translate(
                            'No cars found',
                            'கார்கள் கிடைக்கவில்லை',
                          ),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 768;
                        final crossAxisCount = isMobile ? 1 : (constraints.maxWidth < 1024 ? 2 : 3);
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: isMobile ? 1.1 : 0.85,
                          ),
                          itemCount: popularCarsProvider.popularCars.length,
                          itemBuilder: (context, index) {
                            final car = popularCarsProvider.popularCars[index];
                            return _PopularCarCard(
                              car: car,
                              index: index,
                            );
                          },
                        );
                      },
                    ),
                  // AI Disclaimer with Confidence Score
                  const SizedBox(height: 24),
                  AIDisclaimer(
                    confidenceScore: popularCarsProvider.isUsingFallbackData ? 0.70 : 0.85,
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

class _RegionFilterButton extends StatelessWidget {
  final String label;
  final String value;
  final String currentValue;
  final VoidCallback onTap;

  const _RegionFilterButton({
    required this.label,
    required this.value,
    required this.currentValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentValue == value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _PopularCarCard extends StatelessWidget {
  final Map<String, dynamic> car;
  final int index;

  const _PopularCarCard({
    required this.car,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return GestureDetector(
      onTap: () => context.go('/popular-car/$index'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with region badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade50,
                    Colors.blue.shade100,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${car['make'] ?? 'Unknown'} ${car['model'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: car['region'] == 'India'
                                ? Colors.orange.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: car['region'] == 'India'
                                  ? Colors.orange.shade300
                                  : Colors.blue.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                car['region'] == 'India' ? Icons.flag : Icons.public,
                                size: 12,
                                color: car['region'] == 'India'
                                    ? Colors.orange.shade700
                                    : Colors.blue.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                car['region']?.toString() ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: car['region'] == 'India'
                                      ? Colors.orange.shade700
                                      : Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year and Price
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            car['year']?.toString() ?? '2024',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          car['priceRange']?.toString() ?? 'N/A',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Description
                    Expanded(
                      child: Text(
                        LanguageHelper.getAIContent(context, car, 'description'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Key Stats
                    Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            icon: Icons.local_gas_station,
                            label: languageProvider.translate('Fuel', 'எரிபொருள்'),
                            value: car['fuelType']?.toString() ?? 'N/A',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatItem(
                            icon: Icons.speed,
                            label: languageProvider.translate('Mileage', 'மைலேஜ்'),
                            value: car['mileage']?.toString() ?? 'N/A',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Sustainability Score
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              languageProvider.translate(
                                'Sustainability Score',
                                'நிலைத்தன்மை மதிப்பெண்',
                              ),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '${car['sustainabilityScore'] ?? '70'}/100',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: (int.tryParse(car['sustainabilityScore']?.toString() ?? '70') ?? 70) / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                          minHeight: 6,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // View Details Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/popular-car/$index'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          languageProvider.translate('View Details', 'விவரங்களைப் பார்க்க'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

