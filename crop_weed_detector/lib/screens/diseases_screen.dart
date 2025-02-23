import 'package:flutter/material.dart';
import 'package:crop_weed_detector/services/api_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// Import AppLocalizations
import 'package:crop_weed_detector/app_localizations.dart';

class DiseasesScreen extends StatefulWidget {
  const DiseasesScreen({Key? key}) : super(key: key);

  @override
  _DiseasesScreenState createState() => _DiseasesScreenState();
}

class _DiseasesScreenState extends State<DiseasesScreen> {
  List<dynamic> _diseases = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadDiseases();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDiseases() async {
    try {
      setState(() => _isLoading = true);
      List<dynamic> diseases = await ApiService.fetchDiseases();
      setState(() {
        _diseases = diseases;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showErrorSnackBar();
    }
  }

  void _showErrorSnackBar() {
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              loc?.translate('snackbarLoadError') ?? 'Failed to load diseases',
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: loc?.translate('snackbarRetry') ?? 'Retry',
          onPressed: _loadDiseases,
          textColor: Colors.white,
        ),
      ),
    );
  }

  Color getCommonnessBadgeColor(String commonness) {
    switch (commonness.toLowerCase()) {
      case 'high':
        return Colors.red.shade400;
      case 'moderate':
        return Colors.orange.shade400;
      case 'low':
        return Colors.green.shade400;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            // 1) Ensure the SliverAppBar title is centered
            centerTitle: true,
            expandedHeight: 120,
            floating: true,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              // 2) Also ensure the FlexibleSpaceBar text is centered
              centerTitle: true,
              title: Text(
                loc?.translate('diseasesScreenTitle') ?? "Crop Diseases",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: _loadDiseases,
          child: _isLoading
              ? _buildLoadingGrid()
              : _diseases.isEmpty
                  ? _buildEmptyState()
                  : AnimationLimiter(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _diseases.length,
                        itemBuilder: (context, index) {
                          return AnimationConfiguration.staggeredGrid(
                            position: index,
                            columnCount: 2,
                            duration: const Duration(milliseconds: 250),
                            child: ScaleAnimation(
                              duration: const Duration(milliseconds: 250),
                              child: FadeInAnimation(
                                duration: const Duration(milliseconds: 250),
                                child: _buildDiseaseCard(_diseases[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: _isLoading ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton(
          onPressed: _loadDiseases,
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 20,
              width: 100,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final loc = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.healing, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            loc?.translate('diseaseEmptyTitle') ?? 'No diseases found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadDiseases,
            child: Text(
              loc?.translate('diseaseEmptyRefresh') ?? 'Refresh',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(Map<String, dynamic> disease) {
    final String diseaseName = disease["disease_name"] ?? "";
    final String cropName = disease["crop_name"] ?? "";
    final String commonness = disease["commonness"] ?? "";

    return Hero(
      tag: 'disease_${cropName.isNotEmpty ? cropName : diseaseName}',
      child: Material(
        child: InkWell(
          onTap: () => _showDiseaseDetails(disease),
          borderRadius: BorderRadius.circular(15),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          "assets/crops/${cropName.toLowerCase()}.jpg",
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported_outlined,
                              size: 50,
                              color: Colors.grey[400],
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getCommonnessBadgeColor(commonness),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(15),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            commonness,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (cropName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        cropName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  if (diseaseName.isNotEmpty && diseaseName != cropName) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        diseaseName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDiseaseDetails(Map<String, dynamic> disease) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DiseaseDetailsSheet(disease: disease),
    );
  }
}

class DiseaseDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> disease;

  const DiseaseDetailsSheet({Key? key, required this.disease})
      : super(key: key);

  Color getCommonnessBadgeColor(String commonness) {
    switch (commonness.toLowerCase()) {
      case 'high':
        return Colors.red.shade400;
      case 'moderate':
        return Colors.orange.shade400;
      case 'low':
        return Colors.green.shade400;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final String diseaseName = disease["disease_name"] ?? "";
    final String cropName = disease["crop_name"] ?? "";
    final String cure = disease["cure"] ?? "";
    final String commonness = disease["commonness"] ?? "";

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.grey[300],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                controller: controller,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag:
                                'disease_${cropName.isNotEmpty ? cropName : diseaseName}',
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey.shade100,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  "assets/crops/${cropName.toLowerCase()}.jpg",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 80,
                                        color: Colors.grey[400],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (cropName.isNotEmpty)
                            Text(
                              cropName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (diseaseName.isNotEmpty && diseaseName != cropName)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                diseaseName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          if (commonness.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: getCommonnessBadgeColor(commonness),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                commonness,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          Text(
                            loc?.translate('treatmentHeading') ??
                                "Treatment & Prevention",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            cure,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                loc?.translate('close') ?? "Close",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
