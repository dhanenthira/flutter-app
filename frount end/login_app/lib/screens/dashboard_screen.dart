import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme.dart';
import '../components.dart';
import 'login_screen.dart';
import 'explore_events_screen.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarOpenOnDesktop = false;

  final List<String> _pageTitles = [
    'Dashboard',
    'Explore Events',
    'Live & Matches',
    'My Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildHomeContent(),
      const ExploreEventsScreen(),
      const MatchesScreen(),
      ProfileScreen(user: widget.user),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppTheme.background,
          drawer: _buildAppDrawer(isDesktop),
          body: Stack(
            children: [
              // Ambient Glowing Background
              Positioned(
                top: MediaQuery.of(context).size.height * 0.1,
                left: MediaQuery.of(context).size.width * 0.1,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryFixedDim.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                ).blurred(120),
              ),
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.2,
                right: MediaQuery.of(context).size.width * 0.1,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryFixed.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ).blurred(120),
              ),

              // Main Layout Area
              SafeArea(
                child: Column(
                  children: [
                    // Desktop Top Navigation Header
                    if (isDesktop) _buildDesktopHeader(),

                    // Page Body
                    Expanded(
                      child: Row(
                        children: [
                          // Persistent Collapsible Sidebar for Desktop if toggled
                          if (isDesktop && _isSidebarOpenOnDesktop)
                            _buildDesktopSidebar(),

                          // Main content area
                          Expanded(
                            child: IndexedStack(
                              index: _currentIndex,
                              children: _pages,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Mobile Bottom Navigation Bar (Visible only on mobile/tablet)
              if (!isDesktop)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 20, top: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.75),
                          border: Border(
                            top: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMobileNavItem(Icons.home_rounded, 'Home', 0),
                            _buildMobileNavItem(Icons.emoji_events_rounded, 'Events', 1),
                            _buildMobileNavItem(Icons.sports_soccer_rounded, 'Matches', 2),
                            _buildMobileNavItem(Icons.person_rounded, 'Profile', 3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Desktop Top Header with 3 lines hamburger menu button
  Widget _buildDesktopHeader() {
    final String name = widget.user['name'] ?? 'User';
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          // 3 Lines / Hamburger menu button (left side)
          InkWell(
            onTap: () {
              setState(() {
                _isSidebarOpenOnDesktop = !_isSidebarOpenOnDesktop;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.menu_rounded, // 3 lines icon
                color: AppTheme.primary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // App Logo and Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sports_soccer, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'SportsHub',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 32),

          // Current Page Title indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryFixedDim.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _pageTitles[_currentIndex],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ),

          const Spacer(),

          // Location badge
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppTheme.primary),
              const SizedBox(width: 4),
              const Text(
                'New York, NY',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Notification button
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white),
            ),
            child: const Icon(Icons.notifications_outlined, size: 20, color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(width: 16),

          // User Profile Pill Button
          InkWell(
            onTap: () {
              setState(() => _currentIndex = 3);
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryFixedDim],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
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

  // Desktop Collapsible Sidebar
  Widget _buildDesktopSidebar() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildSidebarNavItem(Icons.home_rounded, 'Home', 0),
          _buildSidebarNavItem(Icons.emoji_events_rounded, 'Events', 1),
          _buildSidebarNavItem(Icons.sports_soccer_rounded, 'Matches', 2),
          _buildSidebarNavItem(Icons.person_rounded, 'Profile', 3),
          const Spacer(),
          Divider(color: Colors.black.withOpacity(0.06), indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          setState(() => _currentIndex = index);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: isSelected
              ? BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
              : null,
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // App Drawer (Usable across screen sizes)
  Widget _buildAppDrawer(bool isDesktop) {
    final String name = widget.user['name'] ?? 'User';
    final String email = widget.user['email'] ?? '';
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: Colors.white.withOpacity(0.85),
            child: Column(
              children: [
                // Drawer Header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.15),
                        Colors.white.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.black.withOpacity(0.06)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryFixedDim],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.onSurfaceVariant.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Navigation Items
                _buildDrawerItem(Icons.home_rounded, 'Home', 0),
                _buildDrawerItem(Icons.emoji_events_rounded, 'Events', 1),
                _buildDrawerItem(Icons.sports_soccer_rounded, 'Matches', 2),
                _buildDrawerItem(Icons.person_rounded, 'Profile', 3),

                const Spacer(),

                // Logout button
                Divider(color: Colors.black.withOpacity(0.06)),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final bool isSelected = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: isSelected ? AppTheme.primary.withOpacity(0.15) : Colors.transparent,
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.primary : AppTheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: () {
          setState(() => _currentIndex = index);
          Navigator.pop(context); // Close drawer
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 800;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32.0 : 20.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mobile Header (Shown on mobile only)
                        if (!isDesktop) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: AppTheme.onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      const Text('New York, NY', style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Good Morning, ${widget.user['name']}!',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                                    ),
                                    child: const Icon(Icons.notifications, color: AppTheme.onSurfaceVariant, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => _currentIndex = 3);
                                    },
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [AppTheme.primary, AppTheme.primaryFixedDim],
                                        ),
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          (widget.user['name'] != null && widget.user['name'].toString().isNotEmpty)
                                              ? widget.user['name'][0].toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Desktop Greeting Banner
                        if (isDesktop) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back, ${widget.user['name']}! 👋',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Track your games, join championships, and view live results.',
                                    style: TextStyle(
                                      color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() => _currentIndex = 1);
                                },
                                icon: const Icon(Icons.search, size: 18),
                                label: const Text('Explore Events'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Layout: Responsive Multi-column for Desktop vs Vertical for Mobile
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Column: Hero Tournament Card + Quick stats
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeroCard(),
                                    const SizedBox(height: 24),
                                    _buildQuickStatsSection(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              // Right Column: Action Now / Live Match Card + Upcoming preview
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Action Now', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                                    const SizedBox(height: 16),
                                    _buildLiveMatchCard(),
                                    const SizedBox(height: 24),
                                    _buildTrendingSportsCard(),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeroCard(),
                              const SizedBox(height: 24),
                              const Text('Action Now', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                              const SizedBox(height: 16),
                              _buildLiveMatchCard(),
                              const SizedBox(height: 24),
                              _buildQuickStatsSection(),
                            ],
                          ),

                        const SizedBox(height: 90), // Bottom padding for navigation
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeroCard() {
    return GlassPanel(
      padding: const EdgeInsets.all(28),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, color: AppTheme.primary, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'FEATURED TOURNAMENT',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Find Your Next Tournament',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Compete. Connect. Win. Join the most prestigious amateur and professional leagues in your area.',
            style: TextStyle(
              color: AppTheme.onSurfaceVariant,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() => _currentIndex = 1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 4,
                ),
                child: const Text('Explore Tournaments', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() => _currentIndex = 2);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Live Matches', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMatchCard() {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(child: Text('FC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  ),
                  const SizedBox(height: 8),
                  const Text('Falcons', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Text('LIVE 64\'', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Text('2', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('-', style: TextStyle(fontSize: 22, color: Colors.grey))),
                      Text('1', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(child: Text('TR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  ),
                  const SizedBox(height: 8),
                  const Text('Trojans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Summer Cup 2026 - Quarter Finals', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          const Text('Pitch 2, Central Park', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() => _currentIndex = 2);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                backgroundColor: Colors.white.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Watch Live Stream', style: TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Tournaments', '12', Icons.emoji_events, Colors.orange),
          _buildStatItem('Matches Won', '28', Icons.sports_score, Colors.green),
          _buildStatItem('MVP Awards', '4', Icons.military_tech, Colors.purple),
          _buildStatItem('Rank', '#3', Icons.leaderboard, AppTheme.primary),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.onSurfaceVariant.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingSportsCard() {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trending Sports',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSportChip('⚽ Football', '34 Events'),
              _buildSportChip('🏏 Cricket', '28 Events'),
              _buildSportChip('🏸 Badminton', '19 Events'),
              _buildSportChip('🏀 Basketball', '12 Events'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSportChip(String sport, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(sport, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(width: 6),
          Text(count, style: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.6), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMobileNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 15),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
