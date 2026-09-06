class HelperModel {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int totalTasks;
  final String location;
  final String distance;
  final String bio;
  final bool isVerified;
  final String category;
  final List<SkillModel> skills;
  final List<ReviewModel> reviews;

  // Strike & Status Tracking Properties
  int currentStrikes;
  String accountStatus; // 'Active', 'Limited Visibility', 'Suspended'
  int jobsCompletedSinceLastStrike;

  HelperModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.totalTasks,
    required this.location,
    required this.distance,
    required this.bio,
    this.isVerified = true,
    required this.category,
    required this.skills,
    required this.reviews,
    this.currentStrikes = 0,
    this.accountStatus = 'Active',
    this.jobsCompletedSinceLastStrike = 0,
  });

  // Strike Engine Logic
  void addStrikes(int count) {
    if (count <= 0) return;
    currentStrikes += count;
    jobsCompletedSinceLastStrike = 0; // Reset counter per rules

    // Evaluate thresholds
    if (currentStrikes >= 5) {
      accountStatus = 'Suspended';
    } else if (currentStrikes >= 3) {
      accountStatus = 'Limited Visibility';
    } else {
      accountStatus = 'Active';
    }
  }

  void recordSuccessfulJob() {
    if (currentStrikes > 0) {
      jobsCompletedSinceLastStrike++;
      // Redemption: 3 successful jobs = -1 strike
      if (jobsCompletedSinceLastStrike >= 3) {
        currentStrikes--;
        jobsCompletedSinceLastStrike = 0;

        // Re-evaluate thresholds
        if (currentStrikes >= 5) {
          accountStatus = 'Suspended';
        } else if (currentStrikes >= 3) {
          accountStatus = 'Limited Visibility';
        } else {
          accountStatus = 'Active';
        }
      }
    }
  }
}

class SkillModel {
  final String name;
  final String icon; // Path to SVG or image asset
  final int tasksCompleted;

  SkillModel({
    required this.name,
    required this.icon,
    required this.tasksCompleted,
  });
}

class ReviewModel {
  final String id;
  final String reviewerName;
  final String reviewerAvatar;
  final double rating;
  final String timeAgo;
  final String text;
  final String? jobId;
  final DateTime? submittedAt;
  bool targetHasReviewed;

  ReviewModel({
    required this.id,
    required this.reviewerName,
    required this.reviewerAvatar,
    required this.rating,
    required this.timeAgo,
    required this.text,
    this.jobId,
    this.submittedAt,
    this.targetHasReviewed = true,
  });

  bool get isVisible {
    if (targetHasReviewed) return true;
    if (submittedAt != null && DateTime.now().difference(submittedAt!).inDays >= 14) return true;
    return false;
  }
}