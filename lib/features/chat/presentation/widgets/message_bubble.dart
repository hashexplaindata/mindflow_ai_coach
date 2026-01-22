import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/models/message.dart';

/// Message Bubble Widget
/// Headspace-style chat bubble with soft corners and appropriate colors
///
/// Per @Architect rules:
/// - All corners rounded (min 16dp)
/// - Soft shadows on cards
/// - Generous spacing (8dp grid)
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.showTimestamp = false,
  });

  final Message message;
  final bool showTimestamp;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? AppSpacing.spacing48 : AppSpacing.spacing8,
        right: isUser ? AppSpacing.spacing8 : AppSpacing.spacing48,
        bottom: AppSpacing.spacing12,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message bubble
          Container(
            decoration: BoxDecoration(
              color:
                  isUser ? AppColors.primaryOrange : AppColors.cardBackground,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 20),
              ),
              boxShadow: isUser
                  ? null
                  : [
                      const BoxShadow(
                        color: Color(0x0D000000), // black at 5% opacity
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
              vertical: AppSpacing.spacing12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message content
                if (message.isStreaming && message.content.isEmpty)
                  _TypingIndicator()
                else
                  _MessageContent(
                    content: message.content,
                    isUser: isUser,
                  ),
              ],
            ),
          ),

          // Timestamp
          if (showTimestamp && !message.isStreaming)
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.spacing4,
                left: AppSpacing.spacing8,
                right: AppSpacing.spacing8,
              ),
              child: Text(
                _formatTimestamp(message.timestamp),
                style: AppTextStyles.chatTimestamp,
              ),
            ),
        ],
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

/// Message content with markdown-lite formatting
class _MessageContent extends StatelessWidget {
  const _MessageContent({
    required this.content,
    required this.isUser,
  });

  final String content;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    // Simple markdown parsing for **bold** and emojis
    return Text.rich(
      _parseContent(content),
      style: isUser ? AppTextStyles.chatUser : AppTextStyles.chatAssistant,
    );
  }

  TextSpan _parseContent(String text) {
    final List<InlineSpan> spans = [];
    final boldPattern = RegExp(r'\*\*(.*?)\*\*');

    int lastEnd = 0;
    for (final match in boldPattern.allMatches(text)) {
      // Add text before the match
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      // Add bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return TextSpan(children: spans);
  }
}

/// Typing indicator (3 bouncing dots)
class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: -6.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Staggered start
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animations[index].value),
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neutralMedium,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Coach Avatar Widget
/// Shows a friendly avatar for the AI coach
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
      decoration: const BoxDecoration(
        gradient: AppColors.sageGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x4DB2AC88), // sage at 30% opacity
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getEmoji(),
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }

  String _getEmoji() {
    switch (state) {
      case CoachState.neutral:
        return '🧠';
      case CoachState.happy:
        return '😊';
      case CoachState.thoughtful:
        return '🤔';
      case CoachState.celebrating:
        return '🎉';
    }
  }
}

/// Coach emotional states
enum CoachState {
  neutral,
  happy,
  thoughtful,
  celebrating,
}
