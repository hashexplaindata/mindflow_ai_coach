// lib/vector-service.ts
import { blink } from './blink';
import { PersonalityVector, INITIAL_VECTOR, calculateVectorDistance } from './engine';

export const VectorService = {
  async getUserVector(userId: string): Promise<PersonalityVector & { turnCount: number }> {
    const records = await blink.db.users_vectors.list({ userId });
    const record = records[0];
    
    if (!record) {
      const initial = await blink.db.users_vectors.create({
        userId,
        ...INITIAL_VECTOR,
        turnCount: 0,
      });
      return { ...initial, turnCount: 0 } as any;
    }
    return record as any;
  },

  async recalibrate(userId: string, messages: { role: string; content: string }[]): Promise<PersonalityVector> {
    const current = await this.getUserVector(userId);
    
    const { object } = await blink.ai.generateObject({
      prompt: `Role: You are a Computational Behavioral Scientist.
Task: Analyze the user's cognitive dimensions from the provided conversation.
Dimensions:
- Discipline (D): Logical density, focus, commitment to a line of thought.
- Novelty (N): Metaphorical complexity, creativity, openness to new perspectives.
- Reactivity (R): Emotional intensity, sensitivity to mirroring, conversational speed.
- Structure (S): Information architecture, organized vs. associative flow.

Conversation:
${messages.map(m => `${m.role.toUpperCase()}: ${m.content}`).join('\n')}

Current Profile: ${JSON.stringify({ D: current.discipline, N: current.novelty, R: current.reactivity, S: current.structure })}

Output the updated vector values (0.0 to 1.0) and shadow telemetry (Cognitive Load and Mindset Drift).`,
      schema: {
        type: 'object',
        properties: {
          discipline: { type: 'number', minimum: 0, maximum: 1 },
          novelty: { type: 'number', minimum: 0, maximum: 1 },
          reactivity: { type: 'number', minimum: 0, maximum: 1 },
          structure: { type: 'number', minimum: 0, maximum: 1 },
          cognitiveLoad: { type: 'number', description: "Measure of processing difficulty observed in the user's syntax." },
          mindsetDrift: { type: 'number', description: "Measure of shift in perspective or emotional state from the baseline." }
        },
        required: ['discipline', 'novelty', 'reactivity', 'structure', 'cognitiveLoad', 'mindsetDrift']
      }
    });

    const newVector = object as any;
    const distance = calculateVectorDistance(current, newVector);

    await blink.db.users_vectors.update(userId, {
      discipline: newVector.discipline,
      novelty: newVector.novelty,
      reactivity: newVector.reactivity,
      structure: newVector.structure,
      turnCount: current.turnCount + 1,
      updatedAt: new Date().toISOString(),
    });

    await blink.db.telemetry.create({
      userId,
      turnIndex: current.turnCount + 1,
      cognitiveLoad: newVector.cognitiveLoad,
      mindsetDrift: newVector.mindsetDrift,
      metadata: JSON.stringify({ distance, timestamp: Date.now() }),
    });

    return newVector;
  },

  async generateBreakthrough(userId: string, messages: { role: string; content: string }[]) {
    const { text } = await blink.ai.generateText({
      prompt: `Synthesize a 'Codified Breakthrough' from this session. 
A Codified Breakthrough is a singular, profound insight expressed in exactly one or two powerful sentences. 
It must reflect a shift in the user's cognitive landscape.

Session history:
${messages.slice(-10).map(m => `${m.role.toUpperCase()}: ${m.content}`).join('\n')}`,
      system: "You are a Lead Behavioral Architect. Deliver a high-density, profound cognitive artifact."
    });

    return await blink.db.breakthroughs.create({
      userId,
      content: text,
      turnCount: messages.length,
    });
  }
};
