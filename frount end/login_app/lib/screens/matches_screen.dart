import 'package:flutter/material.dart';
import '../theme.dart';
import '../components.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  String _selectedSport = 'All';

  final List<Map<String, dynamic>> _matches = [
    {
      'sport': 'Football',
      'teamA': 'Falcons FC',
      'codeA': 'FC',
      'scoreA': '2',
      'teamB': 'Trojans SC',
      'codeB': 'TR',
      'scoreB': '1',
      'status': 'LIVE 64\'',
      'isLive': true,
      'tournament': 'Summer Cup 2026 - Quarter Finals',
      'venue': 'Pitch 2, Central Park',
    },
    {
      'sport': 'Cricket',
      'teamA': 'Chennai Strikers',
      'codeA': 'CS',
      'scoreA': '164/4',
      'teamB': 'Bangalore Blasters',
      'codeB': 'BB',
      'scoreB': '142/8',
      'status': 'LIVE 18.2 ov',
      'isLive': true,
      'tournament': 'T20 Premier League',
      'venue': 'Marina Stadium',
    },
    {
      'sport': 'Badminton',
      'teamA': 'Alex River',
      'codeA': 'AR',
      'scoreA': '21',
      'teamB': 'David Chen',
      'codeB': 'DC',
      'scoreB': '19',
      'status': 'Set 3 Live',
      'isLive': true,
      'tournament': 'State Open Singles',
      'venue': 'Court 4, Indoor Arena',
    },
    {
      'sport': 'Football',
      'teamA': 'Red Wings',
      'codeA': 'RW',
      'scoreA': '-',
      'teamB': 'Blue Sharks',
      'codeB': 'BS',
      'scoreB': '-',
      'status': 'Today, 6:00 PM',
      'isLive': false,
      'tournament': 'Metropolitan League',
      'venue': 'Main Stadium',
    },
    {
      'sport': 'Basketball',
      'teamA': 'Hawks',
      'codeA': 'HW',
      'scoreA': '-',
      'teamB': 'Vipers',
      'codeB': 'VP',
      'scoreB': '-',
      'status': 'Tomorrow, 4:30 PM',
      'isLive': false,
      'tournament': 'City Hoops Cup',
      'venue': 'Downtown Court',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredMatches = _selectedSport == 'All'
        ? _matches
        : _matches.where((m) => m['sport'] == _selectedSport).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Live & Upcoming Matches',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Track real-time scores and tournament fixtures',
                            style: TextStyle(
                              color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      if (isDesktop)
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Refresh Scores'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Football', 'Cricket', 'Badminton', 'Basketball']
                          .map((sport) => _buildFilterChip(sport, _selectedSport == sport))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Matches Grid/List
                  if (isDesktop)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.65,
                      ),
                      itemCount: filteredMatches.length,
                      itemBuilder: (context, index) => _buildMatchCard(filteredMatches[index]),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredMatches.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) => _buildMatchCard(filteredMatches[index]),
                    ),

                  const SizedBox(height: 90), // Bottom space for mobile nav
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
        setState(() => _selectedSport = label);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.white.withOpacity(0.8),
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 12)]
              : null,
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

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final bool isLive = match['isLive'] ?? false;

    return GlassPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  match['sport'] ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isLive ? AppTheme.primary : Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  match['status'] ?? '',
                  style: TextStyle(
                    color: isLive ? Colors.white : AppTheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Team A
              Expanded(
                child: Column(
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
                      child: Center(
                        child: Text(
                          match['codeA'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      match['teamA'],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Score / VS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  children: [
                    if (isLive)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            match['scoreA'],
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            child: Text('-', style: TextStyle(fontSize: 20, color: Colors.grey)),
                          ),
                          Text(
                            match['scoreB'],
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              // Team B
              Expanded(
                child: Column(
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
                      child: Center(
                        child: Text(
                          match['codeB'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      match['teamB'],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.black.withOpacity(0.06), height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match['tournament'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    Text(
                      match['venue'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isLive ? 'Watch >' : 'Details >',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
