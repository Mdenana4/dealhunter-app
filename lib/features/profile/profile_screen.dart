import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final String _userName = 'Ahmed Hassan';
  final String _userEmail = 'ahmed.hassan@email.com';
  final bool _isVip = true;

  // Settings toggles
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _autoScanEnabled = false;
  bool _priceAlertsEnabled = true;

  final List<_Stat> _stats = [
    _Stat('Deals Found', '124', Icons.search),
    _Stat('Total Saved', '8,420', Icons.savings),
    _Stat('Wishlist', '12', Icons.favorite),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with avatar
          SliverToBoxAdapter(
            child: _buildProfileHeader(),
          ),

          // Stats row
          SliverToBoxAdapter(
            child: _buildStatsRow(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Settings section
          SliverToBoxAdapter(
            child: _buildSectionTitle('Settings'),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              _buildToggleTile(
                icon: Icons.notifications_active_outlined,
                title: 'Push Notifications',
                subtitle: 'Get alerts for new deals',
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),
              _buildToggleTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Always use dark theme',
                value: _darkModeEnabled,
                onChanged: (v) => setState(() => _darkModeEnabled = v),
              ),
              _buildToggleTile(
                icon: Icons.radar,
                title: 'Auto Radar Scan',
                subtitle: 'Automatically scan for deals',
                value: _autoScanEnabled,
                onChanged: (v) => setState(() => _autoScanEnabled = v),
              ),
              _buildToggleTile(
                icon: Icons.trending_down,
                title: 'Price Drop Alerts',
                subtitle: 'Notify when wishlist items drop',
                value: _priceAlertsEnabled,
                onChanged: (v) => setState(() => _priceAlertsEnabled = v),
              ),
            ]),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Account section
          SliverToBoxAdapter(
            child: _buildSectionTitle('Account'),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              _buildActionTile(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () {},
              ),
              _buildActionTile(
                icon: Icons.history,
                title: 'Scan History',
                onTap: () {},
              ),
              _buildActionTile(
                icon: Icons.share_outlined,
                title: 'Share App',
                onTap: () {},
              ),
              _buildActionTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {},
              ),
            ]),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // Logout button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.crimsonRed.withOpacity(0.15),
                  foregroundColor: AppColors.crimsonRed,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(
                      color: AppColors.crimsonRed.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final initials = _userName
        .split(' ')
        .map((s) => s.isNotEmpty ? s[0] : '')
        .join('')
        .toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: AppColors.orangePurple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricOrange.withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // VIP badge
              if (_isVip)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldenAmber,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.darkBackground,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldenYellow.withOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.diamond,
                        size: 10,
                        color: Colors.white,
                      ),
                      SizedBox(width: 2),
                      Text(
                        'VIP',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Name
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            _userEmail,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _stats.map((stat) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(stat.icon, size: 20, color: AppColors.electricOrange),
                  const SizedBox(height: 8),
                  Text(
                    stat.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat.label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.electricOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.electricOrange),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.electricOrange,
          activeTrackColor: AppColors.electricOrange.withOpacity(0.3),
          inactiveTrackColor: Colors.white.withOpacity(0.1),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.deepPurple),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: AppColors.textMuted,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.crimsonRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _Stat {
  final String label;
  final String value;
  final IconData icon;

  _Stat(this.label, this.value, this.icon);
}
