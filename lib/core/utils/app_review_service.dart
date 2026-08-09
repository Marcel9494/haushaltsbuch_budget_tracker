import 'package:in_app_review/in_app_review.dart';

class AppReviewService {
  final InAppReview _inAppReview = InAppReview.instance;

  // Für später Stand: 03.08.2026
  Future<void> requestAppReview() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
    }
  }

  Future<void> openStore() async {
    await _inAppReview.openStoreListing();
  }
}
