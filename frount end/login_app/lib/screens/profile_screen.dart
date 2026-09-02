import 'package:flutter/material.dart';
import '../theme.dart';
import '../components.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = user['name'] ?? 'User';
    final String email = user['email'] ?? 'Not provided';
    final String mobile = user['mobile'] ?? 'Not provided';
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 800;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32.0 : 20.0,
            vertical: 20.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage your personal account details and sports preferences',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 28),

                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Avatar & Summary Card
                        Expanded(
                          flex: 2,
                          child: _buildAvatarCard(name, initial),
                        ),
                        const SizedBox(width: 24),
                        // Right Column: Details & Settings
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAccountInfoCard(name, email, mobile),
                              const SizedBox(height: 24),
                              _buildLogoutButton(context),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvatarCard(name, initial),
                        const SizedBox(height: 24),
                        const Text(
                          'Account Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAccountInfoCard(name, email, mobile),
                        const SizedBox(height: 28),
                        _buildLogoutButton(context),
                      ],
                    ),

                  const SizedBox(height: 90), // Bottom padding for mobile nav
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarCard(String name, String initial) {
    return GlassPanel(
      borderRadius: 24.0,
      padding: const EdgeInsets.all(28.0),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryFixedDim],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryFixedDim.withOpacity(0.35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Verified Player',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.black.withOpacity(0.06)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Matches', '32'),
              _buildMiniStat('Wins', '24'),
              _buildMiniStat('Points', '1,450'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard(String name, String email, String mobile) {
    return GlassPanel(
      borderRadius: 20.0,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.person_outline,
            title: 'Full Name',
            value: name,
          ),
          Divider(color: Colors.black.withOpacity(0.06), height: 1),
          _buildInfoTile(
            icon: Icons.email_outlined,
            title: 'Email Address',
            value: email,
          ),
          Divider(color: Colors.black.withOpacity(0.06), height: 1),
          _buildInfoTile(
            icon: Icons.phone_android_outlined,
            title: 'Mobile Number',
            value: mobile,
          ),
          if (user['id'] != null) ...[
            Divider(color: Colors.black.withOpacity(0.06), height: 1),
            _buildInfoTile(
              icon: Icons.badge_outlined,
              title: 'Player ID',
              value: '#${user['id']}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          'Log Out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.shade400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryFixedDim.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.onSurfaceVariant.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
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
