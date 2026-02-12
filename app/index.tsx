// app/index.tsx
import { useEffect } from 'react';
import { View, StyleSheet, Text } from 'react-native';
import { useRouter } from 'expo-router';
import { useBlinkAuth } from '@blinkdotnew/react';
import { blink } from '@/lib/blink';
import { colors, typography, spacing } from '@/constants/design';
import { Button, Container } from '@/components/ui';

export default function WelcomeScreen() {
  const router = useRouter();
  const { isAuthenticated, isLoading } = useBlinkAuth();

  useEffect(() => {
    if (!isLoading && isAuthenticated) {
      router.replace('/(tabs)');
    }
  }, [isAuthenticated, isLoading]);

  const handleLogin = async () => {
    try {
      await blink.auth.signInWithGoogle();
    } catch (error) {
      console.error('Login failed', error);
    }
  };

  if (isLoading) return null;

  return (
    <Container style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>MindFlow</Text>
        <Text style={styles.subtitle}>Adaptive Cognition Engine</Text>
        
        <View style={styles.featureList}>
          <Text style={styles.feature}>• Zero-Shot Cognitive Profiling</Text>
          <Text style={styles.feature}>• Dynamic Style Orchestration</Text>
          <Text style={styles.feature}>• Codified Breakthroughs</Text>
        </View>

        <Button 
          onPress={handleLogin}
          variant="primary"
          size="lg"
          style={styles.button}
        >
          Sign In with Google
        </Button>
      </View>
    </Container>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    padding: spacing.xl,
  },
  content: {
    alignItems: 'center',
  },
  title: {
    ...typography.display,
    color: colors.primary,
    marginBottom: spacing.xs,
  },
  subtitle: {
    ...typography.h3,
    color: colors.secondary,
    marginBottom: spacing.xxl,
  },
  featureList: {
    marginBottom: spacing.xxxl,
    width: '100%',
  },
  feature: {
    ...typography.body,
    color: colors.textMuted,
    marginBottom: spacing.sm,
  },
  button: {
    width: '100%',
  },
});
