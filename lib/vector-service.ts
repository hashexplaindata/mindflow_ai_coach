import { blink } from './blink';
import {
  PersonalityVector,
  ShadowTelemetry,
  INITIAL_VECTOR,
  calculateVectorDistance,
  clampVector,
  selectMiltonPatterns,
} from './engine';

export interface VectorRecord extends PersonalityVector {
  turnCount: number;
}

export const VectorService = {
  async getUserVector(userId: string): Promise<VectorRecord> {
    try {
      const records = await blink.db.usersVectors.list({ userId });
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
      console.warn('Vector load failed:', err);
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
Task: Analyze the user's cognitive dimensions from the conversation.
Dimensions: Discipline [0-1], Novelty [0-1], Reactivity [0-1], Structure [0-1].

Conversation:
${messages.slice(-12).map(m => `${m.role.toUpperCase()}: ${m.content}`).join('\n')}

Current Profile: ${JSON.stringify({ D: current.discipline, N: current.novelty, R: current.reactivity, S: current.structure })}

Output updated vector values and shadow telemetry.`,
      schema: {
        type: 'object',
        properties: {
          discipline: { type: 'number', minimum: 0, maximum: 1 },
          novelty: { type: 'number', minimum: 0, maximum: 1 },
          reactivity: { type: 'number', minimum: 0, maximum: 1 },
          structure: { type: 'number', minimum: 0, maximum: 1 },
          cognitiveLoad: { type: 'number', minimum: 0, maximum: 1 },
          mindsetDrift: { type: 'number', minimum: 0, maximum: 1 },
        },
        required: ['discipline', 'novelty', 'reactivity', 'structure', 'cognitiveLoad', 'mindsetDrift'],
      },
    });

    const raw = object as any;
    const newVector = clampVector(raw);
    const distance = calculateVectorDistance(current, newVector);
    const newTurnCount = current.turnCount + 1;

    const telemetry: ShadowTelemetry = {
      cognitiveLoad: raw.cognitiveLoad ?? 0,
      mindsetDrift: raw.mindsetDrift ?? 0,
      miltonPatterns: selectMiltonPatterns(newVector),
      vectorDistance: distance,
      turnIndex: newTurnCount,
      timestamp: Date.now(),
    };

    await blink.db.usersVectors.upsert({
      userId,
      ...newVector,
      turnCount: newTurnCount,
      updatedAt: new Date().toISOString(),
    });

    await blink.db.telemetry.create({
      userId,
      turnIndex: newTurnCount,
      cognitiveLoad: telemetry.cognitiveLoad,
      mindsetDrift: telemetry.mindsetDrift,
      metadata: JSON.stringify({ distance, miltonPatterns: telemetry.miltonPatterns, timestamp: telemetry.timestamp }),
    });

    return { vector: newVector, telemetry };
  },

  async generateBreakthrough(userId: string, messages: { role: string; content: string }[]) {
    const { text } = await blink.ai.generateText({
      prompt: `Synthesize a 'Codified Breakthrough' from this session.
A Codified Breakthrough is a singular, profound insight in one or two sentences.

Session:
${messages.slice(-10).map(m => `${m.role.toUpperCase()}: ${m.content}`).join('\n')}`,
      system: 'You are a Lead Behavioral Architect. Deliver a profound cognitive artifact.',
    });

    return await blink.db.breakthroughs.create({
      userId,
      content: text,
      turnCount: messages.length,
    });
  },
};
