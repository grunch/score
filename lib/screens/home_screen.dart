import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/match_provider.dart';
import '../models/match.dart';
import '../widgets/create_match_dialog.dart';
import 'match_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('BJJ Score'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<MatchProvider>(
        builder: (context, matchProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (matchProvider.inProgressMatches.isNotEmpty) ...[
                  _buildSectionTitle('In Progress'),
                  const SizedBox(height: 8),
                  ...matchProvider.inProgressMatches.map(
                    (match) => _buildMatchCard(context, match, Colors.green),
                  ),
                  const SizedBox(height: 24),
                ],
                if (matchProvider.waitingMatches.isNotEmpty) ...[
                  _buildSectionTitle('Waiting to Start'),
                  const SizedBox(height: 8),
                  ...matchProvider.waitingMatches.map(
                    (match) => _buildMatchCard(context, match, Colors.orange),
                  ),
                  const SizedBox(height: 24),
                ],
                if (matchProvider.finishedMatches.isNotEmpty) ...[
                  _buildSectionTitle('Finished'),
                  const SizedBox(height: 8),
                  ...matchProvider.finishedMatches.map(
                    (match) => _buildMatchCard(context, match, Colors.grey),
                  ),
                  const SizedBox(height: 24),
                ],
                if (matchProvider.matches.isEmpty)
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_martial_arts,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No matches yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to create a match',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateMatchDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, Match match, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () => _navigateToMatch(context, match),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(match.f1Color.replaceFirst('#', '0xFF')),
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              match.f1Name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            '${match.f1TotalScore}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(match.f2Color.replaceFirst('#', '0xFF')),
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              match.f2Name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            '${match.f2TotalScore}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(
                      match.id.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${match.duration ~/ 60}:${(match.duration % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateMatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateMatchDialog(),
    );
  }

  void _navigateToMatch(BuildContext context, Match match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchScreen(match: match),
      ),
    );
  }
}