import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../chat/presentation/screens/chat_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).refreshProgress();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _onSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    context.read<ChatProvider>().startNewFocus(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Theme-based colors (from MindFlowTheme)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;
    final hintColor = textColor.withValues(alpha: 0.3);
    final accentColor = colorScheme.primary;

    final currentFocus = context.watch<ChatProvider>().currentFocus;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: currentFocus == null
                ? _buildIntentionInput(
                    context, textColor, hintColor, accentColor)
                : _buildActiveFocusDashboard(
                    context, currentFocus, textColor, accentColor),
          ),
        ),
      ),
    );
  }

  Widget _buildIntentionInput(BuildContext context, Color textColor,
      Color hintColor, Color accentColor) {
    return SingleChildScrollView(
      key: const ValueKey('intention'),
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 24.0,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom -
            48, // account for padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // — Greeting
            Text(
              _getGreeting(),
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: textColor,
                height: 1.1,
                letterSpacing: -1.0,
              ),
            ),

            const SizedBox(height: 32),

            const Spacer(),

            // — The "One Thing" prompt
            Center(
              child: Text(
                'What is the one thing\non your mind?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: textColor.withValues(alpha: 0.6),
                  height: 1.4,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // — Minimalist input field
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              textAlign: TextAlign.center,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: textColor,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'Start typing...',
                hintStyle: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: hintColor,
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: textColor.withValues(alpha: 0.12),
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: textColor.withValues(alpha: 0.12),
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: accentColor.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
              ),
              onSubmitted: (_) => _onSubmit(),
            ),

            const SizedBox(height: 32),

            // — Submit button (only visible when text is present)
            Center(
              child: AnimatedOpacity(
                opacity: _hasText ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedScale(
                  scale: _hasText ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _hasText ? _onSubmit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        'Begin',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFocusDashboard(
      BuildContext context, String focus, Color textColor, Color accentColor) {
    return Container(
      key: const ValueKey('focus'),
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            'CURRENT FOCUS',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textColor.withValues(alpha: 0.4),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            focus,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: textColor,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(initialMessage: focus),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
              ),
              child: const Text(
                'Enter Reflection',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.read<ChatProvider>().clearFocus();
                _controller.clear();
                setState(() => _hasText = false);
              },
              child: Text(
                'Reset Focus',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor.withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
