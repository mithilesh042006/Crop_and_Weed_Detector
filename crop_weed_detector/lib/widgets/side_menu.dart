import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

// Import AppLocalizations
import 'package:crop_weed_detector/app_localizations.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> with SingleTickerProviderStateMixin {
  String _username = "User";
  List<Map<String, dynamic>> _history = [];
  late AnimationController _controller;
  late Animation<double> _headerScaleAnimation;
  late Animation<double> _historyTitleAnimation;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUsername();
    _fetchHistory();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _headerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _historyTitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("username") ?? "User";
    });
  }

  Future<void> _fetchHistory() async {
    try {
      final historyData = await ApiService.fetchHistory();
      setState(() {
        _history = List<Map<String, dynamic>>.from(historyData);
      });
    } catch (e) {
      debugPrint("Error fetching history: $e");
    }
  }

  String _formatDate(String rawDate) {
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('MMM d, yyyy h:mm a').format(parsed);
    } catch (e) {
      return rawDate;
    }
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor ?? Colors.teal.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTitle() {
    final loc = AppLocalizations.of(context);
    return FadeTransition(
      opacity: _historyTitleAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
        ).animate(_historyTitleAnimation),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.history,
                color: const Color.fromARGB(255, 88, 161, 77),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                loc?.translate('historyTitle') ?? 'History',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 23, 23, 23),
                ),
              ),
              const Spacer(),
              Text(
                '${_history.length} ${loc?.translate('historyItems') ?? "items"}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> record, int index) {
    final loc = AppLocalizations.of(context);

    final model = record["model_chosen"] ?? loc?.translate('unknownModel') ?? "Unknown Model";
    final crop = record["crop_name"] ?? loc?.translate('unknownCrop') ?? "Unknown Crop";
    final imageUrl = record["processed_image_url"];
    final rawDate = record["created_at"] ?? "";
    final createdAt = _formatDate(rawDate);

    return Hero(
      tag: 'history_card_$index',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 400 + (index * 100)),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(100 * (1 - value), 0),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: () => _showCardDetails(record),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildImageSection(imageUrl),
                      _buildCardContent(crop, model, createdAt),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(String? imageUrl) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.teal.shade300, Colors.teal.shade700],
        ),
      ),
      child: imageUrl != null
          ? ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              ).createShader(bounds),
              blendMode: BlendMode.darken,
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(),
              ),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.teal.shade200, Colors.teal.shade400],
        ),
      ),
      child: Icon(
        Icons.image_outlined,
        size: 50,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  Widget _buildCardContent(String crop, String model, String createdAt) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            crop,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.science_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                model,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                createdAt,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCardDetails(Map<String, dynamic> record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailSheet(record),
    );
  }

  Widget _buildDetailSheet(Map<String, dynamic> record) {
    final loc = AppLocalizations.of(context);

    final model = record["model_chosen"] ??
        loc?.translate('unknownModel') ??
        "Unknown Model";
    final crop = record["crop_name"] ??
        loc?.translate('unknownCrop') ??
        "Unknown Crop";
    final imageUrl = record["processed_image_url"];
    final summary = record["summary"] ??
        loc?.translate('noSummaryAvailable') ??
        "No summary available";
    final rawDate = record["created_at"] ?? "";
    final createdAt = _formatDate(rawDate);
    final username = record["username"] ??
        loc?.translate('unknownUser') ??
        "Unknown User";

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildImagePlaceholder(),
                            )
                          : _buildImagePlaceholder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    crop,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.science_outlined,
                    title: loc?.translate('modelUsed') ?? "Model Used",
                    content: model,
                  ),
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    title: loc?.translate('analyzedBy') ?? "Analyzed By",
                    content: username,
                  ),
                  _buildInfoCard(
                    icon: Icons.access_time,
                    title: loc?.translate('analysisDate') ?? "Analysis Date",
                    content: createdAt,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc?.translate('analysisSummary') ??
                              "Analysis Summary",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          summary,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.teal.shade50,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScaleTransition(
              scale: _headerScaleAnimation,
              child: _buildHeader(loc),
            ),
            _buildHistoryTitle(),
            Expanded(
              child: _history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            loc?.translate('noHistoryAvailable') ??
                                "No history available",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: _history.length,
                      itemBuilder: (context, index) =>
                          _buildHistoryCard(_history[index], index),
                    ),
            ),
            _buildFooter(loc),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations? loc) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.teal.shade700, Colors.teal.shade500],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person_outline,
                  color: Colors.teal.shade700,
                ),
              ),
              title: Text(
                _username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(AppLocalizations? loc) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: Colors.grey[600], size: 16),
          const SizedBox(width: 8),
          Text(
            loc?.translate('appVersionLabel') ?? "App Version 1.0.0",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
