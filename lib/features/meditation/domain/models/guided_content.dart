class GuidedPrompt {
  final int secondsFromStart;
  final String text;
  final PromptType type;

  const GuidedPrompt({
    required this.secondsFromStart,
    required this.text,
    this.type = PromptType.guidance,
  });
}

enum PromptType {
  guidance,
  breatheIn,
  hold,
  breatheOut,
  affirmation,
  transition,
}

class GuidedContent {
  final String meditationId;
  final List<GuidedPrompt> prompts;

  const GuidedContent({
    required this.meditationId,
    required this.prompts,
  });

  GuidedPrompt? getPromptAt(int elapsedSeconds) {
    GuidedPrompt? currentPrompt;
    for (final prompt in prompts) {
      if (prompt.secondsFromStart <= elapsedSeconds) {
        currentPrompt = prompt;
      } else {
        break;
      }
    }
    return currentPrompt;
  }

  GuidedPrompt? getNextPrompt(int elapsedSeconds) {
    for (final prompt in prompts) {
      if (prompt.secondsFromStart > elapsedSeconds) {
        return prompt;
      }
    }
    return null;
  }
}

class GuidedMeditationScripts {
  static const Map<String, GuidedContent> scripts = {
    'stress_1': _releaseTensionScript,
    'stress_2': _stressSosScript,
    'anxiety_1': _easeAnxietyScript,
    'sleep_1': _sleepyTimeScript,
    'focus_1': _sharpenFocusScript,
  };

  static GuidedContent? getScript(String meditationId) {
    return scripts[meditationId];
  }

  static const GuidedContent _releaseTensionScript = GuidedContent(
    meditationId: 'stress_1',
    prompts: [
      GuidedPrompt(
        secondsFromStart: 0,
        text: 'Find a comfortable position and gently close your eyes.',
      ),
      GuidedPrompt(
        secondsFromStart: 8,
        text: 'Allow your shoulders to drop away from your ears.',
      ),
      GuidedPrompt(
        secondsFromStart: 18,
        text: 'Take a slow, deep breath in through your nose...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 24,
        text: 'Hold gently...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 28,
        text: 'And slowly release through your mouth...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 36,
        text: 'Feel any tension beginning to melt away.',
      ),
      GuidedPrompt(
        secondsFromStart: 46,
        text: 'Now bring your attention to your forehead.',
      ),
      GuidedPrompt(
        secondsFromStart: 54,
        text: 'Notice any tightness there. Let it soften.',
      ),
      GuidedPrompt(
        secondsFromStart: 64,
        text: 'Breathe in deeply...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 70,
        text: 'Hold...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 74,
        text: 'Release with a soft sigh...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 84,
        text: 'Move your awareness to your jaw.',
      ),
      GuidedPrompt(
        secondsFromStart: 92,
        text: 'Let your jaw slightly part, releasing any clenching.',
      ),
      GuidedPrompt(
        secondsFromStart: 102,
        text: 'Feel how good it feels to let go.',
      ),
      GuidedPrompt(
        secondsFromStart: 112,
        text: 'Now notice your neck and shoulders.',
      ),
      GuidedPrompt(
        secondsFromStart: 122,
        text: 'With each exhale, let them drop a little more.',
      ),
      GuidedPrompt(
        secondsFromStart: 134,
        text: 'Breathe in calm and peace...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 140,
        text: 'Hold this peaceful feeling...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 144,
        text: 'Exhale any remaining stress...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 154,
        text: 'Allow your arms to feel heavy and relaxed.',
      ),
      GuidedPrompt(
        secondsFromStart: 166,
        text: 'Your hands are soft, fingers gently curled.',
      ),
      GuidedPrompt(
        secondsFromStart: 178,
        text: 'Feel the wave of relaxation moving down your spine.',
      ),
      GuidedPrompt(
        secondsFromStart: 190,
        text: 'Your back is supported and at ease.',
      ),
      GuidedPrompt(
        secondsFromStart: 204,
        text: 'Breathe in serenity...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 210,
        text: 'Hold...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 214,
        text: 'Let everything go...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 226,
        text: 'Notice your legs feeling heavy and grounded.',
      ),
      GuidedPrompt(
        secondsFromStart: 240,
        text: 'All tension is flowing out through your feet.',
      ),
      GuidedPrompt(
        secondsFromStart: 254,
        text: 'Your whole body is now deeply relaxed.',
      ),
      GuidedPrompt(
        secondsFromStart: 268,
        text: 'Take one final deep breath in...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 274,
        text: 'Hold this peaceful state...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 280,
        text: 'And release completely...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 292,
        text: 'Rest here in this calm, peaceful space.',
      ),
      GuidedPrompt(
        secondsFromStart: 320,
        text: 'When you\'re ready, slowly wiggle your fingers and toes.',
      ),
      GuidedPrompt(
        secondsFromStart: 340,
        text: 'Take a gentle stretch if it feels good.',
      ),
      GuidedPrompt(
        secondsFromStart: 356,
        text: 'Slowly open your eyes, feeling refreshed and calm.',
      ),
      GuidedPrompt(
        secondsFromStart: 372,
        text: 'Carry this peace with you throughout your day.',
        type: PromptType.affirmation,
      ),
    ],
  );

  static const GuidedContent _stressSosScript = GuidedContent(
    meditationId: 'stress_2',
    prompts: [
      GuidedPrompt(
        secondsFromStart: 0,
        text: 'Stop whatever you\'re doing. You\'re safe here.',
      ),
      GuidedPrompt(
        secondsFromStart: 6,
        text: 'Place both feet flat on the ground.',
      ),
      GuidedPrompt(
        secondsFromStart: 12,
        text: 'Take a big breath in through your nose...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 16,
        text: 'Hold for 4... 3... 2... 1...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 20,
        text: 'Blow it out slowly through pursed lips...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 30,
        text: 'Good. That\'s it. You\'re doing great.',
        type: PromptType.affirmation,
      ),
      GuidedPrompt(
        secondsFromStart: 38,
        text: 'Another deep breath in...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 42,
        text: 'Hold... letting calm fill your body...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 46,
        text: 'Release all the tension...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 56,
        text: 'Notice 5 things you can see around you.',
      ),
      GuidedPrompt(
        secondsFromStart: 72,
        text: 'Feel your feet connected to the earth.',
      ),
      GuidedPrompt(
        secondsFromStart: 82,
        text: 'You are present. You are grounded.',
        type: PromptType.affirmation,
      ),
      GuidedPrompt(
        secondsFromStart: 92,
        text: 'One more calming breath in...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 96,
        text: 'Hold...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 100,
        text: 'And let it all go...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 110,
        text: 'Feel your heart rate slowing.',
      ),
      GuidedPrompt(
        secondsFromStart: 122,
        text: 'Your body knows how to find calm.',
        type: PromptType.affirmation,
      ),
      GuidedPrompt(
        secondsFromStart: 134,
        text: 'Breathe naturally now, smooth and easy.',
      ),
      GuidedPrompt(
        secondsFromStart: 150,
        text: 'Place a hand on your heart.',
      ),
      GuidedPrompt(
        secondsFromStart: 162,
        text: 'Feel its steady rhythm. You are alive. You are okay.',
        type: PromptType.affirmation,
      ),
      GuidedPrompt(
        secondsFromStart: 178,
        text: 'One final deep breath...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 184,
        text: 'Hold this moment of peace...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 190,
        text: 'Exhale and return to the present...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 202,
        text: 'Open your eyes when you\'re ready.',
      ),
      GuidedPrompt(
        secondsFromStart: 220,
        text: 'You handled that beautifully.',
        type: PromptType.affirmation,
      ),
      GuidedPrompt(
        secondsFromStart: 240,
        text: 'Remember: This moment of calm is always available to you.',
        type: PromptType.affirmation,
      ),
    ],
  );

  static const GuidedContent _easeAnxietyScript = GuidedContent(
    meditationId: 'anxiety_1',
    prompts: [
      GuidedPrompt(
        secondsFromStart: 0,
        text: 'Welcome. Let\'s create some space from your worries.',
      ),
      GuidedPrompt(
        secondsFromStart: 10,
        text: 'Close your eyes and settle into a comfortable position.',
      ),
      GuidedPrompt(
        secondsFromStart: 20,
        text: 'Take a slow breath in, filling your belly...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 26,
        text: 'Hold gently, no strain...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 30,
        text: 'Release slowly, like a balloon deflating...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 42,
        text: 'Any anxious thoughts that arise, just notice them.',
      ),
      GuidedPrompt(
        secondsFromStart: 54,
        text: 'You don\'t need to fix them or follow them.',
      ),
      GuidedPrompt(
        secondsFromStart: 66,
        text: 'Simply observe, like clouds passing in the sky.',
      ),
      GuidedPrompt(
        secondsFromStart: 80,
        text: 'Breathe in slowly and steadily...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 86,
        text: 'Hold in safety and comfort...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 90,
        text: 'Let go of what you cannot control...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 104,
        text: 'Feel your body supported wherever you sit or lie.',
      ),
      GuidedPrompt(
        secondsFromStart: 118,
        text: 'The ground is holding you. You are safe.',
        type: PromptType.affirmation,
      ),
      GuidedPrompt(
        secondsFromStart: 132,
        text: 'Scan your body for any tension.',
      ),
      GuidedPrompt(
        secondsFromStart: 146,
        text: 'Your jaw... your shoulders... your stomach...',
      ),
      GuidedPrompt(
        secondsFromStart: 160,
        text: 'With each exhale, soften these areas.',
      ),
      GuidedPrompt(
        secondsFromStart: 176,
        text: 'Deep breath in, drawing in calm...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 182,
        text: 'Hold this feeling of safety...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 186,
        text: 'Exhale any worry or fear...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 200,
        text: 'You are more than your anxious thoughts.',
        type: PromptType.affirmation,
      ),
      GuidedPrompt(
        secondsFromStart: 216,
        text: 'You are the vast sky, not the passing clouds.',
      ),
      GuidedPrompt(
        secondsFromStart: 232,
        text: 'Let your breathing become natural and easy.',
      ),
      GuidedPrompt(
        secondsFromStart: 250,
        text: 'With each breath, you are calmer.',
        type: PromptType.affirmation,
      ),
      GuidedPrompt(
        secondsFromStart: 268,
        text: 'With each moment, the anxiety has less power.',
        type: PromptType.affirmation,
      ),
      GuidedPrompt(
        secondsFromStart: 290,
        text: 'One last deep breath in...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 296,
        text: 'Hold this peaceful energy...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 302,
        text: 'And release back to the present...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 320,
        text: 'Begin to notice the sounds around you.',
      ),
      GuidedPrompt(
        secondsFromStart: 340,
        text: 'Wiggle your fingers and toes gently.',
      ),
      GuidedPrompt(
        secondsFromStart: 358,
        text: 'When ready, softly open your eyes.',
      ),
      GuidedPrompt(
        secondsFromStart: 378,
        text: 'You can return to this calm space anytime.',
        type: PromptType.affirmation,
      ),
      GuidedPrompt(
        secondsFromStart: 396,
        text: 'Well done. You\'ve given yourself a beautiful gift.',
        type: PromptType.affirmation,
      ),
    ],
  );

  static const GuidedContent _sleepyTimeScript = GuidedContent(
    meditationId: 'sleep_1',
    prompts: [
      GuidedPrompt(
        secondsFromStart: 0,
        text: 'Lie comfortably and let your eyes gently close.',
      ),
      GuidedPrompt(
        secondsFromStart: 12,
        text: 'Let the weight of the day begin to melt away.',
      ),
      GuidedPrompt(
        secondsFromStart: 26,
        text: 'Take a deep, sleepy breath in...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 34,
        text: 'Hold softly...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 42,
        text: 'Exhale slowly, sinking deeper into your bed...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 58,
        text: 'Feel your head heavy on the pillow.',
      ),
      GuidedPrompt(
        secondsFromStart: 74,
        text: 'Your face softens, forehead smooth.',
      ),
      GuidedPrompt(
        secondsFromStart: 90,
        text: 'Your jaw is loose, lips slightly parted.',
      ),
      GuidedPrompt(
        secondsFromStart: 108,
        text: 'Another slow breath in...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 116,
        text: 'Hold in comfort...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 124,
        text: 'Release, letting your body sink deeper...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 144,
        text: 'Your shoulders melt into the mattress.',
      ),
      GuidedPrompt(
        secondsFromStart: 162,
        text: 'Your arms are heavy, completely at rest.',
      ),
      GuidedPrompt(
        secondsFromStart: 182,
        text: 'Feel a warm, sleepy wave moving through your chest.',
      ),
      GuidedPrompt(
        secondsFromStart: 204,
        text: 'Breathe in peace and stillness...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 212,
        text: 'Hold in this cozy moment...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 220,
        text: 'Exhale, drifting closer to sleep...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 244,
        text: 'Your stomach rises and falls gently.',
      ),
      GuidedPrompt(
        secondsFromStart: 266,
        text: 'Your hips and legs are completely relaxed.',
      ),
      GuidedPrompt(
        secondsFromStart: 290,
        text: 'Your feet are warm and heavy.',
      ),
      GuidedPrompt(
        secondsFromStart: 316,
        text: 'The outside world fades away.',
      ),
      GuidedPrompt(
        secondsFromStart: 344,
        text: 'There is nothing to do, nowhere to be.',
      ),
      GuidedPrompt(
        secondsFromStart: 374,
        text: 'Only this peaceful moment.',
      ),
      GuidedPrompt(
        secondsFromStart: 404,
        text: 'Let your breath become natural and slow.',
      ),
      GuidedPrompt(
        secondsFromStart: 436,
        text: 'Each exhale carries you deeper into rest.',
      ),
      GuidedPrompt(
        secondsFromStart: 474,
        text: 'Sleep is arriving to embrace you.',
      ),
      GuidedPrompt(
        secondsFromStart: 516,
        text: 'Let go completely.',
      ),
      GuidedPrompt(
        secondsFromStart: 560,
        text: 'Drift into peaceful sleep...',
        type: PromptType.transition,
      ),
      GuidedPrompt(
        secondsFromStart: 620,
        text: 'Rest deeply. Sweet dreams.',
        type: PromptType.affirmation,
      ),
    ],
  );

  static const GuidedContent _sharpenFocusScript = GuidedContent(
    meditationId: 'focus_1',
    prompts: [
      GuidedPrompt(
        secondsFromStart: 0,
        text: 'Sit upright with a relaxed but alert posture.',
      ),
      GuidedPrompt(
        secondsFromStart: 10,
        text: 'Let your eyes close or soften your gaze downward.',
      ),
      GuidedPrompt(
        secondsFromStart: 20,
        text: 'Take a clearing breath in...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 26,
        text: 'Hold...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 30,
        text: 'Release, letting go of distractions...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 42,
        text: 'Your mind is like a clear mountain lake.',
      ),
      GuidedPrompt(
        secondsFromStart: 56,
        text: 'Thoughts may ripple the surface, but the depths stay calm.',
      ),
      GuidedPrompt(
        secondsFromStart: 72,
        text: 'Bring your attention to your breath.',
      ),
      GuidedPrompt(
        secondsFromStart: 86,
        text: 'Feel the cool air entering your nostrils.',
      ),
      GuidedPrompt(
        secondsFromStart: 100,
        text: 'Feel the warm air leaving.',
      ),
      GuidedPrompt(
        secondsFromStart: 116,
        text: 'Deep breath in, awakening your focus...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 122,
        text: 'Hold, gathering your concentration...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 126,
        text: 'Exhale, releasing mental fog...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 140,
        text: 'Now, notice the sensation of sitting.',
      ),
      GuidedPrompt(
        secondsFromStart: 156,
        text: 'Feel the weight of your body on the chair.',
      ),
      GuidedPrompt(
        secondsFromStart: 172,
        text: 'This is your anchor point.',
        type: PromptType.affirmation,
      ),
      GuidedPrompt(
        secondsFromStart: 188,
        text: 'When your mind wanders, gently return here.',
      ),
      GuidedPrompt(
        secondsFromStart: 206,
        text: 'Breathe in clarity...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 212,
        text: 'Hold this sharp awareness...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 216,
        text: 'Breathe out distraction...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 232,
        text: 'Your mind is becoming crystal clear.',
        type: PromptType.affirmation,
      ),
      GuidedPrompt(
        secondsFromStart: 250,
        text: 'Focus is a muscle. You are training it now.',
      ),
      GuidedPrompt(
        secondsFromStart: 270,
        text: 'Each time you notice wandering and return, you grow stronger.',
      ),
      GuidedPrompt(
        secondsFromStart: 294,
        text: 'Breathe in with intention...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 300,
        text: 'Hold your purpose...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 304,
        text: 'Exhale, centered and ready...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 320,
        text: 'Feel alert yet calm.',
      ),
      GuidedPrompt(
        secondsFromStart: 340,
        text: 'Ready to bring your full attention to what matters.',
      ),
      GuidedPrompt(
        secondsFromStart: 362,
        text: 'One final focusing breath in...',
        type: PromptType.breatheIn,
      ),
      GuidedPrompt(
        secondsFromStart: 368,
        text: 'Hold your sharpest focus...',
        type: PromptType.hold,
      ),
      GuidedPrompt(
        secondsFromStart: 372,
        text: 'Release into complete presence...',
        type: PromptType.breatheOut,
      ),
      GuidedPrompt(
        secondsFromStart: 390,
        text: 'Gently open your eyes.',
      ),
      GuidedPrompt(
        secondsFromStart: 406,
        text: 'Carry this focused awareness with you.',
        type: PromptType.affirmation,
      ),
      GuidedPrompt(
        secondsFromStart: 426,
        text: 'You are ready. Go create something amazing.',
        type: PromptType.affirmation,
      ),
    ],
  );
}
