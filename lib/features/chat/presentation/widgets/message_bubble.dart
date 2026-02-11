import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/models/message.dart';
import 'typing_indicator.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.showTimestamp = false,
    this.showAvatar = true,
  });

  final Message message;
  final bool showTimestamp;
  final bool showAvatar;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

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
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.only(
          left: isUser ? AppSpacing.spacing48 : AppSpacing.spacing8,
          right: isUser ? AppSpacing.spacing8 : AppSpacing.spacing48,
          bottom: AppSpacing.spacing12,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isUser && widget.showAvatar) ...[
                  const CoachAvatar(size: 32),
                  const SizedBox(width: AppSpacing.spacing8),
                ],
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isUser
                          ? AppColors.cardBackground
                          : AppColors.jobsSage.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isUser
                              ? Colors.black.withValues(alpha: 0.05)
                              : AppColors.jobsSage.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: isUser
                          ? Border.all(
                              color: AppColors.neutralMedium
                                  .withValues(alpha: 0.5),
                              width: 1,
                            )
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacing16,
                      vertical: AppSpacing.spacing12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.message.isStreaming &&
                            widget.message.content.isEmpty)
                          const TypingIndicator()
                        else if (widget.message.isLoading)
                          const TypingIndicator()
                        else
                          _MessageContent(
                            content: widget.message.content,
                            isUser: isUser,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (widget.showTimestamp &&
                !widget.message.isStreaming &&
                !widget.message.isLoading)
              Padding(
                padding: EdgeInsets.only(
                  top: AppSpacing.spacing4,
                  left: isUser ? 0 : 40,
                  right: isUser ? 0 : 0,
                ),
                child: Text(
                  _formatTimestamp(widget.message.timestamp),
                  style: AppTextStyles.chatTimestamp.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }
}

class _MessageContent extends StatelessWidget {
  const _MessageContent({
    required this.content,
    required this.isUser,
  });

  final String content;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      _parseContent(content),
      style: isUser
          ? AppTextStyles.bodyMedium.copyWith(
              color: AppColors.jobsObsidian,
              height: 1.5,
            )
          : AppTextStyles.bodyMedium.copyWith(
              color: AppColors.jobsObsidian.withValues(alpha: 0.9),
              height: 1.5,
            ),
    );
  }

  TextSpan _parseContent(String text) {
    final List<InlineSpan> spans = [];
    final boldPattern = RegExp(r'\*\*(.*?)\*\*');

    int lastEnd = 0;
    for (final match in boldPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return TextSpan(children: spans);
  }
}

class CoachAvatar extends StatelessWidget {
  const CoachAvatar({
    super.key,
    this.size = 40,
    this.state = CoachState.neutral,
  });

  final double size;
  final CoachState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.jobsSage,
            AppColors.jobsSage.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.jobsSage.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getEmoji(),
          style: TextStyle(fontSize: size * 0.45),
        ),
      ),
    );
  }

  String _getEmoji() {
    switch (state) {
      case CoachState.neutral:
        return '🧘';
      case CoachState.happy:
        return '😊';
      case CoachState.thoughtful:
        return '🤔';
      case CoachState.celebrating:
        return '🎉';
    }
  }
}

enum CoachState {
  neutral,
  happy,
  thoughtful,
  celebrating,
}

class StreamingMessageBubble extends StatelessWidget {
  const StreamingMessageBubble({
    super.key,
    required this.content,
    this.isComplete = false,
  });

  final String content;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.spacing8,
        right: AppSpacing.spacing48,
        bottom: AppSpacing.spacing12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CoachAvatar(size: 32),
          const SizedBox(width: AppSpacing.spacing8),
          Flexible(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: AppColors.jobsSage.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.jobsSage.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing16,
                vertical: AppSpacing.spacing12,
              ),
              child: content.isEmpty
                  ? const TypingIndicator()
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            content,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color:
                                  AppColors.jobsObsidian.withValues(alpha: 0.9),
                              height: 1.5,
                            ),
                          ),
                        ),
                        if (!isComplete)
                          Container(
                            margin: const EdgeInsets.only(left: 2),
                            width: 2,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.jobsSage,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
