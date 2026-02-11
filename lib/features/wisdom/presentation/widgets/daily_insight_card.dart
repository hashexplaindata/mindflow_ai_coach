import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/wisdom_item.dart';
import '../../domain/models/wisdom_category.dart';

class DailyInsightCard extends StatelessWidget {
  final WisdomItem insight;
  final VoidCallback? onTap;

  const DailyInsightCard({
    super.key,
    required this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.jobsObsidian.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  insight.category.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Insight',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.jobsObsidian.withValues(alpha: 0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.jobsObsidian,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.jobsObsidian.withValues(alpha: 0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class MiniWisdomCard extends StatelessWidget {
  final WisdomItem wisdom;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const MiniWisdomCard({
    super.key,
    required this.wisdom,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.jobsSage.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  wisdom.tone.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  wisdom.tone.displayName,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.jobsSage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              wisdom.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.jobsObsidian.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
            if (wisdom.author != null) ...[
              const SizedBox(height: 8),
              Text(
                '— ${wisdom.author}',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.jobsObsidian.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
