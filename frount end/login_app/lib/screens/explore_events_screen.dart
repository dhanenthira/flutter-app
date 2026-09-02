import 'package:flutter/material.dart';
import '../theme.dart';
import '../components.dart';

class ExploreEventsScreen extends StatefulWidget {
  const ExploreEventsScreen({Key? key}) : super(key: key);

  @override
  State<ExploreEventsScreen> createState() => _ExploreEventsScreenState();
}

class _ExploreEventsScreenState extends State<ExploreEventsScreen> {
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _events = [
    {
      'title': 'Chennai Sports Championship 2026',
      'category': 'Multi-Sport',
      'dates': 'Aug 15 - Aug 20, 2026',
      'venue': 'Jawaharlal Nehru Stadium',
      'imageUrl': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'status': 'Registration Open',
      'teams': '32 Teams Registered',
    },
    {
      'title': 'All-India Badminton Masters',
      'category': 'Badminton',
      'dates': 'Sep 02 - Sep 06, 2026',
      'venue': 'National Sports Academy',
      'imageUrl': 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'status': 'Fast Filling',
      'teams': '16 Teams Registered',
    },
    {
      'title': 'State Premier Football League',
      'category': 'Football',
      'dates': 'Oct 10 - Nov 05, 2026',
      'venue': 'City Sports Complex',
      'imageUrl': 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'status': 'Registration Open',
      'teams': '24 Teams Registered',
    },
    {
      'title': 'Corporate Cricket League 2026',
      'category': 'Cricket',
      'dates': 'Nov 12 - Nov 18, 2026',
      'venue': 'Marina Cricket Ground',
      'imageUrl': 'https://images.unsplash.com/photo-1531415074968-036ba1b575da?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'status': 'Opening Soon',
      'teams': '12 Teams Registered',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _selectedCategory == 'All'
        ? _events
        : _events.where((e) => e['category'] == _selectedCategory).toList();

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
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Subtitle
                  const Text(
                    'Explore Events',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Find tournaments, championships, and athletic events near you.',
                    style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Search Bar & Filter Row
                  if (isDesktop)
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: GlassInput(
                            hintText: 'Search for events, sports, or teams...',
                            prefixIcon: Icons.search,
                            controller: TextEditingController(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.tune, color: AppTheme.primary),
                                SizedBox(width: 12),
                                Text('Filter by Location & Date', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    GlassInput(
                      hintText: 'Search for events, sports, or teams...',
                      prefixIcon: Icons.search,
                      controller: TextEditingController(),
                    ),

                  const SizedBox(height: 20),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Multi-Sport', 'Badminton', 'Cricket', 'Football', 'Basketball']
                          .map((cat) => _buildFilterChip(cat, _selectedCategory == cat))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 28),
                  const Text(
                    'Featured Tournaments',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                  ),
                  const SizedBox(height: 16),

                  // Responsive Event Cards Layout
                  if (isDesktop)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: 1.25,
                      ),
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) => _buildEventCard(filteredEvents[index]),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredEvents.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 20),
                      itemBuilder: (context, index) => _buildEventCard(filteredEvents[index]),
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

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = label);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppTheme.primary : Colors.white.withOpacity(0.8)),
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 12)] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              image: DecorationImage(
                image: NetworkImage(event['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        event['category'],
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, color: AppTheme.primary, size: 8),
                          const SizedBox(width: 6),
                          Text(
                            event['status'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: AppTheme.primary, size: 16),
                    const SizedBox(width: 6),
                    Text(event['dates'], style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppTheme.onSurfaceVariant, size: 16),
                    const SizedBox(width: 6),
                    Text(event['venue'], style: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.8), fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
