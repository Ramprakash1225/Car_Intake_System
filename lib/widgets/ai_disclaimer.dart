import 'package:flutter/material.dart';
import '../providers/language_provider.dart';
import '../providers/ai_usage_provider.dart';
import 'package:provider/provider.dart';

class AIDisclaimer extends StatelessWidget {
  final double? confidenceScore;

  const AIDisclaimer({
    super.key,
    this.confidenceScore,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final aiUsageProvider = Provider.of<AIUsageProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    // Only show disclaimer if AI feature has been used
    if (!aiUsageProvider.hasUsedAIFeature) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.yellow.shade50,
        border: Border(
          top: BorderSide(
            color: Colors.yellow.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: isMobile ? 16 : 18,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: Colors.amber.shade900,
                  fontStyle: FontStyle.italic,
                ),
                children: [
                  TextSpan(
                    text: languageProvider.translate(
                      'Note: Portions of this submission are AI-generated, please ',
                      'குறிப்பு: இந்த சமர்ப்பிப்பின் பகுதிகள் AI உருவாக்கப்பட்டவை, தயவுசெய்து ',
                    ),
                  ),
                  TextSpan(
                    text: languageProvider.translate(
                      'double-check for accuracy.',
                      'துல்லியத்திற்காக இருமுறை சரிபார்க்கவும்.',
                    ),
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (confidenceScore != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                languageProvider.translate(
                  'Confidence: ${(confidenceScore! * 100).toStringAsFixed(0)}%',
                  'நம்பிக்கை: ${(confidenceScore! * 100).toStringAsFixed(0)}%',
                ),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
