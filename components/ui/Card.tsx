// components/ui/Card.tsx
import React from 'react';
import { 
  View, 
  StyleSheet, 
  ViewProps, 
  TouchableOpacity, 
  TouchableOpacityProps 
} from 'react-native';
import { colors, spacing, borderRadius, shadows } from '@/constants/design';

interface CardProps extends ViewProps {
  variant?: 'elevated' | 'outline' | 'flat';
  onPress?: () => void;
}

export function Card({ children, variant = 'elevated', style, onPress, ...props }: CardProps) {
  const Wrapper = onPress ? TouchableOpacity : View;
  const wrapperProps = onPress ? { activeOpacity: 0.9, onPress } : {};
  
  const getVariantStyle = () => {
    switch (variant) {
      case 'elevated': return styles.elevated;
      case 'outline': return styles.outline;
      case 'flat': return styles.flat;
      default: return styles.elevated;
    }
  };

  return (
    <Wrapper 
      style={[styles.base, getVariantStyle(), style]} 
      {...(wrapperProps as any)}
      {...props}
    >
      {children}
    </Wrapper>
  );
}

const styles = StyleSheet.create({
  base: {
    borderRadius: borderRadius.lg,
    padding: spacing.md,
    backgroundColor: colors.surface,
    marginBottom: spacing.md,
  },
  elevated: {
    ...shadows.md,
  },
  outline: {
    borderWidth: 1,
    borderColor: colors.border,
  },
  flat: {
    backgroundColor: colors.surfaceVariant,
  },
});
