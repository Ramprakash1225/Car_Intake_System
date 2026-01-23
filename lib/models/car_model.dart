import 'dart:typed_data';

enum CarStatus {
  pending,
  approved,
  rejected,
}

class Car {
  final int id;
  final String make;
  final String model;
  final int year;
  final String description; // Keep for backward compatibility
  final String? descriptionEn; // English description
  final String? descriptionTa; // Tamil description
  final double sustainabilityScore;
  final CarStatus status;
  final int odometerReading;
  final String exteriorCondition;
  final String interiorCondition;
  final String damageDetails;
  final String tyreCondition;
  final String carbonFootprint;
  final String greenRating;
  final String? additionalInfo;
  final String? imageUrl;
  final Uint8List? imageBytes; // Keep for backward compatibility (first image)
  final List<Uint8List>? allImageBytes; // All uploaded images
  final double? confidenceScore;
  final String? demand; // Market demand for the car
  final String? purchaseRecommendation; // Purchase recommendation (Purchase/Not Purchase)

  Car({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.description,
    this.descriptionEn,
    this.descriptionTa,
    required this.sustainabilityScore,
    required this.status,
    required this.odometerReading,
    required this.exteriorCondition,
    required this.interiorCondition,
    required this.damageDetails,
    required this.tyreCondition,
    required this.carbonFootprint,
    required this.greenRating,
    this.additionalInfo,
    this.imageUrl,
    this.imageBytes,
    this.allImageBytes,
    this.confidenceScore,
    this.demand,
    this.purchaseRecommendation,
  });

  String get fullName => '$make $model ($year)';
  String get statusText => status == CarStatus.approved ? 'Approved' : 'Pending';
}

