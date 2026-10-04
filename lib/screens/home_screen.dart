import 'package:flutter/material.dart';
import '../models/match.dart';
import '../services/storage_service.dart';
import 'match_setup_screen.dart';
import 'match_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storage;

  const HomeScreen({super.key, required this.storage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RugbyMatch> matches = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final x = await widget.storage.loadMatches();
    if (mounted) setState(() => matches = x);
  }

  Future<void> newMatch() async {
    final m = await Navigator.push<RugbyMatch>(
      context,
      MaterialPageRoute(builder: (_) => const MatchSetupScreen()),
    );
    if (m == null) return;
    await widget.storage.saveMatch(m);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchScreen(storage: widget.storage, match: m),
      ),
    );
    load();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.sports_rugby, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Rugby Scorekeeper',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 20),
            const Text(
              'Rugby Scorekeeper',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            if (matches.isEmpty)
              Center(
                child: FilledButton.icon(
                  onPressed: newMatch,
                  icon: const Icon(Icons.add),
                  label: const Text('Create first match'),
                ),
              )
            else ...[
              const Text(
                'Saved matches',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...matches.map(
                (m) => Card(
                  child: ListTile(
                    title: Text(
                      '${m.homeTeam} ${m.homeScore} - ${m.awayScore} '
                      '${m.awayTeam}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${m.finished ? 'Finished' : 'In progress'}\n'
                      'Saved ${MaterialLocalizations.of(c).formatMediumDate(m.createdAt)}',
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MatchScreen(
                          storage: widget.storage,
                          match: m,
                        ),
                      ),
                    ).then((_) {
                      load();
                    }),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'delete') {
                          await widget.storage.deleteMatch(m.id);
                          load();
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: newMatch,
          icon: const Icon(Icons.add),
          label: const Text('New match'),
        ),
      );
}
