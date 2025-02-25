import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crop_weed_detector/services/api_service.dart';

// Import AppLocalizations
import 'package:crop_weed_detector/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  File? _image;
  String? _selectedModel;
  String _selectedMode = 'classify'; // Default mode
  late AnimationController _loadingController;
  bool _isUploading = false;
  Map<String, dynamic>? _result;

  // Separate model choices for each mode
  final Map<String, List<String>> _modelChoices = {
    'classify': ["resnet", "mobilenet", "efficientnet"],
    'detect': ["yolov8_m", "yolov8_l", "yolov8_x"],
  };

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  // Use the newer canLaunchUrl and launchUrl from url_launcher
  Future<void> _launchWikiUrl(String? url) async {
    if (url == null) return;

    final loc = AppLocalizations.of(context);
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc?.translate('couldNotLaunchWiki') ??
                  'Could not launch Wikipedia page',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    final loc = AppLocalizations.of(context);

    if (_image == null || _selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc?.translate('selectImageAndModel') ??
                'Please select both an image and a model',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final responseData = await ApiService.uploadImage(
        imageFile: _image!,
        model: _selectedModel!,
        mode: _selectedMode,
      );

      setState(() {
        _result = responseData;
        _isUploading = false;
      });

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildResultsSheet(),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${loc?.translate('errorUploadingImage') ?? "Error uploading image"}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildResultsSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => GlassmorphicContainer(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.6,
        borderRadius: 20,
        blur: 20,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildResultsContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsContent() {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Draggable handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Success animation on top
        Center(
          child: Lottie.asset(
            'assets/success_animation.json',
            width: 100,
            height: 100,
            repeat: false,
          ),
        ),
        const SizedBox(height: 20),

        // CLASSIFICATION RESULTS
        if (_selectedMode == 'classify' && _result != null) ...[
          _buildResultText(
            loc?.translate('classLabel') ?? 'Class',
            _result!['class_name'],
          ),
          _buildResultText(
            loc?.translate('confidenceLabel') ?? 'Confidence',
            _result!['confidence'],
          ),
          if (_result!['wiki_title'] != null)
            _buildResultText(
              loc?.translate('wikiTitleLabel') ?? 'Wikipedia Title',
              _result!['wiki_title'],
            ),
          if (_result!['wiki_summary'] != null)
            _buildResultText(
              loc?.translate('descriptionLabel') ?? 'Description',
              _result!['wiki_summary'],
            ),
          if (_result!['wiki_url'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                onPressed: () => _launchWikiUrl(_result!['wiki_url']),
                icon: const Icon(Icons.launch),
                label: Text(
                  loc?.translate('viewOnWikipedia') ?? 'View on Wikipedia',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ]

        // DETECTION RESULTS
        else if (_selectedMode == 'detect' && _result != null) ...[
          // 1) Show the annotated image first
          if (_result!['processed_image_url'] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                _result!['processed_image_url'],
                fit: BoxFit.cover,
                height: 300, // limit the max height
              ),
            ),
          const SizedBox(height: 20),
          // 2) Then show Crop/Weed counts
          _buildResultText(
            loc?.translate('cropsDetected') ?? 'Crops Detected',
            _result!['crop_count'].toString(),
          ),
          _buildResultText(
            loc?.translate('weedsDetected') ?? 'Weeds Detected',
            _result!['weed_count'].toString(),
          ),
        ],
      ],
    );
  }

  Widget _buildResultText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade200,
              Colors.blue.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // "AI Image Analysis" -> localize
                  Text(
                    loc?.translate('aiTitle') ?? "AI Image Analysis",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.2),
                  const SizedBox(height: 24),
                  _buildImagePreview()
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(delay: 200.ms),
                  const SizedBox(height: 24),
                  _buildModeSelection()
                      .animate()
                      .slideX(delay: 200.ms)
                      .fadeIn(delay: 200.ms),
                  const SizedBox(height: 24),
                  _buildModelSelection()
                      .animate()
                      .slideX(delay: 400.ms)
                      .fadeIn(delay: 400.ms),
                  const SizedBox(height: 32),
                  _buildUploadButton(loc)
                      .animate()
                      .slideY(delay: 600.ms)
                      .fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: () => _showImagePickerOptions(context),
      child: Hero(
        tag: 'imagePreview',
        child: Container(
          width: double.infinity,
          height: 350,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _buildImageContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    final loc = AppLocalizations.of(context);

    if (_image == null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Lottie.asset(
            'assets/upload_animation.json',
            width: 150,
            height: 150,
          ),
          Positioned(
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                loc?.translate('tapToSelect') ?? "Tap to select image",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          _image!,
          fit: BoxFit.cover,
        ),
        if (_isUploading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Lottie.asset(
                'assets/loading_animation.json',
                width: 100,
                height: 100,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModeSelection() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 70,
      borderRadius: 15,
      blur: 20,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.1),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: _buildModeButton('classify', 'Classification')),
            const SizedBox(width: 12),
            Expanded(child: _buildModeButton('detect', 'Detection')),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String mode, String fallbackLabel) {
    final loc = AppLocalizations.of(context);
    bool isSelected = _selectedMode == mode;

    // localize label
    final String modeKey = (mode == 'classify') ? 'classificationLabel' : 'detectionLabel';
    final String label = loc?.translate(modeKey) ?? fallbackLabel;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMode = mode;
            _selectedModel = null; // reset model if user switches mode
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.white70 : Colors.white30,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModelSelection() {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            _selectedMode == 'classify'
                ? (loc?.translate('selectClassificationModel') ??
                    "Select Classification Model")
                : (loc?.translate('selectDetectionModel') ??
                    "Select Detection Model"),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedModel,
                dropdownColor: Colors.teal.shade900,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                isExpanded: true,
                hint: Text(
                  _selectedMode == 'classify'
                      ? (loc?.translate('selectClassificationModel') ??
                          "Select Classification Model")
                      : (loc?.translate('selectDetectionModel') ??
                          "Select Detection Model"),
                  style: const TextStyle(color: Colors.white70),
                ),
                onChanged: (String? newValue) {
                  setState(() => _selectedModel = newValue!);
                },
                items: _modelChoices[_selectedMode]
                    ?.map<DropdownMenuItem<String>>((String model) {
                  return DropdownMenuItem<String>(
                    value: model,
                    child: Text(
                      model,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton(AppLocalizations? loc) {
    final isClassify = _selectedMode == 'classify';
    final fallbackLabel = isClassify ? "Start Classification" : "Start Detection";
    final processingLabel = loc?.translate('uploadProcessing') ?? "Processing...";

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade700.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isUploading ? null : _uploadImage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.upload_rounded),
            const SizedBox(width: 12),
            Text(
              _isUploading
                  ? processingLabel
                  : (isClassify
                      ? loc?.translate('startClassification') ?? fallbackLabel
                      : loc?.translate('startDetection') ?? fallbackLabel),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: 180,
        borderRadius: 20,
        blur: 20,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: Text(
                loc?.translate('chooseFromGallery') ?? 'Choose from Gallery',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: Text(
                loc?.translate('takeAPhoto') ?? 'Take a Photo',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        _loadingController.forward(from: 0);
      }
    } catch (e) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${loc?.translate('errorPickingImage') ?? "Error picking image"}: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
