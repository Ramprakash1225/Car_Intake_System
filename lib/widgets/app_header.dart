import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/car_provider.dart';
import '../services/ai_service.dart';
import 'language_toggle.dart';

class AppHeader extends StatelessWidget {
  final String currentRoute;

  const AppHeader({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 10 : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isMobile
          ? _buildMobileHeader(context, languageProvider, authProvider)
          : _buildDesktopHeader(context, languageProvider, authProvider),
    );
  }

  Widget _buildMobileHeader(BuildContext context,
      LanguageProvider languageProvider, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row with logo, text, and icons
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo - fixed size
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  shape: BoxShape.rectangle,
                ),
                child: Image.asset(
                  'assets/logos/aathiksh_logo.jpeg',
                  height: 32,
                  width: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.directions_car,
                      color: Color(0xFF1E3A8A),
                      size: 24,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              // Text section - takes remaining space
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      languageProvider.translate(
                        'Aathiksh AutoMart',
                        'ஆத்திக்ஷ் ஆட்டோமார்ட்',
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      languageProvider.translate(
                        'The Precision of Pre-Owned',
                        'கார்களின் துல்லியம்',
                      ),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Three icons on the right - fixed size, properly aligned
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
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
                  IconButton(
                    icon: const Icon(Icons.restart_alt,
                        color: Colors.orange, size: 20),
                    onPressed: () => showResetDialog(
                        context, languageProvider, authProvider),
                    tooltip: languageProvider.translate(
                        'Reset Application', 'அனுப்புத்தொகுப்பை மீட்டமை'),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                    onPressed: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    tooltip: languageProvider.translate('Logout', 'வெளியேறு'),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Navigation bar - separate row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _NavButton(
                  label: languageProvider.translate('Dashboard', 'டாஷ்போர்டு'),
                  route: '/dashboard',
                  currentRoute: currentRoute,
                ),
                const SizedBox(width: 20),
                _NavButton(
                  label: languageProvider.translate(
                      'Analyze New Car', 'கார் பகுப்பாய்வு'),
                  route: '/analyze',
                  currentRoute: currentRoute,
                ),
                const SizedBox(width: 20),
                _NavButton(
                  label: languageProvider.translate(
                      'View Analyze car', 'பகுப்பாய்வு செய்யப்பட்ட கார்'),
                  route: '/inventory',
                  currentRoute: currentRoute,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context,
      LanguageProvider languageProvider, AuthProvider authProvider) {
    return Row(
      children: [
        // Logo
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/logos/aathiksh_logo.jpeg',
                height: 32,
                width: 32,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.directions_car,
                    color: Color(0xFF1E3A8A),
                    size: 24,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageProvider.translate(
                    'Aathiksh AutoMart',
                    'ஆத்திக்ஷ் ஆட்டோமார்ட்',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    // fontSize: isMobile
                    //     ? (languageProvider.isTamil ? 8 : 14)
                    //     : (languageProvider.isTamil ? 14 : 16),

                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  languageProvider.translate(
                    'The Precision of Pre-Owned',
                    'கார்களின் துல்லியம்',
                  ),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        // Navigation
        Row(
          children: [
            _NavButton(
              label: languageProvider.translate(
                  'Business Pulse', 'வணிக நிலைசுட்டி'),
              route: '/dashboard',
              currentRoute: currentRoute,
            ),
            //const SizedBox(width: 8),
            _NavButton(
              label: languageProvider.translate(
                  'Analyze New Car', 'கார் பகுப்பாய்வு'),
              route: '/analyze',
              currentRoute: currentRoute,
            ),
            //const SizedBox(width: 8),
            _NavButton(
              label: languageProvider.translate(
                  'View Analyzed car', 'பகுப்பாய்வு செய்யப்பட்ட கார்'),
              route: '/inventory',
              currentRoute: currentRoute,
            ),
          ],
        ),
        const Spacer(),
        // Language Toggle, Reset & Logout
        Row(
          children: [
            const LanguageToggle(),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: () =>
                  showResetDialog(context, languageProvider, authProvider),
              icon: const Icon(Icons.restart_alt, size: 18),
              label: Text(
                languageProvider.translate('Reset', 'மீட்டமை'),
                style: const TextStyle(fontSize: 14),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange.shade300,
              ),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout, size: 18),
              label: Text(
                languageProvider.translate('Logout', 'வெளியேறு'),
                style: const TextStyle(fontSize: 14),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade300,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final String route;
  final String currentRoute;

  const _NavButton({
    required this.label,
    required this.route,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentRoute == route;
    final isMobile = MediaQuery.of(context).size.width < 768;
    final languageProvider = Provider.of<LanguageProvider>(context);

    return TextButton(
      onPressed: () => context.go(route),
      style: TextButton.styleFrom(
        backgroundColor: isActive
            ? (isMobile
                ? Colors.blueGrey.shade700
                : Colors.white.withValues(alpha: 0.2))
            : Colors.transparent,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 8,
          vertical: isMobile ? 10 : 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: isMobile
              ? (languageProvider.isTamil ? 10 : 14)
              : (languageProvider.isTamil ? 14 : 16),
        ),
      ),
    );
  }
}

void showResetDialog(BuildContext context, LanguageProvider languageProvider,
    AuthProvider authProvider) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 64,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                languageProvider.translate(
                  'Reset Application',
                  'அனுப்புத்தொகுப்பை மீட்டமை',
                ),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                languageProvider.translate(
                  'This will permanently delete all data including:\n• All car inventory\n• All user data\n• All saved information',
                  'இது அனைத்து தரவையும் நிரந்தரமாக நீக்கும்:\n• அனைத்து கார் சரக்கு\n• அனைத்து பயனர் தரவு\n• அனைத்து சேமிக்கப்பட்ட தகவல்',
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Warning Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        languageProvider.translate(
                          'This action cannot be undone!',
                          'இந்த செயலை திரும்பப் பெற முடியாது!',
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        languageProvider.translate('Cancel', 'ரத்துசெய்'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();

                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (loadingContext) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        // Clear all data
                        final carProvider =
                            Provider.of<CarProvider>(context, listen: false);
                        carProvider.clearAllCars();
                        await authProvider.clearAllData();

                        // Clear AI cache to force fresh API calls on next request
                        await AIService.clearAICache();

                        // Close loading dialog
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }

                        // Show success message and navigate to login
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                languageProvider.translate(
                                  'All data has been reset successfully',
                                  'அனைத்து தரவும் வெற்றிகரமாக மீட்டமைக்கப்பட்டது',
                                ),
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          // Navigate to login after a brief delay
                          await Future.delayed(
                              const Duration(milliseconds: 500));
                          if (context.mounted) {
                            context.go('/login');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: Colors.red.shade300,
                      ),
                      child: Text(
                        languageProvider.translate('Reset', 'மீட்டமை'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
