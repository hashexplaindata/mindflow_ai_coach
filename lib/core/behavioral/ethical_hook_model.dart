/// **Ethical Hook Model Implementation**
///
/// **Based on:** Nir Eyal's "Hooked" model, filtered through MindFlow's Constitution
///
/// **The Paradox:** Hook models are powerful behavioral tools. They can be used
/// for evil (social media addiction) or good (habit formation, flow states).
///
/// **MindFlow's Stance:** We use hooks ONLY for:
/// 1. Building healthy habits (meditation, focus sessions)
/// 2. Teaching meta-cognitive skills (awareness, self-regulation)
/// 3. Cognitive unlocks (insights, not dopamine hits)
///
/// **Anti-Patterns Banned:**
/// ❌ Infinite scroll
/// ❌ Red notification badges
/// ❌ Artificial scarcity ("only 3 spots left!")
/// ❌ FOMO triggers ("your friends are ahead")
/// ❌ Dark UX (hiding unsubscribe, confusing settings)
///
/// **Constitutional Requirement:** All hook patterns must be disclosed during
/// onboarding with opt-out mechanism.
library ethical_hook_model;

class EthicalHookModel {
  // =============================================================================
  // PHASE 1: TRIGGER (Cue for Action)
  // =============================================================================

  /// **External Triggers** (User initiates, not us)
  ///
  /// ✅ Allowed:
  /// - User sets focus session reminder (they choose time)
  /// - User requests daily check-in (90-day streak, they control frequency)
  ///
  /// ❌ Banned:
  /// - Push notifications without explicit user request
  /// - "We miss you" guilt-trip messages
  /// - Random re-engagement tactics
  static List<TriggerType> getAllowedExternalTriggers() {
    return [
      TriggerType.userScheduledReminder, // They set the time
      TriggerType.habitStreakMilestone, // Celebrates real achievement
      TriggerType
          .flowWindowOpening, // Predictive, helpful (9am: "Your flow window")
    ];
  }

  /// **Internal Triggers** (Emotional cues)
  ///
  /// ✅ Allowed:
  /// - Boredom → "Start 5-minute curiosity sprint"
  /// - Procrastination → Meta-Model intervention
  /// - Anxiety → Breathing exercise suggestion
  ///
  /// ❌ Banned:
  /// - Exploiting loneliness for engagement
  /// - Creating artificial negative states to "solve"
  static Map<EmotionalState, String> getInternalTriggerResponses() {
    return {
      EmotionalState.boredom: 'Boredom is curiosity waiting to be directed. '
          'Start a 5-minute sprint on anything.',
      EmotionalState.procrastination: 'What are you avoiding? '
          'Can you start imperfectly for just 2 minutes?',
      EmotionalState.anxiety: 'Your nervous system is activated. '
          'Would a 4-second breath cycle help right now?',
      EmotionalState.overwhelm: 'Too many inputs. '
          'What\'s the ONE thing that would reduce this feeling?',
    };
  }

  // =============================================================================
  // PHASE 2: ACTION (Simplest Possible Behavior)
  // =============================================================================

  /// **Fogg Behavior Model:** Behavior = Motivation × Ability × Trigger
  ///
  /// **Strategy:** When motivation is low, make ability ULTRA high.
  ///
  /// ✅ Good Action Design:
  /// - "Start 2-minute session" (not 30-minute commitment)
  /// - "Log one word about your day" (not journaling requirement)
  /// - "Tap to acknowledge stress" (not full emotional inventory)
  ///
  /// ❌ Bad Action Design:
  /// - Requiring complex multi-step workflows
  /// - Hiding "skip" or "not now" options
  /// - Making exit harder than entry
  static Map<String, ActionComplexity> getMinimalActions() {
    return {
      'Start Focus Session': ActionComplexity.oneClick, // Just tap
      'Log Mood': ActionComplexity.oneClick, // Single emoji
      'View Insight': ActionComplexity.zeroClick, // Auto-displayed
      'Skip Session': ActionComplexity.oneClick, // Always visible
    };
  }

  /// **3-Click Rule:** Any core action must be reachable in ≤3 taps
  static bool validateActionComplexity(int clickCount) {
    return clickCount <= 3;
  }

  // =============================================================================
  // PHASE 3: VARIABLE REWARD (Unpredictable Reinforcement)
  // =============================================================================

  /// **The Science:** Variable rewards trigger dopamine more than predictable ones.
  /// Slot machines exploit this. MindFlow uses it ethically.
  ///
  /// ✅ Ethical Variable Rewards:
  /// - Random cognitive insights after flow sessions (learning, not points)
  /// - Unpredictable pattern discoveries ("You flow best after morning walks")
  /// - Occasional Milton Model wisdom drops (educational, not addictive)
  ///
  /// ❌ Unethical Variable Rewards:
  /// - Loot boxes, random badges, gamification points
  /// - Leaderboards (social comparison = anxiety)
  /// - Streaks that punish breaks (guilt-based retention)
  static List<RewardType> getEthicalRewards() {
    return [
      RewardType.cognitiveInsight, // "Your habit entropy dropped 40%!"
      RewardType.patternDiscovery, // "You focus best at 9am"
      RewardType.miltonModelWisdom, // Random hypnotic pattern (educational)
      RewardType.metaAwareness, // "Notice how you just self-corrected?"
    ];
  }

  /// **Anti-Reward:** What we DON'T reward
  static List<String> getBannedRewards() {
    return [
      'Points/XP systems',
      'Leaderboards',
      'Social comparison metrics',
      'Streak penalties (guilt)',
      'Artificial scarcity',
    ];
  }

  // =============================================================================
  // PHASE 4: INVESTMENT (User Commits)
  // =============================================================================

  /// **The Hook:** The more users invest, the harder it is to leave.
  /// **Ethical Use:** Only track investments that SERVE THE USER, not us.
  ///
  /// ✅ Ethical Investments:
  /// - Personalized habit data (helps them, not us)
  /// - Milton Model training (they benefit from better suggestions)
  /// - Flow insights (their cognitive advantage)
  ///
  /// ❌ Unethical Investments:
  /// - Social graphs (friend networks to trap users)
  /// - Sunk cost manipulation ("You've spent 100 hours here!")
  /// - Content that only exists in our ecosystem (lock-in)
  static Map<String, InvestmentValue> getEthicalInvestments() {
    return {
      'Habit Entropy History': InvestmentValue.userOwned, // Their data
      'Flow Window Insights': InvestmentValue.userOwned, // Their advantage
      'VAK Profile': InvestmentValue.userOwned, // Their learning style
      'Meta-Model Interventions': InvestmentValue.userOwned, // Their growth
    };
  }

  /// **Constitutional Guarantee:** All user investments are exportable (GDPR Art. 20)
  static Future<Map<String, dynamic>> exportUserInvestments(
      String userId) async {
    // In production: return all user data in portable JSON format
    return {
      'user_id': userId,
      'habit_data': '...',
      'flow_insights': '...',
      'vak_profile': '...',
      'exportable': true,
      'format': 'JSON',
    };
  }

  // =============================================================================
  // TRANSPARENCY & OPT-OUT
  // =============================================================================

  /// **Constitutional Requirement:** Disclose hook mechanics during onboarding
  static String getOnboardingDisclosure() {
    return '''
MindFlow uses behavioral science to help you build better habits.

Here's how it works:
1. **Triggers**: We'll remind you at times YOU choose (not random)
2. **Actions**: Everything is 1-click simple (no complexity traps)
3. **Rewards**: You'll get insights and patterns (not points or badges)
4. **Investment**: Your data helps YOU (it's exportable anytime)

We DON'T use:
❌ Infinite scroll or attention traps
❌ Red notification badges
❌ Guilt-based retention
❌ Social comparison or leaderboards

You can disable ANY of these features in Settings.
    ''';
  }

  /// **Opt-Out Mechanism:** User can disable all hook patterns
  static Map<String, bool> getUserHookPreferences() {
    return {
      'allow_reminders': true, // Can be disabled
      'allow_insights': true, // Can be disabled
      'allow_pattern_discovery': true, // Can be disabled
      'allow_milton_wisdom': true, // Can be disabled
    };
  }
}

// =============================================================================
// DATA STRUCTURES
// =============================================================================

enum TriggerType {
  userScheduledReminder,
  habitStreakMilestone,
  flowWindowOpening,
}

enum EmotionalState {
  boredom,
  procrastination,
  anxiety,
  overwhelm,
}

enum ActionComplexity {
  zeroClick, // Auto-displayed
  oneClick, // Single tap
  twoClick, // Two taps
  threeClick, // Three taps (max allowed)
}

enum RewardType {
  cognitiveInsight, // Pattern discovery
  patternDiscovery, // Behavioral insight
  miltonModelWisdom, // Educational NLP
  metaAwareness, // Self-awareness prompt
}

enum InvestmentValue {
  userOwned, // Belongs to user, benefits user
  platformLockIn, // Traps user (BANNED)
}
