import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/wisdom_item.dart';

class GratitudePromptCard extends StatefulWidget {
  final WisdomItem? prompt;
  final Function(String content)? onSubmit;
  final bool hasWrittenToday;

  const GratitudePromptCard({
    super.key,
    this.prompt,
    this.onSubmit,
    this.hasWrittenToday = false,
  });

  @override
  State<GratitudePromptCard> createState() => _GratitudePromptCardState();
}

class _GratitudePromptCardState extends State<GratitudePromptCard> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_controller.text.trim().isEmpty) return;

    widget.onSubmit?.call(_controller.text.trim());
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.jobsObsidian.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('🙏', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gratitude',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.jobsObsidian,
                      ),
                    ),
                    if (widget.hasWrittenToday)
                      Text(
                        'Completed today',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: AppColors.successGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.hasWrittenToday)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColors.successGreen,
                    size: 16,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          if (widget.prompt != null)
            Text(
              widget.prompt!.content,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.jobsObsidian.withOpacity(0.8),
                height: 1.4,
              ),
            ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = true;
              });
              _focusNode.requestFocus();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.jobsCream.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isExpanded
                      ? AppColors.jobsSage.withOpacity(0.5)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: _isExpanded ? 4 : 2,
                    decoration: InputDecoration(
                      hintText: 'Write what you\'re grateful for...',
                      hintStyle: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        color: AppColors.jobsObsidian.withOpacity(0.4),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      color: AppColors.jobsObsidian,
                      height: 1.5,
                    ),
                    onTap: () {
                      setState(() {
                        _isExpanded = true;
                      });
                    },
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _controller.clear();
                            _focusNode.unfocus();
                            setState(() {
                              _isExpanded = false;
                            });
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.jobsObsidian.withOpacity(0.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.jobsSage,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
