import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/startup_profile/models/startup.dart';
import '../auth/logout_confirmation.dart';

/// Shown for a startup profile that isn't verified yet — either still
/// pending review, or rejected by an admin.
class PendingApprovalScreen extends StatelessWidget {
  final Startup startup;
  const PendingApprovalScreen({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    final rejected = startup.isRejected;

    return Scaffold(
      appBar: AppBar(
        title: Text(rejected ? 'Not approved' : 'Verification pending'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => confirmAndLogOut(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: rejected ? AppColors.errorBg : AppColors.warningBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    rejected ? Icons.block_outlined : Icons.hourglass_top,
                    color: rejected ? AppColors.error : AppColors.warning,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(startup.name, style: AppTextStyles.title, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  rejected
                      ? "Your startup profile wasn't approved for VentureConnect. "
                          'Reach out to the ALU admin team if you think this needs a second look.'
                      : "Your startup profile is under review. An ALU admin needs to verify "
                          "it before you can post opportunities. This usually doesn't take long.",
                  style: AppTextStyles.bodyMuted,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
