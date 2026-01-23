import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car_model.dart';
import '../services/ai_service.dart';

class CarProvider with ChangeNotifier {
  final List<Car> _cars = [];
  bool _isLoading = false;

  List<Car> get cars => _cars;
  bool get isLoading => _isLoading;

  CarProvider() {
    // Load cars asynchronously
    _loadCars();
  }

  Future<void> _loadCars() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final carsJson = prefs.getString('cars_data');
      if (carsJson != null && carsJson.isNotEmpty) {
        final List<dynamic> carsList = json.decode(carsJson);
        _cars.clear();
        for (var carMap in carsList) {
          _cars.add(_carFromJson(carMap as Map<String, dynamic>));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cars: $e');
    }
  }

  Future<void> _saveCars() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final carsList = _cars.map((car) => _carToJson(car)).toList();
      await prefs.setString('cars_data', json.encode(carsList));
    } catch (e) {
      debugPrint('Error saving cars: $e');
    }
  }

  Map<String, dynamic> _carToJson(Car car) {
    return {
      'id': car.id,
      'make': car.make,
      'model': car.model,
      'year': car.year,
      'description': car.description,
      'descriptionEn': car.descriptionEn,
      'descriptionTa': car.descriptionTa,
      'sustainabilityScore': car.sustainabilityScore,
      'status': car.status.index,
      'odometerReading': car.odometerReading,
      'exteriorCondition': car.exteriorCondition,
      'interiorCondition': car.interiorCondition,
      'damageDetails': car.damageDetails,
      'tyreCondition': car.tyreCondition,
      'carbonFootprint': car.carbonFootprint,
      'greenRating': car.greenRating,
      'additionalInfo': car.additionalInfo,
      'imageUrl': car.imageUrl,
      'imageBytes':
          car.imageBytes != null ? base64Encode(car.imageBytes!) : null,
      'allImageBytes':
          car.allImageBytes?.map((bytes) => base64Encode(bytes)).toList(),
      'confidenceScore': car.confidenceScore,
      'demand': car.demand,
      'purchaseRecommendation': car.purchaseRecommendation,
    };
  }

  Car _carFromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as int,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      description: json['description'] as String,
      descriptionEn: json['descriptionEn'] as String?,
      descriptionTa: json['descriptionTa'] as String?,
      sustainabilityScore: (json['sustainabilityScore'] as num).toDouble(),
      status: CarStatus.values[json['status'] as int],
      odometerReading: json['odometerReading'] as int,
      exteriorCondition: json['exteriorCondition'] as String,
      interiorCondition: json['interiorCondition'] as String,
      damageDetails: json['damageDetails'] as String,
      tyreCondition: json['tyreCondition'] as String,
      carbonFootprint: json['carbonFootprint'] as String,
      greenRating: json['greenRating'] as String,
      additionalInfo: json['additionalInfo'] as String?,
      imageUrl: json['imageUrl'] as String?,
      imageBytes: json['imageBytes'] != null
          ? base64Decode(json['imageBytes'] as String)
          : null,
      allImageBytes: json['allImageBytes'] != null
          ? (json['allImageBytes'] as List)
              .map((e) => base64Decode(e as String))
              .toList()
          : null,
      confidenceScore: json['confidenceScore'] != null
          ? (json['confidenceScore'] as num).toDouble()
          : null,
      demand: json['demand'] as String?,
      purchaseRecommendation: json['purchaseRecommendation'] as String?,
    );
  }

  Future<void> analyzeCar({
    required List<Uint8List> imageBytes,
    String? additionalInfo,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('=== Starting car analysis ===');
      debugPrint('Image count: ${imageBytes.length}');
      debugPrint('Additional info: ${additionalInfo ?? 'None'}');
      
      final analysis = await AIService.analyzeCarImages(
        imageBytes: imageBytes,
        additionalInfo: additionalInfo,
      );

      debugPrint('=== AI Analysis Result ===');
      debugPrint('Analysis keys: ${analysis.keys.toList()}');
      debugPrint('Make: ${analysis['make']}');
      debugPrint('Model: ${analysis['model']}');
      debugPrint('DescriptionEn length: ${analysis['descriptionEn']?.length ?? 0}');
      debugPrint('DescriptionTa length: ${analysis['descriptionTa']?.length ?? 0}');
      debugPrint('Is Fallback: ${analysis['_isFallback'] ?? 'false'}');
      debugPrint('Error: ${analysis['_error'] ?? 'none'}');
      debugPrint('=== End Analysis Result ===');

      // Generate unique ID
      int newId = _cars.isEmpty
          ? 1
          : (_cars.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1);

      // Ensure descriptions are not empty
      final descriptionEn = analysis['descriptionEn']?.toString().trim() ?? 
          analysis['description']?.toString().trim() ?? 
          'Car analysis completed. Detailed vehicle information has been extracted from the provided images.';
      final descriptionTa = analysis['descriptionTa']?.toString().trim() ?? 
          'கார் பகுப்பாய்வு முடிக்கப்பட்டது. வழங்கப்பட்ட படங்களிலிருந்து விரிவான வாகன தகவல் பிரித்தெடுக்கப்பட்டது.';
      
      final newCar = Car(
        id: newId,
        make: analysis['make'] ?? 'Unknown',
        model: analysis['model'] ?? 'Unknown',
        year: int.tryParse(analysis['year'] ?? '2020') ?? 2020,
        description: descriptionEn, // Use descriptionEn as primary description
        descriptionEn: descriptionEn,
        descriptionTa: descriptionTa,
        sustainabilityScore:
            double.tryParse(analysis['sustainabilityScore'] ?? '70') ?? 70.0,
        status: CarStatus.pending,
        odometerReading: int.tryParse(
                analysis['odometerReading']?.replaceAll(',', '') ?? '0') ??
            0,
        exteriorCondition: analysis['exteriorCondition'] ?? 'Unknown',
        interiorCondition: analysis['interiorCondition'] ?? 'Unknown',
        damageDetails: analysis['damageDetails'] ?? 'None',
        tyreCondition: analysis['tyreCondition'] ?? 'Unknown',
        carbonFootprint: analysis['carbonFootprint'] ?? 'Unknown',
        greenRating: analysis['greenRating'] ?? 'C',
        additionalInfo: additionalInfo,
        imageBytes: imageBytes.isNotEmpty
            ? imageBytes.first
            : null, // First image for backward compatibility
        allImageBytes: imageBytes.isNotEmpty ? imageBytes : null, // All images
        confidenceScore:
            double.tryParse(analysis['confidenceScore'] ?? '85') ?? 85.0,
        demand: analysis['demand'],
        purchaseRecommendation: analysis['purchaseRecommendation'],
      );

      _cars.insert(0, newCar);
      await _saveCars();
    } catch (e) {
      debugPrint('Error analyzing car: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Car? getCarById(int id) {
    try {
      return _cars.firstWhere((car) => car.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteCar(int id) async {
    _cars.removeWhere((car) => car.id == id);
    await _saveCars();
    notifyListeners();
  }

  Future<void> updateCar(Car updatedCar) async {
    final index = _cars.indexWhere((car) => car.id == updatedCar.id);
    if (index != -1) {
      _cars[index] = updatedCar;
      await _saveCars();
      notifyListeners();
    }
  }

  Future<void> clearAllCars() async {
    _cars.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cars_data');
    notifyListeners();
  }

  int get totalCars => _cars.length;
  int get pendingCars =>
      _cars.where((c) => c.status == CarStatus.pending).length;
  int get approvedCars =>
      _cars.where((c) => c.status == CarStatus.approved).length;
  double get avgSustainabilityScore {
    if (_cars.isEmpty) return 0.0;
    return _cars.map((c) => c.sustainabilityScore).reduce((a, b) => a + b) /
        _cars.length;
  }
}
