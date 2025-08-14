import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match.dart';

class MatchProvider extends ChangeNotifier {
  final List<Match> _matches = [];
  Match? _currentMatch;
  Timer? _timer;
  int _remainingTime = 0;
  bool _isRunning = false;

  List<Match> get matches => _matches;
  Match? get currentMatch => _currentMatch;
  int get remainingTime => _remainingTime;
  bool get isRunning => _isRunning;

  List<Match> get waitingMatches =>
      _matches.where((m) => m.status == MatchStatus.waiting).toList();
  List<Match> get inProgressMatches =>
      _matches.where((m) => m.status == MatchStatus.inProgress).toList();
  List<Match> get finishedMatches =>
      _matches.where((m) => m.status == MatchStatus.finished).toList();

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> loadMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final matchesJson = prefs.getStringList('matches') ?? [];
    
    _matches.clear();
    for (final matchJson in matchesJson) {
      try {
        final match = Match.fromJson(json.decode(matchJson));
        _matches.add(match);
      } catch (e) {
        debugPrint('Error loading match: $e');
      }
    }
    notifyListeners();
  }

  Future<void> saveMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final matchesJson = _matches.map((m) => json.encode(m.toJson())).toList();
    await prefs.setStringList('matches', matchesJson);
  }

  String _generateUniqueId() {
    String id;
    do {
      id = Match.generateId();
    } while (_matches.any((m) => m.id == id));
    return id;
  }

  void createMatch({
    required String f1Name,
    required String f2Name,
    int duration = 300,
    String f1Color = '#0066cc',
    String f2Color = '#cc0000',
  }) {
    final match = Match(
      id: _generateUniqueId(),
      startAt: DateTime.now().millisecondsSinceEpoch,
      duration: duration,
      f1Name: f1Name,
      f2Name: f2Name,
      f1Color: f1Color,
      f2Color: f2Color,
    );

    _matches.add(match);
    saveMatches();
    notifyListeners();
  }

  void setCurrentMatch(Match match) {
    _currentMatch = match;
    _remainingTime = match.duration;
    notifyListeners();
  }

  void startMatch() {
    if (_currentMatch == null) return;
    
    _currentMatch!.startMatch();
    _isRunning = true;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        notifyListeners();
      } else {
        _finishMatch();
      }
    });
    
    saveMatches();
    notifyListeners();
  }

  void pauseMatch() {
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void resumeMatch() {
    if (_currentMatch == null || _remainingTime <= 0) return;
    
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        notifyListeners();
      } else {
        _finishMatch();
      }
    });
    
    notifyListeners();
  }

  void _finishMatch() {
    _isRunning = false;
    _timer?.cancel();
    _currentMatch?.finishMatch();
    saveMatches();
    notifyListeners();
  }

  void finishMatch() {
    _finishMatch();
  }

  void cancelMatch() {
    _isRunning = false;
    _timer?.cancel();
    _currentMatch?.cancelMatch();
    saveMatches();
    notifyListeners();
  }

  void addPoints(int fighter, int points) {
    _currentMatch?.addPoints(fighter, points);
    saveMatches();
    notifyListeners();
  }

  void removePoints(int fighter, int points) {
    _currentMatch?.removePoints(fighter, points);
    saveMatches();
    notifyListeners();
  }

  void addAdvantage(int fighter) {
    _currentMatch?.addAdvantage(fighter);
    saveMatches();
    notifyListeners();
  }

  void removeAdvantage(int fighter) {
    _currentMatch?.removeAdvantage(fighter);
    saveMatches();
    notifyListeners();
  }

  void addPenalty(int fighter) {
    _currentMatch?.addPenalty(fighter);
    saveMatches();
    notifyListeners();
  }

  void removePenalty(int fighter) {
    _currentMatch?.removePenalty(fighter);
    saveMatches();
    notifyListeners();
  }

  void deleteMatch(String id) {
    _matches.removeWhere((m) => m.id == id);
    if (_currentMatch?.id == id) {
      _currentMatch = null;
      _timer?.cancel();
      _isRunning = false;
    }
    saveMatches();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}