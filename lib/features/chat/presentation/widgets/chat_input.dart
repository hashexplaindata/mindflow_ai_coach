import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Chat Input Widget
/// Headspace-style input field with send button
///
/// Per @Architect rules:
/// - Soft corners (16dp radius)
/// - Generous padding
/// - Smooth animations on focus
class ChatInput extends StatefulWidget {
  const ChatInput({
    super.key,
    required this.onSend,
    this.onTypingChanged,
    this.enabled = true,
    this.placeholder = 'Type your message...',
  });

  final void Function(String message) onSend;
  final void Function(bool isTyping)? onTypingChanged;
  final bool enabled;
  final String placeholder;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      widget.onTypingChanged?.call(hasText);
    }
  }

  void _onSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;

    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000), // black at 5% opacity
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text input
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.neutralLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacing16,
                      vertical: AppSpacing.spacing12,
                    ),
                  ),
                  onSubmitted: (_) => _onSend(),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.spacing12),

            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 48,
              height: 48,
              child: Material(
                color: _hasText && widget.enabled
                    ? AppColors.primaryOrange
                    : AppColors.neutralMedium,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _hasText && widget.enabled ? _onSend : null,
                  child: const Center(
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Suggestions chip row
/// Shows quick prompts for users who don't know what to say
class SuggestionChips extends StatelessWidget {
  const SuggestionChips({
    super.key,
    required this.onTap,
    this.suggestions = const [
      "I'm feeling stuck",
      "Help me set a goal",
      "I need motivation",
    ],
  });

  final void Function(String suggestion) onTap;
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing16,
      ),
      child: Row(
        children: suggestions.map((suggestion) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.spacing8),
            child: ActionChip(
              label: Text(
                suggestion,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryOrange,
                ),
              ),
              backgroundColor:
                  const Color(0x1AF4A261), // primaryOrange at 10% opacity
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              onPressed: () => onTap(suggestion),
            ),
          );
        }).toList(),
      ),
    );
  }
}
