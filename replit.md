# MindFlow AI Coach

## Overview
MindFlow is a Flutter web application - an AI-powered cognitive coaching app that uses NLP psychology frameworks for personalized coaching. It's designed with a "Steve Jobs" aesthetic philosophy: obsessive minimalism, typography-first, zero borders.

## Tech Stack
- **Frontend:** Flutter Web (Dart only)
- **State Management:** Provider (current), transitioning to Riverpod
- **Backend/DB:** Firebase (Firestore + Auth)
- **AI:** Google Gemini 2.5 Flash
- **Payments:** RevenueCat SDK

## Project Structure
```
lib/
├── core/
│   ├── theme/        # HeadspaceTheme (Colors, Type, Physics)
│   ├── constants/    # App colors, spacing, text styles
│   └── services/     # RevenueCatService (Monetization)
├── features/
│   ├── chat/         # Invisible Architect Engine & UI
│   ├── onboarding/   # Multidimensional Quiz
│   └── subscription/ # Subscription/payment handling
├── shared/
│   └── widgets/      # Reusable UI components
└── main.dart         # Entry point
```

## Design System
- **Palette:** Cream (#F9F9F2), Sage (#94A684), Obsidian (#1D1D1F)
- **Radius:** 32.0
- **Typography:** DM Sans only
- **Animations:** SpringSimulation (no linear tweens)

## Running the App
```bash
flutter pub get
flutter run -d web-server --web-port=5000 --web-hostname=0.0.0.0
```

## Environment Variables
Copy `.env.example` to `.env` and fill in:
- `GEMINI_API_KEY` - Google AI Studio API key
- `REVENUECAT_IOS_KEY` - RevenueCat iOS key
- `REVENUECAT_ANDROID_KEY` - RevenueCat Android key

## Documentation
See `/docs` folder for:
- `AGENT_RULES.md` - Development guidelines
- `ARCHITECTURE.md` - Technical architecture
- `PRD.md` - Product requirements
