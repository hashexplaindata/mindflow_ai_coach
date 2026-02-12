// app/(tabs)/settings.tsx
import React from 'react';
import { View, StyleSheet, Text, ScrollView, Alert } from 'react-native';
import { useBlinkAuth } from '@blinkdotnew/react';
import { blink } from '@/lib/blink';
import { colors, typography, spacing } from '@/constants/design';
import { Container, Button, Card, Avatar } from '@/components/ui';
import { useCustomerInfo, usePackages } from '@/lib/payments';

export default function SettingsScreen() {
  const { user } = useBlinkAuth();
  const { isPro, customerInfo } = useCustomerInfo();
  const { packages, purchasePackage } = usePackages();

  const handleLogout = async () => {
    try {
      await blink.auth.signOut();
    } catch (error) {
      console.error('Logout failed', error);
    }
  };

  const handleUpgrade = async () => {
    if (packages.length > 0) {
      try {
        await purchasePackage(packages[0]);
      } catch (error: any) {
        if (!error.userCancelled) {
          Alert.alert('Error', 'Failed to complete purchase');
        }
      }
    }
  };

  return (
    <Container>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.profileSection}>
          <Avatar 
            name={user?.displayName || 'User'} 
            src={user?.avatarUrl} 
            size="xl" 
          />
          <Text style={styles.userName}>{user?.displayName || 'Flow User'}</Text>
          <Text style={styles.userEmail}>{user?.email}</Text>
          {isPro && (
            <View style={styles.proBadge}>
              <Text style={styles.proText}>PRO MEMBER</Text>
            </View>
          )}
        </View>

        {!isPro && (
          <Card variant="elevated" style={styles.upgradeCard}>
            <Text style={styles.upgradeTitle}>Unlock Pro Access</Text>
            <Text style={styles.upgradeText}>
              Get real-time vector recalibration and recursive cognitive mapping.
            </Text>
            <Button onPress={handleUpgrade} variant="primary" style={styles.upgradeButton}>
              Upgrade to Pro
            </Button>
          </Card>
        )}

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Account</Text>
          <Card variant="outline">
            <Button variant="ghost" onPress={handleLogout} style={styles.logoutButton}>
              Sign Out
            </Button>
          </Card>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Privacy</Text>
          <Text style={styles.privacyNote}>
            All cognitive telemetry is encrypted and anonymized. 
            MindFlow prioritizes your mental privacy.
          </Text>
        </View>
      </ScrollView>
    </Container>
  );
}

const styles = StyleSheet.create({
  scrollContent: {
    paddingVertical: spacing.xl,
  },
  profileSection: {
    alignItems: 'center',
    marginBottom: spacing.xxl,
  },
  userName: {
    ...typography.h2,
    color: colors.text,
    marginTop: spacing.md,
  },
  userEmail: {
    ...typography.bodySmall,
    color: colors.textMuted,
  },
  proBadge: {
    backgroundColor: colors.primary,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
    borderRadius: spacing.full,
    marginTop: spacing.sm,
  },
  proText: {
    ...typography.tiny,
    color: colors.textInverted,
    fontWeight: '700',
  },
  upgradeCard: {
    backgroundColor: colors.surfaceVariant,
    borderColor: colors.primary,
    borderWidth: 1,
  },
  upgradeTitle: {
    ...typography.h3,
    color: colors.primaryLight,
  },
  upgradeText: {
    ...typography.bodySmall,
    color: colors.text,
    marginVertical: spacing.sm,
  },
  upgradeButton: {
    marginTop: spacing.sm,
  },
  section: {
    marginTop: spacing.xl,
  },
  sectionTitle: {
    ...typography.caption,
    color: colors.textMuted,
    textTransform: 'uppercase',
    marginBottom: spacing.sm,
    marginLeft: spacing.xs,
  },
  logoutButton: {
    justifyContent: 'flex-start',
  },
  privacyNote: {
    ...typography.bodySmall,
    color: colors.textMuted,
    fontStyle: 'italic',
  },
});
