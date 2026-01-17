import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle.dart';
import '../widgets/welcome_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);

      final mobileNumber = _mobileController.text;
      final success = await authProvider.login(mobileNumber);

      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
          // Show welcome dialog for specific mobile number
          if (mobileNumber == '9999900000') {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const WelcomeDialog(),
            );
          } else {
          context.go('/dashboard');
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(languageProvider.translate(
                'Invalid mobile number. Only authorized numbers are allowed.',
                'தவறான மொபைல் எண். அங்கீகரிக்கப்பட்ட எண்கள் மட்டுமே அனுமதிக்கப்படுகின்றன.',
              )),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  String? _validateMobileNumber(
      String? value, LanguageProvider languageProvider) {
    if (value == null || value.isEmpty) {
      return languageProvider.translate(
        'Please enter your mobile number',
        'உங்கள் மொபைல் எண்ணை உள்ளிடவும்',
      );
    }
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 10) {
      return languageProvider.translate(
        'Mobile number must be 10 digits',
        'மொபைல் எண் 10 இலக்கங்களாக இருக்க வேண்டும்',
      );
    }
    return null;
  }

  Widget _buildLoginForm(
      BuildContext context, LanguageProvider languageProvider) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        const SizedBox(height: 24),
        CircleAvatar(
          radius: isMobile ? 45 : 72,
          backgroundColor: Colors.white,
          backgroundImage: const AssetImage('assets/logos/aathiksh_logo.jpeg'),
        ),

        //const SizedBox(height: 8),
        Text(
          languageProvider.translate('Welcome Back', 'மீண்டும் வரவேற்கிறோம்'),
          style: TextStyle(
            fontSize: isMobile ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          languageProvider.translate(
            'Sign in with your mobile number',
            'உங்கள் மொபைல் எண்ணுடன் உள்நுழையவும்',
          ),
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    labelText: languageProvider.translate(
                        'Mobile Number', 'மொபைல் எண்'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.phone_android,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                  ),
                  validator: (value) =>
                      _validateMobileNumber(value, languageProvider),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: isMobile ? 56 : 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.blue.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.login, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              languageProvider.translate('Sign In', 'உள்நுழைய'),
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Container(
        //   padding: const EdgeInsets.all(16),
        //   decoration: BoxDecoration(
        //     color: Colors.blue.shade50,
        //     borderRadius: BorderRadius.circular(12),
        //     border: Border.all(color: Colors.blue.shade200),
        //   ),
        //   child: Row(
        //     children: [
        //       Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
        //       const SizedBox(width: 12),
        //       Expanded(
        //         child: Text(
        //           languageProvider.translate(
        //             'Enter your 10-digit mobile number to continue',
        //             'தொடர உங்கள் 10 இலக்க மொபைல் எண்ணை உள்ளிடவும்',
        //           ),
        //           style: TextStyle(
        //             fontSize: isMobile ? 11 : 12,
        //             color: Colors.blue.shade800,
        //           ),
        //           maxLines: 2,
        //           overflow: TextOverflow.ellipsis,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: isMobile
                ? _buildMobileLayout(context, languageProvider)
                : _buildDesktopLayout(context, languageProvider),
          ),
          //const AIDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, LanguageProvider languageProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top Section - Logo and Branding
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E3A8A),
                  Colors.blue.shade700,
                ],
              ),
              image: DecorationImage(
                image: const AssetImage('assets/images/car_interior.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.blue.shade900.withValues(alpha: 0.6),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Stack(
              children: [
                const Positioned(
                  top: 16,
                  right: 16,
                  child: LanguageToggle(),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Aathiksh AutoMart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        languageProvider.translate(
                          'The Precision of Pre-Owned',
                          'பழையவற்றின் துல்லியம்',
                        ),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Login Form
          Container(
            padding: const EdgeInsets.all(24),
            child: _buildLoginForm(context, languageProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, LanguageProvider languageProvider) {
    return Row(
      children: [
        // Left Section - Dark Blue Background with Car Image
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E3A8A),
                  Colors.blue.shade700,
                ],
              ),
              image: DecorationImage(
                image: const AssetImage('assets/images/car_interior.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.blue.shade900.withValues(alpha: 0.6),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 40,
                  bottom: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                16), // change radius as needed
                            child: SizedBox(
                              height: 90,
                              width: 90,
                              child: Image.asset(
                                'assets/logos/aathiksh_logo.jpeg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.directions_car,
                                      color: Colors.white, size: 60);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aathiksh AutoMart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                languageProvider.translate(
                                  'The Precision of Pre-Owned',
                                  'பழையவற்றின் துல்லியம்',
                                ),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        languageProvider.translate(
                          'Smart Vehicle Analysis Platform',
                          'ஸ்மார்ட் வாகன பகுப்பாய்வு தளம்',
                        ),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right Section - Login Form
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.grey.shade50,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(60),
                  child: Column(
                    children: [
                      //const SizedBox(height: 40),
                      _buildLoginForm(context, languageProvider),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                // Language Toggle - Fixed position
                const Positioned(
                  top: 20,
                  right: 20,
                  child: LanguageToggle(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
