import 'dart:async';

import 'package:flutter/material.dart';

import '../models/match.dart';
import '../services/storage_service.dart';
import '../widgets/score_button.dart';
import 'match_summary_screen.dart';

class MatchScreen extends StatefulWidget {
  final StorageService storage;
  final RugbyMatch match;

  const MatchScreen({super.key, required this.storage, required this.match});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late RugbyMatch match;
  Timer? timer;
  int seconds = 0;
  bool running = false;

  @override
  void initState() {
    super.initState();
    match = widget.match;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String get clock =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  int get minute => (seconds ~/ 60) + 1;

  void toggle() {
    if (running) {
      timer?.cancel();
      setState(() => running = false);
    } else {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => seconds++);
      });
      setState(() => running = true);
    }
  }

  Future<bool?> team(EventType t) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('${t.label} - team'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(match.homeTeam),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(match.awayTeam),
                ),
              ),
            ],
          ),
        ),
      );

  Future<void> add(EventType t) async {
    final home = await team(t);
    if (!mounted || home == null) return;

    String player = '';
    if (t == EventType.tryScore ||
        t == EventType.conversion ||
        t == EventType.penalty ||
        t == EventType.dropGoal ||
        t == EventType.yellowCard ||
        t == EventType.redCard) {
      final ctl = TextEditingController();
      final r = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('${t.label} player'),
          content: TextField(
            controller: ctl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Player name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, ctl.text.trim()),
              child: const Text('Add'),
            ),
          ],
        ),
      );
      ctl.dispose();
      if (!mounted || r == null) return;
      player = r;
    }

    final e = MatchEvent(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: t,
      homeTeam: home,
      minute: minute,
      player: player,
    );
    setState(() => match = match.copyWith(events: [...match.events, e]));
    await widget.storage.saveMatch(match);
  }

  Future<void> finish() async {
    timer?.cancel();
    running = false;
    match = match.copyWith(finished: true);
    await widget.storage.saveMatch(match);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MatchSummaryScreen(match: match)),
      ).then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> undo() async {
    if (match.events.isEmpty) return;
    final x = [...match.events]..removeLast();
    setState(() => match = match.copyWith(events: x));
    await widget.storage.saveMatch(match);
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(
          title: const Text('Match control'),
          actions: [
            IconButton(
              onPressed: match.events.isEmpty ? null : undo,
              icon: const Icon(Icons.undo),
            ),
            IconButton(
              onPressed: finish,
              icon: const Icon(Icons.check_circle_outline),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: teamScore(match.homeTeam, match.homeScore)),
                    const Text(
                      '-',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Expanded(child: teamScore(match.awayTeam, match.awayScore)),
                  ],
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: Text(
                  clock,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: const Text('MATCH CLOCK'),
                trailing: IconButton.filled(
                  onPressed: toggle,
                  icon: Icon(running ? Icons.pause : Icons.play_arrow),
                ),
              ),
            ),
            const Text(
              'Scoring',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.35,
              children: [
                ScoreButton(
                  title: 'Try',
                  points: '+5',
                  icon: Icons.sports_rugby,
                  onPressed: () => add(EventType.tryScore),
                ),
                ScoreButton(
                  title: 'Conversion',
                  points: '+2',
                  icon: Icons.adjust,
                  onPressed: () => add(EventType.conversion),
                ),
                ScoreButton(
                  title: 'Penalty',
                  points: '+3',
                  icon: Icons.gavel,
                  onPressed: () => add(EventType.penalty),
                ),
                ScoreButton(
                  title: 'Drop goal',
                  points: '+3',
                  icon: Icons.sports_rugby,
                  onPressed: () => add(EventType.dropGoal),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => add(EventType.yellowCard),
                    child: const Text('🟨 Yellow card'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => add(EventType.redCard),
                    child: const Text('🟥 Red card'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Timeline',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...match.events.reversed.map(
              (e) => Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${e.minute}')),
                  title: Text('${e.type.label} — ${e.player}'),
                  subtitle: Text(e.homeTeam ? match.homeTeam : match.awayTeam),
                  trailing: e.type.points > 0
                      ? Text(
                          '+${e.type.points}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      );

  Widget teamScore(String n, int s) => Column(
        children: [
          Text(
            n,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '$s',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
          ),
        ],
      );
}
