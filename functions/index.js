import { onCall } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { gemini15Flash, googleAI } from "@genkit-ai/googleai";
import { genkit, z } from "genkit";

// Initialize Firebase Admin
admin.initializeApp();

// Initialize Genkit
const ai = genkit({
  plugins: [googleAI()],
  model: gemini15Flash,
});

// —————————————————————————————————————————————————————————————————————————————
// 🧠 The Core Weapon: Adaptive Cognition Engine
// —————————————————————————————————————————————————————————————————————————————

// Define the Input Schema
const CoachingInputSchema = z.object({
  message: z.string(),
  isPro: z.boolean(),
  personalityVector: z.object({
    discipline: z.number().optional(), // 0.0 - 1.0
    noveltySeeking: z.number().optional(),
    structureNeed: z.number().optional(),
    emotionalReactivity: z.number().optional(),
  }).optional(),
  context: z.string().optional(), // Previous conversation summary or key facts
});

// Define the Output Schema
const CoachingOutputSchema = z.object({
  text: z.string(),
  breakthroughDetected: z.boolean().optional(),
});

// Define the Flow
export const generateAdaptiveCoaching = ai.defineFlow(
  {
    name: "generateAdaptiveCoaching",
    inputSchema: CoachingInputSchema,
    outputSchema: CoachingOutputSchema,
  },
  async (input) => {
    const { message, isPro, personalityVector, context } = input;

    // 1. Construct the System Prompt based on Tier & Vector
    let systemPrompt =
      "You are MindFlow, a strategic AI coach. Your goal is to help the user think clearly and act intentionally.";

    if (isPro && personalityVector) {
      // lethal adaptive logic
      systemPrompt += `\n\nUSER COGNITIVE PROFILE:
- Discipline: ${personalityVector.discipline ?? 0.5}
- Novelty Seeking: ${personalityVector.noveltySeeking ?? 0.5}
- Structure Need: ${personalityVector.structureNeed ?? 0.5}
- Reactivity: ${personalityVector.emotionalReactivity ?? 0.5}`;

      // Adjust tone based on 'Discipline'
      if ((personalityVector.discipline ?? 0.5) > 0.7) {
        systemPrompt += "\nTONE: Direct, challenge-oriented, efficient. Cut the fluff.";
      } else {
        systemPrompt += "\nTONE: Encouraging, supportive, breakdown tasks into small steps.";
      }

      // Adjust structure based on 'Structure Need'
      if ((personalityVector.structureNeed ?? 0.5) > 0.7) {
        systemPrompt += "\nFORMAT: Use bullet points, numbered lists, and clear action items.";
      } else {
        systemPrompt += "\nFORMAT: Conversational, fluid, narrative style.";
      }
    } else {
      // Free Tier / No Vector
      systemPrompt += "\nTONE: Calm, balanced, and inquisitive.";
      systemPrompt += "\nNOTE: Keep responses under 3 sentences unless asked for deep dive.";
    }

    if (context) {
      systemPrompt += `\n\nCONTEXT:\n${context}`;
    }

    // 2. Generate Response
    const response = await ai.generate({
      prompt: `${systemPrompt}\n\nUSER: ${message}`,
      config: {
        temperature: isPro ? 0.7 : 0.5, // More creative for Pro
      },
    });

    const outputText = response.text;

    // 3. Detect Breakthroughs (Simple Heuristic for now)
    const breakthroughKeywords = ["aha", "realize", "understand", "clear now", "shifts"];
    const breakthroughDetected = breakthroughKeywords.some((k) =>
      outputText.toLowerCase().includes(k)
    );

    return {
      text: outputText,
      breakthroughDetected,
    };
  }
);

// —————————————————————————————————————————————————————————————————————————————
// ☁️ Cloud Function Exposure
// —————————————————————————————————————————————————————————————————————————————

export const coachingFlow = onCall(async (request) => {
    // 1. Auth Check
    if (!request.auth) {
        throw new admin.functions.https.HttpsError(
            "unauthenticated",
            "The function must be called while authenticated."
        );
    }

    // 2. Run the Flow
    try {
        const result = await generateAdaptiveCoaching(request.data);
        return result;
    } catch (e) {
        console.error("Genkit Flow Error:", e);
        throw new admin.functions.https.HttpsError("internal", "AI generation failed");
    }
});
