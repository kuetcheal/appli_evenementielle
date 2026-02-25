import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class NotificationsProvider extends ChangeNotifier {
  final String _baseUrl = AppConfig.apiUrl;

  static const _enabledKey = "notif_enabled";
  static const _lastSeenKey = "notif_last_seen_iso";

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

  DateTime _lastSeen = DateTime.fromMillisecondsSinceEpoch(0);

  Timer? _timer;

  NotificationsProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    _enabled = prefs.getBool(_enabledKey) ?? false;

    final lastSeenIso = prefs.getString(_lastSeenKey);
    if (lastSeenIso != null) {
      final parsed = DateTime.tryParse(lastSeenIso);
      if (parsed != null) _lastSeen = parsed.toUtc();
    } else {
      _lastSeen = DateTime.now().toUtc();
      await prefs.setString(_lastSeenKey, _lastSeen.toIso8601String());
    }

    notifyListeners();

    // Premier check badge
    await refreshNewEvents();

    // Optionnel : polling léger si activé
    _startOrStopPolling();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, _enabled);

    notifyListeners();
    _startOrStopPolling();

    // Si on active, on refresh direct
    if (_enabled) {
      await refreshNewEvents();
    } else {
      // si désactivé, badge = 0
      _badgeCount = 0;
      _newEvents = [];
      notifyListeners();
    }
  }

  void _startOrStopPolling() {
    _timer?.cancel();
    _timer = null;

    if (!_enabled) return;

    // Toutes les 60 secondes (tu peux mettre 30s ou 2min)
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
      final uri = Uri.parse("$_baseUrl/api/events/updates").replace(
        queryParameters: {
          "since": _lastSeen.toIso8601String(),
          "limit": "50",
        },
      );

      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);

        _newEvents = data.map((e) => Map<String, dynamic>.from(e)).toList();

        // image_url relative -> absolue
        for (final ev in _newEvents) {
          final img = ev["image_url"]?.toString() ?? "";
          if (img.isNotEmpty && !img.startsWith("http")) {
            ev["image_url"] = "$_baseUrl$img";
          }
        }

        _badgeCount = _newEvents.length;
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

  /// Quand l’utilisateur ouvre la page Notifications et “consulte”
  Future<void> markAllAsSeen() async {
    final now = DateTime.now().toUtc();
    _lastSeen = now;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSeenKey, _lastSeen.toIso8601String());

    _badgeCount = 0;
    _newEvents = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}