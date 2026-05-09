import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/deal_card.dart';
import '../../models/deal.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const String _savedDealsKey = 'saved_deals';
  static const String _priceDropDealsKey = 'price_drop_deals';

  late final TabController _tabController;
  late Future<List<Deal>> _savedDealsFuture;
  late Future<List<Deal>> _priceDropDealsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _savedDealsFuture = _loadSavedDeals();
    _priceDropDealsFuture = _loadPriceDropDeals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Deal>> _loadSavedDeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getStringList(_savedDealsKey) ?? [];
      if (savedJson.isEmpty) {
        // Pre-populate with some sample saved deals
        final sampleDeals = await _getSampleSavedDeals();
        await _persistDeals(_savedDealsKey, sampleDeals);
        return sampleDeals;
      }
      return savedJson
          .map((json) => Deal.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return _getSampleSavedDeals();
    }
  }

  Future<List<Deal>> _loadPriceDropDeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dropJson = prefs.getStringList(_priceDropDealsKey) ?? [];
      if (dropJson.isEmpty) {
        final sampleDrops = _getSamplePriceDrops();
        await _persistDeals(_priceDropDealsKey, sampleDrops);
        return sampleDrops;
      }
      return dropJson
          .map((json) => Deal.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return _getSamplePriceDrops();
    }
  }

  Future<List<Deal>> _getSampleSavedDeals() async {
    final api = ApiService();
    final deals = await api.getDeals();
    // Mark first 3 as saved
    for (var i = 0; i < deals.length && i < 3; i++) {
      deals[i].isSaved = true;
    }
    return deals.where((d) => d.isSaved).toList();
  }

  List<Deal> _getSamplePriceDrops() {
    return [
      Deal(
        id: 'drop_001',
        title: 'Samsung Galaxy S23 Ultra 5G - 256GB',
        site: 'amazon_eg',
        siteDisplay: 'Amazon Egypt',
        category: 'electronics',
        currentPrice: 24999.00,
        originalPrice: 42999.00,
        discount: 42,
        discountDisplay: '42% OFF',
        imageUrl: 'https://m.media-amazon.com/images/I/61VfL-aiToL._AC_SL1000_.jpg',
        productUrl: 'https://www.amazon.eg/dp/B0BSH4FRTX',
        rating: 4.6,
        reviewCount: 2341,
        currency: 'EGP',
        verificationStatus: 'GENUINE',
        verificationConfidence: 0.92,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isSaved: true,
      ),
      Deal(
        id: 'drop_002',
        title: 'Apple AirPods Pro (2nd Gen) USB-C',
        site: 'amazon_eg',
        siteDisplay: 'Amazon Egypt',
        category: 'electronics',
        currentPrice: 7999.00,
        originalPrice: 14999.00,
        discount: 47,
        discountDisplay: '47% OFF',
        imageUrl: 'https://m.media-amazon.com/images/I/61SUj2aKoEL._AC_SL1500_.jpg',
        productUrl: 'https://www.amazon.eg/dp/B0CHWRXH8B',
        rating: 4.7,
        reviewCount: 1856,
        currency: 'EGP',
        verificationStatus: 'GENUINE',
        verificationConfidence: 0.95,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isSaved: true,
      ),
    ];
  }

  Future<void> _persistDeals(String key, List<Deal> deals) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = deals.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(key, jsonList);
  }

  Future<void> _toggleSave(Deal deal, List<Deal> currentList) async {
    setState(() {
      deal.isSaved = !deal.isSaved;
      if (!deal.isSaved) {
        currentList.remove(deal);
      }
    });
    await _persistDeals(_savedDealsKey, currentList);
  }

  void _refresh() {
    setState(() {
      _savedDealsFuture = _loadSavedDeals();
      _priceDropDealsFuture = _loadPriceDropDeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.electricOrange,
          indicatorWeight: 3,
          labelColor: AppColors.electricOrange,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Wishlist'),
            Tab(text: 'Price Drops'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWishlistTab(),
          _buildPriceDropsTab(),
        ],
      ),
    );
  }

  Widget _buildWishlistTab() {
    return FutureBuilder<List<Deal>>(
      future: _savedDealsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildShimmerGrid();
        }

        final deals = snapshot.data ?? [];

        if (deals.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'Your wishlist is empty',
            subtitle: 'Tap the heart icon on deals to save them here',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.62,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: deals.length,
          itemBuilder: (context, index) {
            final deal = deals[index];
            return _SavedDealGridCard(
              deal: deal,
              onSaveToggle: () => _toggleSave(deal, deals),
            );
          },
        );
      },
    );
  }

  Widget _buildPriceDropsTab() {
    return FutureBuilder<List<Deal>>(
      future: _priceDropDealsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, index) => const _PriceDropShimmer(),
          );
        }

        final deals = snapshot.data ?? [];

        if (deals.isEmpty) {
          return _buildEmptyState(
            icon: Icons.trending_down_rounded,
            title: 'No price drops yet',
            subtitle: 'We\'ll notify you when saved items drop in price',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: deals.length,
          itemBuilder: (context, index) {
            final deal = deals[index];
            return _PriceDropCard(deal: deal);
          },
        );
      },
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: AppColors.surfaceLight,
        highlightColor: AppColors.surfaceLighter,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Saved Deal Grid Card ──
class _SavedDealGridCard extends StatelessWidget {
  final Deal deal;
  final VoidCallback? onSaveToggle;

  const _SavedDealGridCard({
    required this.deal,
    this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    final sourceColor = AppColors.sourceColor(deal.site);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: AppColors.surfaceLight,
                    child: deal.imageUrl != null
                        ? Image.network(
                            deal.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppColors.textMuted,
                                size: 32,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image,
                              color: AppColors.textMuted,
                              size: 32,
                            ),
                          ),
                  ),
                ),
                // Source badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: sourceColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppColors.sourceLogo(deal.site),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                // Heart button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onSaveToggle,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 16,
                        color: AppColors.crimsonRed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info area
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${deal.currentPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.emeraldGreen,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        deal.currency,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.emeraldGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: AppColors.orangeYellow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      deal.discountDisplay,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
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
  }
}

// ── Price Drop Card ──
class _PriceDropCard extends StatelessWidget {
  final Deal deal;

  const _PriceDropCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    final sourceColor = AppColors.sourceColor(deal.site);
    final savings = deal.savingsValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.crimsonRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // PRICE DROP banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.crimsonRed.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.trending_down_rounded,
                  size: 16,
                  color: AppColors.crimsonRed,
                ),
                const SizedBox(width: 6),
                const Text(
                  'PRICE DROP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.crimsonRed,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surfaceLight,
                    child: deal.imageUrl != null
                        ? Image.network(
                            deal.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppColors.textMuted,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image,
                              color: AppColors.textMuted,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: sourceColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            deal.siteDisplay,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: sourceColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        deal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${deal.currentPrice.toStringAsFixed(0)} ${deal.currency}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.emeraldGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${deal.originalPrice.toStringAsFixed(0)} ${deal.currency}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Save ${savings.toStringAsFixed(0)} ${deal.currency}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.goldenYellow,
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
    );
  }
}

// ── Price Drop Shimmer ──
class _PriceDropShimmer extends StatelessWidget {
  const _PriceDropShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.surfaceLight,
        highlightColor: AppColors.surfaceLighter,
        child: Container(
          color: AppColors.surfaceLighter,
        ),
      ),
    );
  }
}
