class UserReward {
  final String userId;
  final int points;
  final int level;
  final int dailyGoal;
  final int dailyGoalProgress;
  final DateTime lastLoginBonusDate;
  final String referralCode;

  UserReward({
    required this.userId,
    this.points = 0,
    this.level = 1,
    this.dailyGoal = 30,
    this.dailyGoalProgress = 0,
    DateTime? lastLoginBonusDate,
    this.referralCode = '',
  }) : this.lastLoginBonusDate = lastLoginBonusDate ?? DateTime(2000);

  factory UserReward.fromMap(Map<String, dynamic> map) {
    return UserReward(
      userId: map['userId'] ?? '',
      points: map['points'] ?? 0,
      level: map['level'] ?? 1,
      dailyGoal: map['dailyGoal'] ?? 30,
      dailyGoalProgress: map['dailyGoalProgress'] ?? 0,
      lastLoginBonusDate:
          DateTime.tryParse(map['lastLoginBonusDate'] ?? '') ?? DateTime(2000),
      referralCode: map['referralCode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'points': points,
      'level': level,
      'dailyGoal': dailyGoal,
      'dailyGoalProgress': dailyGoalProgress,
      'lastLoginBonusDate': lastLoginBonusDate.toIso8601String(),
      'referralCode': referralCode,
    };
  }

  int get pointsToNextLevel => (level * 1000) - points;
  double get goalProgress => dailyGoal > 0 ? dailyGoalProgress / dailyGoal : 0;
}
