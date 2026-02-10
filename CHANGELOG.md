# MindFlow AI Coach - Development Changelog

## [Hackathon Sprint] - 2026-02-10

### 🚀 Major Pivot: Mobile-First & Multi-Coach Architecture
In preparation for the RevenueCat Shipyard 2026 contest (Simon @BetterCreating brief), we executed a major architectural pivot from a web-based prototype to a native Android application.

### 📱 Mobile Core Transition
- **Removed Web Dependencies:** Stripped out `dart:js_interop` and `package:web` from audio services (`AmbientSoundService`, `BinauralAudioService`, `AdvancedHypnoticAudioService`). Replaced with stubbed implementations or native-compatible code to ensure Android compilation.
- **Audio Engine Update:** Migrated `AmbientSoundService` to use `audioplayers` package for native mobile audio playback.
- **Backend Strategy:** Switched `ApiService` to "Mock Mode" by default for the MVP. This decouples the app from the local Python backend, allowing it to run standalone on Android using `SharedPreferences` for persistence.
- **Gemini Streaming:** Validated the direct HTTP streaming implementation for the chatbot, ensuring it works without a backend proxy for this hackathon build.

### 🧠 Multi-Coach System (The "Simon" Feature)
Implemented the core requirement of "browsing and sharing AI coaches":
- **Data Model:** Defined `Coach` model with `nlpType`, `systemPromptBase`, and `tone`.
- **Coach Gallery:** Built `CoachGalleryScreen` to browse available personas (MindFlow, The Reframer, The Clarifier, Simon, The Visualizer).
- **Personality Injection:** Updated `NLPPromptBuilder` to inject specific NLP instructions (Milton Model, Meta Model, VAK) based on the active coach.
- **State Management:** Updated `ChatProvider` and `GeminiService` to track the active coach context.

### 💰 Monetization (RevenueCat)
- **Integration:** Verified `RevenueCatService` setup with Android API keys.
- **Gating:** Implemented `PaywallTrigger` logic in `CoachGalleryScreen`. Users can chat with the default coach for free, but premium personas are locked behind the Pro subscription.

### 🛠️ Android Environment Setup
- Installed OpenJDK 17 via Winget.
- Configured Android SDK command-line tools.
- Generated Android project files via `flutter create . --platforms android`.
- Fixed `local.properties` and `AndroidManifest.xml`.

### 📝 Next Steps
- Final APK build and testing on device.
- Recording the demo video showcasing the Multi-Coach system.
- Submitting to Google Play Internal Testing.
