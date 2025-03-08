import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user_reward.dart';


class RewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDynamicLinks _dynamicLinks = FirebaseDynamicLinks.instance;



Future<void> initializeTestUserData() async {
    String testUserId = 'test_user_id_123'; // MUST MATCH the ID in getUserRewards()

    UserReward initialRewardData = UserReward(
        userId: testUserId,
        points: 200, // Initial points
        level: 1,
        dailyGoal: 1000,
        dailyGoalProgress: 500,
        referrals: [],
        lastLoginBonusDate: DateTime.now().subtract(const Duration(days: 2)), // Claimable daily bonus
    );

    await _firestore
        .collection('user_rewards')
        .doc(testUserId)
        .set(initialRewardData.toMap());

    print("Test user data initialized for user ID: $testUserId");
}


  // Create referral link
  Future<String> createReferralLink() async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://yourapp.page.link',
      link: Uri.parse('https://yourapp.com/refer?uid=${user.uid}'),
      androidParameters: AndroidParameters(packageName: 'com.yourapp.android'),
      iosParameters: IOSParameters(bundleId: 'com.yourapp.ios'),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Join me on Narratra.!',
        description: 'Use my referral link to get bonus points!',
      ),
    );

    final ShortDynamicLink shortLink = await _dynamicLinks.buildShortLink(
      parameters,
    );
    return shortLink.shortUrl.toString();
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

  // Redeem points without transaction (for simpler cases, but less consistent)
  Future<bool> redeemPoints(int amount) async {
    final rewards = await getUserRewards();
    if (rewards.points < amount) return false;

    rewards.points -= amount;
    await saveUserRewards(rewards);
    return true;
  }


  late DateTime lastLoginBonusDate;

  Stream<UserReward> get userRewardsStream {
    User? user = _auth.currentUser; // Get current user
    String userId; // Declare userId

    if (user == null) {
        // **TEMPORARY WORKAROUND - DEFAULT USER ID FOR TESTING**
        userId = 'test_user_id_123'; // Use the SAME hardcoded ID as in getUserRewards()
        print("WARNING (Stream): Using default test user ID: $userId. Authentication is bypassed!");
    } else {
        userId = user.uid;
    }

    return _firestore
        .collection('user_rewards')
        .doc(userId) // Use the resolved userId (either test or actual)
        .snapshots()
        .map((doc) => UserReward.fromMap(doc.data() ?? {}));
}

  // Get current user reward data
  Future<UserReward> getUserRewards() async {
    User? user = _auth.currentUser;
    String userId;

    if (user == null) {
        // **TEMPORARY WORKAROUND - DEFAULT USER ID FOR TESTING**
        userId = 'test_user_id_123'; // Use a hardcoded ID (replace with your own string)
        print("WARNING: Using default test user ID: $userId.  Authentication is bypassed!");
    } else {
        userId = user.uid;
    }

    final doc = await _firestore.collection('user_rewards').doc(user?.uid).get();

    if (doc.exists) {
      return UserReward.fromMap(doc.data()!);
    } else {
      // Create new reward document for user
      final newReward = UserReward(
        userId: user?.uid ?? userId,
        lastLoginBonusDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      await _firestore
          .collection('user_rewards')
          .doc(user?.uid)
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

      if (isSameDay(userData.lastLoginBonusDate, now)) {
        dailyBonus = 0; // Already claimed today
        return; // Stop transaction here, no bonus awarded
      }

      dailyBonus = 50; // Award daily bonus (50 points)

      // Update points and lastLoginBonusDate in a single transaction
      transaction.update(userDoc, {
        'points': userData.points + dailyBonus,
        'lastLoginBonusDate': now, // Use DateTime object directly for Firestore
      });
    });

    if (dailyBonus > 0) {
      // Re-fetch rewards to get updated data after transaction
      final updatedRewards = await getUserRewards();
      checkAndUpdateLevel(updatedRewards);
    }
    return dailyBonus; // Return the bonus awarded (0 if already claimed)
  }


  // Update daily goal
  Future<void> updateDailyGoal(int newGoal) async {
    final rewards = await getUserRewards();
    rewards.dailyGoal = newGoal;
    await saveUserRewards(rewards);
  }

  // Update goal progress and award points
  Future<void> updateGoalProgress(int progressIncrement) async {
    final rewards = await getUserRewards();
    rewards.dailyGoalProgress += progressIncrement;

    // Cap at daily goal
    if (rewards.dailyGoalProgress > rewards.dailyGoal) {
      rewards.dailyGoalProgress = rewards.dailyGoal;
    }

    // Award points based on progress (1 point per 1% of goal)
    final previousProgress =
        (rewards.dailyGoalProgress - progressIncrement) / rewards.dailyGoal;
    final currentProgress = rewards.dailyGoalProgress / rewards.dailyGoal;

    final previousPercent = (previousProgress * 100).floor();
    final currentPercent = (currentProgress * 100).floor();

    if (currentPercent > previousPercent) {
      // Award points for each percentage point gained
      final pointsToAdd = currentPercent - previousPercent;
      rewards.points += pointsToAdd;

      // Check if level up
      checkAndUpdateLevel(rewards);
    }

    await saveUserRewards(rewards);
  }


  // Check and update level if needed
  void checkAndUpdateLevel(UserReward rewards) {
    final newLevel = (rewards.points / 1000).floor() + 1;
    if (newLevel > rewards.level) {
      rewards.level = newLevel;
    }
  }

  // Helper to check if two dates are the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
}