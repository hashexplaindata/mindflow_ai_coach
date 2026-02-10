# MindFlow AI Coach - Shipyard 2026 Submission

## ⛴️ Challenge: Simon @BetterCreating (Minimalist AI Coaching)

**MindFlow** is a native Android application that brings rigorous NLP (Neuro-Linguistic Programming) frameworks into a minimalist, Steve Jobs-inspired coaching interface. Unlike generic chatbots, MindFlow allows users to choose specific "Coach Personas" (The Reframer, The Clarifier, The Visualizer) that use distinct psychological linguistic patterns to unlock flow states.

---

## 🚀 Key Features (The "Simon" Brief)

### 1. Multi-Coach Gallery (Browse, Create, Share)
- **The Reframer (Milton Model):** Uses artfully vague hypnotic language, metaphors, and double binds to bypass resistance.
- **The Clarifier (Meta Model):** challenging limiting beliefs ("I can't do this") with precision questioning ("What specifically stops you?").
- **The Visualizer (VAK - Visual):** Speaks in rich visual metaphors ("Picture this", "Clear vision") for visual thinkers.
- **Simon (Productivity):** Focused on systems, removing friction, and actionable steps (Notion/Atomic Habits style).

### 2. Native Mobile Core
- **Audio Engine:** `audioplayers` integration for ambient textures (Rain, Forest, Binaural Beats).
- **Offline-First:** Runs on-device with local persistence (`SharedPreferences`) for streaks and journals.
- **Secure:** Backend API decoupled for MVP; runs standalone without local server dependencies.

### 3. Monetization (RevenueCat)
- **Freemium Model:** Daily chat limits and access to the "MindFlow" core coach.
- **Pro Subscription:** Unlocks specialized coaches (Milton/Meta/VAK) and unlimited sessions.
- **Implementation:** `purchases_flutter` with native Android API key integration.

---

## 🛠️ Technical Stack

- **Framework:** Flutter (Mobile-First Architecture)
- **Language:** Dart 3.0+
- **AI Engine:** Gemini 2.0 Flash (via direct streaming API)
- **State Management:** Riverpod + Provider (Hybrid)
- **Audio:** AudioPlayers
- **Monetization:** RevenueCat (Android)

---

## 📲 How to Run

### Prerequisites
1. **Android SDK:** Ensure Android SDK Platform-Tools and Build-Tools are installed.
2. **Java:** JDK 17 (Microsoft OpenJDK recommended).
3. **Flutter:** Version 3.27+ (Channel Stable).

### Setup
1. Clone the repository.
2. Create `assets/.env` with your keys:
   ```env
   GEMINI_API_KEY=your_key_here
   REVENUECAT_ANDROID_KEY=goog_your_rc_key_here
   ```
3. Run on device:
   ```bash
   flutter run
   ```

### Building for Release
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🧠 Architecture Highlights

- **`NLPPromptBuilder`:** Dynamic system prompt injection based on the selected Coach Persona.
- **`GeminiService`:** Handles real-time streaming and chat history context.
- **`CoachRepository`:** Central registry of available AI personalities.
- **`DualStream Architecture`:** (Planned) Separation of "Wisdom" (User Text) and "Telemetry" (Psychometrics).

---

## 📄 License
Copyright © 2026 MindFlow. All rights reserved.
