import 'package:depi_final_project/core/widgets/feedback/app_feedback.dart';
import 'package:flutter/material.dart';

class SnackbarHelper {
  SnackbarHelper._();

  static void showSuccess(BuildContext context, String message) =>
      AppFeedback.showSnackBar(context, message, type: FeedbackType.success);

  static void showError(BuildContext context, String message) =>
      AppFeedback.showSnackBar(context, message, type: FeedbackType.error);

  static void showInfo(BuildContext context, String message) =>
      AppFeedback.showSnackBar(context, message);
}
