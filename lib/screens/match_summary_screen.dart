import 'package:flutter/material.dart';

import '../models/match.dart';

class MatchSummaryScreen extends StatelessWidget {
  final RugbyMatch match;

  const MatchSummaryScreen({super.key, required this.match});

  @override
  Widget build(BuildContext c) {
    final ht =
        match.events.where((e) => e.homeTeam && e.type == EventType.tryScore);
    final at =
        match.events.where((e) => !e.homeTeam && e.type == EventType.tryScore);

    return Scaffold(
      appBar: AppBar(title: const Text('Match summary')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'FULL TIME',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          Text(
            '${match.homeScore} - ${match.awayScore}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w900),
          ),
          Text(
            '${match.homeTeam}  v  ${match.awayTeam}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 25),
          tries(match.homeTeam, ht),
          const SizedBox(height: 12),
          tries(match.awayTeam, at),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'All events',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...match.events.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        '${e.minute}’ ${e.type.label} — ${e.player} '
                        '(${e.homeTeam ? match.homeTeam : match.awayTeam})',
                      ),
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

  Widget tries(String team, Iterable<MatchEvent> events) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$team try scorers',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...events.map(
                (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text('${e.minute}')),
                  title: Text(e.player),
                  subtitle: Text('${e.minute} minute'),
                ),
              ),
            ],
          ),
        ),
      );
}
