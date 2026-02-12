import React, { useState, useEffect } from 'react';
import { blink } from '@/lib/blink';
import { useAuth } from '@/hooks/use-auth';
import { ChatInterface } from '@/components/chat-interface';
import { Toaster } from 'sonner';
import { Brain, Sparkle, GoogleLogo, GithubLogo } from '@phosphor-icons/react';

function LandingPage({ onLogin }: { onLogin: () => void }) {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-4 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-primary/20 via-background to-background">
      <div className="max-w-2xl w-full text-center space-y-12">
        <div className="space-y-4">
          <div className="flex justify-center">
            <div className="p-4 rounded-3xl bg-primary/10 border border-primary/20 animate-float">
              <Brain size={64} weight="duotone" className="text-primary" />
            </div>
          </div>
          <h1 className="text-5xl md:text-7xl font-display font-bold tracking-tighter">
            Mind<span className="text-primary">Flow</span>
          </h1>
          <p className="text-xl md:text-2xl text-muted-foreground font-light max-w-lg mx-auto leading-relaxed">
            Profiling cognitive dimensions to adapt the interface of thought.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 text-left">
          {[
            { icon: Sparkle, title: 'Adaptive Style', desc: 'AI modifies syntax and metaphor density based on your personality.' },
            { icon: Brain, title: 'Zero-Shot Profiling', desc: 'No onboarding. Your messages are your cognitive footprint.' },
            { icon: GithubLogo, title: 'Breakthrough Logs', desc: 'Codified insights saved to your personal wisdom log.' },
          ].map((f, i) => (
            <div key={i} className="glass-panel p-6 rounded-2xl space-y-3">
              <f.icon size={24} className="text-secondary" />
              <h3 className="font-display font-semibold">{f.title}</h3>
              <p className="text-sm text-muted-foreground leading-snug">{f.desc}</p>
            </div>
          ))}
        </div>

        <div className="flex flex-col items-center gap-4">
          <button
            onClick={onLogin}
            className="group relative px-8 py-4 bg-primary text-white rounded-2xl font-semibold text-lg hover:scale-105 transition-all cyber-glow active:scale-95"
          >
            Enter the Flow
          </button>
          <p className="text-xs text-muted-foreground uppercase tracking-widest font-mono">
            Powered by Gemini 2.0 Flash
          </p>
        </div>
      </div>
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
