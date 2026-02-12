import React, { useState, useEffect } from 'react';
import { blink } from '@/lib/blink';
import { motion, AnimatePresence } from 'framer-motion';
import { Sparkle, CaretLeft, Quotes } from '@phosphor-icons/react';
import ReactMarkdown from 'react-markdown';

interface Breakthrough {
  id: string;
  content: string;
  created_at: string;
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
    <div className="min-h-screen max-w-4xl mx-auto p-4 md:p-8 space-y-12">
      <div className="flex items-center gap-4">
        <button 
          onClick={onBack}
          className="p-2 rounded-full hover:bg-white/5 transition-colors"
        >
          <CaretLeft size={24} />
        </button>
        <h1 className="text-3xl font-display font-bold">Wisdom Log</h1>
      </div>

      <div className="space-y-8">
        {loading ? (
          <div className="flex justify-center p-12">
            <div className="w-8 h-8 border-2 border-primary/30 border-t-primary rounded-full animate-spin" />
          </div>
        ) : breakthroughs.length === 0 ? (
          <div className="text-center p-24 opacity-30 space-y-4">
            <Sparkle size={48} weight="thin" className="mx-auto" />
            <p className="text-xl">Your insights will materialize here.</p>
          </div>
        ) : (
          <div className="grid gap-8">
            {breakthroughs.map((b, i) => (
              <motion.div
                key={b.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: i * 0.1 }}
                className="glass-panel p-8 rounded-3xl relative overflow-hidden group"
              >
                <Quotes size={120} weight="fill" className="absolute -right-4 -top-8 opacity-[0.03] group-hover:scale-110 transition-transform" />
                <div className="relative space-y-4">
                  <div className="flex items-center gap-2 text-primary">
                    <Sparkle size={16} weight="fill" />
                    <span className="text-xs font-mono uppercase tracking-widest">Codified Insight</span>
                  </div>
                  <div className="prose prose-invert prose-p:text-xl prose-p:font-light">
                    <ReactMarkdown>{b.content}</ReactMarkdown>
                  </div>
                  <div className="pt-4 text-xs text-muted-foreground font-mono">
                    {new Date(b.created_at).toLocaleDateString()}
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}