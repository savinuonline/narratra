class UserReward {
  String userId;
  int points;
  int level;
  int dailyGoal;
  int dailyGoalProgress;
  DateTime lastLoginBonusDate;
  List<String> referrals;

  UserReward({
    required this.userId,
    this.points = 0,
    this.level = 1,
    this.dailyGoal = 100,
    this.dailyGoalProgress = 0,
    required this.lastLoginBonusDate,
    this.referrals = const [],
  });

  factory UserReward.fromJson(Map<String, dynamic> json) {
    return UserReward(
      userId: json['userId'],
      points: json['points'] ?? 0,
      level: json['level'] ?? 1,
      dailyGoal: json['dailyGoal'] ?? 100,
      dailyGoalProgress: json['dailyGoalProgress'] ?? 0,
      lastLoginBonusDate: json['lastLoginBonusDate'] != null 
          ? DateTime.parse(json['lastLoginBonusDate']) 
          : DateTime.now().subtract(const Duration(days: 1)),
      referrals: List<String>.from(json['referrals'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'points': points,
      'level': level,
      'dailyGoal': dailyGoal,
      'dailyGoalProgress': dailyGoalProgress,
      'lastLoginBonusDate': lastLoginBonusDate.toIso8601String(),
      'referrals': referrals,
    };
  }

  int get pointsToNextLevel => level * 1000 - points;
  double get goalProgress => dailyGoalProgress / dailyGoal;
}