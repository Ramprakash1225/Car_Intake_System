import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

/// Helper class to extract language-specific content from bilingual text
class LanguageHelper {
  /// Extracts content based on current language preference
  /// Expects format: "English content. Tamil content."
  /// or separate fields with _en and _tamil suffixes
  static String getContent(
    BuildContext context,
    dynamic data, {
    String? englishKey,
    String? tamilKey,
  }) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isTamil = languageProvider.isTamil;

    if (data is Map<String, dynamic>) {
      // If separate keys provided, use them
      if (englishKey != null && tamilKey != null) {
        if (isTamil && data[tamilKey] != null) {
          return data[tamilKey].toString();
        }
        if (!isTamil && data[englishKey] != null) {
          return data[englishKey].toString();
        }
        // Fallback to either key
        return data[tamilKey]?.toString() ?? data[englishKey]?.toString() ?? '';
      }

      // Try common bilingual patterns
      final text = data.values.first?.toString() ?? '';
      return _extractLanguage(text, isTamil);
    }

    if (data is String) {
      return _extractLanguage(data, isTamil);
    }

    return data?.toString() ?? '';
  }

  /// Extracts language-specific content from bilingual text
  /// Handles patterns like: "English. Tamil." or "English content. Tamil content."
  static String _extractLanguage(String text, bool wantTamil) {
    if (text.isEmpty) return '';

    // Check if text contains Tamil characters (Unicode range for Tamil)
    final hasTamil = text.contains(RegExp(r'[\u0B80-\u0BFF]'));

    // If text doesn't contain Tamil, return as-is (English)
    if (!hasTamil) {
      return text;
    }

    // If text contains only Tamil (no English), return as-is
    final hasEnglish = text.contains(RegExp(r'[a-zA-Z]')) && 
                      !text.startsWith(RegExp(r'^[\u0B80-\u0BFF]'));

    if (hasEnglish) {
      // Bilingual text - try to split
      // Common patterns: "English. Tamil." or "English content. Tamil content."
      final parts = text.split(RegExp(r'\.\s+(?=[\u0B80-\u0BFF])'));
      if (parts.length >= 2) {
        return wantTamil ? parts.last : parts.first;
      }

      // Try splitting by newline
      final lines = text.split('\n');
      final tamilLines = lines.where((line) => line.contains(RegExp(r'[\u0B80-\u0BFF]'))).toList();
      final englishLines = lines.where((line) => !line.contains(RegExp(r'[\u0B80-\u0BFF]')) && line.trim().isNotEmpty).toList();

      if (wantTamil && tamilLines.isNotEmpty) {
        return tamilLines.join(' ').trim();
      }
      if (!wantTamil && englishLines.isNotEmpty) {
        return englishLines.join(' ').trim();
      }
    }

    // If we want Tamil and text has Tamil, return it
    if (wantTamil && hasTamil) {
      return text;
    }

    // If we want English but only Tamil exists, return empty or try to extract English parts
    if (!wantTamil && hasTamil && !hasEnglish) {
      // Text is only in Tamil, but user wants English
      // In this case, we'd need translation, but for now return empty or the text
      return text; // Could be enhanced with translation service
    }

    return text;
  }

  /// Helper to get content from AI data fields
  /// This method should be called from widgets that are already listening to LanguageProvider
  static String getAIContent(BuildContext context, Map<String, dynamic> data, String field) {
    // Use listen: false to avoid unnecessary rebuilds - the parent widget should already be listening
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isTamil = languageProvider.isTamil;
    
    // Try language-specific keys first (new bilingual format)
    final tamilKey = '${field}_ta';
    final englishKey = '${field}_en';
    
    if (data.containsKey(tamilKey) && data.containsKey(englishKey)) {
      // Both keys exist - return based on language preference
      return isTamil 
          ? (data[tamilKey]?.toString() ?? '') 
          : (data[englishKey]?.toString() ?? '');
    }
    
    if (data.containsKey(tamilKey)) {
      return data[tamilKey]?.toString() ?? '';
    }
    
    if (data.containsKey(englishKey)) {
      return data[englishKey]?.toString() ?? '';
    }
    
    // Fallback to base field (legacy format)
    final content = data[field]?.toString() ?? '';
    if (content.isEmpty) return '';
    
    return _extractLanguage(content, isTamil);
  }
}

