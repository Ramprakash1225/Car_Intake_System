import 'package:flutter/material.dart';

/// A widget that displays feature images from Gemini AI with fallback to local assets
/// Primary: Uses images from Gemini AI API calls
/// Fallback: Uses local assets only if Gemini image fails to load
class FeatureImage extends StatelessWidget {
  final String? imageUrl;
  final String fallbackAsset;
  final BoxFit fit;
  final double? width;
  final double? height;

  const FeatureImage({
    super.key,
    required this.imageUrl,
    required this.fallbackAsset,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // If no URL provided, use asset directly
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Image.asset(
        fallbackAsset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width ?? double.infinity,
            height: height ?? double.infinity,
            color: Colors.grey.shade200,
            child: const Icon(Icons.directions_car, size: 48, color: Colors.grey),
          );
        },
      );
    }

    // Primary: Try to load Gemini-provided image first
    // Even if URL format is not perfect, attempt to load it (Gemini might provide various formats)
    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          color: Colors.grey.shade200,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Fallback: If Gemini image fails, use local asset
        return Image.asset(
          fallbackAsset,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            // Final fallback: Show placeholder icon
            return Container(
              width: width ?? double.infinity,
              height: height ?? double.infinity,
              color: Colors.grey.shade200,
              child: const Icon(Icons.directions_car, size: 48, color: Colors.grey),
            );
          },
        );
      },
    );
  }
}

