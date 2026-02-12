// app/(tabs)/index.tsx
import React, { useState, useEffect, useRef } from 'react';
import { 
  View, 
  StyleSheet, 
  Text, 
  FlatList, 
  KeyboardAvoidingView, 
  Platform 
} from 'react-native';
import { useBlinkAuth } from '@blinkdotnew/react';
import { blink } from '@/lib/blink';
import { colors, typography, spacing } from '@/constants/design';
import { VectorService } from '@/lib/vector-service';
import { CognitiveEngine } from '@/lib/engine';
import { Container, Input, Button, Card } from '@/components/ui';
import { Ionicons } from '@expo/vector-icons';

export default function FlowScreen() {
  const { user } = useBlinkAuth();
  const [messages, setMessages] = useState<{ role: string; content: string }[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [vector, setVector] = useState<any>(null);
  const flatListRef = useRef<FlatList>(null);

  useEffect(() => {
    if (user) {
      VectorService.getUserVector(user.id).then(setVector);
    }
  }, [user]);

  const handleSend = async () => {
    if (!input.trim() || !user || !vector) return;

    const userMessage = { role: 'user', content: input };
    const newMessages = [...messages, userMessage];
    setMessages(newMessages);
    setInput('');
    setLoading(true);

    try {
      // Logic for cognitive profiling (first 3 messages)
      if (newMessages.filter(m => m.role === 'user').length % 3 === 0) {
        const updatedVector = await VectorService.recalibrate(user.id, newMessages);
        setVector(updatedVector);
      }

      const systemPrompt = CognitiveEngine.generateSystemPrompt(vector);
      const { text } = await blink.ai.generateText({
        prompt: input,
        system: systemPrompt,
        messages: messages.map(m => ({ role: m.role as any, content: m.content })),
      });

      setMessages(prev => [...prev, { role: 'assistant', content: text }]);
    } catch (error) {
      console.error('Flow error:', error);
    } finally {
      setLoading(false);
    }
  };

  const renderMessage = ({ item }: { item: any }) => (
    <View style={[
      styles.messageContainer,
      item.role === 'user' ? styles.userMessage : styles.assistantMessage
    ]}>
      <Card variant={item.role === 'user' ? 'flat' : 'elevated'} style={styles.messageCard}>
        <Text style={styles.messageText}>{item.content}</Text>
      </Card>
    </View>
  );

  return (
    <Container style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Flow State</Text>
        {vector && (
          <View style={styles.vectorBadge}>
            <Text style={styles.vectorText}>
              D:{vector.discipline.toFixed(1)} N:{vector.novelty.toFixed(1)} R:{vector.reactivity.toFixed(1)} S:{vector.structure.toFixed(1)}
            </Text>
          </View>
        )}
      </View>

      <FlatList
        ref={flatListRef}
        data={messages}
        keyExtractor={(_, i) => i.toString()}
        renderItem={renderMessage}
        contentContainerStyle={styles.messageList}
        onContentSizeChange={() => flatListRef.current?.scrollToEnd()}
      />

      <KeyboardAvoidingView 
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        keyboardVerticalOffset={Platform.OS === 'ios' ? 100 : 0}
      >
        <View style={styles.inputArea}>
          <Input
            value={input}
            onChangeText={setInput}
            placeholder="Enter the flow..."
            multiline
            style={styles.textInput}
          />
          <Button 
            onPress={handleSend} 
            loading={loading}
            style={styles.sendButton}
            variant="primary"
          >
            Send
          </Button>
        </View>
      </KeyboardAvoidingView>
    </Container>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
  },
  headerTitle: {
    ...typography.h2,
    color: colors.primary,
  },
  vectorBadge: {
    backgroundColor: colors.surfaceVariant,
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: spacing.sm,
  },
  vectorText: {
    ...typography.tiny,
    color: colors.secondary,
  },
  messageList: {
    paddingVertical: spacing.md,
  },
  messageContainer: {
    marginBottom: spacing.sm,
    maxWidth: '85%',
  },
  userMessage: {
    alignSelf: 'flex-end',
  },
  assistantMessage: {
    alignSelf: 'flex-start',
  },
  messageCard: {
    marginBottom: 0,
  },
  messageText: {
    ...typography.body,
    color: colors.text,
  },
  inputArea: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    paddingVertical: spacing.md,
    gap: spacing.sm,
  },
  textInput: {
    flex: 1,
    maxHeight: 100,
  },
  sendButton: {
    height: 50,
  },
});
