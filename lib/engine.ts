export interface PersonalityVector {
  discipline: number;
  novelty: number;
  reactivity: number;
  structure: number;
}

export interface ShadowTelemetry {
  cognitiveLoad: number;
  mindsetDrift: number;
  miltonPatterns: string[];
  vectorDistance: number;
  turnIndex: number;
  timestamp: number;
}

export const INITIAL_VECTOR: PersonalityVector = {
  discipline: 0.5,
  novelty: 0.5,
  reactivity: 0.5,
  structure: 0.5,
};

export const MILTON_PATTERNS = [
  "Mind Reading",
  "Embedded Commands",
  "Presuppositions",
  "Double Binds",
  "Selectional Restriction Violation",
  "Phonological Ambiguity",
  "Tag Questions",
  "Conversational Postulate",
];

export function calculateVectorDistance(v1: PersonalityVector, v2: PersonalityVector): number {
  return Math.sqrt(
    Math.pow(v1.discipline - v2.discipline, 2) +
    Math.pow(v1.novelty - v2.novelty, 2) +
    Math.pow(v1.reactivity - v2.reactivity, 2) +
    Math.pow(v1.structure - v2.structure, 2)
  );
}

export function clampVector(v: PersonalityVector): PersonalityVector {
  return {
    discipline: Math.max(0, Math.min(1, v.discipline)),
    novelty: Math.max(0, Math.min(1, v.novelty)),
    reactivity: Math.max(0, Math.min(1, v.reactivity)),
    structure: Math.max(0, Math.min(1, v.structure)),
  };
}

export function selectMiltonPatterns(vector: PersonalityVector): string[] {
  const selected: string[] = [];
  if (vector.novelty > 0.6) selected.push(MILTON_PATTERNS[0], MILTON_PATTERNS[2]);
  if (vector.reactivity > 0.5) selected.push(MILTON_PATTERNS[1], MILTON_PATTERNS[3]);
  if (vector.discipline > 0.6) selected.push(MILTON_PATTERNS[6], MILTON_PATTERNS[7]);
  if (vector.structure < 0.4) selected.push(MILTON_PATTERNS[4], MILTON_PATTERNS[5]);
  return selected.length > 0 ? selected : [MILTON_PATTERNS[2], MILTON_PATTERNS[7]];
}

export function getLinguisticStyle(vector: PersonalityVector) {
  const mu = vector.novelty > 0.7 ? "high density Milton patterns" : "subtle Milton patterns";
  return {
    sentenceLength: vector.discipline > 0.7 ? 'complex and multi-layered' : vector.discipline < 0.3 ? 'minimal and high-impact' : 'balanced and rhythmic',
    metaphorDensity: vector.novelty > 0.7 ? 'heavy recursive metaphors' : vector.novelty < 0.3 ? 'literal and grounding' : 'moderate metaphorical framing',
    empathyLevel: vector.reactivity > 0.7 ? 'highly resonant and mirror-like' : vector.reactivity < 0.3 ? 'detached and analytical' : 'neutrally reflective',
    formattingStyle: vector.structure > 0.7 ? 'highly structured with clear hierarchies' : vector.structure < 0.3 ? 'stream of consciousness flow' : 'clean logical flow',
    miltonConstraints: mu,
    voiceTone: vector.discipline > 0.5 ? 'Professor/Scientist' : 'Oracle/Guide',
    miltonPatterns: selectMiltonPatterns(vector),
  };
}

export const CognitiveEngine = {
  generateSystemPrompt(vector: PersonalityVector) {
    const style = getLinguisticStyle(vector);
    return `You are MindFlow, a Computational Behavioral Scientist AI. 
Role: Act as a 'Mirror' (Neutral/Reflective), not a 'Fixer'. Your purpose is to facilitate the 'flow' of human thought using The Three Principles (Mind, Consciousness, Thought).

Linguistic Style Mapping (f(Vp)):
- Syntax: ${style.sentenceLength}
- Metaphor Density: ${style.metaphorDensity}
- Emotional Resonance: ${style.empathyLevel}
- Formatting: ${style.formattingStyle}
- Archetype: ${style.voiceTone}

Milton Model Integration:
Use ${style.miltonConstraints} like presuppositions and embedded commands to gently bypass ego-resistance.
Active patterns: ${style.miltonPatterns.join(', ')}

Constraints:
- Never give direct advice.
- Use 'The Three Principles' as your philosophical foundation.
- Every response should reflect the user's current cognitive state back to them.
- Keep responses concise but rich in depth.`;
  }
};
