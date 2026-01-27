import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/suggestion_chips.dart';
import '../widgets/typing_indicator.dart';
import '../../domain/models/conversation_context.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/widgets/paywall_trigger.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
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
        if (chatProvider.messages.isNotEmpty) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());
        }

        final conversationContext = chatProvider.getConversationContext();

        return Scaffold(
          backgroundColor: AppColors.jobsCream,
          appBar: _buildAppBar(context, chatProvider),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                if (chatProvider.errorMessage != null)
                  _ErrorBanner(
                    message: chatProvider.errorMessage!,
                    onRetry: chatProvider.retryLastMessage,
                    onDismiss: chatProvider.clearError,
                  ),
                Expanded(
                  child: chatProvider.isLoading
                      ? const _LoadingState()
                      : chatProvider.messages.isEmpty
                          ? _EmptyState(
                              context: conversationContext,
                              onSuggestionTap: chatProvider.sendMessage,
                            )
                          : _MessagesList(
                              messages: chatProvider.messages,
                              scrollController: _scrollController,
                              isSending: chatProvider.isSending,
                            ),
                ),
                if (chatProvider.hasMessages && !chatProvider.isSending)
                  QuickActionChips(
                    actions: conversationContext.getQuickActions(),
                    onTap: chatProvider.sendMessage,
                  ),
                ChatInput(
                  onSend: chatProvider.sendMessage,
                  enabled: !chatProvider.isSending,
                  placeholder: chatProvider.isSending
                      ? 'Presence is responding...'
                      : 'What\'s on your mind?',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, ChatProvider provider) {
    return AppBar(
      backgroundColor: AppColors.jobsCream,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.jobsObsidian.withOpacity(0.7),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CoachAvatar(size: 36, state: CoachState.neutral),
          const SizedBox(width: AppSpacing.spacing12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Presence',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.jobsObsidian,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  provider.isSending ? 'Responding...' : 'Here for you',
                  key: ValueKey(provider.isSending),
                  style: AppTextStyles.caption.copyWith(
                    color: provider.isSending
                        ? AppColors.jobsSage
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (!context.watch<SubscriptionProvider>().isPro)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: UnlockProButton(),
          ),
        IconButton(
          icon: Icon(
            Icons.more_vert_rounded,
            color: AppColors.jobsObsidian.withOpacity(0.7),
          ),
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
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusCard),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                ListTile(
                  leading: Icon(Icons.add_rounded, color: AppColors.jobsSage),
                  title: const Text('New Conversation'),
                  onTap: () {
                    Navigator.pop(context);
                    provider.clearHistory();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.refresh_rounded, color: AppColors.jobsSage),
                  title: const Text('Clear History'),
                  onTap: () {
                    Navigator.pop(context);
                    provider.clearHistory();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.star_rounded,
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
                  leading: Icon(Icons.psychology_outlined, color: AppColors.jobsSage),
                  title: const Text('Your Profile'),
                  subtitle: Text(provider.userProfile.displayName),
                  onTap: () {
                    Navigator.pop(context);
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

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CoachAvatar(size: 64, state: CoachState.thoughtful),
          const SizedBox(height: AppSpacing.spacing16),
          Text(
            'Preparing...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.context,
    required this.onSuggestionTap,
  });

  final ConversationContext context;
  final void Function(String) onSuggestionTap;

  @override
  Widget build(BuildContext buildContext) {
    final greeting = context.getWelcomeGreeting();
    final suggestions = context.getSuggestedStarters();
    final quickActions = context.getQuickActions();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.spacing32),
          const CoachAvatar(size: 80, state: CoachState.neutral),
          const SizedBox(height: AppSpacing.spacing24),
          Text(
            greeting,
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.jobsObsidian,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacing12),
          Text(
            'I adapt to how your mind works. Share what\'s present, and I\'ll meet you there.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacing32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.spacing8,
            runSpacing: AppSpacing.spacing8,
            children: quickActions.map((action) {
              return _QuickActionButton(
                action: action,
                onTap: () => onSuggestionTap(action.message),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.spacing32),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start a conversation:',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing12),
                ...suggestions.map((suggestion) {
                  return _SuggestionTile(
                    text: suggestion,
                    onTap: () => onSuggestionTap(suggestion),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.action,
    required this.onTap,
  });

  final QuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing16,
            vertical: AppSpacing.spacing12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.jobsSage.withOpacity(0.15),
                AppColors.jobsSage.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.jobsSage.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                action.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: AppSpacing.spacing8),
              Text(
                action.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.jobsObsidian,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.spacing12,
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.jobsSage,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.spacing12),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.jobsObsidian.withOpacity(0.8),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.jobsSage.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  const _MessagesList({
    required this.messages,
    required this.scrollController,
    required this.isSending,
  });

  final List messages;
  final ScrollController scrollController;
  final bool isSending;

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

        final isLastMessage = index == messages.length - 1;
        final showAvatar = !message.isUser &&
            (isLastMessage ||
                messages[index + 1].isUser ||
                messages[index + 1].timestamp
                        .difference(message.timestamp)
                        .inMinutes >
                    1);

        return MessageBubble(
          message: message,
          showTimestamp: showTimestamp,
          showAvatar: showAvatar,
        );
      },
    );
  }
}

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
      color: AppColors.errorRed.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
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
            child: Text(
              'Retry',
              style: TextStyle(color: AppColors.errorRed),
            ),
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
