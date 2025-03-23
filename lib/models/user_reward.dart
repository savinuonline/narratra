import 'package:cloud_firestore/cloud_firestore.dart';

class UserReward {
  final String userId;
  int points;
  int xp;
  int level;
  final DateTime registrationDate;
  final DateTime lastLoginBonusDate;
  final String referralCode;
  final List<String> referrals;
  final String? inviteCode;
  final List<String> usedInviteCodes;
  final List<String> generatedInviteCodes;
  final int freeAudiobooks;
  final int premiumAudiobooks;
  final int inviteRewardCount;
  int currentStreak;
  final List<int> weeklyClaimedDays;
  int dailyGoalProgress;
  int weeklyListeningMinutes;
  int dailyListeningMinutes;
  int weeklyGoalMinutes;
  int dailyGoalMinutes;
  DateTime lastListeningUpdate;
  List<String> listeningTips;
  String currentMotivation;

  UserReward({
    required this.userId,
    this.points = 0,
    this.xp = 0,
    this.level = 1,
    required this.registrationDate,
    required this.lastLoginBonusDate,
    this.referralCode = '',
    this.referrals = const [],
    this.inviteCode,
    this.usedInviteCodes = const [],
    this.generatedInviteCodes = const [],
    this.freeAudiobooks = 0,
    this.premiumAudiobooks = 0,
    this.inviteRewardCount = 0,
    this.currentStreak = 0,
    this.weeklyClaimedDays = const [],
    this.dailyGoalProgress = 0,
    this.weeklyListeningMinutes = 0,
    this.dailyListeningMinutes = 0,
    this.weeklyGoalMinutes = 120, // Default 2 hours per week
    this.dailyGoalMinutes = 30, // Default 30 minutes per day
    DateTime? lastListeningUpdate,
    List<String>? listeningTips,
    String? currentMotivation,
  }) : lastListeningUpdate = lastListeningUpdate ?? DateTime.now(),
       listeningTips = listeningTips ?? _generateListeningTips(),
       currentMotivation = currentMotivation ?? _generateMotivation();

  factory UserReward.fromMap(Map<String, dynamic> map) {
    // Helper function to parse date from either Timestamp or String
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else {
        return DateTime.now();
      }
    }

    return UserReward(
      userId: map['userId'] ?? '',
      points: map['points'] ?? 0,
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,
      registrationDate: parseDate(map['registrationDate']),
      lastLoginBonusDate: parseDate(map['lastLoginBonusDate']),
      referralCode: map['referralCode'] ?? '',
      inviteCode: map['inviteCode'],
      usedInviteCodes: List<String>.from(map['usedInviteCodes'] ?? []),
      generatedInviteCodes: List<String>.from(
        map['generatedInviteCodes'] ?? [],
      ),
      freeAudiobooks: map['freeAudiobooks'] ?? 0,
      premiumAudiobooks: map['premiumAudiobooks'] ?? 0,
      inviteRewardCount: map['inviteRewardCount'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      weeklyClaimedDays: List<int>.from(map['weeklyClaimedDays'] ?? []),
      weeklyListeningMinutes: map['weeklyListeningMinutes'] ?? 0,
      dailyListeningMinutes: map['dailyListeningMinutes'] ?? 0,
      weeklyGoalMinutes: map['weeklyGoalMinutes'] ?? 120,
      dailyGoalMinutes: map['dailyGoalMinutes'] ?? 30,
      lastListeningUpdate: parseDate(map['lastListeningUpdate']),
      listeningTips: List<String>.from(
        map['listeningTips'] ?? _generateListeningTips(),
      ),
      currentMotivation: map['currentMotivation'] ?? _generateMotivation(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'points': points,
      'xp': xp,
      'level': level,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'lastLoginBonusDate': Timestamp.fromDate(lastLoginBonusDate),
      'referralCode': referralCode,
      'inviteCode': inviteCode,
      'usedInviteCodes': usedInviteCodes,
      'generatedInviteCodes': generatedInviteCodes,
      'freeAudiobooks': freeAudiobooks,
      'premiumAudiobooks': premiumAudiobooks,
      'inviteRewardCount': inviteRewardCount,
      'currentStreak': currentStreak,
      'weeklyClaimedDays': weeklyClaimedDays,
      'weeklyListeningMinutes': weeklyListeningMinutes,
      'dailyListeningMinutes': dailyListeningMinutes,
      'weeklyGoalMinutes': weeklyGoalMinutes,
      'dailyGoalMinutes': dailyGoalMinutes,
      'lastListeningUpdate': Timestamp.fromDate(lastListeningUpdate),
      'listeningTips': listeningTips,
      'currentMotivation': currentMotivation,
    };
  }

  // Level names and descriptions
  static const Map<int, String> levelNames = {
    1: 'New Listener',
    2: 'Page Turner',
    3: 'Story Seeker',
    4: 'Chapter Chaser',
    5: 'Bookworm',
    6: 'Tale Traveler',
    7: 'Narrative Explorer',
    8: 'Audiobook Aficionado',
    9: 'Literary Sage',
    10: 'Legendary Listener',
  };

  static const Map<int, String> levelDescriptions = {
    1: 'Just getting started—welcome aboard!',
    2: 'Warming up those ears with some chapters.',
    3: 'Actively diving into more stories.',
    4: 'Consistently consuming books.',
    5: 'Starting to stand out among readers.',
    6: 'Journeying through stories with ease.',
    7: 'Experienced listener with a thirst for more.',
    8: 'Knows their way around narrations.',
    9: 'Respected among fellow listeners.',
    10: 'A true master of the audiobook world.',
  };

  // XP required for each level (increased difficulty)
  static const Map<int, int> levelXp = {
    1: 0,
    2: 5000,
    3: 15000,
    4: 35000,
    5: 75000,
    6: 150000,
    7: 300000,
    8: 600000,
    9: 1000000,
    10: 2000000,
  };

  // Getters for level information
  String get levelName => levelNames[level] ?? 'Unknown Level';
  String get levelDescription => levelDescriptions[level] ?? '';

  int get xpToNextLevel {
    if (level >= 10) return 0;
    return levelXp[level + 1]! - xp;
  }

  double get levelProgress {
    if (level >= 10) return 1.0;
    int nextLevelXp = levelXp[level + 1]!;
    int currentLevelXp = levelXp[level]!;
    return (xp - currentLevelXp) / (nextLevelXp - currentLevelXp).toDouble();
  }

  // Getter to check if user can claim daily bonus
  bool get canClaimDailyBonus {
    final now = DateTime.now();
    final lastClaimDate = DateTime(
      lastLoginBonusDate.year,
      lastLoginBonusDate.month,
      lastLoginBonusDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);

    // Debug print to check the dates
    print('Last claim date: $lastClaimDate');
    print('Today: $today');
    print('Can claim: ${!isSameDay(lastClaimDate, today)}');

    // Can claim if it's not the same day
    return !isSameDay(lastClaimDate, today);
  }

  // Helper method to check if two dates are the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Helper method to get XP for current streak day
  int getXpForStreakDay() {
    switch (currentStreak) {
      case 1:
        return 50; // Base XP
      case 2:
        return 100; // 2x base
      case 3:
        return 200; // 4x base
      case 4:
        return 400; // 8x base
      case 5:
        return 800; // 16x base
      case 6:
        return 1600; // 32x base
      case 7:
        return 3200; // 64x base
      default:
        return 50;
    }
  }

  // Points calculation methods
  int calculatePointsForListening(int minutes) {
    // Base points: 1 point per 2 minutes (slower earning)
    // Bonus points for reaching daily goal: 100 points
    // Bonus points for reaching weekly goal: 500 points
    int points = minutes ~/ 2; // 1 point per 2 minutes

    if (dailyListeningMinutes + minutes >= dailyGoalMinutes) {
      points += 100;
    }

    if (weeklyListeningMinutes + minutes >= weeklyGoalMinutes) {
      points += 500;
    }

    return points;
  }

  // Helper method to get points for current streak day
  int getPointsForStreakDay() {
    switch (currentStreak) {
      case 1:
        return 10;
      case 2:
        return 15;
      case 3:
        return 20;
      case 4:
        return 25;
      case 5:
        return 30;
      case 6:
        return 40;
      case 7:
        return 50;
      default:
        return 10;
    }
  }

  // Progress getters
  double get dailyProgress => dailyListeningMinutes / dailyGoalMinutes;
  double get weeklyProgress => weeklyListeningMinutes / weeklyGoalMinutes;

  // Static methods for generating tips and motivation
  static List<String> _generateListeningTips() {
    final tips = [
      "Try listening during your commute or while exercising",
      "Set a daily listening goal to build a consistent habit",
      "Use headphones for better audio quality",
      "Take short breaks between chapters to process the content",
      "Listen at a comfortable speed - don't rush",
      "Create a dedicated listening space free from distractions",
      "Use the bookmark feature to track your progress",
      "Share your favorite books with friends",
      "Try different genres to keep things interesting",
      "Listen before bed to help you relax",
    ];
    tips.shuffle();
    return tips.take(5).toList();
  }

  static String _generateMotivation() {
    final motivations = [
      "Every minute of listening brings you closer to your next level!",
      "Your dedication to learning is inspiring!",
      "Keep going - you're making great progress!",
      "Every story you listen to expands your world.",
      "You're building a valuable habit - stay consistent!",
      "Your listening journey is unique and valuable.",
      "Remember: small steps lead to big achievements.",
      "Your commitment to learning is admirable!",
      "Keep pushing your boundaries with new stories!",
      "You're becoming a better listener every day!",
    ];
    return motivations[DateTime.now().millisecondsSinceEpoch %
        motivations.length];
  }

  // Method to update listening progress
  void updateListeningProgress(int minutes) {
    final now = DateTime.now();

    // Reset daily progress if it's a new day
    if (now.difference(lastListeningUpdate).inDays >= 1) {
      dailyListeningMinutes = 0;
    }

    // Reset weekly progress if it's a new week
    if (now.difference(lastListeningUpdate).inDays >= 7) {
      weeklyListeningMinutes = 0;
    }

    dailyListeningMinutes += minutes;
    weeklyListeningMinutes += minutes;
    lastListeningUpdate = now;
  }

  // Method to update goals
  void updateGoals({int? dailyGoal, int? weeklyGoal}) {
    if (dailyGoal != null) dailyGoalMinutes = dailyGoal;
    if (weeklyGoal != null) weeklyGoalMinutes = weeklyGoal;
  }

  // Method to refresh tips and motivation
  void refreshTipsAndMotivation() {
    listeningTips = _generateListeningTips();
    currentMotivation = _generateMotivation();
  }

  // Getter for daily goal based on streak
  int get dailyGoal {
    // Base goal is 100 points
    // Each day of streak adds 10 points to the goal
    return 100 + (currentStreak * 10);
  }
}
