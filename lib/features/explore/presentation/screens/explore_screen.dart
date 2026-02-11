import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../meditation/domain/models/meditation_session.dart';
import '../../../meditation/domain/models/meditation_category.dart';
import '../../../meditation/domain/models/sample_data.dart';
import '../../../meditation/presentation/screens/player_screen.dart';
import '../../../subscription/presentation/screens/subscription_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  final MeditationCategory? initialCategory;

  const ExploreScreen({super.key, this.initialCategory});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  MeditationCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    if (widget.initialCategory != null) {
      _searchQuery = widget.initialCategory!.displayName;
      _searchController.text = _searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MeditationSession> _getFilteredMeditations() {
    if (_searchQuery.isEmpty) {
      return SampleData.allMeditations;
    }
    return SampleData.allMeditations.where((m) {
      return m.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.category.displayName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _handleMeditationTap(MeditationSession meditation) {
    final userState = ref.read(userProvider);

    if (meditation.isPremium && !userState.isSubscribed) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SubscriptionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const PlayerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 200),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jobsCream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.spacing16),
                    Row(
                      children: [
                        if (widget.initialCategory != null)
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.jobsObsidian,
                                size: 22,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            widget.initialCategory != null
                                ? widget.initialCategory!.displayName
                                : 'Explore',
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.jobsObsidian,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.spacing24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.jobsObsidian.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _selectedCategory = null;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search meditations...',
                          hintStyle: TextStyle(
                            fontFamily: 'DM Sans',
                            color:
                                AppColors.jobsObsidian.withValues(alpha: 0.4),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color:
                                AppColors.jobsObsidian.withValues(alpha: 0.4),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _searchQuery = '';
                                      _searchController.clear();
                                      _selectedCategory = null;
                                    });
                                  },
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: AppColors.jobsObsidian
                                        .withValues(alpha: 0.4),
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Text(
                        'Search Results',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.jobsObsidian,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.jobsSage.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_getFilteredMeditations().length}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.jobsSage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _getFilteredMeditations().isEmpty
                  ? SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 48),
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: AppColors.jobsObsidian
                                    .withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No meditations found',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.jobsObsidian
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try searching for something else',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 14,
                                  color: AppColors.jobsObsidian
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final meditation = _getFilteredMeditations()[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _MeditationListTile(
                                meditation: meditation,
                                onTap: () => _handleMeditationTap(meditation),
                              ),
                            );
                          },
                          childCount: _getFilteredMeditations().length,
                        ),
                      ),
                    ),
            ] else ...[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = MeditationCategory.values[index];
                    final meditations =
                        SampleData.getMeditationsByCategory(category);
                    return _CategorySection(
                      category: category,
                      meditations: meditations,
                      onMeditationTap: _handleMeditationTap,
                    );
                  },
                  childCount: MeditationCategory.values.length,
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final MeditationCategory category;
  final List<MeditationSession> meditations;
  final Function(MeditationSession) onMeditationTap;

  const _CategorySection({
    required this.category,
    required this.meditations,
    required this.onMeditationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: Row(
              children: [
                Text(
                  category.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  category.displayName,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.jobsObsidian,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              itemCount: meditations.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                      right: index < meditations.length - 1 ? 16 : 0),
                  child: _MeditationCard(
                    meditation: meditations[index],
                    onTap: () => onMeditationTap(meditations[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MeditationCard extends ConsumerWidget {
  final MeditationSession meditation;
  final VoidCallback onTap;

  const _MeditationCard({
    required this.meditation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final isLocked = meditation.isPremium && !userState.isSubscribed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.jobsObsidian.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.jobsSage.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    meditation.formattedDuration,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.jobsSage,
                    ),
                  ),
                ),
                const Spacer(),
                if (isLocked)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 14,
                      color: AppColors.primaryOrange,
                    ),
                  )
                else if (meditation.isPremium)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.jobsSage.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColors.jobsSage,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              meditation.title,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isLocked
                    ? AppColors.jobsObsidian.withValues(alpha: 0.5)
                    : AppColors.jobsObsidian,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              meditation.description,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: AppColors.jobsObsidian
                    .withValues(alpha: isLocked ? 0.3 : 0.5),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MeditationListTile extends ConsumerWidget {
  final MeditationSession meditation;
  final VoidCallback onTap;

  const _MeditationListTile({
    required this.meditation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final isLocked = meditation.isPremium && !userState.isSubscribed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.jobsObsidian.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.jobsSage.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  meditation.category.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meditation.title,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isLocked
                          ? AppColors.jobsObsidian.withValues(alpha: 0.5)
                          : AppColors.jobsObsidian,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${meditation.category.displayName} • ${meditation.formattedDuration}',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: AppColors.jobsObsidian
                          .withValues(alpha: isLocked ? 0.3 : 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 16,
                  color: AppColors.primaryOrange,
                ),
              )
            else if (meditation.isPremium)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.jobsSage.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: AppColors.jobsSage,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
