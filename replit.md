# MindFlow - Meditation & Wellness App

## Overview
MindFlow is a Headspace-style Flutter web application for meditation and wellness. Features guided meditations, sleep content, progress tracking, and premium subscriptions. Built with Steve Jobs aesthetic philosophy: obsessive minimalism, typography-first, zero borders.

## Tech Stack
- **Frontend:** Flutter Web (Dart)
- **State Management:** Provider
- **Backend:** Node.js/Express (port 3000) + Python Flask (port 5000)
- **Database:** PostgreSQL with Drizzle ORM
- **Payments:** Stripe + RevenueCat
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

server/                  # Node.js backend
├── index.ts             # Express server with Stripe
├── routes.ts            # API endpoints
├── stripeClient.ts      # Stripe integration
├── storage.ts           # Database queries
├── db.ts                # Drizzle setup
└── seed-products.ts     # Create subscription products

shared/schema.ts         # Drizzle schema (users, sessions, progress)
server.py                # Flask server for Flutter web hosting
```

## Features
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
# Frontend (port 5000)
python server.py

# Backend API (port 3000)
cd server && npm run dev
```

### Seed Stripe Products
```bash
cd server && npm run seed
```

## API Endpoints
- `GET /api/health` - Health check
- `GET /api/products` - List subscription products
- `POST /api/checkout` - Create Stripe checkout session
- `GET /api/subscription` - Get user subscription status
- `POST /api/users` - Create/get user
- `POST /api/sessions` - Log meditation session
- `GET /api/progress/:userId` - Get user progress stats

## Environment Variables
- `DATABASE_URL` - PostgreSQL connection string
- `GEMINI_API_KEY` - Google AI Studio API key
- `REVENUECAT_API_KEY` - RevenueCat API key
- Stripe keys managed via Replit connector

## Competition Criteria Alignment
- **Audience Fit (30%):** Wellness/meditation content for mindful living audience
- **User Experience (25%):** Polished Headspace-inspired UI with smooth transitions
- **Monetization (20%):** Free tier + Premium monthly/annual subscriptions
- **Innovation (15%):** AI coach integration, NLP-based personalization
- **Technical Quality (10%):** PostgreSQL, Stripe, proper API architecture
