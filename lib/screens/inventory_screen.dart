import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/car_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/ai_disclaimer.dart';
import '../models/car_model.dart';

class InventoryScreen extends StatefulWidget {
  final String? initialTab;
  
  const InventoryScreen({super.key, this.initialTab});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _filterStatus = 'all'; // Use constant key instead of translated value
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Determine initial tab index based on parameter
    int initialIndex = 0;
    if (widget.initialTab == 'approved') {
      initialIndex = 2;
      _filterStatus = 'approved';
    } else if (widget.initialTab == 'pending') {
      initialIndex = 1;
      _filterStatus = 'pending';
    } else {
      _filterStatus = 'all';
    }
    
    _tabController = TabController(length: 3, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          switch (_tabController.index) {
            case 0:
              _filterStatus = 'all';
              break;
            case 1:
              _filterStatus = 'pending';
              break;
            case 2:
              _filterStatus = 'approved';
              break;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    final filteredCars = carProvider.cars.where((car) {
      // Search by make, model, description, demand, and purchase recommendation
      final description = languageProvider.isTamil
          ? (car.descriptionTa ?? car.description)
          : (car.descriptionEn ?? car.description);
      final demand = car.demand ?? '';
      final purchaseRec = car.purchaseRecommendation ?? '';
      final matchesSearch = _searchQuery.isEmpty ||
          car.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          demand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          purchaseRec.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _filterStatus == 'all' ||
          (_filterStatus == 'pending' && car.status == CarStatus.pending) ||
          (_filterStatus == 'approved' && car.status == CarStatus.approved);

      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(currentRoute: '/inventory'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width < 768 ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 768;
                      return isMobile
                          ? Column(
                              children: [
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    image: const DecorationImage(
                                      image: AssetImage(
                                          'assets/images/inventory_car.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        bottom: 16,
                                        left: 16,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                languageProvider.translate(
                                                  'Live Inventory',
                                                  'நேரடி சரக்கு',
                                                ),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
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
                                const SizedBox(height: 16),
                                // _buildStatsCards(
                                //     context, languageProvider, carProvider),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 300,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: const DecorationImage(
                                        image: AssetImage(
                                            'assets/images/inventory_car.jpg'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: 16,
                                          left: 16,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  languageProvider.translate(
                                                    'Live Inventory',
                                                    'நேரடி சரக்கு',
                                                  ),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
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
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  languageProvider.translate(
                                                    'Analyzed cars',
                                                    'பகுப்பாய்வு செய்யப்பட்ட கார்கள்',
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              languageProvider.translate(
                                                'Comprehensive vehicle management system',
                                                'விரிவான வாகன மேலாண்மை அமைப்பு',
                                              ),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            // Row(
                                            //   children: [
                                            //     // Expanded(
                                            //     //   child: Container(
                                            //     //     padding:
                                            //     //         const EdgeInsets.all(
                                            //     //             16),
                                            //     //     decoration: BoxDecoration(
                                            //     //       border: Border.all(
                                            //     //         color: Colors.green,
                                            //     //         width: 2,
                                            //     //       ),
                                            //     //       borderRadius:
                                            //     //           BorderRadius.circular(
                                            //     //               8),
                                            //     //     ),
                                            //     //     child: Column(
                                            //     //       children: [
                                            //     //         const Icon(
                                            //     //           Icons.check_circle,
                                            //     //           color: Colors.green,
                                            //     //           size: 32,
                                            //     //         ),
                                            //     //         const SizedBox(
                                            //     //             height: 8),
                                            //     //         Text(
                                            //     //           languageProvider
                                            //     //               .translate(
                                            //     //             'Total Vehicles',
                                            //     //             'மொத்த வாகனங்கள்',
                                            //     //           ),
                                            //     //           style: TextStyle(
                                            //     //             fontSize: 12,
                                            //     //             color: Colors
                                            //     //                 .grey.shade600,
                                            //     //           ),
                                            //     //         ),
                                            //     //         const SizedBox(
                                            //     //             height: 4),
                                            //     //         Text(
                                            //     //           carProvider.totalCars
                                            //     //               .toString(),
                                            //     //           style:
                                            //     //               const TextStyle(
                                            //     //             fontSize: 24,
                                            //     //             fontWeight:
                                            //     //                 FontWeight.bold,
                                            //     //             color: Colors.green,
                                            //     //           ),
                                            //     //         ),
                                            //     //       ],
                                            //     //     ),
                                            //     //   ),
                                            //     // ),
                                            //     // const SizedBox(width: 12),
                                            //     Expanded(
                                            //       child: Container(
                                            //         padding:
                                            //             const EdgeInsets.all(
                                            //                 16),
                                            //         decoration: BoxDecoration(
                                            //           border: Border.all(
                                            //             color: Colors
                                            //                 .blue.shade300,
                                            //             width: 2,
                                            //           ),
                                            //           borderRadius:
                                            //               BorderRadius.circular(
                                            //                   8),
                                            //         ),
                                            //         child: Column(
                                            //           children: [
                                            //             Icon(
                                            //               Icons.access_time,
                                            //               color: Colors
                                            //                   .blue.shade300,
                                            //               size: 32,
                                            //             ),
                                            //             const SizedBox(
                                            //                 height: 8),
                                            //             Text(
                                            //               languageProvider
                                            //                   .translate(
                                            //                 'Pending',
                                            //                 'நிலுவையில்',
                                            //               ),
                                            //               style: TextStyle(
                                            //                 fontSize: 12,
                                            //                 color: Colors
                                            //                     .grey.shade600,
                                            //               ),
                                            //             ),
                                            //             const SizedBox(
                                            //                 height: 4),
                                            //             Text(
                                            //               carProvider
                                            //                   .pendingCars
                                            //                   .toString(),
                                            //               style: TextStyle(
                                            //                 fontSize: 24,
                                            //                 fontWeight:
                                            //                     FontWeight.bold,
                                            //                 color: Colors
                                            //                     .blue.shade300,
                                            //               ),
                                            //             ),
                                            //           ],
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Search
                  // TextField(
                  //   onChanged: (value) => setState(() => _searchQuery = value),
                  //   decoration: InputDecoration(
                  //     hintText: languageProvider.translate(
                  //       'Search cars...',
                  //       'கார்களைத் தேடவும்...',
                  //     ),
                  //     prefixIcon: const Icon(Icons.search),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     filled: true,
                  //     fillColor: Colors.grey.shade50,
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  // Tabs for filtering
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 768;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          labelPadding: EdgeInsets.zero,
                          indicator: BoxDecoration(
                            color: const Color(0xFF1E3A8A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey.shade700,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile
                                ? (languageProvider.isTamil ? 8 : 14)
                                : (languageProvider.isTamil ? 14 : 16),
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: isMobile ? 12 : 14,
                          ),

                          // 🔴 No horizontal scroll – occupy full width
                          isScrollable: false,
                          tabAlignment: TabAlignment.fill,

                          tabs: [
                            Tab(
                              height: isMobile ? 48 : 56,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 8 : 12,
                                  vertical: isMobile ? 4 : 8,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.directions_car, size: 18),
                                    SizedBox(width: isMobile ? 4 : 6),
                                    Flexible(
                                      child: Text(
                                        languageProvider.translate(
                                          'Total Cars',
                                          'மொத்த கார்கள்',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(width: isMobile ? 4 : 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        carProvider.totalCars.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Tab(
                              height: isMobile ? 48 : 56,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 8 : 12,
                                  vertical: isMobile ? 4 : 8,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.access_time, size: 18),
                                    SizedBox(width: isMobile ? 4 : 6),
                                    Flexible(
                                      child: Text(
                                        languageProvider.translate(
                                          'Pending',
                                          'நிலுவையில்',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(width: isMobile ? 4 : 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        carProvider.pendingCars.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Tab(
                              height: isMobile ? 48 : 56,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 8 : 12,
                                  vertical: isMobile ? 4 : 8,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle, size: 18),
                                    SizedBox(width: isMobile ? 4 : 6),
                                    Flexible(
                                      child: Text(
                                        languageProvider.translate(
                                          'Approved',
                                          'அனுமதிக்கப்பட்டது',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(width: isMobile ? 4 : 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        carProvider.approvedCars.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  // Car Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 768;
                      final crossAxisCount =
                          isMobile ? 1 : (constraints.maxWidth < 1024 ? 2 : 3);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: isMobile ? 1.8 : 2.0,
                        ),
                        itemCount: filteredCars.length,
                        itemBuilder: (context, index) {
                          final car = filteredCars[index];
                          return _CarCard(car: car);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Show disclaimer only if there are cars in the inventory
          if (carProvider.cars.isNotEmpty) const AIDisclaimer(),
        ],
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  final Car car;

  const _CarCard({required this.car});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return GestureDetector(
      onTap: () => context.go('/car/${car.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image - Half width
            Expanded(
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: car.imageBytes != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Image.memory(
                          car.imageBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.directions_car_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.directions_car_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
            ),
            // Car Info - Half width
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            car.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 6),
                    // // Summary/Description (Compulsory)
                    // Text(
                    //   // Show description based on selected language
                    //   languageProvider.isTamil
                    //       ? (car.descriptionTa ?? car.description)
                    //       : (car.descriptionEn ?? car.description),
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     color: Colors.grey.shade700,
                    //     height: 1.4,
                    //   ),
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                    const SizedBox(height: 16),
                    // Market Demand and Purchase Recommendation
                    if (car.demand != null ||
                        car.purchaseRecommendation != null) ...[
                      Row(
                        children: [
                          if (car.demand != null) ...[
                            Icon(Icons.trending_up,
                                size: 14, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            Text(
                              car.demand!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                          if (car.demand != null &&
                              car.purchaseRecommendation != null)
                            const SizedBox(width: 12),
                          if (car.purchaseRecommendation != null) ...[
                            Icon(
                              car.purchaseRecommendation!
                                      .toLowerCase()
                                      .contains('purchase')
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 14,
                              color: car.purchaseRecommendation!
                                      .toLowerCase()
                                      .contains('purchase')
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              car.purchaseRecommendation!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: car.purchaseRecommendation!
                                        .toLowerCase()
                                        .contains('purchase')
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Sustainability Score
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                languageProvider.translate(
                                  'Sustainability Score',
                                  'நிலைத்தன்மை மதிப்பெண்',
                                ),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: car.sustainabilityScore / 100,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  car.sustainabilityScore >= 70
                                      ? Colors.green.shade600
                                      : car.sustainabilityScore >= 50
                                          ? Colors.orange.shade600
                                          : Colors.red.shade600,
                                ),
                                minHeight: 6,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${car.sustainabilityScore.toStringAsFixed(1)}/100',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: car.sustainabilityScore >= 70
                                      ? Colors.green.shade700
                                      : car.sustainabilityScore >= 50
                                          ? Colors.orange.shade700
                                          : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Status Badge - Only show for pending cars
                    Row(
                      children: [
                        // Only show badge if car is pending
                        if (car.status == CarStatus.pending)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Colors.amber.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  car.statusText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => context.go('/car/${car.id}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            languageProvider.translate(
                                'View Details', 'விவரங்களைப் பார்க்க'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
