import React, { useState, useEffect } from 'react';
import { blink } from '@/lib/blink';
import { useAuth } from '@/hooks/use-auth';
import { ChatInterface } from '@/components/chat-interface';
import { Toaster } from 'sonner';
import { Brain, Sparkle, GoogleLogo, GithubLogo, ClockCounterClockwise, SignOut, Crown } from '@phosphor-icons/react';
import { motion } from 'framer-motion';

function LandingPage({ onLogin }: { onLogin: () => void }) {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-4 relative overflow-hidden">
      {/* Background Orbs */}
      <div className="absolute top-0 left-0 w-full h-full pointer-events-none">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-primary/10 blur-[120px] rounded-full animate-pulse" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-secondary/10 blur-[120px] rounded-full animate-pulse [animation-delay:2s]" />
      </div>

      <div className="max-w-4xl w-full text-center space-y-16 relative z-10">
        <div className="space-y-6">
          <motion.div 
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            className="flex justify-center"
          >
            <div className="p-6 rounded-[2rem] bg-white/[0.02] border border-white/[0.05] shadow-2xl cyber-glow backdrop-blur-xl">
              <Brain size={80} weight="duotone" className="text-primary animate-pulse" />
            </div>
          </motion.div>
          
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="space-y-4"
          >
            <h1 className="text-6xl md:text-8xl font-display font-bold tracking-tighter">
              Mind<span className="text-primary">Flow</span>
            </h1>
            <p className="text-xl md:text-3xl text-muted-foreground font-light max-w-2xl mx-auto leading-relaxed">
              An adaptive interface of thought.
              <span className="block text-lg mt-4 opacity-50 font-mono tracking-widest uppercase">Computational Behavioral Science</span>
            </p>
          </motion.div>
        </div>

        <motion.div 
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.4 }}
          className="grid grid-cols-1 md:grid-cols-3 gap-8 text-left"
        >
          {[
            { icon: Sparkle, title: 'Adaptive Style', desc: 'AI modifies syntax and metaphor density based on your unique personality vector.' },
            { icon: Brain, title: 'Zero-Shot Profiling', desc: 'No onboarding. Your first 3 messages define your cognitive footprint.' },
            { icon: ClockCounterClockwise, title: 'Insight Log', desc: 'Codified breakthroughs captured into your personal longitudinal wisdom log.' },
          ].map((f, i) => (
            <div key={i} className="glass-panel p-8 rounded-3xl space-y-4 hover:bg-white/[0.03] transition-colors group">
              <div className="p-3 rounded-2xl bg-white/[0.05] w-fit group-hover:scale-110 transition-transform">
                <f.icon size={28} className="text-secondary" />
              </div>
              <h3 className="text-xl font-display font-semibold tracking-tight">{f.title}</h3>
              <p className="text-base text-muted-foreground leading-relaxed opacity-70">{f.desc}</p>
            </div>
          ))}
        </motion.div>

        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="flex flex-col items-center gap-6"
        >
          <button
            onClick={onLogin}
            className="group relative px-12 py-5 bg-primary text-primary-foreground rounded-2xl font-bold text-xl hover:scale-105 transition-all cyber-glow active:scale-95 shadow-2xl shadow-primary/20"
          >
            Begin the Recalibration
          </button>
          <div className="flex items-center gap-2 text-xs text-muted-foreground uppercase tracking-[0.3em] font-mono opacity-40">
            <span className="w-2 h-2 rounded-full bg-primary animate-pulse" />
            Gemini 2.0 Flash Core Enabled
          </div>
        </motion.div>
      </div>

      <footer className="absolute bottom-8 left-0 right-0 text-center opacity-20 text-[10px] font-mono uppercase tracking-widest">
        Privacy-First Shadow Telemetry Active • Recursive Recalibration v1.0
      </footer>
    </div>
  );
}

export default function App() {
  const { user, loading, login, isAuthenticated } = useAuth();

  if (loading) {
    return (
      <div className="h-screen flex items-center justify-center">
        <div className="w-12 h-12 border-4 border-primary/30 border-t-primary rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <main className="min-h-screen bg-background text-foreground selection:bg-primary/30 selection:text-primary-foreground">
      {isAuthenticated ? (
        <ChatInterface userId={user.id} />
      ) : (
        <LandingPage onLogin={login} />
      )}
      <Toaster position="top-center" theme="dark" closeButton />
    </main>
  );
}