import React from 'react';
import { PersonalityVector } from '@/lib/engine';
import { motion } from 'framer-motion';

interface VectorDisplayProps {
  vector: PersonalityVector;
}

export function VectorDisplay({ vector }: VectorDisplayProps) {
  const dimensions = [
    { label: 'D', value: vector.discipline, color: 'hsl(var(--primary))' },
    { label: 'N', value: vector.novelty, color: 'hsl(var(--secondary))' },
    { label: 'R', value: vector.reactivity, color: 'hsl(var(--accent))' },
    { label: 'S', value: vector.structure, color: 'hsl(210, 100%, 70%)' },
  ];

  return (
    <div className="flex gap-4 p-4 glass-panel rounded-full cyber-glow">
      {dimensions.map((d) => (
        <div key={d.label} className="flex flex-col items-center gap-1">
          <div className="relative h-24 w-1.5 bg-white/10 rounded-full overflow-hidden">
            <motion.div
              initial={{ height: 0 }}
              animate={{ height: `${d.value * 100}%` }}
              className="absolute bottom-0 w-full"
              style={{ backgroundColor: d.color }}
              transition={{ type: 'spring', stiffness: 100 }}
            />
          </div>
          <span className="text-[10px] font-mono opacity-50">{d.label}</span>
        </div>
      ))}
    </div>
  );
}
