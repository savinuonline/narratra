class UserReward {
  final String userId;
  int points;
  int level;
  final int dailyGoal;
  int dailyGoalProgress;
  final DateTime lastLoginBonusDate;
  final String referralCode;
  final int pointsToNextLevel;
  final bool canClaimDailyBonus;
  final List<String> referrals;
  final String? inviteCode;
  final List<String> usedInviteCodes;
  final List<String> generatedInviteCodes;
  final int freeAudiobooks;
  final int premiumAudiobooks;
  final int inviteRewardCount;
  final int currentStreak;
  final List<int> weeklyClaimedDays;

  UserReward({
    required this.userId,
    this.points = 0,
    this.level = 1,
    this.dailyGoal = 30,
    this.dailyGoalProgress = 0,
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
  }) : this.pointsToNextLevel = 100,
       this.canClaimDailyBonus = true;

  factory UserReward.fromMap(Map<String, dynamic> map) {
    return UserReward(
      userId: map['userId'] ?? '',
      points: map['points'] ?? 0,
      level: map['level'] ?? 1,
      dailyGoal: map['dailyGoal'] ?? 30,
      dailyGoalProgress: map['dailyGoalProgress'] ?? 0,
      lastLoginBonusDate:
          map.containsKey('lastLoginBonusDate')
              ? DateTime.parse(map['lastLoginBonusDate'])
              : DateTime.now().subtract(
                const Duration(days: 1),
              ), // Yesterday by default
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
      'inviteCode': inviteCode,
      'usedInviteCodes': usedInviteCodes,
      'generatedInviteCodes': generatedInviteCodes,
      'freeAudiobooks': freeAudiobooks,
      'premiumAudiobooks': premiumAudiobooks,
      'inviteRewardCount': inviteRewardCount,
      'currentStreak': currentStreak,
      'weeklyClaimedDays': weeklyClaimedDays,
    };
  }

  double get goalProgress => dailyGoal > 0 ? dailyGoalProgress / dailyGoal : 0;
}
