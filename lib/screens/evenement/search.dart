import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/events_provider.dart';
import '../widgets/filter_text_field.dart';
import '../widgets/time_filter_field.dart';
import '../widgets/type_filter_dropdown.dart';
import '../widgets/event_result_card.dart';
import 'detail_event_page.dart';

class SearchEventPage extends StatefulWidget {
  const SearchEventPage({Key? key}) : super(key: key);

  @override
  State<SearchEventPage> createState() => _SearchEventPageState();
}

class _SearchEventPageState extends State<SearchEventPage> {
  final _cityCtrl = TextEditingController();

  String? _selectedType; // ex: "sport"
  TimeOfDay? _selectedTime;

  List<Map<String, dynamic>> _results = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();

    // Charger les events
    Future.microtask(() async {
      await Provider.of<EventsProvider>(context, listen: false).fetchEvents();

      // Initialiser résultats dès que les données sont prêtes
      if (mounted) {
        final events =
            Provider.of<EventsProvider>(context, listen: false).events;
        _runSearch(events, markSearched: false);
      }
    });

    // ✅ Filtrage live sur la ville (au fur et à mesure de la saisie)
    _cityCtrl.addListener(() {
      final events = Provider.of<EventsProvider>(context, listen: false).events;
      _runSearch(events, markSearched: true);
    });
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    super.dispose();
  }

  String _norm(String v) => v.trim().toLowerCase();

  bool _matchTime(Map<String, dynamic> e) {
    if (_selectedTime == null) return true;

    final raw = (e["time_event"] ?? "").toString().trim(); // "21:00:00" ou "21:00"
    if (raw.isEmpty) return false;

    final parts = raw.split(":");
    if (parts.length < 2) return false;

    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return false;

    return h == _selectedTime!.hour && m == _selectedTime!.minute;
  }

  void _runSearch(List<Map<String, dynamic>> allEvents, {bool markSearched = true}) {
    final cityQuery = _norm(_cityCtrl.text);
    final typeQuery = _selectedType?.trim().toLowerCase();

    final filtered = allEvents.where((e) {
      final c = _norm((e["city"] ?? "").toString());
      final type = _norm((e["event_type"] ?? "").toString());

      final okCity = cityQuery.isEmpty || c.contains(cityQuery);
      final okType = typeQuery == null || typeQuery.isEmpty || type == typeQuery;
      final okTime = _matchTime(e);

      return okCity && okType && okTime;
    }).toList();

    setState(() {
      _results = filtered;
      _hasSearched = markSearched ? true : _hasSearched;
    });
  }

  void _resetFilters(List<Map<String, dynamic>> events) {
    setState(() {
      _selectedType = null;
      _selectedTime = null;
      _cityCtrl.clear();
      _results = events;
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventsProvider>(context);
    final events = provider.events;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Rechercher un événement",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox.shrink(),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(
        child: Text(
          provider.error!,
          style: const TextStyle(color: Colors.red),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Carte formulaire filtre ---
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TypeFilterDropdown(
                    events: events,
                    value: _selectedType,
                    onChanged: (v) {
                      setState(() => _selectedType = v);
                      _runSearch(events, markSearched: true);
                    },
                    label: "Type d'événement",
                  ),
                  const SizedBox(height: 12),

                  // ✅ Ville avec filtrage LIVE (via listener)
                  FilterTextField(
                    controller: _cityCtrl,
                    hintText: "Ville",
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),

                  TimeFilterField(
                    value: _selectedTime,
                    hintText: "Heure",
                    onChanged: (t) {
                      setState(() => _selectedTime = t);
                      _runSearch(events, markSearched: true);
                    },
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => _runSearch(events, markSearched: true),
                            icon: const Icon(Icons.manage_search_rounded),
                            label: const Text(
                              "Rechercher",
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6C63FF),
                            side: const BorderSide(color: Color(0xFF6C63FF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => _resetFilters(events),
                          child: const Text("Reset"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // --- Résultats ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                !_hasSearched ? "0 Résultat" : "${_results.length} Résultats",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFF6C63FF),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: (!_hasSearched && _cityCtrl.text.trim().isEmpty && _selectedType == null && _selectedTime == null)
                  ? _EmptySearch()
                  : _results.isEmpty
                  ? _EmptySearch()
                  : ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, i) {
                  final event = _results[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailEventPage(event: event),
                        ),
                      );
                    },
                    child: EventResultCard(event: event),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 56, color: Colors.black26),
          SizedBox(height: 12),
          Text(
            "Rechercher un événement",
            style: TextStyle(color: Colors.black45),
          ),
        ],
      ),
    );
  }
}