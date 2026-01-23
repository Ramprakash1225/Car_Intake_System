import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/car_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/ai_disclaimer.dart';
import '../models/car_model.dart';

class CarDetailsScreen extends StatelessWidget {
  final int carId;

  const CarDetailsScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final car = carProvider.getCarById(carId);

    if (car == null) {
      return Scaffold(
        body: Center(
          child: Text(
            languageProvider.translate('Car not found', 'கார் கிடைக்கவில்லை'),
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(currentRoute: '/inventory'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width < 768 ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  TextButton.icon(
                    onPressed: () => context.go('/inventory'),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(
                      languageProvider.translate(
                        'Back to Inventory',
                        'சரக்குக்கு திரும்பு',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title, ID and Action Buttons Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title and ID
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.fullName,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width < 768
                                        ? 24
                                        : 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${car.id}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Action Buttons
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showEditDialog(
                                context, car, carProvider, languageProvider),
                            icon: const Icon(Icons.edit),
                            label: Text(
                              languageProvider.translate('Edit', 'திருத்து'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => _showDeleteDialog(
                                context, car, carProvider, languageProvider),
                            icon: const Icon(Icons.delete),
                            label: Text(
                              languageProvider.translate(
                                  'Delete Car', 'காரை நீக்கு'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Car Images Gallery - Display all uploaded images
                  if (car.allImageBytes != null &&
                      car.allImageBytes!.isNotEmpty) ...[
                    Text(
                      languageProvider.translate(
                        'Uploaded Images',
                        'பதிவேற்றப்பட்ட படங்கள்',
                      ),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Image Gallery Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width < 768 ? 2 : 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: car.allImageBytes!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(
                                  car.allImageBytes![index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Image number badge
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${index + 1}/${car.allImageBytes!.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Quick Info about analyzed images
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              languageProvider.translate(
                                'All ${car.allImageBytes!.length} image(s) were analyzed using AI to extract comprehensive vehicle information.',
                                'அனைத்து ${car.allImageBytes!.length} படங்களும் வாகன தகவலை பிரித்தெடுக்க AI பயன்படுத்தி பகுப்பாய்வு செய்யப்பட்டது.',
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade800,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else if (car.imageBytes != null) ...[
                    // Fallback to single image for backward compatibility
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.width < 768
                                ? 200
                                : 350,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                car.imageBytes!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: Icon(
                                        Icons.directions_car_outlined,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.blue.shade700,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          languageProvider.translate(
                                            'Analyzed Image',
                                            'பகுப்பாய்வு செய்யப்பட்ட படம்',
                                          ),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      languageProvider.translate(
                                        'This image was analyzed using AI to extract vehicle information.',
                                        'இந்த படம் வாகன தகவலை பிரித்தெடுக்க AI பயன்படுத்தி பகுப்பாய்வு செய்யப்பட்டது.',
                                      ),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.blue.shade800,
                                        height: 1.4,
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
                    const SizedBox(height: 24),
                  ],
                  // Summary/Description (Compulsory) - with bullet marks
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languageProvider.translate('Summary', 'சுருக்கம்'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildBulletSummary(
                          languageProvider.isTamil
                              ? (car.descriptionTa ?? car.description)
                              : (car.descriptionEn ?? car.description),
                          languageProvider,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // All Analyzed Data - Show below Summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languageProvider.translate(
                            'Analyzed Data',
                            'பகுப்பாய்வு செய்யப்பட்ட தரவு',
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 768;
                            final details = [
                              _DetailRow(
                                label: languageProvider.translate(
                                    'Make', 'தயாரிப்பு'),
                                value: car.make,
                              ),
                              const SizedBox(height: 8),
                              _DetailRow(
                                label: languageProvider.translate(
                                    'Model', 'மாதிரி'),
                                value: car.model,
                              ),
                              const SizedBox(height: 8),
                              _DetailRow(
                                label:
                                    languageProvider.translate('Year', 'ஆண்டு'),
                                value: car.year.toString(),
                              ),
                              const SizedBox(height: 8),
                              _DetailRow(
                                label: languageProvider.translate(
                                  'Odometer Reading',
                                  'ஓடோமீட்டர் வாசிப்பு',
                                ),
                                value:
                                    '${car.odometerReading.toString().replaceAllMapped(
                                          RegExp(
                                              r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                          (Match m) => '${m[1]},',
                                        )} km',
                              ),
                              const SizedBox(height: 8),
                              _DetailRow(
                                label: languageProvider.translate(
                                  'Exterior Condition',
                                  'வெளிப்புற நிலை',
                                ),
                                value: car.exteriorCondition,
                              ),
                              const SizedBox(height: 8),
                              _DetailRow(
                                label: languageProvider.translate(
                                  'Interior Condition',
                                  'உட்புற நிலை',
                                ),
                                value: car.interiorCondition,
                              ),
                              const SizedBox(height: 8),
                              _DetailRow(
                                label: languageProvider.translate(
                                  'Damage Details',
                                  'சேதம் விவரங்கள்',
                                ),
                                value: car.damageDetails,
                              ),
                              const SizedBox(height: 8),
                              _DetailRow(
                                label: languageProvider.translate(
                                  'Tyre Condition',
                                  'டயர் நிலை',
                                ),
                                value: car.tyreCondition,
                              ),
                              if (car.confidenceScore != null) ...[
                                const SizedBox(height: 8),
                                _DetailRow(
                                  label: languageProvider.translate(
                                    'Confidence Score',
                                    'நம்பிக்கை மதிப்பெண்',
                                  ),
                                  value:
                                      '${car.confidenceScore!.toStringAsFixed(1)}%',
                                ),
                              ],
                              if (car.carbonFootprint.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _DetailRow(
                                  label: languageProvider.translate(
                                    'Carbon Footprint',
                                    'கார்பன் பாதச்சுவடு',
                                  ),
                                  value: car.carbonFootprint,
                                ),
                              ],
                              if (car.greenRating.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _DetailRow(
                                  label: languageProvider.translate(
                                    'Green Rating',
                                    'பசுமை மதிப்பீடு',
                                  ),
                                  value: car.greenRating,
                                ),
                              ],
                            ];

                            return isMobile
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: details,
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: details
                                              .take((details.length / 2).ceil())
                                              .toList(),
                                        ),
                                      ),
                                      const SizedBox(width: 32),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: details
                                              .skip((details.length / 2).ceil())
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Market Demand, Purchase Recommendation, and Environmental & Social Measures
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 768;

                      if (isMobile) {
                        // Mobile: Stack vertically
                        return Column(
                          children: [
                            // Market Demand
                            if (car.demand != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.blue.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.trending_up,
                                          color: Colors.blue.shade700,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          languageProvider.translate(
                                            'Market Demand',
                                            'சந்தை தேவை',
                                          ),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      car.demand!,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            // Purchase Recommendation
                            if (car.purchaseRecommendation != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: car.purchaseRecommendation!
                                          .toLowerCase()
                                          .contains('purchase')
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: car.purchaseRecommendation!
                                            .toLowerCase()
                                            .contains('purchase')
                                        ? Colors.green.shade200
                                        : Colors.red.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          car.purchaseRecommendation!
                                                  .toLowerCase()
                                                  .contains('purchase')
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: car.purchaseRecommendation!
                                                  .toLowerCase()
                                                  .contains('purchase')
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          languageProvider.translate(
                                            'Recommendation',
                                            'பரிந்துரை',
                                          ),
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: car.purchaseRecommendation!
                                                    .toLowerCase()
                                                    .contains('purchase')
                                                ? Colors.green.shade900
                                                : Colors.red.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      car.purchaseRecommendation!,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: car.purchaseRecommendation!
                                                .toLowerCase()
                                                .contains('purchase')
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ],
                        );
                      } else {
                        // Desktop: Horizontal layout
                        if (car.demand != null ||
                            car.purchaseRecommendation != null) {
                          return Row(
                            children: [
                              // Market Demand
                              if (car.demand != null)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.blue.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.trending_up,
                                              color: Colors.blue.shade700,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              languageProvider.translate(
                                                'Market Demand',
                                                'சந்தை தேவை',
                                              ),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          car.demand!,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (car.demand != null &&
                                  car.purchaseRecommendation != null)
                                const SizedBox(width: 16),
                              // Purchase Recommendation
                              if (car.purchaseRecommendation != null)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: car.purchaseRecommendation!
                                              .toLowerCase()
                                              .contains('purchase')
                                          ? Colors.green.shade50
                                          : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: car.purchaseRecommendation!
                                                .toLowerCase()
                                                .contains('purchase')
                                            ? Colors.green.shade200
                                            : Colors.red.shade200,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              car.purchaseRecommendation!
                                                      .toLowerCase()
                                                      .contains('purchase')
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              color: car.purchaseRecommendation!
                                                      .toLowerCase()
                                                      .contains('purchase')
                                                  ? Colors.green.shade700
                                                  : Colors.red.shade700,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              languageProvider.translate(
                                                'Recommendation',
                                                'பரிந்துரை',
                                              ),
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: car
                                                        .purchaseRecommendation!
                                                        .toLowerCase()
                                                        .contains('purchase')
                                                    ? Colors.green.shade900
                                                    : Colors.red.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          car.purchaseRecommendation!,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: car.purchaseRecommendation!
                                                    .toLowerCase()
                                                    .contains('purchase')
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Additional Information
                  if (car.additionalInfo != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            languageProvider.translate(
                              'Additional Information',
                              'கூடுதல் தகவல்',
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            car.additionalInfo!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Environmental & Social Measures
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
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
                            Icon(
                              Icons.eco,
                              color: Colors.green.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              languageProvider.translate(
                                'Environmental & Social Measures',
                                'சுற்றுச்சூழல் & சமூக நடவடிக்கைகள்',
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      languageProvider.translate(
                                        'Eco Score',
                                        'சுற்றுச்சூழல் மதிப்பெண்',
                                      ),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${car.sustainabilityScore.toStringAsFixed(1)}/100',
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Status Tab
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              car.status == CarStatus.pending
                                  ? Icons.access_time
                                  : Icons.check_circle,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              languageProvider.translate(
                                'Status',
                                'நிலை',
                              ),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _StatusDropdown(
                          car: car,
                          carProvider: carProvider,
                          languageProvider: languageProvider,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const AIDisclaimer(),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade900,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusDropdown extends StatefulWidget {
  final Car car;
  final CarProvider carProvider;
  final LanguageProvider languageProvider;

  const _StatusDropdown({
    required this.car,
    required this.carProvider,
    required this.languageProvider,
  });

  @override
  State<_StatusDropdown> createState() => _StatusDropdownState();
}

class _StatusDropdownState extends State<_StatusDropdown> {
  late CarStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.car.status;
  }

  String _getStatusText(CarStatus status) {
    switch (status) {
      case CarStatus.pending:
        return widget.languageProvider.translate('Pending', 'நிலுவையில்');
      case CarStatus.approved:
        return widget.languageProvider
            .translate('Approved', 'அனுமதிக்கப்பட்டது');
      case CarStatus.rejected:
        return widget.languageProvider
            .translate('Rejected', 'நிராகரிக்கப்பட்டது');
    }
  }

  Color _getStatusColor(CarStatus status) {
    switch (status) {
      case CarStatus.pending:
        return Colors.amber.shade800;
      case CarStatus.approved:
        return Colors.green.shade800;
      case CarStatus.rejected:
        return Colors.red.shade800;
    }
  }

  Color _getStatusBgColor(CarStatus status) {
    switch (status) {
      case CarStatus.pending:
        return Colors.amber.shade100;
      case CarStatus.approved:
        return Colors.green.shade100;
      case CarStatus.rejected:
        return Colors.red.shade100;
    }
  }

  IconData _getStatusIcon(CarStatus status) {
    switch (status) {
      case CarStatus.pending:
        return Icons.access_time;
      case CarStatus.approved:
        return Icons.check_circle;
      case CarStatus.rejected:
        return Icons.cancel;
    }
  }

  Future<void> _updateStatus(CarStatus newStatus) async {
    if (newStatus == _selectedStatus) return;

    setState(() {
      _selectedStatus = newStatus;
    });

    // Create updated car with new status
    final updatedCar = Car(
      id: widget.car.id,
      make: widget.car.make,
      model: widget.car.model,
      year: widget.car.year,
      description: widget.car.description,
      descriptionEn: widget.car.descriptionEn,
      descriptionTa: widget.car.descriptionTa,
      sustainabilityScore: widget.car.sustainabilityScore,
      status: newStatus,
      odometerReading: widget.car.odometerReading,
      exteriorCondition: widget.car.exteriorCondition,
      interiorCondition: widget.car.interiorCondition,
      damageDetails: widget.car.damageDetails,
      tyreCondition: widget.car.tyreCondition,
      carbonFootprint: widget.car.carbonFootprint,
      greenRating: widget.car.greenRating,
      additionalInfo: widget.car.additionalInfo,
      imageUrl: widget.car.imageUrl,
      imageBytes: widget.car.imageBytes,
      allImageBytes: widget.car.allImageBytes,
      confidenceScore: widget.car.confidenceScore,
      demand: widget.car.demand,
      purchaseRecommendation: widget.car.purchaseRecommendation,
    );

    await widget.carProvider.updateCar(updatedCar);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.languageProvider.translate(
              'Status updated successfully',
              'நிலை வெற்றிகரமாக புதுப்பிக்கப்பட்டது',
            ),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Navigate to approved tab if status is approved
      if (newStatus == CarStatus.approved) {
        context.go('/inventory?tab=approved');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: _getStatusBgColor(_selectedStatus),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(_selectedStatus).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(_selectedStatus),
            color: _getStatusColor(_selectedStatus),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CarStatus>(
                value: _selectedStatus,
                isExpanded: true,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: _getStatusColor(_selectedStatus),
                ),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(_selectedStatus),
                ),
                dropdownColor: Colors.white,
                items: CarStatus.values
                    .where((status) => status != CarStatus.rejected)
                    .map((status) {
                  return DropdownMenuItem<CarStatus>(
                    value: status,
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          color: _getStatusColor(status),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(_getStatusText(status)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (CarStatus? newStatus) {
                  if (newStatus != null) {
                    _updateStatus(newStatus);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildBulletSummary(
  String text,
  LanguageProvider languageProvider,
) {
  // Split text into sentences or by periods
  final sentences = text
      .split(RegExp(r'[.!?]\s+'))
      .where((s) => s.trim().isNotEmpty)
      .toList();

  // Group sentences into pairs (2 lines per bullet)
  final List<List<String>> bulletGroups = [];
  for (int i = 0; i < sentences.length; i += 2) {
    if (i + 1 < sentences.length) {
      bulletGroups.add([sentences[i], sentences[i + 1]]);
    } else {
      bulletGroups.add([sentences[i]]);
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: bulletGroups.map((group) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 8),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: group.map((sentence) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      sentence.trim(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

void _showDeleteDialog(BuildContext context, Car car, CarProvider carProvider,
    LanguageProvider languageProvider) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(
          languageProvider.translate('Delete Car', 'காரை நீக்கு'),
        ),
        content: Text(
          languageProvider.translate(
            'Are you sure you want to delete ${car.fullName}? This action cannot be undone.',
            'நீங்கள் ${car.fullName} ஐ நிச்சயமாக நீக்க விரும்புகிறீர்களா? இந்த செயலை திரும்பப் பெற முடியாது.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              languageProvider.translate('Cancel', 'ரத்துசெய்'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Close dialog first
              Navigator.of(dialogContext).pop();

              // Delete the car
              await carProvider.deleteCar(car.id);

              // Navigate to inventory screen
              if (context.mounted) {
                context.go('/inventory');

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      languageProvider.translate(
                        'Car deleted successfully',
                        'கார் வெற்றிகரமாக நீக்கப்பட்டது',
                      ),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              languageProvider.translate('Delete', 'நீக்கு'),
            ),
          ),
        ],
      );
    },
  );
}

void _showEditDialog(BuildContext context, Car car, CarProvider carProvider,
    LanguageProvider languageProvider) {
  final makeController = TextEditingController(text: car.make);
  final modelController = TextEditingController(text: car.model);
  final yearController = TextEditingController(text: car.year.toString());
  // Use language-specific description if available, otherwise fallback to general description
  final descriptionController = TextEditingController(
    text: languageProvider.isTamil
        ? (car.descriptionTa ?? car.description)
        : (car.descriptionEn ?? car.description),
  );
  final odometerController =
      TextEditingController(text: car.odometerReading.toString());
  final exteriorController = TextEditingController(text: car.exteriorCondition);
  final interiorController = TextEditingController(text: car.interiorCondition);
  final damageController = TextEditingController(text: car.damageDetails);
  final tyreController = TextEditingController(text: car.tyreCondition);
  final additionalInfoController =
      TextEditingController(text: car.additionalInfo ?? '');
  CarStatus selectedStatus = car.status;

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              languageProvider.translate('Edit Car', 'காரை திருத்து'),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: makeController,
                    decoration: InputDecoration(
                      labelText:
                          languageProvider.translate('Make', 'தயாரிப்பு'),
                    ),
                  ),
                  TextField(
                    controller: modelController,
                    decoration: InputDecoration(
                      labelText: languageProvider.translate('Model', 'மாதிரி'),
                    ),
                  ),
                  TextField(
                    controller: yearController,
                    decoration: InputDecoration(
                      labelText: languageProvider.translate('Year', 'ஆண்டு'),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText:
                          languageProvider.translate('Description', 'விளக்கம்'),
                    ),
                    maxLines: 2,
                  ),
                  TextField(
                    controller: odometerController,
                    decoration: InputDecoration(
                      labelText: languageProvider.translate(
                          'Odometer Reading', 'ஓடோமீட்டர் வாசிப்பு'),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: exteriorController,
                    decoration: InputDecoration(
                      labelText: languageProvider.translate(
                          'Exterior Condition', 'வெளிப்புற நிலை'),
                    ),
                  ),
                  TextField(
                    controller: interiorController,
                    decoration: InputDecoration(
                      labelText: languageProvider.translate(
                          'Interior Condition', 'உட்புற நிலை'),
                    ),
                  ),
                  TextField(
                    controller: damageController,
                    decoration: InputDecoration(
                      labelText: languageProvider.translate(
                          'Damage Details', 'சேதம் விவரங்கள்'),
                    ),
                  ),
                  TextField(
                    controller: tyreController,
                    decoration: InputDecoration(
                      labelText: languageProvider.translate(
                          'Tyre Condition', 'டயர் நிலை'),
                    ),
                  ),
                  TextField(
                    controller: additionalInfoController,
                    decoration: InputDecoration(
                      labelText: languageProvider.translate(
                          'Additional Information', 'கூடுதல் தகவல்'),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  FormField<CarStatus>(
                    initialValue: selectedStatus,
                    builder: (FormFieldState<CarStatus> field) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          labelText:
                              languageProvider.translate('Status', 'நிலை'),
                          errorText: field.errorText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<CarStatus>(
                            value: selectedStatus,
                            isExpanded: true,
                            items: [
                              DropdownMenuItem(
                                value: CarStatus.pending,
                                child: Text(languageProvider.translate(
                                    'Pending', 'நிலுவையில்')),
                              ),
                              DropdownMenuItem(
                                value: CarStatus.approved,
                                child: Text(languageProvider.translate(
                                    'Approved', 'அனுமதிக்கப்பட்டது')),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedStatus = value;
                                });
                                field.didChange(value);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  makeController.dispose();
                  modelController.dispose();
                  yearController.dispose();
                  descriptionController.dispose();
                  odometerController.dispose();
                  exteriorController.dispose();
                  interiorController.dispose();
                  damageController.dispose();
                  tyreController.dispose();
                  additionalInfoController.dispose();
                  Navigator.of(dialogContext).pop();
                },
                child: Text(
                  languageProvider.translate('Cancel', 'ரத்துசெய்'),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Read all values from controllers before closing dialog
                  final makeValue = makeController.text;
                  final modelValue = modelController.text;
                  final yearValue =
                      int.tryParse(yearController.text) ?? car.year;
                  final descriptionValue = descriptionController.text;
                  final odometerValue = int.tryParse(odometerController.text) ??
                      car.odometerReading;
                  final exteriorValue = exteriorController.text;
                  final interiorValue = interiorController.text;
                  final damageValue = damageController.text;
                  final tyreValue = tyreController.text;
                  final additionalInfoValue =
                      additionalInfoController.text.isEmpty
                          ? null
                          : additionalInfoController.text;

                  // Update description based on current language
                  final updatedCar = Car(
                    id: car.id,
                    make: makeValue,
                    model: modelValue,
                    year: yearValue,
                    description:
                        descriptionValue, // Keep for backward compatibility
                    descriptionEn: languageProvider.isTamil
                        ? car.descriptionEn
                        : descriptionValue, // Update English if in English mode
                    descriptionTa: languageProvider.isTamil
                        ? descriptionValue
                        : car.descriptionTa, // Update Tamil if in Tamil mode
                    sustainabilityScore: car.sustainabilityScore,
                    status: selectedStatus,
                    odometerReading: odometerValue,
                    exteriorCondition: exteriorValue,
                    interiorCondition: interiorValue,
                    damageDetails: damageValue,
                    tyreCondition: tyreValue,
                    carbonFootprint: car.carbonFootprint,
                    greenRating: car.greenRating,
                    additionalInfo: additionalInfoValue,
                    imageUrl: car.imageUrl,
                    imageBytes: car.imageBytes,
                    allImageBytes:
                        car.allImageBytes, // Preserve all images when editing
                    confidenceScore: car.confidenceScore,
                  );

                  // Close the dialog first
                  Navigator.of(dialogContext).pop();

                  // Wait for the dialog to fully close before proceeding
                  // Use post-frame callback to ensure dialog is completely removed
                  SchedulerBinding.instance.addPostFrameCallback((_) async {
                    // Update car after dialog is fully closed
                    await carProvider.updateCar(updatedCar);

                    // Dispose controllers after dialog is fully closed
                    makeController.dispose();
                    modelController.dispose();
                    yearController.dispose();
                    descriptionController.dispose();
                    odometerController.dispose();
                    exteriorController.dispose();
                    interiorController.dispose();
                    damageController.dispose();
                    tyreController.dispose();
                    additionalInfoController.dispose();

                    // Navigate to inventory screen
                    if (context.mounted) {
                      context.go('/inventory');

                      // Show success message
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              languageProvider.translate(
                                'Car updated successfully',
                                'கார் வெற்றிகரமாக புதுப்பிக்கப்பட்டது',
                              ),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  languageProvider.translate('Save', 'சேமி'),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
