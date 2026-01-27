# MindFlow - Meditation & Wellness App

## Overview
MindFlow is a Headspace-style Flutter web application for meditation and wellness. Features guided meditations, sleep content, progress tracking, and premium subscriptions. Built with Steve Jobs aesthetic philosophy: obsessive minimalism, typography-first, zero borders.

## Tech Stack
- **Frontend:** Flutter Web (Dart)
- **State Management:** Provider
- **Backend:** Python Flask (port 5000) - consolidated single server
- **Database:** PostgreSQL with psycopg2
- **Payments:** Stripe (via Replit connector)
- **AI Coach:** Google Gemini 2.5 Flash (optional feature)

## Project Structure
```
lib/
├── core/
│   ├── theme/           # JobsTheme (Colors, Type)
│   ├── constants/       # AppColors, AppSpacing, AppTextStyles
│   └── services/        # ApiService (backend communication)
├── features/
│   ├── home/            # Home screen with daily recommendations
│   ├── explore/         # Meditation library by category
│   ├── sleep/           # Sleep stories, soundscapes, breathing
│   ├── profile/         # User stats, settings, subscription
│   ├── meditation/      # Player, models, sample data
│   ├── subscription/    # Paywall and premium features
│   ├── auth/            # UserProvider (local user management)
│   ├── chat/            # AI Coach (Gemini integration)
│   └── onboarding/      # NLP profiling quiz
├── shared/
│   └── widgets/         # BottomNavBar, FlowStreakRing, AppButton
└── main.dart            # Entry point with MultiProvider

server.py                # Flask server: API + Flutter web hosting
build/web/               # Built Flutter app (generated)
```

## Features
- **Guided Meditations:** 5 complete meditation scripts with timed prompts (Release Tension, Stress SOS, Ease Anxiety, Sleepy Time, Sharpen Focus)
- **Breathing Animations:** Visual breathing indicator that responds to prompts (inhale/hold/exhale phases with smooth animations)
- **Ambient Sounds:** 6 background sound options (Rain, Ocean, Forest, White Noise, Fireplace) using Web Audio API
- **Meditation Library:** 24 sessions across 6 categories (Stress, Anxiety, Sleep, Focus, Relationships, Self-Esteem)
- **Sleep Content:** 4 sleep stories, 3 soundscapes, 3 breathing exercises
- **Progress Tracking:** Minutes meditated, streak counter, session history
- **Premium Subscriptions:** Monthly ($9.99) and Annual ($79.99) via Stripe
- **AI Coach:** Optional Gemini-powered personalized coaching

## Design System
- **Palette:** Cream (#F9F9F2), Sage (#94A684), Obsidian (#1D1D1F), Orange (#F4A261)
- **Radius:** 32px
- **Typography:** DM Sans
- **Animations:** Spring physics, smooth transitions

## Running the App

### Development
```bash
python server.py
```
This builds Flutter and starts the Flask server on port 5000.

## API Endpoints
- `GET /api/health` - Health check
- `GET /api/products` - List subscription products
- `POST /api/checkout` - Create Stripe checkout session
- `GET /api/subscription/<userId>` - Get user subscription status
- `POST /api/users` - Create/get user
- `POST /api/sessions` - Log meditation session
- `GET /api/progress/<userId>` - Get user progress stats

## Environment Variables
- `DATABASE_URL` - PostgreSQL connection string (auto-provided)
- `GEMINI_API_KEY` - Google AI Studio API key
- Stripe keys managed via Replit connector

## Competition Criteria Alignment
- **Audience Fit (30%):** Wellness/meditation content for mindful living audience
- **User Experience (25%):** Polished Headspace-inspired UI with smooth transitions
- **Monetization (20%):** Free tier + Premium monthly/annual subscriptions
- **Innovation (15%):** AI coach integration, NLP-based personalization
- **Technical Quality (10%):** PostgreSQL, Stripe, proper API architecture

## User Preferences
- Steve Jobs minimalist aesthetic
- Zero borders design philosophy
- Clean, functional code
- UI reference: https://mobbin.com/discover/apps/ios/latest

## MindFlow V5 Constitution

### I. Integrity of the "Presence"
The AI never identifies as a "Language Model." It is a "Presence." It never explains its logic—only provides the intervention.

### II. Brand Purity (The Jobs Standard)
If a feature adds clutter, it is a defect. "Simple" is harder than "Complex." Every pixel serves the user's flow.

### III. Data Sovereignty
User psychological data is sacred. No PII in telemetry. Strict pathing: `/artifacts/{appId}/users/{userId}/`

### IV. The "Velocity" Rule
Latency is the enemy of Flow State. AI responses sub-1s. UI at 60fps.

### V. Evolution
The app must learn. Every interaction refines the MultiDimensionalProfile.

## Master Bibliography

- **NLP:** Bandler & Grinder (Structure of Magic), Tad James (Timeline Therapy)
- **Design:** Apple HIG, Steve Jobs (Walter Isaacson)
- **ML/Stats:** Martin Kleppmann (DDIA), Aurelien Geron (Hands-on ML)
- **Audience:** Simon @ Better Creating (Systems Philosophy)
