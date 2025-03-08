class UserReward {
  final String userId;
  int points;
  int level;
  int dailyGoal;
  int dailyGoalProgress;
  DateTime lastLoginBonusDate;
  final String referralCode;
  final int pointsToNextLevel;
  final bool canClaimDailyBonus;
  List<String> referrals;

  UserReward({
    required this.userId,
    this.points = 0,
    this.level = 1,
    this.dailyGoal = 30,
    this.dailyGoalProgress = 0,
    DateTime? lastLoginBonusDate,
    this.referralCode = '',
    this.referrals = const [],
  }) : this.lastLoginBonusDate = lastLoginBonusDate ?? DateTime(2000),
       this.pointsToNextLevel = 100,
       this.canClaimDailyBonus = true;

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

  double get goalProgress => dailyGoal > 0 ? dailyGoalProgress / dailyGoal : 0;
}
