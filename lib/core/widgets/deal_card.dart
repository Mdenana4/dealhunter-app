import 'dart:math' show sin, pi;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/deal.dart';
import '../theme/app_colors.dart';

class DealCard extends StatefulWidget {
  final Deal deal;
  final int index;
  final VoidCallback? onSaveToggle;

  const DealCard({
    super.key,
    required this.deal,
    required this.index,
    this.onSaveToggle,
  });

  @override
  State<DealCard> createState() => _DealCardState();
}

class _DealCardState extends State<DealCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Staggered delay based on index
    final delay = Duration(milliseconds: widget.index * 80);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    Future.delayed(delay, () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.deal.productUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sourceColor = AppColors.sourceColor(widget.deal.site);
    final savings = widget.deal.savingsValue;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: _launchUrl,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
              // Source-colored left border glow
              boxShadow: [
                BoxShadow(
                  color: sourceColor.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left colored border strip
                  Container(
                    width: 3,
                    height: 160,
                    color: sourceColor,
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Source row
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: sourceColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: sourceColor.withOpacity(0.4),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.deal.siteDisplay,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: sourceColor,
                                ),
                              ),
                              const Spacer(),
                              // Animated discount badge
                              _DiscountBadge(discount: widget.deal.discount),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Image + details row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  color: AppColors.surfaceLight,
                                  child: widget.deal.imageUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: widget.deal.imageUrl!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Shimmer.fromColors(
                                            baseColor: AppColors.surfaceLight,
                                            highlightColor: AppColors.surfaceLighter,
                                            child: Container(
                                              color: AppColors.surfaceLight,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Center(
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
                              const SizedBox(width: 12),
                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    Text(
                                      widget.deal.title,
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
                                    // Price row
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          '${widget.deal.currentPrice.toStringAsFixed(0)} ${widget.deal.currency}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.emeraldGreen,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${widget.deal.originalPrice.toStringAsFixed(0)} ${widget.deal.currency}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.textMuted,
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Savings
                                    Text(
                                      'You save ${savings.toStringAsFixed(0)} ${widget.deal.currency}',
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
                          const SizedBox(height: 10),
                          // Footer: verification + save
                          Row(
                            children: [
                              // Verification badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.deal.statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: widget.deal.statusColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      widget.deal.verificationStatus == 'GENUINE'
                                          ? Icons.verified_rounded
                                          : widget.deal.verificationStatus ==
                                                  'SUSPICIOUS'
                                              ? Icons.warning_amber_rounded
                                              : Icons.info_outline_rounded,
                                      size: 12,
                                      color: widget.deal.statusColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.deal.statusText,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: widget.deal.statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.deal.rating != null) ...[
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 12,
                                      color: AppColors.goldenYellow,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      widget.deal.rating!.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const Spacer(),
                              // Heart save button
                              GestureDetector(
                                onTap: widget.onSaveToggle,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.deal.isSaved
                                        ? AppColors.crimsonRed.withOpacity(0.15)
                                        : Colors.white.withOpacity(0.05),
                                  ),
                                  child: Icon(
                                    widget.deal.isSaved
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 18,
                                    color: widget.deal.isSaved
                                        ? AppColors.crimsonRed
                                        : AppColors.textMuted,
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
          ),
        ),
      ),
    );
  }
}

// ── Animated Discount Badge ──
class _DiscountBadge extends StatefulWidget {
  final int discount;

  const _DiscountBadge({required this.discount});

  @override
  State<_DiscountBadge> createState() => _DiscountBadgeState();
}

class _DiscountBadgeState extends State<_DiscountBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.05);
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppColors.orangeYellow,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricOrange.withOpacity(
                    0.2 + _pulseController.value * 0.2,
                  ),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Text(
              '${widget.discount}% OFF',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
