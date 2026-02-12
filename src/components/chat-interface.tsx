import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { blink } from '@/lib/blink';
import { VectorService } from '@/lib/vector-service';
import { PersonalityVector, INITIAL_VECTOR, getLinguisticStyle } from '@/lib/engine';
import { VectorDisplay } from './vector-display';
import { Brain, PaperPlaneTilt, Sparkle, ClockCounterClockwise, SignOut, Crown } from '@phosphor-icons/react';
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
  const [showWisdom, setShowWisdom] = useState(false);
  const { isPro, upgrade } = usePayments();
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    VectorService.getUserVector(userId).then(setVector);
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
      const style = getLinguisticStyle(vector);
      
      const { text } = await blink.ai.generateText({
        messages: [
          { 
            role: 'system', 
            content: `You are MindFlow, a Computational Behavioral Scientist AI. 
            Philosophical Bedrock: The Three Principles (Mind, Consciousness, Thought).
            Tone: Mirror (Neutral/Reflective), not a 'Fixer'.
            Linguistic Style Constraints: ${JSON.stringify(style)}.
            Linguistic Patterns: Milton Model (presuppositions, embedded commands) to bypass ego-resistance.` 
          },
          ...newMessages
        ],
      });

      const updatedMessages: Message[] = [...newMessages, { role: 'assistant', content: text }];
      setMessages(updatedMessages);

      // Recalibrate every 3 turns
      if (updatedMessages.length % 6 === 0) { // 3 turns = 6 messages
        if (isPro) {
          const newV = await VectorService.recalibrate(userId, updatedMessages);
          setVector(newV);
          toast.info("MindFlow has recalibrated your cognitive vector.", {
            icon: <Brain className="w-4 h-4" />,
          });
        } else {
          toast.info("Recursive Recalibration is a Pro feature.", {
            description: "Upgrade to unlock real-time vector updates.",
            action: {
              label: "Upgrade",
              onClick: upgrade
            }
          });
        }
      }

      // Check for breakthrough at session end (arbitrary logic for demo)
      if (updatedMessages.length > 10 && updatedMessages.length % 10 === 0) {
        await VectorService.generateBreakthrough(userId, updatedMessages);
        toast.success("Codified Breakthrough generated in your Wisdom Log.", {
          icon: <Sparkle className="w-4 h-4" />,
        });
      }
    } catch (error) {
      console.error(error);
      toast.error("An error occurred in the cognition engine.");
    } finally {
      setLoading(false);
    }
  };

  if (showWisdom) {
    return <WisdomLog onBack={() => setShowWisdom(false)} />;
  }

  return (
    <div className="flex flex-col h-screen max-w-4xl mx-auto p-4 md:p-8 relative">
      <div className="flex items-center justify-between mb-8">
        <div className="flex items-center gap-2">
          <Brain size={32} weight="duotone" className="text-primary animate-pulse" />
          <h1 className="text-2xl font-display font-bold tracking-tight">MindFlow</h1>
        </div>
        <div className="flex items-center gap-4">
          <VectorDisplay vector={vector} />
          <div className="flex items-center gap-2">
            <button 
              onClick={() => setShowWisdom(true)}
              className="p-2 rounded-full hover:bg-white/5 transition-colors"
              title="Wisdom Log"
            >
              <ClockCounterClockwise size={20} />
            </button>
            {!isPro && (
              <button 
                onClick={upgrade}
                className="p-2 rounded-full hover:bg-primary/20 text-primary transition-colors"
                title="Upgrade to Pro"
              >
                <Crown size={20} weight="fill" />
              </button>
            )}
            <button 
              onClick={() => blink.auth.signOut()}
              className="p-2 rounded-full hover:bg-white/5 transition-colors"
              title="Sign Out"
            >
              <SignOut size={20} />
            </button>
          </div>
        </div>
      </div>

      <div 
        ref={scrollRef}
        className="flex-1 overflow-y-auto space-y-8 pb-32 scrollbar-none"
      >
        <AnimatePresence>
          {messages.length === 0 && (
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="h-full flex flex-col items-center justify-center text-center space-y-4 opacity-50"
            >
              <Sparkle size={48} weight="thin" className="animate-spin-slow" />
              <p className="text-lg font-display">Begin the flow of thought.</p>
            </motion.div>
          )}
          {messages.map((m, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className={`flex ${m.role === 'user' ? 'justify-end' : 'justify-start'}`}
            >
              <div className={`max-w-[85%] md:max-w-[70%] p-6 rounded-3xl ${
                m.role === 'user' 
                  ? 'bg-primary/10 border border-primary/20 rounded-tr-none' 
                  : 'glass-panel rounded-tl-none milton-reveal'
              }`}>
                <div className="prose prose-invert prose-p:leading-relaxed text-foreground/90">
                  <ReactMarkdown>{m.content}</ReactMarkdown>
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
              <div className="glass-panel p-6 rounded-3xl rounded-tl-none flex items-center gap-2">
                <div className="w-2 h-2 bg-primary rounded-full animate-bounce" />
                <div className="w-2 h-2 bg-primary rounded-full animate-bounce [animation-delay:-0.15s]" />
                <div className="w-2 h-2 bg-primary rounded-full animate-bounce [animation-delay:-0.3s]" />
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      <form 
        onSubmit={handleSubmit}
        className="fixed bottom-8 left-4 right-4 max-w-4xl mx-auto"
      >
        <div className="relative glass-panel rounded-2xl cyber-glow input-focus-glow">
          <textarea
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                handleSubmit();
              }
            }}
            placeholder="What occupies your mind?"
            className="w-full bg-transparent p-6 pr-16 outline-none resize-none min-h-[80px] text-lg"
            rows={1}
          />
          <button
            type="submit"
            disabled={loading || !input.trim()}
            className="absolute right-4 bottom-4 p-3 rounded-xl bg-primary text-white hover:scale-105 active:scale-95 transition-all disabled:opacity-50 disabled:scale-100"
          >
            <PaperPlaneTilt size={24} weight="fill" />
          </button>
        </div>
      </form>
    </div>
  );
}
