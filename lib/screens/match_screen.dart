import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/match_provider.dart';
import '../models/match.dart';

class MatchScreen extends StatefulWidget {
  final Match match;

  const MatchScreen({super.key, required this.match});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MatchProvider>(context, listen: false)
          .setCurrentMatch(widget.match);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Match ${widget.match.id.toUpperCase()}'),
        actions: [
          Consumer<MatchProvider>(
            builder: (context, matchProvider, child) {
              if (matchProvider.currentMatch?.status == MatchStatus.inProgress) {
                return IconButton(
                  onPressed: () => _showFinishDialog(context),
                  icon: const Icon(Icons.stop),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<MatchProvider>(
        builder: (context, matchProvider, child) {
          final match = matchProvider.currentMatch ?? widget.match;
          
          return Column(
            children: [
              // Timer and controls section
              Container(
                color: Colors.black,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      matchProvider.formatTime(matchProvider.remainingTime),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (match.status == MatchStatus.waiting) ...[
                          ElevatedButton.icon(
                            onPressed: matchProvider.startMatch,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Match'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ] else if (match.status == MatchStatus.inProgress) ...[
                          if (matchProvider.isRunning) ...[
                            ElevatedButton.icon(
                              onPressed: matchProvider.pauseMatch,
                              icon: const Icon(Icons.pause),
                              label: const Text('Pause'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ] else ...[
                            ElevatedButton.icon(
                              onPressed: matchProvider.resumeMatch,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Resume'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ] else if (match.status == MatchStatus.finished) ...[
                          const Text(
                            'Match Finished',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Scoring section
              Expanded(
                child: Container(
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      // Fighter 1
                      Expanded(
                        child: _buildFighterSection(
                          context,
                          matchProvider,
                          fighter: 1,
                          name: match.f1Name,
                          color: match.f1Color,
                          totalScore: match.f1TotalScore,
                          pt2: match.f1Pt2,
                          pt3: match.f1Pt3,
                          pt4: match.f1Pt4,
                          advantages: match.f1Adv,
                          penalties: match.f1Pen,
                        ),
                      ),
                      // Divider
                      Container(
                        width: 2,
                        color: Colors.grey[300],
                      ),
                      // Fighter 2
                      Expanded(
                        child: _buildFighterSection(
                          context,
                          matchProvider,
                          fighter: 2,
                          name: match.f2Name,
                          color: match.f2Color,
                          totalScore: match.f2TotalScore,
                          pt2: match.f2Pt2,
                          pt3: match.f2Pt3,
                          pt4: match.f2Pt4,
                          advantages: match.f2Adv,
                          penalties: match.f2Pen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFighterSection(
    BuildContext context,
    MatchProvider matchProvider, {
    required int fighter,
    required String name,
    required String color,
    required int totalScore,
    required int pt2,
    required int pt3,
    required int pt4,
    required int advantages,
    required int penalties,
  }) {
    final isMatchActive = matchProvider.currentMatch?.status == MatchStatus.inProgress;
    
    return Container(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Fighter name and color
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(color),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$totalScore',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Points section
            const Text(
              'Points',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            
            // 2 Points
            _buildScoreControl(
              context,
              matchProvider,
              label: '2 Points',
              value: pt2,
              isActive: isMatchActive,
              onAdd: () => matchProvider.addPoints(fighter, 2),
              onRemove: () => matchProvider.removePoints(fighter, 2),
            ),
            
            // 3 Points
            _buildScoreControl(
              context,
              matchProvider,
              label: '3 Points',
              value: pt3,
              isActive: isMatchActive,
              onAdd: () => matchProvider.addPoints(fighter, 3),
              onRemove: () => matchProvider.removePoints(fighter, 3),
            ),
            
            // 4 Points
            _buildScoreControl(
              context,
              matchProvider,
              label: '4 Points',
              value: pt4,
              isActive: isMatchActive,
              onAdd: () => matchProvider.addPoints(fighter, 4),
              onRemove: () => matchProvider.removePoints(fighter, 4),
            ),
            
            const SizedBox(height: 12),
            
            // Advantages
            const Text(
              'Advantages',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            _buildScoreControl(
              context,
              matchProvider,
              label: 'Advantages',
              value: advantages,
              isActive: isMatchActive,
              onAdd: () => matchProvider.addAdvantage(fighter),
              onRemove: () => matchProvider.removeAdvantage(fighter),
            ),
            
            const SizedBox(height: 12),
            
            // Penalties
            const Text(
              'Penalties',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            _buildScoreControl(
              context,
              matchProvider,
              label: 'Penalties',
              value: penalties,
              isActive: isMatchActive,
              onAdd: () => matchProvider.addPenalty(fighter),
              onRemove: () => matchProvider.removePenalty(fighter),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreControl(
    BuildContext context,
    MatchProvider matchProvider, {
    required String label,
    required int value,
    required bool isActive,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Remove button
          SizedBox(
            width: 36,
            height: 36,
            child: ElevatedButton(
              onPressed: isActive && value > 0 ? onRemove : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Icon(Icons.remove, size: 18),
            ),
          ),
          
          // Value display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Add button
          SizedBox(
            width: 36,
            height: 36,
            child: ElevatedButton(
              onPressed: isActive ? onAdd : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Icon(Icons.add, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTextColor(String hexColor) {
    final color = Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  void _showFinishDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Match'),
        content: const Text('Are you sure you want to finish this match?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<MatchProvider>(context, listen: false).finishMatch();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}