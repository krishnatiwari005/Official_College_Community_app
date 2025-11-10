import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Providers (Unchanged) ---

final placementsDataProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {
      'name': 'Anshuman Nandan',
      'branch': 'Computer Science',
      'company': 'Google',
      'package': '₹30 LPA',
      'image': 'assets/1.png',
    },
    {
      'name': 'Archas Srivastava',
      'branch': 'Information Technology',
      'company': 'Goldman Sachs',
      'package': '₹21 LPA',
      'image': 'assets/2.png',
    },
    {
      'name': 'Soumya Maheshwari',
      'branch': 'Computer Science',
      'company': 'Google',
      'package': '₹13.2 LPA',
      'image': 'assets/3.png',
    },
    {
      'name': 'Garima Gautam',
      'branch': 'Electronics',
      'company': 'Amazon',
      'package': '₹13.2 LPA',
      'image': 'assets/4.png',
    },
    {
      'name': 'SAKSHAM TIWARI',
      'branch': 'Computer Science',
      'company': 'Meta',
      'package': '₹42.75 LPA',
      'image': 'assets/5.png',
    },
    {
      'name': 'SAUMYA CHAUDHARY',
      'branch': 'Information Technology',
      'company': 'Uber',
      'package': '₹38.44 LPA',
      'image': 'assets/6.png',
    },
    {
      'name': 'SUYASH SINGH',
      'branch': 'Computer Science',
      'company': 'Netflix',
      'package': '₹34 LPA',
      'image': 'assets/7.png',
    },
  ];
});

final barChartDataProvider = Provider<List<BarChartGroupData>>((ref) {
  return [
    BarChartGroupData(
      x: 0,
      barRods: [BarChartRodData(toY: 85, color: Colors.blueAccent, width: 18)],
    ),
    BarChartGroupData(
      x: 1,
      barRods: [BarChartRodData(toY: 78, color: Colors.greenAccent, width: 18)],
    ),
    BarChartGroupData(
      x: 2,
      barRods: [
        BarChartRodData(toY: 72, color: Colors.orangeAccent, width: 18),
      ],
    ),
    BarChartGroupData(
      x: 3,
      barRods: [BarChartRodData(toY: 65, color: Colors.redAccent, width: 18)],
    ),
    BarChartGroupData(
      x: 4,
      barRods: [
        BarChartRodData(toY: 58, color: Colors.purpleAccent, width: 18),
      ],
    ),
  ];
});

final lineChartDataProvider = Provider<List<FlSpot>>((ref) {
  return const [
    FlSpot(0, 20),
    FlSpot(1, 35),
    FlSpot(2, 50),
    FlSpot(3, 65),
    FlSpot(4, 75),
    FlSpot(5, 85),
  ];
});

// --- UI Implementation ---

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placements = ref.watch(placementsDataProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Placement Leaderboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff4A148C), Color(0xff6A1B9A), Color(0xff8E24AA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff3E1E68),
                  Color(0xff2B1055),
                  Color(0xff120A2A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGraphCard(
                title: 'Placement Statistics 2024',
                graph: _buildBarChart(ref),
              ),
            ),
          ),

          // Foreground Content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _glassCard(
                  title: 'Placement Statistics 2024',
                  child: SizedBox(height: 200, child: _buildBarChart(ref)),
                ),
                const SizedBox(height: 22),
                _glassCard(
                  title: 'Branch-wise Placements',
                  child: SizedBox(height: 200, child: _buildLineChart(ref)),
                ),
                const SizedBox(height: 30),

                const Text(
                  'Top Placements',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
              _buildGraphCard(
                title: 'Branch-wise Placements',
                graph: _buildLineChart(ref),
              ),
              const SizedBox(height: 24),

              const Text(
                'Top Placements',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: placements.length,
                    itemBuilder: (context, index) {
                      return _placementCard(index + 1, placements[index]);
                    },
                  ),
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: placements.length,
                  itemBuilder: (context, index) {
                    return _buildPlacementCard(index + 1, placements[index]);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Reusable Glass Card Container ---
  Widget _glassCard({required String title, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(2, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }

  // --- Charts ---
  Widget _buildBarChart(WidgetRef ref) {
    final barGroups = ref.watch(barChartDataProvider);
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        gridData: const FlGridData(show: true, drawHorizontalLine: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = ['CS', 'IT', 'ECE', 'ME', 'CE'];
                return Text(
                  titles[value.toInt()],
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildLineChart(WidgetRef ref) {
    final spots = ref.watch(lineChartDataProvider);
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                return Text(
                  labels[value.toInt()],
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, m) => Text(
                v.toInt().toString(),
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
              reservedSize: 40,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.cyanAccent,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.cyanAccent.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  // --- Placement Card ---
  Widget _placementCard(int rank, Map<String, String> data) {
    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white24,
                          backgroundImage: AssetImage(data['image']!),
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          data['image']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.primaries[rank %
                                        Colors.primaries.length],
                                    Colors.primaries[(rank + 3) %
                                        Colors.primaries.length],
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['branch']!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            data['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.business,
                          color: Colors.cyanAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.business, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          data['company']!,
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade50, Colors.green.shade100],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.currency_rupee,
                          color: Colors.greenAccent,
                          size: 18,
                        ),
                        Text(
                          data['package']!,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getRankColor(rank),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _getRankColor(rank).withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amberAccent.shade700;
    if (rank == 2) return Colors.grey.shade400;
    if (rank == 3) return Colors.brown.shade400;
    return Colors.blueAccent;
  }
}
