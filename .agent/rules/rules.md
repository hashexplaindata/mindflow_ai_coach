---
trigger: manual
---

# 🚀 MISSION PROTOCOL: MindFlow MVP (Shipyard Hackathon)

## 🎯 CORE OBJECTIVE

Build a "Pocket Essentialist" AI Coach.
**PRIORITY 1:** RevenueCat Paywall must trigger and work.
**PRIORITY 2:** Gemini 2.0 Flash must provide high-quality NLP reframing.
**PRIORITY 3:** UI must be "Radically Minimalist" (The 'Better Creating' Aesthetic).

---

## 🛠 TECH STACK (STRICT)

- **Framework:** Flutter (Latest Stable)
- **State Management:** `flutter_riverpod` (DO NOT use `provider` context.read/watch)
- **Monetization:** `purchases_flutter` (^8.0.0) & `purchases_ui_flutter`& 'revenue cat'
- **AI Backend:** `google_generative_ai` (Gemini 2.0 Flash)
- **Database:** Firebase

---

## 🎨 DESIGN SYSTEM ("The Simon Aesthetic")

**Philosophy:** Clarity > Features. If it can be removed, remove it.

### 1. Color Palette

- **Canvas:** Off-White `#FAFAFA` (Light) | Deep Charcoal `#1A1A1A` (Dark)
- **Primary Text:** Jet Black `#111111` | Pure White `#FFFFFF`
- **Accent/Action:** Burnt Orange `#E67E22` (Use sparingly for Primary Buttons only)
- **Surface:** `#F5F5F5` (Subtle cards, no shadows)

### 2. Typography & Layout

- **Font:** SF Pro Display / Roboto.
- **Headers:** `FontWeight.w900`, Size 32+, Tight tracking (-1.0).
- **Body:** `FontWeight.w400`, Size 16, Relaxed height (1.5).
- **Padding:** Minimum `24.0` horizontal padding. No elements touching edges.
- **Whitespace:** Use `SizedBox(height: 32)` instead of Dividers.

### 3. Components

- **Buttons:** Flat, pill-shaped `StadiumBorder`. No gradients/shadows unless active.
- **Inputs:** Minimalist underlining or transparent fields with large text.
- **Chat:** No bubbles. Just text and alignment. "iMessage meets Zen".

---

## 💰 REVENUECAT STRATEGY (The Winning Condition)

1. **The Gate:** The app is "Free to Chat", but "Paid to Deep Dive".
2. **Trigger Points:**
   - User taps "Deep Reflection" (Analysis Mode).
   - User taps "Past Insights" (History).
   - User selects "Premium Audio" (Binaural Beats).
3. **Implementation:**
   - Use `SubscriptionProvider` to check `isPro` status globally.
   - If `!isPro`: Show `PaywallTrigger` (Native RevenueCat Paywall).
   - **Entitlement ID:** `pro_access` (Hardcoded).

---

## 🧠 AGENT BEHAVIOR & CODING STANDARDS

### 1. The "Anti-Hallucination" Protocol

- **NEVER** invent new packages. Check `pubspec.yaml` first.
- **NEVER** try to fix the "Breathing" or "Music Generator" features. They are deprecated.
- **ALWAYS** prefer standard Flutter Widgets (`Container`, `Column`, `Row`) over complex custom implementations.

### 2. File Editing ("Sniper Mode")

- When asked to fix a bug, modify **ONLY** the specific function or widget.
- **DO NOT** rewrite the entire file unless explicitly instructed.
- **DO NOT** remove comments that say `// Hackathon Fix` or `// RevenueCat Logic`.

### 3. NLP Persona (Gemini 2.0)

- **System Prompt:** Enforce "The Milton Model" (NLP).
- **Style:** Metaphorical, brief (max 3 sentences), open-ended.
- **Forbidden:** Generic advice ("You should try yoga"), Lists (Bullet points).
- **Goal:** Reframe the user's narrative, do not just solve the problem.

### 4. Error Handling

- Wrap all API calls (Gemini/RevenueCat) in `try-catch`.
- On Error: Fail silently to a "Safe State" (e.g., if RevenueCat fails, assume Free Tier; if Gemini fails, show "I'm listening...").
- **NEVER** show a Red Screen of Death (`RenderFlex overflow`). Use `SafeArea` and `SingleChildScrollView`.

---

## 🚫 FORBIDDEN ACTIONS

- Do not create `docs/` documentation. Code is the documentation.
- Do not touch `lib/core/behavioral/` (Legacy code).
- Do not touch `lib/core/audio/` (Legacy code).
