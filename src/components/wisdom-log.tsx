import React, { useState, useEffect } from 'react';
import { blink } from '@/lib/blink';
import { motion, AnimatePresence } from 'framer-motion';
import { Sparkle, CaretLeft, Quotes } from '@phosphor-icons/react';
import ReactMarkdown from 'react-markdown';

interface Breakthrough {
  id: string;
  content: string;
  created_at: string;
  turn_count?: number;
}

export function WisdomLog({ onBack }: { onBack: () => void }) {
  const [breakthroughs, setBreakthroughs] = useState<Breakthrough[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetch = async () => {
      const records = await blink.db.breakthroughs.list({
        orderBy: { createdAt: 'desc' }
      });
      setBreakthroughs(records as any);
      setLoading(false);
    };
    fetch();
  }, []);

  return (
    <div className="min-h-screen max-w-5xl mx-auto p-4 md:p-12 space-y-16 relative">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-6">
          <button 
            onClick={onBack}
            className="p-3 rounded-2xl bg-white/[0.03] border border-white/[0.05] hover:bg-white/10 transition-all active:scale-90"
          >
            <CaretLeft size={24} weight="light" />
          </button>
          <div className="space-y-1">
            <h1 className="text-4xl font-display font-bold tracking-tight">Wisdom Log</h1>
            <p className="text-sm text-muted-foreground font-mono uppercase tracking-widest opacity-40">Longitudinal Cognitive Insights</p>
          </div>
        </div>
        <div className="p-4 rounded-3xl bg-primary/5 border border-primary/10">
          <Sparkle size={32} weight="duotone" className="text-primary animate-pulse" />
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        {loading ? (
          <div className="col-span-full flex flex-col items-center justify-center p-24 space-y-4">
            <div className="w-12 h-12 border-2 border-primary/20 border-t-primary rounded-full animate-spin" />
            <p className="text-xs font-mono uppercase tracking-[0.3em] opacity-30">Accessing neural artifacts</p>
          </div>
        ) : breakthroughs.length === 0 ? (
          <div className="col-span-full text-center p-32 space-y-6">
            <div className="relative inline-block">
              <div className="absolute inset-0 bg-primary/10 blur-2xl rounded-full" />
              <Sparkle size={64} weight="thin" className="relative text-primary/20 mx-auto" />
            </div>
            <p className="text-2xl font-display font-light text-foreground/20">Insights have not yet materialized.</p>
          </div>
        ) : (
          <AnimatePresence>
            {breakthroughs.map((b, i) => (
              <motion.div
                key={b.id}
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: i * 0.1, duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
                className="glass-panel p-10 rounded-[2.5rem] relative overflow-hidden group hover:bg-white/[0.02] transition-colors border-white/[0.05]"
              >
                <Quotes size={160} weight="fill" className="absolute -right-8 -top-12 opacity-[0.02] group-hover:scale-110 transition-transform group-hover:text-primary" />
                <div className="relative space-y-8">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3 text-primary/60">
                      <Sparkle size={20} weight="duotone" />
                      <span className="text-xs font-mono uppercase tracking-[0.2em] font-bold">Insight Codified</span>
                    </div>
                    <span className="text-[10px] font-mono opacity-20 uppercase tracking-widest">Turn {b.turn_count}</span>
                  </div>
                  
                  <div className="prose prose-invert max-w-none">
                    <p className="text-2xl md:text-3xl font-display font-light leading-snug tracking-tight text-foreground/90 italic">
                      {b.content}
                    </p>
                  </div>

                  <div className="pt-8 border-t border-white/[0.05] flex items-center justify-between">
                    <div className="text-xs text-muted-foreground font-mono uppercase tracking-widest opacity-30">
                      {new Date(b.created_at).toLocaleDateString(undefined, { month: 'long', day: 'numeric', year: 'numeric' })}
                    </div>
                  </div>
                </div>
              </motion.div>
            ))}
          </AnimatePresence>
        )}
      </div>
    </div>
  );
}
