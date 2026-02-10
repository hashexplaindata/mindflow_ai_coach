# MindFlow: Design & Telemetry Map

---

## 1. Design Tokens (The "Flow" Theme)

| **Token**       | **Value**                | **Psychological Justification**              |
|-----------------|--------------------------|----------------------------------------------|
| `color-primary` | `#1A237E` (Deep Indigo)  | Promotes calm, deep focus.                   |
| `color-accent`  | `#00E676` (Neo-Mint)     | High visibility for progress markers.        |
| `font-main`     | `'Inter', sans-serif`    | High legibility, reduces cognitive load.     |
| `border-radius` | `12px`                   | Soft edges reduce "visual threat" response.  |
| `spacing-unit`  | `8px` (Base-8)           | Harmonic visual rhythm.                      |

---

## 2. UI/UX Principles

- **The 3-Click Rule:** No focus session should be more than 3 clicks away.

- **Negative Space:** 40% of the screen must remain unoccupied to prevent sensory overload.

- **Progressive Disclosure:** Advanced stats are hidden until the user masters basic habits.

---

## 3. Telemetry Map

We track metrics that matter for *User Success*, not *App Profit*:

- **Focus Duration (FD):** Time spent in active window without tab-switching.

- **Cognitive Bounce Rate (CBR):** Frequency of app-switching during a session.

- **Recovery Time (RT):** Time taken to return to focus after an interruption.

### Telemetry Pipeline

```text
Client Event → Kinesis/Kafka → Lambda (Anonymizer) → PostgreSQL (Aggregated)
```

> **Note:** All PII (Personally Identifiable Information) is stripped at the Anonymizer layer.
