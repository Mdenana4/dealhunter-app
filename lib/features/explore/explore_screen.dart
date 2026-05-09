import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<_Store> _stores = [
    _Store(
      name: 'Amazon Egypt',
      logo: 'A',
      color: AppColors.amazonOrange,
      dealCount: 52,
      bgColor: AppColors.amazonOrange.withOpacity(0.15),
    ),
    _Store(
      name: 'Noon Egypt',
      logo: 'N',
      color: AppColors.noonYellow,
      dealCount: 38,
      bgColor: AppColors.noonYellow.withOpacity(0.15),
    ),
    _Store(
      name: 'Jumia Egypt',
      logo: 'J',
      color: AppColors.jumiaOrange,
      dealCount: 24,
      bgColor: AppColors.jumiaOrange.withOpacity(0.15),
    ),
  ];

  final List<_Category> _categories = [
    _Category('Electronics', 'electronics', Icons.phone_iphone, AppColors.electricOrange),
    _Category('Fashion', 'fashion', Icons.checkroom, const Color(0xFFEC4899)),
    _Category('Home', 'home', Icons.home_outlined, const Color(0xFF8B5CF6)),
    _Category('Beauty', 'beauty', Icons.brush, const Color(0xFFF43F5E)),
    _Category('Sports', 'sports', Icons.sports_soccer, const Color(0xFF10B981)),
    _Category('Toys', 'toys', Icons.toys, const Color(0xFFF59E0B)),
    _Category('Grocery', 'grocery', Icons.local_grocery_store, const Color(0xFF14B8A6)),
    _Category('Travel', 'travel', Icons.flight_takeoff, const Color(0xFF3B82F6)),
    _Category('VIP', 'vip', Icons.diamond, AppColors.goldenYellow),
  ];

  final List<_TrendingItem> _trending = [
    _TrendingItem('Samsung Galaxy S24 Ultra', '34% OFF', 1, 'amazon_eg'),
    _TrendingItem('Sony WH-1000XM5 Headphones', '37% OFF', 2, 'noon_eg'),
    _TrendingItem('Apple AirPods Pro 2', '40% OFF', 3, 'amazon_eg'),
    _TrendingItem('Xiaomi Redmi Note 13 Pro', '23% OFF', 4, 'jumia_eg'),
    _TrendingItem('Samsung 55" 4K Smart TV', '24% OFF', 5, 'jumia_eg'),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: CustomScrollView(
        slivers: [
          // Popular Stores Section
          SliverToBoxAdapter(
            child: _buildSectionTitle('Popular Stores', Icons.store),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildStoreCard(_stores[index]),
              childCount: _stores.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Browse by Category Section
          SliverToBoxAdapter(
            child: _buildSectionTitle('Browse by Category', Icons.grid_view),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCategoryCard(_categories[index]),
                childCount: _categories.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Trending Now Section
          SliverToBoxAdapter(
            child: _buildSectionTitle('Trending Now', Icons.trending_up),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildTrendingCard(_trending[index]),
              childCount: _trending.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.electricOrange),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(_Store store) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: store.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: store.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: store.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                store.logo,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: store.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${store.dealCount} active deals',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: store.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              store.dealCount.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: store.color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(_Category category) {
    return GestureDetector(
      onTap: () {
        // Navigate to category-specific deals list
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingCard(_TrendingItem item) {
    Color rankColor;
    if (item.rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
    } else if (item.rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
    } else if (item.rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
    } else {
      rankColor = AppColors.textMuted;
    }

    final sourceColor = AppColors.sourceColor(item.source);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: item.rank <= 3
                  ? rankColor.withOpacity(0.15)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#${item.rank}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: rankColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Deal info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: sourceColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _sourceName(item.source),
                      style: TextStyle(
                        fontSize: 11,
                        color: sourceColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Discount badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.orangeYellow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.discount,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sourceName(String source) {
    switch (source) {
      case 'amazon_eg':
        return 'Amazon';
      case 'noon_eg':
        return 'Noon';
      case 'jumia_eg':
        return 'Jumia';
      default:
        return source;
    }
  }
}

// ── Data classes ──
class _Store {
  final String name;
  final String logo;
  final Color color;
  final int dealCount;
  final Color bgColor;

  _Store({
    required this.name,
    required this.logo,
    required this.color,
    required this.dealCount,
    required this.bgColor,
  });
}

class _Category {
  final String name;
  final String key;
  final IconData icon;
  final Color color;

  _Category(this.name, this.key, this.icon, this.color);
}

class _TrendingItem {
  final String title;
  final String discount;
  final int rank;
  final String source;

  _TrendingItem(this.title, this.discount, this.rank, this.source);
}
