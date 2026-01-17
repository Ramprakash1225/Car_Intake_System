import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/popular_cars_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_header.dart';

class PopularCarDetailsScreen extends StatelessWidget {
  final int carIndex;

  const PopularCarDetailsScreen({super.key, required this.carIndex});

  @override
  Widget build(BuildContext context) {
    final popularCarsProvider = Provider.of<PopularCarsProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final car = popularCarsProvider.getCarByIndex(carIndex);

    if (car == null) {
      return Scaffold(
        body: Column(
          children: [
            const AppHeader(currentRoute: '/popular-cars'),
            Expanded(
              child: Center(
                child: Text(
                  languageProvider.translate('Car not found', 'கார் கிடைக்கவில்லை'),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
                  // Back Button
                  TextButton.icon(
                    onPressed: () => context.go('/popular-cars'),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(
                      languageProvider.translate(
                        'Back to Popular Cars',
                        'பிரபலமான கார்களுக்கு திரும்பு',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title and Region Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${car['make'] ?? 'Unknown'} ${car['model'] ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width < 768 ? 28 : 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: car['region'] == 'India'
                                        ? Colors.orange.shade50
                                        : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
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
                                        size: 16,
                                        color: car['region'] == 'India'
                                            ? Colors.orange.shade700
                                            : Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        car['region']?.toString() ?? 'Unknown',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: car['region'] == 'India'
                                              ? Colors.orange.shade700
                                              : Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    car['year']?.toString() ?? '2024',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Description
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              languageProvider.translate('Overview', 'கண்ணோட்டம்'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          car['description']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Key Information Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 768;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isMobile ? 2 : 4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: isMobile ? 1.2 : 1.0,
                        children: [
                          _InfoCard(
                            icon: Icons.attach_money,
                            label: languageProvider.translate('Price Range', 'விலை வரம்பு'),
                            value: car['priceRange']?.toString() ?? 'N/A',
                            color: Colors.green,
                          ),
                          _InfoCard(
                            icon: Icons.local_gas_station,
                            label: languageProvider.translate('Fuel Type', 'எரிபொருள் வகை'),
                            value: car['fuelType']?.toString() ?? 'N/A',
                            color: Colors.orange,
                          ),
                          _InfoCard(
                            icon: Icons.speed,
                            label: languageProvider.translate('Mileage', 'மைலேஜ்'),
                            value: car['mileage']?.toString() ?? 'N/A',
                            color: Colors.blue,
                          ),
                          _InfoCard(
                            icon: Icons.engineering,
                            label: languageProvider.translate('Engine', 'இயந்திரம்'),
                            value: car['engineCapacity']?.toString() ?? 'N/A',
                            color: Colors.purple,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Sales Figures
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_up, color: Colors.green.shade700, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              languageProvider.translate('Sales Performance', 'விற்பனை செயல்திறன்'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          car['salesFigures']?.toString() ?? 'N/A',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          car['marketPosition']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Sustainability Metrics
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.eco, color: Colors.green.shade700, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              languageProvider.translate(
                                'Sustainability Metrics',
                                'நிலைத்தன்மை அளவீடுகள்',
                              ),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    languageProvider.translate(
                                      'Sustainability Score',
                                      'நிலைத்தன்மை மதிப்பெண்',
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${car['sustainabilityScore'] ?? '70'}/100',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    languageProvider.translate(
                                      'Carbon Footprint',
                                      'கார்பன் பாதச்சுவடு',
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    car['carbonFootprint']?.toString() ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    languageProvider.translate(
                                      'Green Rating',
                                      'பசுமை மதிப்பீடு',
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    car['greenRating']?.toString() ?? 'C',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Features, Pros, Cons
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 768;
                      return isMobile
                          ? Column(
                              children: [
                                _FeaturesSection(
                                  title: languageProvider.translate('Key Features', 'முக்கிய அம்சங்கள்'),
                                  items: car['keyFeatures']?.toString().split(',') ?? [],
                                  icon: Icons.star,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 16),
                                _FeaturesSection(
                                  title: languageProvider.translate('Pros', 'நன்மைகள்'),
                                  items: car['pros']?.toString().split(',') ?? [],
                                  icon: Icons.check_circle,
                                  color: Colors.green,
                                ),
                                const SizedBox(height: 16),
                                _FeaturesSection(
                                  title: languageProvider.translate('Cons', 'குறைபாடுகள்'),
                                  items: car['cons']?.toString().split(',') ?? [],
                                  icon: Icons.cancel,
                                  color: Colors.orange,
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _FeaturesSection(
                                    title: languageProvider.translate('Key Features', 'முக்கிய அம்சங்கள்'),
                                    items: car['keyFeatures']?.toString().split(',') ?? [],
                                    icon: Icons.star,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    children: [
                                      _FeaturesSection(
                                        title: languageProvider.translate('Pros', 'நன்மைகள்'),
                                        items: car['pros']?.toString().split(',') ?? [],
                                        icon: Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(height: 16),
                                      _FeaturesSection(
                                        title: languageProvider.translate('Cons', 'குறைபாடுகள்'),
                                        items: car['cons']?.toString().split(',') ?? [],
                                        icon: Icons.cancel,
                                        color: Colors.orange,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                    },
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final MaterialColor color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color.shade700, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.shade700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final MaterialColor color;

  const _FeaturesSection({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: color.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.trim(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

