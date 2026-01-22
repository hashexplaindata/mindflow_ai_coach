import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/headspace_theme.dart';
import '../../../../shared/widgets/loading_animation.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/widgets/paywall_trigger.dart';

/// Chat Screen for MindFlow AI Coach
/// Headspace-inspired design with NLP-adaptive coaching
///
/// Per @Architect rules:
/// - ConsumerWidget pattern (extends StatelessWidget with Provider)
/// - No setState - use ref.watch equivalent (context.watch)
/// - Handle ALL loading/error states with .when() pattern
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        // Scroll to bottom when messages change
        if (chatProvider.messages.isNotEmpty) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());
        }

        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: _buildAppBar(context, chatProvider),
          body: Column(
            children: [
              // Error banner
              if (chatProvider.errorMessage != null)
                _ErrorBanner(
                  message: chatProvider.errorMessage!,
                  onRetry: chatProvider.retryLastMessage,
                  onDismiss: chatProvider.clearError,
                ),

              // Messages list
              Expanded(
                child: chatProvider.isLoading
                    ? const _LoadingState()
                    : chatProvider.messages.isEmpty
                        ? _EmptyState(
                            onSuggestionTap: (suggestion) {
                              chatProvider.sendMessage(suggestion);
                            },
                          )
                        : _MessagesList(
                            messages: chatProvider.messages,
                            scrollController: _scrollController,
                          ),
              ),

              // Chat input
              ChatInput(
                onSend: chatProvider.sendMessage,
                enabled: !chatProvider.isSending,
                placeholder: chatProvider.isSending
                    ? 'Coach is thinking...'
                    : 'Type your message...',
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, ChatProvider provider) {
    return AppBar(
      backgroundColor: AppColors.cream,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CoachAvatar(size: 32),
          const SizedBox(width: AppSpacing.spacing8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MindFlow Coach',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralBlack,
                ),
              ),
              Text(
                provider.isSending ? 'Typing...' : 'Online',
                style: AppTextStyles.caption.copyWith(
                  color: provider.isSending
                      ? AppColors.primaryOrange
                      : AppColors.successGreen,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Pro unlock button (only if not pro)
        if (!context.watch<SubscriptionProvider>().isPro)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: UnlockProButton(),
          ),

        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: () {
            _showOptionsMenu(context, provider);
          },
        ),
      ],
    );
  }

  void _showOptionsMenu(BuildContext context, ChatProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusCard),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: AppSpacing.spacing12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutralMedium,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing16),

                // Options
                ListTile(
                  leading: const Icon(Icons.add_rounded),
                  title: const Text('New Conversation'),
                  onTap: () {
                    Navigator.pop(context);
                    provider.startNewChat();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history_rounded),
                  title: const Text('Chat History'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to history
                  },
                ),

                // Subscription Management
                ListTile(
                  leading: const Icon(Icons.star_rounded,
                      color: AppColors.primaryOrange),
                  title: const Text('Manage Subscription'),
                  subtitle: Text(
                    context.watch<SubscriptionProvider>().isPro
                        ? 'You are a Pro member'
                        : 'Upgrade to Pro',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    final subProvider = context.read<SubscriptionProvider>();
                    if (subProvider.isPro) {
                      subProvider.showCustomerCenter();
                    } else {
                      subProvider.showPaywall();
                    }
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.psychology_outlined),
                  title: const Text('My Profile'),
                  subtitle: Text(provider.userProfile.displayName),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to profile
                  },
                ),
                const SizedBox(height: AppSpacing.spacing16),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Loading state widget
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeadspaceLoader(),
          SizedBox(height: AppSpacing.spacing16),
          Text(
            'Loading your conversation...',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Empty state widget with suggestions
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onSuggestionTap,
  });

  final void Function(String) onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.spacing48),

          // Coach avatar
          const CoachAvatar(size: 80, state: CoachState.neutral),
          const SizedBox(height: AppSpacing.spacing24),

          // Welcome message
          const Text(
            'Hey there! 👋',
            style: AppTextStyles.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacing12),

          Text(
            'I\'m your MindFlow coach, trained in NLP frameworks from Bandler, Grinder, and James.\n\nI adapt to how YOUR brain works. What\'s on your mind?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.spacing32),

          // Suggestion cards
          Container(
            decoration: HeadspaceTheme.cardDecoration,
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Try asking about:',
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: AppSpacing.spacing12),
                _SuggestionTile(
                  emoji: '🎯',
                  text: 'Setting and achieving goals',
                  onTap: () => onSuggestionTap('Help me set a meaningful goal'),
                ),
                _SuggestionTile(
                  emoji: '🧠',
                  text: 'Understanding my thinking style',
                  onTap: () =>
                      onSuggestionTap('Tell me more about my thinking style'),
                ),
                _SuggestionTile(
                  emoji: '💪',
                  text: 'Overcoming procrastination',
                  onTap: () => onSuggestionTap(
                      'I\'ve been procrastinating on something important'),
                ),
                _SuggestionTile(
                  emoji: '🔄',
                  text: 'Breaking limiting beliefs',
                  onTap: () => onSuggestionTap(
                      'I have a belief that\'s holding me back'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.emoji,
    required this.text,
    required this.onTap,
  });

  final String emoji;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.spacing8,
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: AppSpacing.spacing12),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryOrange,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.neutralMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Messages list widget
class _MessagesList extends StatelessWidget {
  const _MessagesList({
    required this.messages,
    required this.scrollController,
  });

  final List messages;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.spacing16,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final showTimestamp = index == 0 ||
            messages[index]
                    .timestamp
                    .difference(messages[index - 1].timestamp)
                    .inMinutes >
                5;

        return MessageBubble(
          message: message,
          showTimestamp: showTimestamp,
        );
      },
    );
  }
}

/// Error banner widget
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onRetry,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing16,
        vertical: AppSpacing.spacing12,
      ),
      color: const Color(0x1AE57373), // errorRed at 10% opacity
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.errorRed,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.spacing12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.errorRed,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onDismiss,
            color: AppColors.errorRed,
          ),
        ],
      ),
    );
  }
}
