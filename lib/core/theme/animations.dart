import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../theme/mindflow_theme.dart';

/// **Breathing Background Animation**
///
/// **The Story:** Like a meditative breath cycle, the background subtly
/// expands and contracts to create a calming ambient effect.
///
/// **Science:** 4-second breath cycle (inhale 2s, exhale 2s) synchronizes
/// with parasympathetic nervous system activation (vagal tone).
///
/// **Use Case:** Background of focus sessions, meditation timer
class BreathingBackground extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color accentColor;

  const BreathingBackground({
    super.key,
    required this.child,
    this.baseColor = MindFlowTheme.cream,
    this.accentColor = MindFlowTheme.sageLight,
  });

  @override
  State<BreathingBackground> createState() => _BreathingBackgroundState();
}

class _BreathingBackgroundState extends State<BreathingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();

    // 4-second breathing cycle (infinite loop)
    _controller = AnimationController(
      duration: MindFlowTheme.durationBreath,
      vsync: this,
    )..repeat(reverse: true);

    // Smooth ease-in-out for natural breath feel
    _breathAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathAnimation,
      builder: (context, child) {
        final scale = 1.0 + (_breathAnimation.value * 0.02); // 2% expansion
        final opacity = 0.5 + (_breathAnimation.value * 0.5); // Fade in/out

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: scale,
              colors: [
                widget.accentColor.withValues(alpha: opacity * 0.3),
                widget.baseColor,
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// **SpringSimulation Transition**
///
/// **The Story:** Like a perfectly tuned suspension system, transitions
/// feel organic and inevitable rather than robotic.
///
/// **Physics:** Uses spring simulation (mass, stiffness, damping) instead
/// of linear curves for natural motion.
///
/// **Use Case:** Page transitions, modal animations, card reveals
class SpringTransition extends StatelessWidget {
  final Widget child;
  final bool visible;
  final Duration duration;

  const SpringTransition({
    super.key,
    required this.child,
    required this.visible,
    this.duration = MindFlowTheme.durationStandard,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: visible ? 1.0 : 0.0),
      duration: duration,
      curve: _springCurve(),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (value * 0.2), // Scale from 80% to 100%
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Creates a spring-like curve
  Curve _springCurve() {
    const spring = SpringDescription(
      mass: 1.0,
      stiffness: 100.0,
      damping: 15.0,
    );

    final simulation = SpringSimulation(spring, 0.0, 1.0, 0.0);

    return _SpringCurve(simulation);
  }
}

/// Custom curve based on SpringSimulation
class _SpringCurve extends Curve {
  final SpringSimulation simulation;

  const _SpringCurve(this.simulation);

  @override
  double transformInternal(double t) {
    // SpringSimulation expects time in seconds, t is 0-1
    return simulation.x(t * 0.4); // 400ms total duration
  }
}

/// **Ripple Feedback Animation**
///
/// **The Story:** Like a pebble dropped in water, button presses create
/// satisfying ripple effects that confirm the action.
///
/// **Use Case:** All interactive elements (buttons, cards, list items)
class RippleFeedback extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? rippleColor;

  const RippleFeedback({
    super.key,
    required this.child,
    required this.onTap,
    this.rippleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: (rippleColor ?? MindFlowTheme.sage).withValues(alpha: 0.2),
        highlightColor:
            (rippleColor ?? MindFlowTheme.sage).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(MindFlowTheme.radius16),
        child: child,
      ),
    );
  }
}

/// **Flow Shimmer Effect**
///
/// **The Story:** When in flow state, UI elements shimmer subtly to
/// reinforce the "in the zone" feeling.
///
/// **Use Case:** Flow session indicator, flow streak ring
class FlowShimmer extends StatefulWidget {
  final Widget child;
  final bool isActive;

  const FlowShimmer({
    super.key,
    required this.child,
    required this.isActive,
  });

  @override
  State<FlowShimmer> createState() => _FlowShimmerState();
}

class _FlowShimmerState extends State<FlowShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _shimmerAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                MindFlowTheme.flowBlue.withValues(alpha: 0.0),
                MindFlowTheme.flowBlue.withValues(alpha: 0.3),
                MindFlowTheme.flowBlue.withValues(alpha: 0.0),
              ],
              stops: [
                0.0,
                _shimmerAnimation.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// **Fade-In Stagger**
///
/// **The Story:** List items don't just appear—they cascade in like
/// dominos, creating a sense of order and intentionality.
///
/// **Use Case:** Insight cards, habit list, chat messages
class FadeInStagger extends StatelessWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration staggerDelay;

  const FadeInStagger({
    super.key,
    required this.children,
    this.delay = Duration.zero,
    this.staggerDelay = const Duration(milliseconds: 80),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        children.length,
        (index) => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: MindFlowTheme.durationQuick,
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: children[index],
        ),
      ),
    );
  }
}
