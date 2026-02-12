import { blink } from './blink';
import {
  PersonalityVector,
  ShadowTelemetry,
  INITIAL_VECTOR,
  calculateVectorDistance,
  clampVector,
  CognitiveEngine,
} from './engine';

export interface VectorRecord extends PersonalityVector {
  turnCount: number;
}

export const VectorService = {
  async getUserVector(userId: string): Promise<VectorRecord> {
    try {
      const records = await blink.db.usersVectors.list({
        where: { userId },
      });
      const record = records[0];

      if (!record) {
        await blink.db.usersVectors.upsert({
          userId,
          ...INITIAL_VECTOR,
          turnCount: 0,
        });
        return { ...INITIAL_VECTOR, turnCount: 0 };
      }
      return {
        discipline: Number(record.discipline) || 0.5,
        novelty: Number(record.novelty) || 0.5,
        reactivity: Number(record.reactivity) || 0.5,
        structure: Number(record.structure) || 0.5,
        turnCount: Number(record.turnCount) || 0,
      };
    } catch (err) {
      console.warn('Failed to load vector, using defaults:', err);
      return { ...INITIAL_VECTOR, turnCount: 0 };
    }
  },

  async recalibrate(
    userId: string,
    messages: { role: string; content: string }[]
  ): Promise<{ vector: PersonalityVector; telemetry: ShadowTelemetry }> {
    const current = await this.getUserVector(userId);

    const { object } = await blink.ai.generateObject({
      prompt: `Role: You are a Computational Behavioral Scientist.
Task: Analyze the user's cognitive dimensions from the provided conversation.
Dimensions:
- Discipline (D): Logical density, focus, commitment to a line of thought. [0.0 - 1.0]
- Novelty (N): Metaphorical complexity, creativity, openness to new perspectives. [0.0 - 1.0]
- Reactivity (R): Emotional intensity, sensitivity to mirroring, conversational speed. [0.0 - 1.0]
- Structure (S): Information architecture, organized vs. associative flow. [0.0 - 1.0]

Conversation:
${messages.slice(-12).map((m) => `${m.role.toUpperCase()}: ${m.content}`).join('\n')}

Current Profile: ${JSON.stringify({ D: current.discipline, N: current.novelty, R: current.reactivity, S: current.structure })}

Analyze the user's language patterns, emotional indicators, and cognitive style. Output updated vector values (0.0 to 1.0) and shadow telemetry metrics.`,
      schema: {
        type: 'object',
        properties: {
          discipline: { type: 'number', minimum: 0, maximum: 1 },
          novelty: { type: 'number', minimum: 0, maximum: 1 },
          reactivity: { type: 'number', minimum: 0, maximum: 1 },
          structure: { type: 'number', minimum: 0, maximum: 1 },
          cognitiveLoad: {
            type: 'number',
            minimum: 0,
            maximum: 1,
            description: "Processing difficulty observed in the user's syntax (0=simple, 1=dense).",
          },
          mindsetDrift: {
            type: 'number',
            minimum: 0,
            maximum: 1,
            description: 'Shift in perspective or emotional state from baseline (0=stable, 1=major shift).',
          },
        },
        required: ['discipline', 'novelty', 'reactivity', 'structure', 'cognitiveLoad', 'mindsetDrift'],
      },
    });

    const raw = object as any;
    const newVector = clampVector({
      discipline: raw.discipline,
      novelty: raw.novelty,
      reactivity: raw.reactivity,
      structure: raw.structure,
    });
    const distance = calculateVectorDistance(current, newVector);
    const newTurnCount = current.turnCount + 1;

    const telemetry: ShadowTelemetry = CognitiveEngine.createTelemetrySnapshot(
      newVector,
      current,
      messages,
      newTurnCount
    );
    telemetry.cognitiveLoad = raw.cognitiveLoad ?? telemetry.cognitiveLoad;
    telemetry.mindsetDrift = raw.mindsetDrift ?? telemetry.mindsetDrift;

    // Persist vector update
    await blink.db.usersVectors.upsert({
      userId,
      discipline: newVector.discipline,
      novelty: newVector.novelty,
      reactivity: newVector.reactivity,
      structure: newVector.structure,
      turnCount: newTurnCount,
      updatedAt: new Date().toISOString(),
    });

    // Persist shadow telemetry
    await blink.db.telemetry.create({
      userId,
      turnIndex: newTurnCount,
      cognitiveLoad: telemetry.cognitiveLoad,
      mindsetDrift: telemetry.mindsetDrift,
      metadata: JSON.stringify({
        distance,
        miltonPatterns: telemetry.miltonPatterns,
        timestamp: telemetry.timestamp,
      }),
    });

    return { vector: newVector, telemetry };
  },

  async getTelemetryHistory(userId: string): Promise<ShadowTelemetry[]> {
    try {
      const records = await blink.db.telemetry.list({
        where: { userId },
        order: { field: 'createdAt', direction: 'desc' },
      });
      return records.map((r: any) => {
        const meta = JSON.parse(r.metadata || '{}');
        return {
          cognitiveLoad: Number(r.cognitiveLoad) || 0,
          mindsetDrift: Number(r.mindsetDrift) || 0,
          miltonPatterns: meta.miltonPatterns || [],
          vectorDistance: meta.distance || 0,
          turnIndex: Number(r.turnIndex) || 0,
          timestamp: meta.timestamp || new Date(r.createdAt).getTime(),
        };
      });
    } catch (err) {
      console.warn('Failed to fetch telemetry:', err);
      return [];
    }
  },

  async generateBreakthrough(userId: string, messages: { role: string; content: string }[]) {
    const { text } = await blink.ai.generateText({
      prompt: `Synthesize a 'Codified Breakthrough' from this session. 
A Codified Breakthrough is a singular, profound insight expressed in exactly one or two powerful sentences. 
It must reflect a shift in the user's cognitive landscape — not advice, but a mirror of their transformation.

Session history:
${messages.slice(-10).map((m) => `${m.role.toUpperCase()}: ${m.content}`).join('\n')}`,
      system: 'You are a Lead Behavioral Architect. Deliver a high-density, profound cognitive artifact. No quotation marks around the insight.',
    });

    return await blink.db.breakthroughs.create({
      userId,
      content: text,
      turnCount: messages.length,
    });
  },
};
