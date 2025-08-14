import 'dart:math';

enum MatchStatus { waiting, inProgress, finished, canceled, expired }

class Match {
  final String id;
  MatchStatus status;
  final int startAt;
  final int duration;
  final String f1Name;
  final String f2Name;
  final String f1Color;
  final String f2Color;
  int f1Pt2;
  int f2Pt2;
  int f1Pt3;
  int f2Pt3;
  int f1Pt4;
  int f2Pt4;
  int f1Adv;
  int f2Adv;
  int f1Pen;
  int f2Pen;

  Match({
    required this.id,
    this.status = MatchStatus.waiting,
    required this.startAt,
    this.duration = 300,
    required this.f1Name,
    required this.f2Name,
    this.f1Color = '#0066cc',
    this.f2Color = '#cc0000',
    this.f1Pt2 = 0,
    this.f2Pt2 = 0,
    this.f1Pt3 = 0,
    this.f2Pt3 = 0,
    this.f1Pt4 = 0,
    this.f2Pt4 = 0,
    this.f1Adv = 0,
    this.f2Adv = 0,
    this.f1Pen = 0,
    this.f2Pen = 0,
  });

  static String generateId() {
    final random = Random();
    return random.nextInt(0x10000).toRadixString(16).padLeft(4, '0').toLowerCase();
  }

  int get f1TotalScore => (f1Pt2 * 2) + (f1Pt3 * 3) + (f1Pt4 * 4);
  int get f2TotalScore => (f2Pt2 * 2) + (f2Pt3 * 3) + (f2Pt4 * 4);

  void addPoints(int fighter, int points) {
    if (fighter == 1) {
      switch (points) {
        case 2:
          f1Pt2++;
          break;
        case 3:
          f1Pt3++;
          break;
        case 4:
          f1Pt4++;
          break;
      }
    } else {
      switch (points) {
        case 2:
          f2Pt2++;
          break;
        case 3:
          f2Pt3++;
          break;
        case 4:
          f2Pt4++;
          break;
      }
    }
  }

  void removePoints(int fighter, int points) {
    if (fighter == 1) {
      switch (points) {
        case 2:
          if (f1Pt2 > 0) f1Pt2--;
          break;
        case 3:
          if (f1Pt3 > 0) f1Pt3--;
          break;
        case 4:
          if (f1Pt4 > 0) f1Pt4--;
          break;
      }
    } else {
      switch (points) {
        case 2:
          if (f2Pt2 > 0) f2Pt2--;
          break;
        case 3:
          if (f2Pt3 > 0) f2Pt3--;
          break;
        case 4:
          if (f2Pt4 > 0) f2Pt4--;
          break;
      }
    }
  }

  void addAdvantage(int fighter) {
    if (fighter == 1) {
      f1Adv++;
    } else {
      f2Adv++;
    }
  }

  void removeAdvantage(int fighter) {
    if (fighter == 1) {
      if (f1Adv > 0) f1Adv--;
    } else {
      if (f2Adv > 0) f2Adv--;
    }
  }

  void addPenalty(int fighter) {
    if (fighter == 1) {
      f1Pen++;
    } else {
      f2Pen++;
    }
  }

  void removePenalty(int fighter) {
    if (fighter == 1) {
      if (f1Pen > 0) f1Pen--;
    } else {
      if (f2Pen > 0) f2Pen--;
    }
  }

  void startMatch() {
    status = MatchStatus.inProgress;
  }

  void finishMatch() {
    status = MatchStatus.finished;
  }

  void cancelMatch() {
    status = MatchStatus.canceled;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.index,
      'start_at': startAt,
      'duration': duration,
      'f1_name': f1Name,
      'f2_name': f2Name,
      'f1_color': f1Color,
      'f2_color': f2Color,
      'f1_pt2': f1Pt2,
      'f2_pt2': f2Pt2,
      'f1_pt3': f1Pt3,
      'f2_pt3': f2Pt3,
      'f1_pt4': f1Pt4,
      'f2_pt4': f2Pt4,
      'f1_adv': f1Adv,
      'f2_adv': f2Adv,
      'f1_pen': f1Pen,
      'f2_pen': f2Pen,
    };
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      status: MatchStatus.values[json['status']],
      startAt: json['start_at'],
      duration: json['duration'],
      f1Name: json['f1_name'],
      f2Name: json['f2_name'],
      f1Color: json['f1_color'],
      f2Color: json['f2_color'],
      f1Pt2: json['f1_pt2'],
      f2Pt2: json['f2_pt2'],
      f1Pt3: json['f1_pt3'],
      f2Pt3: json['f2_pt3'],
      f1Pt4: json['f1_pt4'],
      f2Pt4: json['f2_pt4'],
      f1Adv: json['f1_adv'],
      f2Adv: json['f2_adv'],
      f1Pen: json['f1_pen'],
      f2Pen: json['f2_pen'],
    );
  }
}