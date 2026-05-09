import 'dart:async';
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/golden_sparkle.dart';
import '../../core/widgets/deal_card.dart';
import '../../models/deal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final ApiService _apiService;
  late Future<List<Deal>> _dealsFuture;
  late Future<Map<String, int>> _sourceCountsFuture;
  String _selectedFilter = 'all';
  bool _isUsingMockData = false;
  int _totalDeals = 0;
  late final AnimationController _counterAnimController;
  late final Animation<int> _counterAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _dealsFuture = _apiService.getDeals();
    _sourceCountsFuture = _apiService.getSourceCounts();
    _counterAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _counterAnimation = IntTween(begin: 0, end: 124).animate(
      CurvedAnimation(
        parent: _counterAnimController,
        curve: Curves.easeOutCubic,
      ),
    );
    _loadDeals();
  }

  @override
  void dispose() {
    _counterAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadDeals() async {
    setState(() {
      _isUsingMockData = false;
    });

    try {
      final deals = await _apiService.getDeals(
        source: _selectedFilter == 'all' ? null : _selectedFilter,
      );
      final counts = await _apiService.getSourceCounts();

      // Check if we're getting mock data (indicated by known mock IDs)
      if (deals.isNotEmpty && deals.first.id.startsWith('amz_')) {
        _isUsingMockData = true;
      }

      _totalDeals = counts.values.fold(0, (a, b) => a + b);

      setState(() {
        _dealsFuture = Future.value(deals);
        _sourceCountsFuture = Future.value(counts);
      });

      _counterAnimController.reset();
      _counterAnimation = IntTween(begin: 0, end: _totalDeals).animate(
        CurvedAnimation(
          parent: _counterAnimController,
          curve: Curves.easeOutCubic,
        ),
      );
      _counterAnimController.forward();
    } catch (e) {
      setState(() {
        _isUsingMockData = true;
      });
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadDeals();
  }

  Future<void> _onRefresh() async {
    await _loadDeals();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.electricOrange,
        backgroundColor: AppColors.cardBackground,
        child: Stack(
          children: [
            // ── Golden particles background ──
            const Positioned.fill(
              child: GoldenParticles(),
            ),
            // ── Header gradient overlay ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 340,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.electricOrange.withOpacity(0.15),
                      AppColors.deepPurple.withOpacity(0.08),
                      AppColors.emeraldGreen.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // ── Main content ──
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),
                // Offline banner
                if (_isUsingMockData)
                  SliverToBoxAdapter(
                    child: _buildOfflineBanner(),
                  ),
                SliverToBoxAdapter(
                  child: _buildSearchBar(),
                ),
                SliverToBoxAdapter(
                  child: _buildFilterChips(),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 8),
                ),
                // Deals list
                _buildDealsList(),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Row(
            children: [
              Text(
                _greeting,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Hunter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.electricOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Live deal counter
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedBuilder(
                animation: _counterAnimation,
                builder: (context, child) {
                  return Text(
                    '${_counterAnimation.value}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.electricOrange,
                      letterSpacing: -1,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'live deals found',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.emeraldGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emeraldGreen.withOpacity(0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Updated ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.statusSuspicious.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.statusSuspicious.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 18,
            color: AppColors.statusSuspicious,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Showing cached deals — API unavailable',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.statusSuspicious,
              ),
            ),
          ),
          TextButton(
            onPressed: _onRefresh,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.statusSuspicious,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => _showSearchScreen(context),
      child: Container(
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              Icons.search_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Search deals, brands, products...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.electricOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.tune_rounded,
                size: 16,
                color: AppColors.electricOrange,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return FutureBuilder<Map<String, int>>(
      future: _sourceCountsFuture,
      builder: (context, snapshot) {
        final counts = snapshot.data ?? {};
        final allCount = counts.values.fold<int>(0, (a, b) => a + b);

        return Container(
          height: 44,
          margin: const EdgeInsets.only(top: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _FilterChip(
                label: 'All',
                count: allCount,
                isActive: _selectedFilter == 'all',
                activeColor: AppColors.electricOrange,
                onTap: () => _onFilterChanged('all'),
              ),
              _FilterChip(
                label: 'Amazon',
                count: counts['amazon_eg'] ?? 0,
                isActive: _selectedFilter == 'amazon_eg',
                activeColor: AppColors.amazonOrange,
                onTap: () => _onFilterChanged('amazon_eg'),
              ),
              _FilterChip(
                label: 'Noon',
                count: counts['noon_eg'] ?? 0,
                isActive: _selectedFilter == 'noon_eg',
                activeColor: AppColors.noonYellow,
                onTap: () => _onFilterChanged('noon_eg'),
              ),
              _FilterChip(
                label: 'Jumia',
                count: counts['jumia_eg'] ?? 0,
                isActive: _selectedFilter == 'jumia_eg',
                activeColor: AppColors.jumiaOrange,
                onTap: () => _onFilterChanged('jumia_eg'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDealsList() {
    return FutureBuilder<List<Deal>>(
      future: _dealsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const _DealCardShimmer(),
              childCount: 6,
            ),
          );
        }

        if (snapshot.hasError && !snapshot.hasData) {
          return SliverFillRemaining(
            child: _buildErrorState(),
          );
        }

        final deals = snapshot.data ?? [];

        if (deals.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final deal = deals[index];
              return DealCard(
                deal: deal,
                index: index,
                onSaveToggle: () {
                  setState(() {
                    deal.isSaved = !deal.isSaved;
                  });
                },
              );
            },
            childCount: deals.length,
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load deals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              'No deals found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchScreen(BuildContext context) {
    showSearch(
      context: context,
      delegate: _DealSearchDelegate(_apiService),
    );
  }
}

// ── Filter Chip ──
class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.2) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isActive ? activeColor.withOpacity(0.5) : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? activeColor : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor.withOpacity(0.3)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isActive ? activeColor : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Deal Card Shimmer ──
class _DealCardShimmer extends StatelessWidget {
  const _DealCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.surfaceLight,
        highlightColor: AppColors.surfaceLighter,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.surfaceLighter,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLighter,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLighter,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 160,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLighter,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 120,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLighter,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLighter,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search Delegate ──
class _DealSearchDelegate extends SearchDelegate<String> {
  final ApiService _apiService;
  Timer? _debounce;

  _DealSearchDelegate(this._apiService);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        titleTextStyle: theme.textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.textMuted),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentSearches(context);
    }
    return _buildSearchResults(query);
  }

  Widget _buildSearchResults(String query) {
    return FutureBuilder<List<Deal>>(
      future: _apiService.searchDeals(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            itemCount: 4,
            itemBuilder: (context, index) => const _DealCardShimmer(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.textMuted, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Search failed. Try again.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          );
        }

        final deals = snapshot.data ?? [];

        if (deals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, color: AppColors.textMuted, size: 48),
                const SizedBox(height: 16),
                Text(
                  'No results for "$query"',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: deals.length,
          itemBuilder: (context, index) => DealCard(
            deal: deals[index],
            index: index,
          ),
        );
      },
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    final recent = ['Samsung', 'iPhone', 'laptop', 'headphones'];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Recent Searches',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ...recent.map((term) => ListTile(
              leading: const Icon(Icons.history, color: AppColors.textMuted, size: 20),
              title: Text(
                term,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
              onTap: () {
                query = term;
                showResults(context);
              },
            )),
      ],
    );
  }
}
