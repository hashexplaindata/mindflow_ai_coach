// app/(tabs)/insights.tsx
import React, { useState, useEffect } from 'react';
import { View, StyleSheet, Text, FlatList, RefreshControl } from 'react-native';
import { useBlinkAuth } from '@blinkdotnew/react';
import { blink } from '@/lib/blink';
import { colors, typography, spacing } from '@/constants/design';
import { Container, Card } from '@/components/ui';

export default function InsightsScreen() {
  const { user } = useBlinkAuth();
  const [breakthroughs, setBreakthroughs] = useState<any[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const fetchBreakthroughs = async () => {
    if (!user) return;
    try {
      const records = await blink.db.breakthroughs.list({ 
        userId: user.id,
        order: { field: 'createdAt', direction: 'desc' }
      });
      setBreakthroughs(records);
    } catch (error) {
      console.error('Fetch error:', error);
    }
  };

  useEffect(() => {
    fetchBreakthroughs();
  }, [user]);

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchBreakthroughs();
    setRefreshing(false);
  };

  const renderBreakthrough = ({ item }: { item: any }) => (
    <Card variant="outline" style={styles.insightCard}>
      <Text style={styles.insightText}>{item.content}</Text>
      <View style={styles.insightFooter}>
        <Text style={styles.insightDate}>
          {new Date(item.createdAt).toLocaleDateString()}
        </Text>
        <Text style={styles.turnCount}>Turn {item.turnCount}</Text>
      </View>
    </Card>
  );

  return (
    <Container>
      <View style={styles.header}>
        <Text style={styles.title}>Wisdom Log</Text>
        <Text style={styles.subtitle}>Codified Breakthroughs</Text>
      </View>

      <FlatList
        data={breakthroughs}
        keyExtractor={(item) => item.id}
        renderItem={renderBreakthrough}
        contentContainerStyle={styles.list}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={colors.primary} />
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>No breakthroughs yet. Continue the flow.</Text>
          </View>
        }
      />
    </Container>
  );
}

const styles = StyleSheet.create({
  header: {
    paddingVertical: spacing.xl,
  },
  title: {
    ...typography.h1,
    color: colors.primary,
  },
  subtitle: {
    ...typography.bodySmall,
    color: colors.textMuted,
  },
  list: {
    paddingBottom: spacing.xxxl,
  },
  insightCard: {
    padding: spacing.lg,
  },
  insightText: {
    ...typography.h3,
    color: colors.text,
    lineHeight: 28,
  },
  insightFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: spacing.md,
    paddingTop: spacing.sm,
    borderTopWidth: 1,
    borderTopColor: colors.border,
  },
  insightDate: {
    ...typography.caption,
    color: colors.textMuted,
  },
  turnCount: {
    ...typography.caption,
    color: colors.secondary,
  },
  emptyContainer: {
    alignItems: 'center',
    marginTop: spacing.xxxl,
  },
  emptyText: {
    ...typography.body,
    color: colors.textMuted,
    textAlign: 'center',
  },
});
