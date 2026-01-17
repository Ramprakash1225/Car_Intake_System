import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/language_provider.dart';

class WelcomeDialog extends StatelessWidget {
  const WelcomeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: isMobile ? double.infinity : 640,
        height: isMobile ? 560 : 520,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // ====== HEADER HERO ======
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                color: Colors.white.withOpacity(0.12),
              ),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            12), // change radius as needed
                        child: Image.asset(
                          'assets/logos/aathiksh_logo.jpeg',
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Aathiksh AutoMart",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            languageProvider.translate(
                              "The Precision of Pre-Owned",
                              "பழையவற்றின் துல்லியம்",
                            ),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Language Toggle Button - Top Right
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.language,
                          color: Colors.white, size: 20),
                      onPressed: () => languageProvider.toggleLanguage(),
                      tooltip: languageProvider.isTamil ? 'English' : 'தமிழ்',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ====== TITLE ======
            Text(
              languageProvider.translate(
                "Welcome to Aathiksh AutoMart",
                "ஆத்திக்ஷ் ஆட்டோமார்ட்டுக்கு வரவேற்கிறோம்",
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              languageProvider.translate(
                "Smart Insights • AI Decisions • Business Intelligence",
                "ஸ்மார்ட் நுண்ணறிவுகள் • AI முடிவுகள் • வணிக நுண்ணறிவு",
              ),
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 22),

            // ====== VERTICAL FEATURE STACK ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  _featureTile(
                    Icons.analytics_outlined,
                    languageProvider.translate(
                      "AI-Powered Vehicle Analysis",
                      "AI-இயங்கும் வாகன பகுப்பாய்வு",
                    ),
                    languageProvider.translate(
                      "Upload images — get instant quality & price intelligence",
                      "படங்களை பதிவேற்றவும் — உடனடி தரம் மற்றும் விலை நுண்ணறிவைப் பெறுங்கள்",
                    ),
                  ),
                  const SizedBox(height: 10),
                  _featureTile(
                    Icons.trending_up_rounded,
                    languageProvider.translate(
                      "Market Intelligence Dashboard",
                      "சந்தை நுண்ணறிவு டாஷ்போர்டு",
                    ),
                    languageProvider.translate(
                      "Demand signals, pricing trends & dealer insights",
                      "தேவை சமிக்ஞைகள், விலை போக்குகள் மற்றும் விற்பனையாளர் நுண்ணறிவுகள்",
                    ),
                  ),
                  const SizedBox(height: 10),
                  _featureTile(
                    Icons.inventory_2_outlined,
                    languageProvider.translate(
                      "Smart Inventory Tracking",
                      "ஸ்மார்ட் சரக்கு கண்காணிப்பு",
                    ),
                    languageProvider.translate(
                      "Lifecycle status & confidence scoring for every car",
                      "ஒவ்வொரு காருக்கும் வாழ்க்கைச் சுழற்சி நிலை மற்றும் நம்பிக்கை மதிப்பெண்",
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ====== CTA BUTTON ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    languageProvider.translate(
                      "Get Started",
                      "தொடங்குங்கள்",
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureTile(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
