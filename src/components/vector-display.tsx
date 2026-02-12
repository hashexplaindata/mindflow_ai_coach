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
    { label: 'S', value: vector.structure, color: 'hsl(180, 100%, 70%)' },
  ];

  return (
    <div className="flex gap-4 p-3 glass-panel rounded-2xl cyber-glow border-white/[0.05]">
      {dimensions.map((d) => (
        <div key={d.label} className="flex flex-col items-center gap-1.5 group cursor-help">
          <div className="relative h-12 w-1 bg-white/[0.05] rounded-full overflow-hidden">
            <motion.div
              initial={{ height: 0 }}
              animate={{ height: `${d.value * 100}%` }}
              className="absolute bottom-0 w-full rounded-full"
              style={{ 
                backgroundColor: d.color,
                boxShadow: `0 0 10px ${d.color}`
              }}
              transition={{ type: 'spring', stiffness: 50, damping: 15 }}
            />
          </div>
          <span className="text-[9px] font-mono opacity-30 group-hover:opacity-100 transition-opacity">{d.label}</span>
        </div>
      ))}
    </div>
  );
}
