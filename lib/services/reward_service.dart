import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';
import '../models/user_reward.dart';
import 'dart:async';

class RewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDynamicLinks _dynamicLinks = FirebaseDynamicLinks.instance;

  final _userRewardsController = StreamController<UserReward>.broadcast();

  Stream<UserReward> get userRewardsStream {
    _refreshUserRewards();
    return _userRewardsController.stream;
  }

  void _refreshUserRewards() async {
    try {
      final rewards = await getUserRewards();
      _userRewardsController.add(rewards);
    } catch (e) {
      _userRewardsController.addError(e);
    }
  }

  // Create referral link
  Future<String> createReferralLink() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No current user found');
    }
    final String userId = user.uid;

    try {
      final parameters = DynamicLinkParameters(
        uriPrefix: 'https://narratra.page.link',
        link: Uri.parse('https://narratra.com/refer?uid=$userId'),
        androidParameters: AndroidParameters(
          packageName: 'com.example.frontend',
          minimumVersion: 0,
        ),
        iosParameters: IOSParameters(
          bundleId: 'com.example.frontend',
          minimumVersion: '0',
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: 'Join me on Narratra!',
          description: 'Use my referral link to get bonus points!',
        ),
      );

      final shortLink = await _dynamicLinks.buildShortLink(parameters);
      print('Short Link Generated: ${shortLink.shortUrl}');
      return shortLink.shortUrl.toString();
    } on FirebaseException catch (e) {
      print('Firebase Exception: $e');
      return 'https://narratra.com/refer?uid=$userId';
    } on Exception catch (e) {
      print('Generic Exception: $e');
      return 'https://narratra.com/refer?uid=$userId'; // Fallback URL
    }
  }

  // Share referral link
  Future<void> shareReferralLink(BuildContext context) async {
    final link = await createReferralLink();

    await Share.share(
      'Join me on Narratra. and start reading today! $link',
      subject: 'Check out this awesome app!',
    );
  }

  // Process referral
  Future<void> processReferral(String referrerId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Don't allow self-referrals
    if (user.uid == referrerId) return;

    // Get referrer's rewards
    final referrerDoc =
        await _firestore.collection('user_rewards').doc(referrerId).get();

    if (referrerDoc.exists) {
      final referrerRewards = UserReward.fromMap(
        referrerDoc.data()!..['userId'] = referrerId,
      );

      // Check if this user was already referred
      if (!referrerRewards.referrals.contains(user.uid)) {
        // Add to referrals list
        referrerRewards.referrals.add(user.uid);

        // Award referral bonus (100 points)
        referrerRewards.points += 100;

        // Check if level up
        checkAndUpdateLevel(referrerRewards);

        await saveUserRewards(referrerRewards);

        // Also give the new user a bonus
        final newUserRewards = await getUserRewards();
        newUserRewards.points += 50; // Bonus for using a referral
        checkAndUpdateLevel(newUserRewards);
        await saveUserRewards(newUserRewards);
      }
    }
  }

  // Redeem points with transaction for data consistency
  Future<void> redeemPointsWithTransaction(int points) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final userDoc = _firestore.collection('user_rewards').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(userDoc);

      if (!docSnapshot.exists) {
        throw Exception('User rewards not found');
      }

      final userData = UserReward.fromMap(docSnapshot.data()!);

      if (userData.points < points) {
        throw Exception('Not enough points');
      }

      transaction.update(userDoc, {'points': userData.points - points});
    });
  }

  // Redeem points without transaction
  Future<bool> redeemPoints(int amount) async {
    final rewards = await getUserRewards();
    if (rewards.points < amount) return false;

    rewards.points -= amount;
    await saveUserRewards(rewards);
    return true;
  }

  late DateTime lastLoginBonusDate;

  // Get current user reward data
  Future<UserReward> getUserRewards() async {
    User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('No current user found.');
    }

    final doc = await _firestore.collection('user_rewards').doc(user.uid).get();

    if (doc.exists) {
      return UserReward.fromMap(doc.data()!);
    } else {
      // Create new reward document for user
      final newReward = UserReward(
        userId: user.uid,
        lastLoginBonusDate: DateTime.now().subtract(const Duration(days: 1)),
        registrationDate: DateTime.now(),
      );

      await _firestore
          .collection('user_rewards')
          .doc(user.uid)
          .set(newReward.toMap());
      return newReward;
    }
  }

  // Save user rewards
  Future<void> saveUserRewards(UserReward rewards) async {
    await _firestore
        .collection('user_rewards')
        .doc(rewards.userId)
        .set(rewards.toMap());
  }

  // Claim daily login bonus with transaction for atomicity
  Future<int> claimDailyLoginBonus() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final userDoc = _firestore.collection('user_rewards').doc(userId);
    int dailyBonus = 0;

    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(userDoc);

      if (!docSnapshot.exists) {
        throw Exception('User rewards not found');
      }

      final userData = UserReward.fromMap(docSnapshot.data()!);
      final now = DateTime.now();

      // Debug prints
      print('Checking daily bonus eligibility:');
      print('Current time: ${now.toString()}');
      print('Last claim time: ${userData.lastLoginBonusDate.toString()}');
      print(
        'Hours since last claim: ${now.difference(userData.lastLoginBonusDate).inHours}',
      );
      print('Can claim bonus: ${userData.canClaimDailyBonus}');
      print('Current streak: ${userData.currentStreak}');

      // Check if user can claim today's bonus
      if (!userData.canClaimDailyBonus) {
        print('Cannot claim bonus yet - waiting period not over');
        dailyBonus = 0;
        return;
      }

      // Calculate streak
      final lastClaim = userData.lastLoginBonusDate;
      final hoursDifference = now.difference(lastClaim).inHours;

      // Reset streak if more than 24 hours has passed
      if (hoursDifference > 24) {
        print('Streak reset - more than 24 hours passed');
        userData.currentStreak = 0;
        userData.weeklyClaimedDays.clear();
      }

      // Increment streak (1-7)
      userData.currentStreak = (userData.currentStreak + 1) % 7;
      if (userData.currentStreak == 0) userData.currentStreak = 7;

      // Get points for current streak day
      dailyBonus = userData.getPointsForStreakDay();

      // Update weekly claimed days
      final currentDayIndex = now.weekday - 1; // 0-6 for Monday-Sunday
      if (!userData.weeklyClaimedDays.contains(currentDayIndex)) {
        userData.weeklyClaimedDays.add(currentDayIndex);
      }

      print('Awarding daily bonus:');
      print('Points awarded: $dailyBonus');
      print('New streak: ${userData.currentStreak}');
      print('Weekly claimed days: ${userData.weeklyClaimedDays}');

      // Update points and lastLoginBonusDate in a single transaction
      transaction.update(userDoc, {
        'points': userData.points + dailyBonus,
        'lastLoginBonusDate': now.toIso8601String(),
        'currentStreak': userData.currentStreak,
        'weeklyClaimedDays': userData.weeklyClaimedDays,
      });
    });

    if (dailyBonus > 0) {
      // Re-fetch rewards to get updated data after transaction
      final updatedRewards = await getUserRewards();
      checkAndUpdateLevel(updatedRewards);
    }
    return dailyBonus;
  }

  // Test method to verify login bonus functionality
  Future<void> testLoginBonus() async {
    try {
      final rewards = await getUserRewards();
      print('\n=== Login Bonus Test ===');
      print('Current user rewards:');
      print('Points: ${rewards.points}');
      print('Last login bonus: ${rewards.lastLoginBonusDate}');
      print('Current streak: ${rewards.currentStreak}');
      print('Can claim bonus: ${rewards.canClaimDailyBonus}');
      print('Weekly claimed days: ${rewards.weeklyClaimedDays}');

      final bonus = await claimDailyLoginBonus();
      print('\nClaim attempt result:');
      print('Bonus points awarded: $bonus');

      final updatedRewards = await getUserRewards();
      print('\nUpdated rewards:');
      print('Points: ${updatedRewards.points}');
      print('Last login bonus: ${updatedRewards.lastLoginBonusDate}');
      print('Current streak: ${updatedRewards.currentStreak}');
      print('Weekly claimed days: ${updatedRewards.weeklyClaimedDays}');
    } catch (e) {
      print('Error testing login bonus: $e');
    }
  }

  // Update daily goal
  Future<void> updateDailyGoal(int newGoal) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection('user_rewards').doc(user.uid);
        transaction.update(docRef, {'dailyGoal': newGoal});
      });

      // Trigger a manual refresh of the userRewardsStream
      _userRewardsController.add(await getUserRewards());

      print('Daily goal updated to $newGoal');
    } catch (e) {
      print('Error updating daily goal: $e');
    }
  }

  // Update goal progress and award points
  Future<void> updateGoalProgress(int progressIncrement) async {
    final rewards = await getUserRewards();
    rewards.dailyGoalProgress += progressIncrement;

    if (rewards.dailyGoalProgress > rewards.dailyGoal) {
      rewards.dailyGoalProgress = rewards.dailyGoal;
    }

    final previousProgress =
        (rewards.dailyGoalProgress - progressIncrement) / rewards.dailyGoal;
    final currentProgress = rewards.dailyGoalProgress / rewards.dailyGoal;

    final previousPercent = (previousProgress * 100).floor();
    final currentPercent = (currentProgress * 100).floor();

    if (currentPercent > previousPercent) {
      final pointsToAdd = currentPercent - previousPercent;
      rewards.points += pointsToAdd;

      // Check if level up
      checkAndUpdateLevel(rewards);
    }

    await saveUserRewards(rewards);
  }

  // Check and update level if needed
  void checkAndUpdateLevel(UserReward rewards) {
    // Define level XP thresholds
    final levelXp = {
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

    // Find the highest level the user qualifies for
    int newLevel = 1;
    for (int level = 10; level >= 1; level--) {
      if (rewards.xp >= levelXp[level]!) {
        newLevel = level;
        break;
      }
    }

    // Only update if the new level is higher than current level
    if (newLevel > rewards.level) {
      rewards.level = newLevel;
    }
  }

  bool isSameDay(DateTime dateTime1, DateTime dateTime2) {
    // Add debug prints to see what's happening
    print(
      'Comparing dates: ${dateTime1.toString()} with ${dateTime2.toString()}',
    );

    if (dateTime1 == null) return false;

    return dateTime1.year == dateTime2.year &&
        dateTime1.month == dateTime2.month &&
        dateTime1.day == dateTime2.day;
  }

  // Reset daily goal progress at midnight
  void setupDailyGoalReset() {
    // Calculate time until next midnight
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    // Schedule reset
    Future.delayed(timeUntilMidnight, () async {
      final rewards = await getUserRewards();
      rewards.dailyGoalProgress = 0;
      await saveUserRewards(rewards);

      // Schedule next reset
      setupDailyGoalReset();
    });
  }

  Future<void> setGoalProgress(int progress) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection('user_rewards').doc(userId).update({
      'dailyGoalProgress': progress,
    });
  }

  Future<void> setDailyGoal(int goal) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection('user_rewards').doc(userId).update({
      'dailyGoal': goal,
    });
  }

  Future<String> generateReferralCode() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Generate a simple referral code using timestamp and user ID
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${userId.substring(0, 6)}$timestamp'.substring(0, 8);
  }

  // Initialize rewards for new user
  Future<void> initializeUserRewards() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docRef = _firestore.collection('user_rewards').doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        final now = DateTime.now();
        // Set lastLoginBonusDate to 23 hours ago for new users
        final lastLoginBonusDate = now.subtract(const Duration(hours: 23));

        await docRef.set({
          'userId': user.uid,
          'points': 0,
          'xp': 0,
          'level': 1,
          'registrationDate': now.toIso8601String(),
          'lastLoginBonusDate': lastLoginBonusDate.toIso8601String(),
          'freeAudiobooks': 0,
          'premiumAudiobooks': 0,
          'inviteRewardCount': 0,
          'usedInviteCodes': [],
          'generatedInviteCodes': [],
          'currentStreak': 0,
          'weeklyClaimedDays': [],
          'weeklyListeningMinutes': 0,
          'dailyListeningMinutes': 0,
          'weeklyGoalMinutes': 120,
          'dailyGoalMinutes': 30,
          'lastListeningUpdate': now.toIso8601String(),
          'listeningTips': _generateListeningTips(),
          'currentMotivation': _generateMotivation(),
        });
      }
    } catch (e) {
      print('Error initializing user rewards: $e');
      rethrow;
    }
  }

  // Helper method to generate listening tips
  List<String> _generateListeningTips() {
    return [
      'Try listening at 1.25x speed to get through more content',
      'Use headphones for better audio quality',
      'Take breaks every hour to rest your ears',
      'Listen while doing household chores',
      'Create a dedicated listening space',
    ];
  }

  // Helper method to generate motivation message
  String _generateMotivation() {
    final messages = [
      'Keep going! Every minute of listening counts.',
      'You\'re making great progress!',
      'Stay consistent with your daily goals.',
      'Remember why you started this journey.',
      'Your dedication is inspiring!',
    ];
    return messages[DateTime.now().millisecondsSinceEpoch % messages.length];
  }

  // Claim daily bonus
  Future<void> claimDailyBonus() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final userDoc = _firestore.collection('user_rewards').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(userDoc);
      if (!docSnapshot.exists) throw Exception('User rewards not found');

      final userData = UserReward.fromMap(docSnapshot.data()!);
      if (!userData.canClaimDailyBonus) {
        throw Exception('Daily bonus already claimed');
      }

      transaction.update(userDoc, {
        'points': userData.points + 50,
        'lastLoginBonusDate': DateTime.now().toIso8601String(),
      });
    });
  }

  // Process referral code
  Future<void> processReferralCode(String referralCode) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final referrerDoc =
        await _firestore
            .collection('user_rewards')
            .where('referralCode', isEqualTo: referralCode)
            .limit(1)
            .get();

    if (referrerDoc.docs.isEmpty) throw Exception('Invalid referral code');

    final referrerId = referrerDoc.docs.first.id;
    if (referrerId == user.uid) throw Exception('Cannot use own referral code');

    final batch = _firestore.batch();
    final referrerRef = _firestore.collection('user_rewards').doc(referrerId);
    final newUserRef = _firestore.collection('user_rewards').doc(user.uid);

    // Add points to referrer
    batch.update(referrerRef, {
      'points': FieldValue.increment(100),
      'referrals': FieldValue.arrayUnion([user.uid]),
    });

    // Add points to new user
    batch.update(newUserRef, {'points': FieldValue.increment(50)});

    await batch.commit();
  }

  // Generate a new invite code
  Future<String> generateInviteCode() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Generate random 8-character alphanumeric code
    final Random random = Random();
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final String code =
        List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();

    // Save the generated code to Firestore
    await _firestore.collection('user_rewards').doc(user.uid).update({
      'generatedInviteCodes': FieldValue.arrayUnion([code]),
    });

    return code;
  }

  // Redeem an invite code
  Future<void> redeemInviteCode(String code) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Check if code has been used by this user already
    final userDoc =
        await _firestore.collection('user_rewards').doc(user.uid).get();
    if (userDoc.exists) {
      final userData = userDoc.data();
      if (userData != null &&
          userData['usedInviteCodes'] != null &&
          (userData['usedInviteCodes'] as List).contains(code)) {
        throw Exception('You have already used this invite code');
      }
    }

    // Find who generated this code
    final querySnapshot =
        await _firestore
            .collection('user_rewards')
            .where('generatedInviteCodes', arrayContains: code)
            .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Invalid invite code');
    }

    final inviterDoc = querySnapshot.docs.first;
    final inviterId = inviterDoc.id;

    // Prevent self-referral
    if (inviterId == user.uid) {
      throw Exception('You cannot use your own invite code');
    }

    // Update both users in a transaction
    return _firestore.runTransaction((transaction) async {
      // Add free audiobook to new user
      transaction.update(_firestore.collection('user_rewards').doc(user.uid), {
        'freeAudiobooks': FieldValue.increment(1),
        'usedInviteCodes': FieldValue.arrayUnion([code]),
      });

      // Add premium audiobook to inviter
      transaction.update(_firestore.collection('user_rewards').doc(inviterId), {
        'premiumAudiobooks': FieldValue.increment(1),
        'inviteRewardCount': FieldValue.increment(1),
      });
    });
  }

  Future<bool> canClaimDailyBonus() async {
    final User? user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore.collection('user_rewards').doc(user.uid).get();
    if (!doc.exists) return true;

    final data = doc.data()!;
    if (!data.containsKey('lastLoginBonusDate')) {
      return true;
    }

    final lastClaimDate = DateTime.parse(data['lastLoginBonusDate']);
    final now = DateTime.now();

    // Allow claim if not same day
    return now.year != lastClaimDate.year ||
        now.month != lastClaimDate.month ||
        now.day != lastClaimDate.day;
  }

  Future<int> claimLoginBonus() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final docRef = _firestore.collection('user_rewards').doc(user.uid);

    return _firestore.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data() ?? {};

      // Get current streak info
      int currentStreak = data['currentStreak'] ?? 0;
      List<dynamic> weeklyClaimedDays = data['weeklyClaimedDays'] ?? [];

      // Check if we're on a new week
      final lastClaimDate =
          data.containsKey('lastLoginBonusDate')
              ? DateTime.parse(data['lastLoginBonusDate'])
              : null;

      final now = DateTime.now();

      // Reset streak if it's been more than 24 hours since last claim
      if (lastClaimDate != null) {
        final difference = now.difference(lastClaimDate).inHours;
        if (difference > 24) {
          currentStreak = 0;
          weeklyClaimedDays = [];
        }
      }

      // Increase streak and calculate rewards
      currentStreak = (currentStreak + 1) % 7; // Keep within 0-6 range
      if (currentStreak == 0) currentStreak = 7;

      // Calculate points and XP based on streak
      final userData = UserReward.fromMap(data);
      int pointsToAdd = userData.getPointsForStreakDay();
      int xpToAdd = userData.getXpForStreakDay();

      // Update weekly claimed days
      final currentDayIndex = now.weekday - 1; // 0-6 for Monday-Sunday
      if (!weeklyClaimedDays.contains(currentDayIndex)) {
        weeklyClaimedDays.add(currentDayIndex);
      }

      // Update document
      transaction.update(docRef, {
        'points': FieldValue.increment(pointsToAdd),
        'xp': FieldValue.increment(xpToAdd),
        'lastLoginBonusDate': now.toIso8601String(),
        'currentStreak': currentStreak,
        'weeklyClaimedDays': weeklyClaimedDays,
      });

      return pointsToAdd;
    });
  }

  // Update listening progress and award points
  Future<void> updateListeningProgress(int minutes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('user_rewards').doc(user.uid);
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;

      final rewards = UserReward.fromMap(doc.data()!);
      final pointsToAdd = rewards.calculatePointsForListening(minutes);
      
      rewards.updateListeningProgress(minutes);
      
      transaction.update(docRef, {
        'dailyListeningMinutes': rewards.dailyListeningMinutes,
        'weeklyListeningMinutes': rewards.weeklyListeningMinutes,
        'lastListeningUpdate': rewards.lastListeningUpdate.toIso8601String(),
        'points': FieldValue.increment(pointsToAdd),
        'xp': FieldValue.increment(pointsToAdd * 2), // 2 XP per point
      });
    });
  }

  // Update user's listening goals
  Future<void> updateListeningGoals({
    required int dailyGoal,
    required int weeklyGoal,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('user_rewards').doc(user.uid).update({
      'dailyGoalMinutes': dailyGoal,
      'weeklyGoalMinutes': weeklyGoal,
    });
  }

  // Refresh tips and motivation
  Future<void> refreshTipsAndMotivation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('user_rewards').doc(user.uid);
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;

      final rewards = UserReward.fromMap(doc.data()!);
      rewards.refreshTipsAndMotivation();
      
      transaction.update(docRef, {
        'listeningTips': rewards.listeningTips,
        'currentMotivation': rewards.currentMotivation,
      });
    });
  }
}
