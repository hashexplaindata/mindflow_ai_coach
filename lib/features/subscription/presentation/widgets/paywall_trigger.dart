import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/subscription_provider.dart';

/// A wrapper widget that triggers the Paywall when tapped
/// Use this to wrap locked features or upgrade buttons
class PaywallTrigger extends StatelessWidget {
  const PaywallTrigger({
    super.key,
    required this.child,
    this.onPurchaseSuccess,
  });

  final Widget child;
  final VoidCallback? onPurchaseSuccess;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final provider = context.read<SubscriptionProvider>();
        final success = await provider.showPaywall();
        if (success) {
          onPurchaseSuccess?.call();
        }
      },
      child: child,
    );
  }
}

/// A standard "Unlock Pro" button
class UnlockProButton extends StatelessWidget {
  const UnlockProButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PaywallTrigger(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_open_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Unlock Pro',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
