import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { blink } from '@/lib/blink';
import { VectorService } from '@/lib/vector-service';
import { PersonalityVector, ShadowTelemetry, INITIAL_VECTOR, CognitiveEngine } from '@/lib/engine';
import { VectorDisplay } from './vector-display';
import { TelemetryPanel } from './telemetry-panel';
import { Brain, PaperPlaneTilt, Sparkle, ClockCounterClockwise, SignOut, Crown, Eye, EyeClosed } from '@phosphor-icons/react';
import ReactMarkdown from 'react-markdown';
import { toast } from 'sonner';
import { WisdomLog } from './wisdom-log';
import { usePayments } from '@/hooks/use-payments';

interface Message {
  role: 'user' | 'assistant';
  content: string;
}

export function ChatInterface({ userId }: { userId: string }) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [vector, setVector] = useState<PersonalityVector>(INITIAL_VECTOR);
  const [turnCount, setTurnCount] = useState(0);
  const [showWisdom, setShowWisdom] = useState(false);
  const [latestTelemetry, setLatestTelemetry] = useState<ShadowTelemetry | null>(null);
  const [showTelemetry, setShowTelemetry] = useState(false);
  const { isPro, upgrade } = usePayments();
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    VectorService.getUserVector(userId).then(data => {
      setVector({
        discipline: data.discipline,
        novelty: data.novelty,
        reactivity: data.reactivity,
        structure: data.structure
      });
      setTurnCount(data.turnCount);
    });
  }, [userId]);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  const handleSubmit = async (e?: React.FormEvent) => {
    e?.preventDefault();
    if (!input.trim() || loading) return;

    const userMsg = input.trim();
    setInput('');
    const newMessages: Message[] = [...messages, { role: 'user', content: userMsg }];
    setMessages(newMessages);
    setLoading(true);

    try {
      const systemPrompt = CognitiveEngine.generateSystemPrompt(vector);

      const { text } = await blink.ai.generateText({
        messages: [
          { role: 'system', content: systemPrompt },
          ...newMessages
        ],
      });

      const updatedMessages: Message[] = [...newMessages, { role: 'assistant', content: text }];
      setMessages(updatedMessages);

      const userMessageCount = updatedMessages.filter(m => m.role === 'user').length;

      // Zero-shot profiling: After first 3 user messages
      if (userMessageCount === 3 && turnCount === 0) {
        const result = await VectorService.recalibrate(userId, updatedMessages);
        setVector(result.vector);
        setLatestTelemetry(result.telemetry);
        setTurnCount(1);
        toast.success("Cognitive Profile Extracted", {
          description: `D:${result.vector.discipline.toFixed(2)} N:${result.vector.novelty.toFixed(2)} R:${result.vector.reactivity.toFixed(2)} S:${result.vector.structure.toFixed(2)}`,
          icon: <Brain weight="duotone" className="text-primary" />
        });
      } else if (userMessageCount > 3 && userMessageCount % 3 === 0) {
        // Recursive recalibration — Pro users only after initial profiling
        if (isPro) {
          const result = await VectorService.recalibrate(userId, updatedMessages);
          setVector(result.vector);
          setLatestTelemetry(result.telemetry);
          setTurnCount(prev => prev + 1);
          toast.info("Vector Recalibrated", {
            description: `Drift: ${(result.telemetry.mindsetDrift * 100).toFixed(0)}% • Load: ${(result.telemetry.cognitiveLoad * 100).toFixed(0)}%`,
            icon: <Sparkle weight="duotone" className="text-secondary" />
          });
        } else if (userMessageCount === 6) {
          // Nudge free users once
          toast("Unlock deeper adaptation", {
            description: "Pro members get real-time vector recalibration.",
            action: { label: "Upgrade", onClick: upgrade },
          });
        }
      }

      // Codified Breakthrough — every 5 user messages after 10
      if (userMessageCount >= 10 && userMessageCount % 5 === 0) {
        await VectorService.generateBreakthrough(userId, updatedMessages);
        toast.success("New Insight Codified", {
          description: "Check your Wisdom Log for the latest breakthrough.",
        });
      }
    } catch (error) {
      console.error(error);
      toast.error("Cognition engine failed to respond.");
    } finally {
      setLoading(false);
    }
  };

  if (showWisdom) {
    return <WisdomLog onBack={() => setShowWisdom(false)} />;
  }

  return (
    <div className="flex flex-col h-screen max-w-5xl mx-auto p-4 md:p-12 relative">
      {/* Header */}
      <header className="flex items-center justify-between mb-8 md:mb-12">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-primary/10 rounded-xl border border-primary/20">
            <Brain size={24} weight="duotone" className="text-primary" />
          </div>
          <h1 className="text-xl font-display font-bold tracking-tight opacity-80">MindFlow</h1>
        </div>

        <div className="flex items-center gap-4 md:gap-6">
          <VectorDisplay vector={vector} />

          <div className="flex items-center gap-1">
            {latestTelemetry && (
              <button
                onClick={() => setShowTelemetry(!showTelemetry)}
                className={`p-2.5 rounded-xl transition-all active:scale-90 ${showTelemetry ? 'bg-secondary/10 text-secondary' : 'hover:bg-white/5'}`}
                title="Shadow Telemetry"
              >
                {showTelemetry ? <Eye size={22} weight="fill" /> : <EyeClosed size={22} weight="light" />}
              </button>
            )}
            <button
              onClick={() => setShowWisdom(true)}
              className="p-2.5 rounded-xl hover:bg-white/5 transition-all active:scale-90"
              title="Wisdom Log"
            >
              <ClockCounterClockwise size={22} weight="light" />
            </button>
            {!isPro && (
              <button
                onClick={upgrade}
                className="p-2.5 rounded-xl hover:bg-accent/10 text-accent transition-all active:scale-90"
                title="Upgrade to Pro"
              >
                <Crown size={22} weight="fill" />
              </button>
            )}
            <button
              onClick={() => blink.auth.signOut()}
              className="p-2.5 rounded-xl hover:bg-white/5 transition-all active:scale-90"
              title="Sign Out"
            >
              <SignOut size={22} weight="light" />
            </button>
          </div>
        </div>
      </header>

      {/* Telemetry Panel */}
      <AnimatePresence>
        {showTelemetry && latestTelemetry && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className="mb-6"
          >
            <TelemetryPanel telemetry={latestTelemetry} isVisible={true} />
          </motion.div>
        )}
      </AnimatePresence>

      {/* Message Stream */}
      <div
        ref={scrollRef}
        className="flex-1 overflow-y-auto space-y-12 pb-40 scrollbar-none px-2"
      >
        <AnimatePresence mode="popLayout">
          {messages.length === 0 && (
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="h-[60vh] flex flex-col items-center justify-center text-center space-y-6"
            >
              <div className="relative">
                <div className="absolute inset-0 bg-primary/20 blur-3xl rounded-full" />
                <Sparkle size={64} weight="thin" className="relative text-primary/40" />
              </div>
              <div className="space-y-2">
                <p className="text-2xl font-display font-light text-foreground/40">The flow is quiet.</p>
                <p className="text-sm font-mono uppercase tracking-[0.2em] text-foreground/20">Awaiting cognitive input</p>
              </div>
            </motion.div>
          )}
          {messages.map((m, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
              className={`flex ${m.role === 'user' ? 'justify-end' : 'justify-start'}`}
            >
              <div className={`max-w-[90%] md:max-w-[75%] ${m.role === 'user' ? 'text-right' : 'milton-reveal'}`}>
                <div className={`inline-block text-left p-0 ${m.role === 'user' ? 'text-primary' : 'text-foreground/90'}`}>
                  {m.role === 'user' ? (
                    <span className="text-3xl md:text-4xl font-display font-light leading-tight tracking-tight">
                      {m.content}
                    </span>
                  ) : (
                    <div className="prose prose-invert prose-lg md:prose-xl max-w-none prose-p:leading-relaxed prose-p:font-light font-sans selection:bg-secondary/30">
                      <ReactMarkdown>{m.content}</ReactMarkdown>
                    </div>
                  )}
                </div>
              </div>
            </motion.div>
          ))}
          {loading && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="flex justify-start"
            >
              <div className="flex gap-1.5 py-4">
                <div className="w-1.5 h-1.5 bg-primary/40 rounded-full animate-bounce [animation-duration:1s]" />
                <div className="w-1.5 h-1.5 bg-primary/40 rounded-full animate-bounce [animation-duration:1s] [animation-delay:0.2s]" />
                <div className="w-1.5 h-1.5 bg-primary/40 rounded-full animate-bounce [animation-duration:1s] [animation-delay:0.4s]" />
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Simon UX Input */}
      <div className="fixed bottom-0 left-0 right-0 p-6 md:p-12 pointer-events-none">
        <form
          onSubmit={handleSubmit}
          className="max-w-4xl mx-auto pointer-events-auto"
        >
          <div className="relative group">
            <div className="absolute -inset-0.5 bg-gradient-to-r from-primary/20 via-secondary/20 to-accent/20 rounded-3xl blur opacity-0 group-focus-within:opacity-100 transition duration-1000" />
            <div className="relative glass-panel rounded-3xl overflow-hidden border-white/[0.08] group-focus-within:border-primary/30 transition-colors">
              <textarea
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    handleSubmit();
                  }
                }}
                placeholder="Share your reflection..."
                className="w-full bg-transparent p-6 md:p-8 pr-20 outline-none resize-none min-h-[80px] md:min-h-[100px] text-lg md:text-2xl font-light tracking-tight placeholder:text-foreground/10"
                rows={1}
              />
              <button
                type="submit"
                disabled={loading || !input.trim()}
                className="absolute right-4 md:right-6 bottom-4 md:bottom-6 p-3 md:p-4 rounded-2xl bg-primary text-primary-foreground hover:scale-105 active:scale-95 transition-all disabled:opacity-0 disabled:scale-90 shadow-xl shadow-primary/20"
              >
                <PaperPlaneTilt size={24} weight="fill" />
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
}
