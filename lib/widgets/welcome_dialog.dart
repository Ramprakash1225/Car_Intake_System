import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';

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
        height: isMobile ? 500 : 520,
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
                          Text(
                            languageProvider.translate(
                              "Aathiksh AutoMart",
                              "ஆத்திக்ஷ் ஆட்டோமார்ட்",
                            ),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: isMobile
                                  ? (languageProvider.isTamil ? 8 : 16)
                                  : (languageProvider.isTamil ? 14 : 16),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            languageProvider.translate(
                              "The Precision of Pre-Owned",
                              "கார்களின் துல்லியம்",
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
            // Text(
            //   languageProvider.translate(
            //     "Aathiksh AutoMart",
            //     "ஆத்திக்ஷ் ஆட்டோமார்ட்",
            //   ),
            //   style: const TextStyle(
            //     color: Colors.white,
            //     fontSize: 22,
            //     fontWeight: FontWeight.w900,
            //   ),
            // ),

            // const SizedBox(height: 6),

            // Text(
            //   languageProvider.translate(
            //     "Smart Insights • AI Decisions • Business Intelligence",
            //     "ஸ்மார்ட் நுண்ணறிவுகள் • AI முடிவுகள் • வணிக நுண்ணறிவு",
            //   ),
            //   style: TextStyle(
            //     color: Colors.white.withOpacity(0.85),
            //     fontSize: 13,
            //   ),
            // ),

            // const SizedBox(height: 22),

            // ====== VERTICAL FEATURE STACK ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  Text(
                    languageProvider.translate(
                      "Welcome Mr.Palanikumar",
                      "திரு. பழனிகுமார் அவர்களை வரவேற்கிறோம்.",
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: isMobile
                          ? (languageProvider.isTamil ? 8 : 16)
                          : (languageProvider.isTamil ? 14 : 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _featureTile(
                    context,
                    languageProvider,
                    Icons.trending_up_rounded,
                    languageProvider.translate(
                      "Latest Car Trends",
                      "சமீபத்திய கார் போக்குகள்",
                    ),
                    languageProvider.translate(
                      "Stay updated with the latest automotive trends and market insights",
                      "சமீபத்திய வாகன போக்குகள் மற்றும் சந்தை நுண்ணறிவுகளுடன் புதுப்பிக்கப்பட்டு இருங்கள்",
                    ),
                    '/trends',
                  ),
                  const SizedBox(height: 10),
                  _featureTile(
                    context,
                    languageProvider,
                    Icons.directions_car,
                    languageProvider.translate(
                      "Latest Car in Market",
                      "சந்தையில் சமீபத்திய கார்",
                    ),
                    languageProvider.translate(
                      "Discover the newest car launches and market arrivals",
                      "புதிய கார் வெளியீடுகள் மற்றும் சந்தை வருகைகளைக் கண்டறியவும்",
                    ),
                    '/car-launches',
                  ),
                  const SizedBox(height: 10),
                  _featureTile(
                    context,
                    languageProvider,
                    Icons.analytics_outlined,
                    languageProvider.translate(
                      "Analyze New Car",
                      "புதிய காரை பகுப்பாய்வு செய்ய",
                    ),
                    languageProvider.translate(
                      "Upload car images and get instant AI-powered analysis",
                      "கார் படங்களை பதிவேற்றி உடனடி பகுப்பாய்வைப் பெறுங்கள்",
                    ),
                    '/analyze',
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
                  onPressed: () async {
                    // Clear welcome dialog flag before navigation
                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                    await authProvider.clearWelcomeDialogFlag();
                    if (context.mounted) {
                      Navigator.pop(context);
                      context.go('/dashboard');
                    }
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
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  Widget _featureTile(
    BuildContext context,
    LanguageProvider languageProvider,
    IconData icon,
    String title,
    String subtitle,
    String route,
  ) {
    return InkWell(
      onTap: () async {
        // Clear welcome dialog flag before navigation
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.clearWelcomeDialogFlag();
        if (context.mounted) {
          Navigator.pop(context);
          context.go(route);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: languageProvider.isTamil ? 11 : 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.88),
                      fontSize: languageProvider.isTamil ? 8 : 12,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
