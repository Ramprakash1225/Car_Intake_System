import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/ai_usage_provider.dart';
//import '../providers/auth_provider.dart';
import '../providers/car_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_header.dart';

class AnalyzeCarScreen extends StatefulWidget {
  const AnalyzeCarScreen({super.key});

  @override
  State<AnalyzeCarScreen> createState() => _AnalyzeCarScreenState();
}

class _AnalyzeCarScreenState extends State<AnalyzeCarScreen> {
  final Map<String, PlatformFile?> _uploadedFiles = {
    'frontView': null,
    'rightSide': null,
    'leftSide': null,
    'backView': null,
    'odometer': null,
    'rcBook': null,
    'additional': null,
  };
  final _additionalInfoController = TextEditingController();
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String key) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // This ensures bytes are loaded for web
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _uploadedFiles[key] = result.files.single;
      });
    }
  }

  void _removeFile(String key) {
    setState(() {
      _uploadedFiles[key] = null;
    });
  }

  int get _requiredUploads => _uploadedFiles['frontView'] != null ? 1 : 0;
  int get _totalRequired => 1;
  double get _uploadProgress => _requiredUploads / _totalRequired;

  Future<void> _analyzeCar() async {
    if (_uploadedFiles['frontView'] == null) {
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.translate(
              'Please upload all mandatory photos before analyzing',
              'பகுப்பாய்வு செய்வதற்கு முன் அனைத்து கட்டாய புகைப்படங்களையும் பதிவேற்றவும்',
            ),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    final carProvider = Provider.of<CarProvider>(context, listen: false);
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    try {
      // Get image bytes from uploaded files
      final imageBytes = <Uint8List>[];
      for (final file in _uploadedFiles.values) {
        if (file != null && file.bytes != null) {
          imageBytes.add(file.bytes!);
        }
      }

      if (imageBytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.translate(
                'Please upload at least one image',
                'குறைந்தபட்சம் ஒரு படத்தை பதிவேற்றவும்',
              ),
            ),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isAnalyzing = false);
        return;
      }

      final aiUsageProvider =
          Provider.of<AIUsageProvider>(context, listen: false);

      await carProvider.analyzeCar(
        imageBytes: imageBytes,
        additionalInfo: _additionalInfoController.text.isEmpty
            ? null
            : _additionalInfoController.text,
      );

      // Mark AI feature as used after successful analysis
      await aiUsageProvider.markAIFeatureUsed();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.translate(
                'Car analyzed successfully!',
                'கார் வெற்றிகரமாக பகுப்பாய்வு செய்யப்பட்டது!',
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to inventory
        context.go('/inventory');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.translate(
                'Error analyzing car: $e',
                'கார் பகுப்பாய்வு பிழை: $e',
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    // final authProvider = Provider.of<AuthProvider>(context);
    // final userName = authProvider.getUserName();

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(currentRoute: '/analyze'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width < 768 ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Name Display
                  // if (userName != null) ...[
                  //   Container(
                  //     width: double.infinity,
                  //     margin: const EdgeInsets.only(bottom: 20),
                  //     padding: const EdgeInsets.all(20),
                  //     decoration: BoxDecoration(
                  //       gradient: LinearGradient(
                  //         begin: Alignment.topLeft,
                  //         end: Alignment.bottomRight,
                  //         colors: [
                  //           const Color(0xFF1E3A8A),
                  //           Colors.blue.shade700,
                  //         ],
                  //       ),
                  //       borderRadius: BorderRadius.circular(16),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.blue.shade200,
                  //           blurRadius: 12,
                  //           spreadRadius: 2,
                  //           offset: const Offset(0, 4),
                  //         ),
                  //       ],
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Container(
                  //           padding: const EdgeInsets.all(12),
                  //           decoration: BoxDecoration(
                  //             color: Colors.white.withValues(alpha: 0.2),
                  //             shape: BoxShape.circle,
                  //           ),
                  //           child: const Icon(
                  //             Icons.person,
                  //             color: Colors.white,
                  //             size: 28,
                  //           ),
                  //         ),
                  //         const SizedBox(width: 16),
                  //         Expanded(
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Text(
                  //                 languageProvider.translate(
                  //                     'Welcome,', 'வரவேற்கிறோம்,'),
                  //                 style: TextStyle(
                  //                   color: Colors.white.withValues(alpha: 0.9),
                  //                   fontSize: 14,
                  //                   fontWeight: FontWeight.w500,
                  //                 ),
                  //               ),
                  //               const SizedBox(height: 4),
                  //               Text(
                  //                 userName,
                  //                 style: const TextStyle(
                  //                   color: Colors.white,
                  //                   fontSize: 24,
                  //                   fontWeight: FontWeight.bold,
                  //                   letterSpacing: 0.5,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         Container(
                  //           padding: const EdgeInsets.symmetric(
                  //               horizontal: 16, vertical: 8),
                  //           decoration: BoxDecoration(
                  //             color: Colors.white.withValues(alpha: 0.2),
                  //             borderRadius: BorderRadius.circular(20),
                  //             border: Border.all(
                  //               color: Colors.white.withValues(alpha: 0.3),
                  //               width: 1,
                  //             ),
                  //           ),
                  //           child: const Icon(
                  //             Icons.verified,
                  //             color: Colors.white,
                  //             size: 20,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ],
                  // Hero Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width < 768 ? 20 : 40),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: const AssetImage(
                            'assets/images/analyze_car_bg.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.blue.shade900.withValues(alpha: 0.8),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languageProvider.translate(
                              'Analyze New Car', 'புதிய கார் பகுப்பாய்வு'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          languageProvider.translate(
                            'Upload structured car photos for comprehensive analysis',
                            'விரிவான பகுப்பாய்வுக்கான கட்டமைக்கப்பட்ட கார் புகைப்படங்களை பதிவேற்றவும்',
                          ),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                languageProvider.translate(
                                  'Structured Upload',
                                  'கட்டமைக்கப்பட்ட பதிவேற்றம்',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade300,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                languageProvider.translate(
                                  'Instant Results',
                                  'உடனடி முடிவுகள்',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Progress Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              languageProvider.translate(
                                'Required Upload:',
                                'தேவையான பதிவேற்றம்:',
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            Text(
                              '${(_uploadProgress * 100).toInt()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '$_requiredUploads/$_totalRequired',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _uploadProgress,
                                  backgroundColor: Colors.blue.shade100,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue.shade600,
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Front View (Required)
                  _UploadSection(
                    title:
                        languageProvider.translate('Front View', 'முன் பார்வை'),
                    description: languageProvider.translate(
                      'Full front view of the vehicle',
                      'வாகனத்தின் முழு முன் பார்வை',
                    ),
                    isRequired: true,
                    icon: Icons.directions_car,
                    file: _uploadedFiles['frontView'],
                    onUpload: () => _pickFile('frontView'),
                    onRemove: () => _removeFile('frontView'),
                  ),
                  const SizedBox(height: 16),
                  // Back View (Optional)
                  _UploadSection(
                    title: languageProvider.translate(
                        'Back View', 'பின்புற பார்வை'),
                    description: languageProvider.translate(
                      'Full rear view of the vehicle',
                      'வாகனத்தின் முழு பின்புற பார்வை',
                    ),
                    isRequired: false,
                    icon: Icons.directions_car_outlined,
                    file: _uploadedFiles['backView'],
                    onUpload: () => _pickFile('backView'),
                    onRemove: () => _removeFile('backView'),
                  ),
                  const SizedBox(height: 16),
                  // Right Side View (Optional)
                  _UploadSection(
                    title: languageProvider.translate(
                        'Right Side View', 'வலது பக்க பார்வை'),
                    description: languageProvider.translate(
                      'Complete right side profile',
                      'முழு வலது பக்க சுயவிவரம்',
                    ),
                    isRequired: false,
                    icon: Icons.arrow_forward,
                    file: _uploadedFiles['rightSide'],
                    onUpload: () => _pickFile('rightSide'),
                    onRemove: () => _removeFile('rightSide'),
                  ),
                  const SizedBox(height: 16),
                  // Left Side View (Optional)
                  _UploadSection(
                    title: languageProvider.translate(
                        'Left Side View', 'இடது பக்க பார்வை'),
                    description: languageProvider.translate(
                      'Complete left side profile',
                      'முழு இடது பக்க சுயவிவரம்',
                    ),
                    isRequired: false,
                    icon: Icons.arrow_back,
                    file: _uploadedFiles['leftSide'],
                    onUpload: () => _pickFile('leftSide'),
                    onRemove: () => _removeFile('leftSide'),
                  ),
                  const SizedBox(height: 16),

                  // Odometer Reading (Optional)
                  _UploadSection(
                    title: languageProvider.translate(
                        'Odometer Reading', 'ஓடோமீட்டர் வாசிப்பு'),
                    description: languageProvider.translate(
                      'Close-up photo of odometer display',
                      'ஓடோமீட்டர் காட்சியின் நெருக்கமான புகைப்படம்',
                    ),
                    isRequired: false,
                    icon: Icons.speed,
                    file: _uploadedFiles['odometer'],
                    onUpload: () => _pickFile('odometer'),
                    onRemove: () => _removeFile('odometer'),
                  ),
                  const SizedBox(height: 16),
                  // RC Book (Optional)
                  _UploadSection(
                    title: languageProvider.translate('RC Book', 'RC புத்தகம்'),
                    description: languageProvider.translate(
                      'Registration certificate document',
                      'பதிவு சான்றிதழ் ஆவணம்',
                    ),
                    isRequired: false,
                    icon: Icons.description,
                    file: _uploadedFiles['rcBook'],
                    onUpload: () => _pickFile('rcBook'),
                    onRemove: () => _removeFile('rcBook'),
                  ),
                  const SizedBox(height: 16),
                  // Additional Photos (Optional)
                  _UploadSection(
                    title: languageProvider.translate(
                        'Additional Photos', 'கூடுதல் புகைப்படங்கள்'),
                    description: languageProvider.translate(
                      'Optional: Interior, engine, damage areas, etc.',
                      'விருப்பமானது: உட்புறம், இயந்திரம், சேதம் பகுதிகள் போன்றவை',
                    ),
                    isRequired: false,
                    icon: Icons.photo_library,
                    file: _uploadedFiles['additional'],
                    onUpload: () => _pickFile('additional'),
                    onRemove: () => _removeFile('additional'),
                  ),
                  const SizedBox(height: 24),
                  // Additional Information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              languageProvider.translate(
                                'Additional Information',
                                'கூடுதல் தகவல்',
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                languageProvider.translate(
                                    '(Optional)', '(விருப்பமானது)'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _additionalInfoController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: languageProvider.translate(
                              'Enter any additional details such as vehicle issues, accident history, modifications, or owner comments...',
                              'வாகன பிரச்சினைகள், விபத்து வரலாறு, மாற்றங்கள் அல்லது உரிமையாளர் கருத்துகள் போன்ற கூடுதல் விவரங்களை உள்ளிடவும்...',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_additionalInfoController.text.length} ${languageProvider.translate("characters", "எழுத்துக்கள்")}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Analyze Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _analyzeCar,
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                        languageProvider.translate(
                            'Analyze Car', 'கார் பகுப்பாய்வு'),
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  if (_requiredUploads < _totalRequired) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  languageProvider.translate(
                                    'Please upload all mandatory photos before analyzing',
                                    'பகுப்பாய்வு செய்வதற்கு முன் அனைத்து கட்டாய புகைப்படங்களையும் பதிவேற்றவும்',
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  languageProvider.translate(
                                    'Please complete all required sections ($_requiredUploads/$_totalRequired) to proceed with analysis.',
                                    'பகுப்பாய்வைத் தொடர, அனைத்து தேவையான பிரிவுகளையும் ($_requiredUploads/$_totalRequired) முடிக்கவும்.',
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadSection extends StatelessWidget {
  final String title;
  final String description;
  final bool isRequired;
  final IconData icon;
  final PlatformFile? file;
  final VoidCallback onUpload;
  final VoidCallback? onRemove;

  const _UploadSection({
    required this.title,
    required this.description,
    required this.isRequired,
    required this.icon,
    this.file,
    required this.onUpload,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: file != null ? Colors.green.shade400 : Colors.grey.shade300,
          width: file != null ? 2 : 1,
        ),
        boxShadow: file != null
            ? [
                BoxShadow(
                  color: Colors.green.shade100,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isRequired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          languageProvider.translate('Required', 'தேவையானது'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          languageProvider.translate(
                              'Optional', 'விருப்பமானது'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          file != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image display area
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: file!.bytes != null
                            ? Stack(
                                children: [
                                  Image.memory(
                                    file!.bytes!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  if (onRemove != null)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.white, size: 20),
                                          onPressed: onRemove,
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      file!.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // File info and status row
                    Row(
                      children: [
                        // Filename
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file!.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Uploaded status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.green.shade200,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green.shade700,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                languageProvider.translate(
                                    'Uploaded', 'பதிவேற்றப்பட்டது'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Replace button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onUpload,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(
                          languageProvider.translate('Replace', 'மாற்று'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: onUpload,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            languageProvider.translate(
                                'Click to upload', 'பதிவேற்ற கிளிக் செய்யவும்'),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            languageProvider.translate(
                                'or drag and drop', 'அல்லது இழுத்து விடவும்'),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
