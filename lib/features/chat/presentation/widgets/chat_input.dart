import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/behavioral/behavioral_observer.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({
    super.key,
    required this.onSend,
    this.onTypingChanged,
    this.enabled = true,
    this.placeholder = 'What\'s on your mind?',
  });

  final void Function(String message) onSend;
  final void Function(bool isTyping)? onTypingChanged;
  final bool enabled;
  final String placeholder;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final BehavioralObserver _behavioralObserver = BehavioralObserver();
  bool _hasText = false;
  bool _isFocused = false;
  String _previousText = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final currentText = _controller.text;
    final hasText = currentText.trim().isNotEmpty;
    
    // Behavioral tracking
    if (currentText.length > _previousText.length) {
      // Character added
      _behavioralObserver.recordKeystroke(isBackspace: false);
    } else if (currentText.length < _previousText.length) {
      // Character deleted (backspace)
      _behavioralObserver.recordKeystroke(isBackspace: true);
    }
    _previousText = currentText;
    
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      widget.onTypingChanged?.call(hasText);
    }
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;

    // Complete behavioral tracking
    _behavioralObserver.recordMessageComplete();
    final cognitiveLoad = _behavioralObserver.inferCognitiveLoad();
    debugPrint('ChatInput: Cognitive load = ${(cognitiveLoad * 100).toStringAsFixed(1)}%');
    
    widget.onSend(text);
    _controller.clear();
    _previousText = '';
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isFocused
                ? AppColors.jobsSage.withValues(alpha: 0.05)
                : AppColors.neutralLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isFocused
                  ? AppColors.jobsSage.withValues(alpha: 0.4)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.jobsObsidian,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textHint,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacing20,
                        vertical: AppSpacing.spacing12,
                      ),
                    ),
                    onSubmitted: (_) => _onSend(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right: AppSpacing.spacing8,
                  bottom: AppSpacing.spacing4,
                ),
                child: AnimatedScale(
                  scale: _hasText ? 1.0 : 0.8,
                  duration: const Duration(milliseconds: 150),
                  child: AnimatedOpacity(
                    opacity: _hasText ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 150),
                    child: Material(
                      color: _hasText && widget.enabled
                          ? AppColors.jobsSage
                          : AppColors.neutralMedium,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _hasText && widget.enabled ? _onSend : null,
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
