import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class NotificationsProvider extends ChangeNotifier {
  final String _baseUrl = AppConfig.apiUrl;

  static const _enabledKey = "notif_enabled";
  static const _lastCheckedKey = "notif_last_checked_iso";
  static const _cacheKey = "notif_cached_events_json";

  static const Duration _retentionDuration = Duration(days: 1);

  bool _enabled = false;
  bool get enabled => _enabled;

  int _badgeCount = 0;
  int get badgeCount => _badgeCount;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  List<Map<String, dynamic>> _newEvents = [];
  List<Map<String, dynamic>> get newEvents => _newEvents;

  DateTime _lastChecked = DateTime.fromMillisecondsSinceEpoch(0).toUtc();

  Timer? _timer;

  NotificationsProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    _enabled = prefs.getBool(_enabledKey) ?? false;

    final lastCheckedIso = prefs.getString(_lastCheckedKey);
    if (lastCheckedIso != null) {
      final parsed = DateTime.tryParse(lastCheckedIso);
      if (parsed != null) {
        _lastChecked = parsed.toUtc();
      }
    } else {
      _lastChecked = DateTime.now().toUtc();
      await prefs.setString(_lastCheckedKey, _lastChecked.toIso8601String());
    }

    await _loadCachedEvents();
    _pruneExpiredEvents();
    _recomputeBadge();

    notifyListeners();

    if (_enabled) {
      await refreshNewEvents();
    }

    _startOrStopPolling();
  }

  Future<void> _loadCachedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);

    if (raw == null || raw.trim().isEmpty) {
      _newEvents = [];
      return;
    }

    try {
      final List decoded = jsonDecode(raw);
      _newEvents = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      _newEvents = [];
    }
  }

  Future<void> _saveCachedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(_newEvents));
  }

  void _pruneExpiredEvents() {
    final now = DateTime.now().toUtc();

    _newEvents = _newEvents.where((event) {
      final detectedAtRaw = event["_detected_at"];
      if (detectedAtRaw == null) return false;

      final detectedAt = DateTime.tryParse(detectedAtRaw.toString())?.toUtc();
      if (detectedAt == null) return false;

      return now.difference(detectedAt) < _retentionDuration;
    }).toList();
  }

  void _recomputeBadge() {
    _badgeCount = _newEvents.where((e) => e["_seen"] != true).length;
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, _enabled);

    if (!_enabled) {
      _badgeCount = 0;
    } else {
      await refreshNewEvents();
    }

    notifyListeners();
    _startOrStopPolling();
  }

  void _startOrStopPolling() {
    _timer?.cancel();
    _timer = null;

    if (!_enabled) return;

    _timer = Timer.periodic(const Duration(seconds: 60), (_) async {
      await refreshNewEvents(silent: true);
    });
  }

  Future<void> refreshNewEvents({bool silent = false}) async {
    if (!_enabled) return;

    if (!silent) {
      _loading = true;
      _error = null;
      notifyListeners();
    }

    try {
      _pruneExpiredEvents();

      final uri = Uri.parse("$_baseUrl/api/events/updates").replace(
        queryParameters: {
          "since": _lastChecked.toIso8601String(),
          "limit": "50",
        },
      );

      final resp = await http.get(uri);

      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);

        final fetched = data.map((e) => Map<String, dynamic>.from(e)).toList();

        final nowIso = DateTime.now().toUtc().toIso8601String();

        for (final ev in fetched) {
          final img = ev["image_url"]?.toString() ?? "";
          if (img.isNotEmpty && !img.startsWith("http")) {
            ev["image_url"] = "$_baseUrl$img";
          }

          ev["_seen"] = false;
          ev["_detected_at"] = nowIso;
        }

        final Map<String, Map<String, dynamic>> mergedById = {
          for (final e in _newEvents)
            (e["id"]?.toString() ?? UniqueKey().toString()): e,
        };

        for (final e in fetched) {
          final id = e["id"]?.toString();
          if (id == null || id.isEmpty) continue;

          if (!mergedById.containsKey(id)) {
            mergedById[id] = e;
          }
        }

        _newEvents = mergedById.values.toList();

        _newEvents.sort((a, b) {
          final aDetected =
              DateTime.tryParse((a["_detected_at"] ?? "").toString()) ??
                  DateTime.fromMillisecondsSinceEpoch(0);
          final bDetected =
              DateTime.tryParse((b["_detected_at"] ?? "").toString()) ??
                  DateTime.fromMillisecondsSinceEpoch(0);
          return bDetected.compareTo(aDetected);
        });

        _lastChecked = DateTime.now().toUtc();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastCheckedKey, _lastChecked.toIso8601String());

        _pruneExpiredEvents();
        _recomputeBadge();
        await _saveCachedEvents();
      } else {
        _error = "Erreur serveur : ${resp.statusCode}";
      }
    } catch (e) {
      _error = "Erreur réseau : $e";
    } finally {
      if (!silent) _loading = false;
      notifyListeners();
    }
  }

  /// Marque les notifications affichées comme vues,
  /// sans les supprimer de la liste.
  Future<void> markAllAsSeen() async {
    bool changed = false;

    for (final event in _newEvents) {
      if (event["_seen"] != true) {
        event["_seen"] = true;
        changed = true;
      }
    }

    _recomputeBadge();

    if (changed) {
      await _saveCachedEvents();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}