import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/wisdom_item.dart';
import '../../domain/models/wisdom_category.dart';

class WisdomCard extends StatelessWidget {
  final WisdomItem wisdom;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onShare;
  final VoidCallback? onTap;
  final bool isCompact;

  const WisdomCard({
    super.key,
    required this.wisdom,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onShare,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isCompact ? 20 : 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.jobsSage,
              AppColors.jobsSage.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.jobsSage.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        wisdom.category.emoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        wisdom.category.displayName.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (onFavoriteToggle != null)
                  _ActionButton(
                    icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                    onTap: onFavoriteToggle!,
                  ),
                if (onShare != null) ...[
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.share_outlined,
                    onTap: onShare!,
                  ),
                ],
              ],
            ),

            SizedBox(height: isCompact ? 16 : 24),

            Text(
              wisdom.content,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: isCompact ? 20 : 26,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.4,
                letterSpacing: -0.3,
              ),
            ),

            if (wisdom.author != null) ...[
              SizedBox(height: isCompact ? 12 : 20),
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    wisdom.author!,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: isCompact ? 13 : 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],

            if (!isCompact) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          wisdom.tone.emoji,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          wisdom.tone.displayName,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

class WisdomCardHero extends StatelessWidget {
  final WisdomItem wisdom;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;
  final VoidCallback? onResonates;
  final VoidCallback? onShowAnother;
  final bool? hasResonated;
  final String? greeting;

  const WisdomCardHero({
    super.key,
    required this.wisdom,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
    this.onResonates,
    this.onShowAnother,
    this.hasResonated,
    this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.jobsSage,
              AppColors.jobsSage.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.jobsSage.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '✨',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        greeting?.toUpperCase() ?? 'CHOSEN FOR YOU',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (onFavoriteToggle != null)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onFavoriteToggle!();
                    },
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white.withOpacity(0.9),
                      size: 22,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              wisdom.content,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.4,
                letterSpacing: -0.3,
              ),
            ),

            if (wisdom.author != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    wisdom.author!,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            Row(
              children: [
                if (onResonates != null)
                  Expanded(
                    child: _FeedbackButton(
                      label: 'This resonates',
                      icon: Icons.favorite_rounded,
                      isSelected: hasResonated == true,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onResonates!();
                      },
                    ),
                  ),
                if (onResonates != null && onShowAnother != null)
                  const SizedBox(width: 12),
                if (onShowAnother != null)
                  Expanded(
                    child: _FeedbackButton(
                      label: 'Show another',
                      icon: Icons.refresh_rounded,
                      isSelected: false,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onShowAnother!();
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white 
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? AppColors.jobsSage 
                  : Colors.white.withOpacity(0.9),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? AppColors.jobsSage 
                    : Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
