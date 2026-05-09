import 'dart:async';
import 'dart:math' show pi, cos, sin;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/deal_card.dart';
import '../../core/services/api_service.dart';
import '../../models/deal.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isScanning = false;
  int _elapsedSeconds = 0;
  int _foundCount = 0;
  Timer? _timer;
  List<Deal> _foundDeals = [];
  late final AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sweepController.dispose();
    super.dispose();
  }

  void _toggleScan() {
    setState(() {
      _isScanning = !_isScanning;
    });

    if (_isScanning) {
      _sweepController.repeat();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedSeconds++;
          // Simulate finding deals
          if (_elapsedSeconds % 3 == 0 && _foundDeals.length < 4) {
            _foundCount++;
            _addMockFoundDeal();
          }
        });
      });
    } else {
      _sweepController.stop();
      _timer?.cancel();
    }
  }

  void _addMockFoundDeal() {
    final mockDeals = [
      Deal(
        id: 'radar_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Canon EOS R50 Mirrorless Camera Kit',
        site: 'amazon_eg',
        siteDisplay: 'Amazon Egypt',
        category: 'electronics',
        currentPrice: 18999.00,
        originalPrice: 24999.00,
        discount: 24,
        discountDisplay: '24% OFF',
        imageUrl: 'https://m.media-amazon.com/images/I/placeholder.jpg',
        productUrl: 'https://www.amazon.eg/dp/radarfound',
        currency: 'EGP',
        verificationStatus: 'GENUINE',
        verificationConfidence: 0.91,
        timestamp: DateTime.now(),
      ),
      Deal(
        id: 'radar_${DateTime.now().millisecondsSinceEpoch + 1}',
        title: 'Dyson V12 Detect Slim Vacuum',
        site: 'noon_eg',
        siteDisplay: 'Noon Egypt',
        category: 'home',
        currentPrice: 15999.00,
        originalPrice: 21999.00,
        discount: 27,
        discountDisplay: '27% OFF',
        productUrl: 'https://www.noon.com/radarfound',
        currency: 'EGP',
        verificationStatus: 'VERIFIED',
        verificationConfidence: 0.87,
        timestamp: DateTime.now(),
      ),
    ];
    if (_foundDeals.length < mockDeals.length * 2) {
      setState(() {
        _foundDeals.add(mockDeals[_foundDeals.length % mockDeals.length]);
      });
    }
  }

  void _resetScan() {
    setState(() {
      _isScanning = false;
      _elapsedSeconds = 0;
      _foundCount = 0;
      _foundDeals = [];
    });
    _timer?.cancel();
    _sweepController.reset();
  }

  String get _elapsedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header
            const Text(
              'Deal Radar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            // Status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isScanning ? AppColors.emeraldGreen : AppColors.textMuted,
                    shape: BoxShape.circle,
                    boxShadow: _isScanning
                        ? [
                            BoxShadow(
                              color: AppColors.emeraldGreen.withOpacity(0.5),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isScanning ? 'ACTIVE' : 'STANDBY',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _isScanning ? AppColors.emeraldGreen : AppColors.textMuted,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Timer
            Text(
              _elapsedTime,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 24),

            // Radar Visualization
            SizedBox(
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Concentric circles
                  ..._buildCircles(),
                  // Rotating sweep
                  if (_isScanning)
                    RotationTransition(
                      turns: _sweepController,
                      child: CustomPaint(
                        size: const Size(220, 220),
                        painter: _RadarSweepPainter(),
                      ),
                    ),
                  // Blinking pulse dots
                  if (_isScanning) ..._buildPulseDots(),
                  // Center icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.deepPurple.withOpacity(0.2),
                      border: Border.all(
                        color: AppColors.deepPurple.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepPurple.withOpacity(0.3),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.radar,
                      color: AppColors.deepPurple,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Scan info
            Text(
              _isScanning
                  ? 'Scanning across 3 stores...'
                  : 'Found $_foundCount deals in last scan',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Amazon Egypt  •  Noon Egypt  •  Jumia Egypt',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),

            const SizedBox(height: 20),

            // Start/Stop button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _toggleScan,
                      icon: Icon(
                        _isScanning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        size: 20,
                      ),
                      label: Text(
                        _isScanning ? 'Stop Scan' : 'Start Scan',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isScanning
                            ? AppColors.crimsonRed
                            : AppColors.electricOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                  if (!_isScanning && _foundDeals.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _resetScan,
                      icon: const Icon(Icons.replay_rounded),
                      color: AppColors.textMuted,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Found deals list
            if (_foundDeals.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Found Deals',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],

            Expanded(
              child: _foundDeals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.radar,
                            size: 48,
                            color: AppColors.textMuted.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isScanning
                                ? 'Scanning for deals...'
                                : 'Start scan to find deals',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      itemCount: _foundDeals.length,
                      itemBuilder: (context, index) => DealCard(
                        deal: _foundDeals[index],
                        index: index,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCircles() {
    return [80.0, 130.0, 180.0].map((radius) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.deepPurple.withOpacity(0.2),
            width: 1,
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildPulseDots() {
    final positions = [
      const Offset(50, -60),
      const Offset(-70, 40),
      const Offset(80, 50),
    ];

    return positions.asMap().entries.map((entry) {
      final i = entry.key;
      final pos = entry.value;
      return _BlinkingDot(
        offset: pos,
        delay: i * 400,
      );
    }).toList();
  }
}

// ── Radar Sweep Painter ──
class _RadarSweepPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Create conic gradient effect
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          AppColors.deepPurple.withOpacity(0.0),
          AppColors.deepPurple.withOpacity(0.0),
          AppColors.deepPurple.withOpacity(0.15),
          AppColors.deepPurple.withOpacity(0.0),
        ],
        stops: const [0.0, 0.7, 0.85, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Blinking Pulse Dot ──
class _BlinkingDot extends StatefulWidget {
  final Offset offset;
  final int delay;

  const _BlinkingDot({required this.offset, required this.delay});

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: widget.offset,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.emeraldGreen.withOpacity(
                0.4 + _controller.value * 0.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.emeraldGreen.withOpacity(
                    0.3 * _controller.value,
                  ),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
