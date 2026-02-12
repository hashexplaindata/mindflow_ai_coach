import React from 'react';
import { motion } from 'framer-motion';
import { ShadowTelemetry } from '@/lib/engine';
import { Pulse, Lightning, Waves } from '@phosphor-icons/react';

interface TelemetryPanelProps {
  telemetry: ShadowTelemetry | null;
  isVisible: boolean;
}

function MetricBar({ label, value, color, icon }: { label: string; value: number; color: string; icon: React.ReactNode }) {
  return (
    <div className="space-y-1.5">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-1.5">
          {icon}
          <span className="text-[10px] font-mono uppercase tracking-[0.15em] opacity-50">{label}</span>
        </div>
        <span className="text-[10px] font-mono opacity-30">{(value * 100).toFixed(0)}%</span>
      </div>
      <div className="h-1 bg-foreground/[0.05] rounded-full overflow-hidden">
        <motion.div
          initial={{ width: 0 }}
          animate={{ width: `${value * 100}%` }}
          transition={{ type: 'spring', stiffness: 50, damping: 20 }}
          className="h-full rounded-full"
          style={{ backgroundColor: color }}
        />
      </div>
    </div>
  );
}

export function TelemetryPanel({ telemetry, isVisible }: TelemetryPanelProps) {
  if (!telemetry || !isVisible) return null;

  return (
    <motion.div
      initial={{ opacity: 0, height: 0 }}
      animate={{ opacity: 1, height: 'auto' }}
      exit={{ opacity: 0, height: 0 }}
      className="glass-panel rounded-2xl p-5 space-y-4 border-white/[0.05]"
    >
      <div className="flex items-center gap-2">
        <Pulse size={14} weight="bold" className="text-secondary" />
        <span className="text-[10px] font-mono uppercase tracking-[0.2em] text-secondary/80 font-bold">
          Shadow Telemetry — Turn {telemetry.turnIndex}
        </span>
      </div>

      <div className="space-y-3">
        <MetricBar
          label="Cognitive Load"
          value={telemetry.cognitiveLoad}
          color="hsl(var(--primary))"
          icon={<Lightning size={10} weight="fill" className="text-primary/60" />}
        />
        <MetricBar
          label="Mindset Drift"
          value={telemetry.mindsetDrift}
          color="hsl(var(--accent))"
          icon={<Waves size={10} weight="fill" className="text-accent/60" />}
        />
      </div>

      {telemetry.miltonPatterns.length > 0 && (
        <div className="pt-2 border-t border-white/[0.03]">
          <span className="text-[9px] font-mono uppercase tracking-[0.15em] opacity-20 block mb-1.5">
            Active Patterns
          </span>
          <div className="flex flex-wrap gap-1.5">
            {telemetry.miltonPatterns.slice(0, 3).map((p, i) => (
              <span
                key={i}
                className="text-[9px] font-mono px-2 py-0.5 bg-white/[0.03] rounded-full border border-white/[0.05] opacity-40"
              >
                {p.split('(')[0].trim()}
              </span>
            ))}
          </div>
        </div>
      )}
    </motion.div>
  );
}
