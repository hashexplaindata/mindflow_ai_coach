import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/wisdom_item.dart';
import '../../domain/models/wisdom_category.dart';
import '../../domain/services/wisdom_service.dart';
import '../../data/wisdom_content.dart';
import '../providers/wisdom_provider.dart';
import '../widgets/wisdom_card.dart';
import '../widgets/gratitude_prompt_card.dart';
import 'gratitude_journal_screen.dart';

class WisdomScreen extends StatefulWidget {
  const WisdomScreen({super.key});

  @override
  State<WisdomScreen> createState() => _WisdomScreenState();
}

class _WisdomScreenState extends State<WisdomScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jobsCream,
      body: SafeArea(
        child: Consumer<WisdomProvider>(
          builder: (context, wisdomProvider, child) {
            final todaysWisdom = wisdomProvider.todaysWisdom;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.jobsCream,
                  elevation: 0,
                  pinned: true,
                  expandedHeight: 100,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.book_outlined),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const GratitudeJournalScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            WisdomService.getWisdomGreeting(),
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.jobsObsidian,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (todaysWisdom != null) ...[
                          WisdomCard(
                            wisdom: todaysWisdom,
                            isFavorite:
                                wisdomProvider.isFavorite(todaysWisdom.id),
                            onFavoriteToggle: () {
                              wisdomProvider.toggleFavorite(todaysWisdom.id);
                              HapticFeedback.lightImpact();
                            },
                            onShare: () => _shareWisdom(todaysWisdom),
                          ),
                          const SizedBox(height: 32),
                        ],
                        GratitudePromptCard(
                          prompt: wisdomProvider.gratitudePrompt,
                          hasWrittenToday:
                              wisdomProvider.hasWrittenGratitudeToday,
                          onSubmit: (content) {
                            wisdomProvider.addGratitudeEntry(
                              content: content,
                              promptId: wisdomProvider.gratitudePrompt?.id,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gratitude saved'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            const Text(
                              'Browse Wisdom',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.jobsObsidian,
                              ),
                            ),
                            const Spacer(),
                            if (wisdomProvider.favoriteIds.isNotEmpty)
                              TextButton.icon(
                                onPressed: () => _showFavorites(context),
                                icon: const Icon(Icons.favorite, size: 16),
                                label: Text(
                                    '${wisdomProvider.favoriteIds.length} saved'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.jobsObsidian,
                    unselectedLabelColor:
                        AppColors.jobsObsidian.withValues(alpha: 0.4),
                    labelStyle: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    indicatorColor: AppColors.jobsSage,
                    indicatorWeight: 3,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    tabs: const [
                      Tab(text: '🔥 Motivation'),
                      Tab(text: '🌊 Calm'),
                      Tab(text: '🧘 Mindfulness'),
                      Tab(text: '🌳 Growth'),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _WisdomList(
                        items: WisdomContent.getWisdomByTone(
                            WisdomTone.motivation),
                        wisdomProvider: wisdomProvider,
                      ),
                      _WisdomList(
                        items: WisdomContent.getWisdomByTone(WisdomTone.calm),
                        wisdomProvider: wisdomProvider,
                      ),
                      _WisdomList(
                        items: WisdomContent.getWisdomByTone(
                            WisdomTone.mindfulness),
                        wisdomProvider: wisdomProvider,
                      ),
                      _WisdomList(
                        items: [
                          ...WisdomContent.getWisdomByTone(WisdomTone.growth),
                          ...WisdomContent.getWisdomByTone(
                              WisdomTone.gratitude),
                        ],
                        wisdomProvider: wisdomProvider,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _shareWisdom(WisdomItem wisdom) {
    final text = wisdom.author != null
        ? '"${wisdom.content}" — ${wisdom.author}'
        : wisdom.content;

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFavorites(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.jobsCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Consumer<WisdomProvider>(
              builder: (context, wisdomProvider, child) {
                final favorites = wisdomProvider.favoriteWisdom;

                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.jobsObsidian.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: AppColors.primaryOrange,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Saved Wisdom',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.jobsObsidian,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${favorites.length} items',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14,
                              color:
                                  AppColors.jobsObsidian.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final wisdom = favorites[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: WisdomCard(
                              wisdom: wisdom,
                              isFavorite: true,
                              isCompact: true,
                              onFavoriteToggle: () {
                                wisdomProvider.toggleFavorite(wisdom.id);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _WisdomList extends StatelessWidget {
  final List<WisdomItem> items;
  final WisdomProvider wisdomProvider;

  const _WisdomList({
    required this.items,
    required this.wisdomProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final wisdom = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: WisdomCard(
            wisdom: wisdom,
            isFavorite: wisdomProvider.isFavorite(wisdom.id),
            isCompact: true,
            onFavoriteToggle: () {
              wisdomProvider.toggleFavorite(wisdom.id);
              HapticFeedback.lightImpact();
            },
          ),
        );
      },
    );
  }
}
