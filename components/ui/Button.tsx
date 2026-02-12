// components/ui/Button.tsx
import React from 'react';
import { 
  TouchableOpacity, 
  Text, 
  StyleSheet, 
  ActivityIndicator, 
  TouchableOpacityProps 
} from 'react-native';
import { colors, spacing, typography, borderRadius, shadows } from '@/constants/design';

interface ButtonProps extends TouchableOpacityProps {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
  children: string;
}

export function Button({ 
  variant = 'primary', 
  size = 'md', 
  loading, 
  children, 
  style, 
  disabled, 
  ...props 
}: ButtonProps) {
  
  const getVariantStyle = () => {
    switch (variant) {
      case 'primary': return styles.primary;
      case 'secondary': return styles.secondary;
      case 'outline': return styles.outline;
      case 'ghost': return styles.ghost;
      case 'danger': return styles.danger;
      default: return styles.primary;
    }
  };

  const getTextStyle = () => {
    switch (variant) {
      case 'outline': return { color: colors.primary };
      case 'ghost': return { color: colors.primary };
      default: return { color: colors.textInverted };
    }
  };

  const getSizeStyle = () => {
    switch (size) {
      case 'sm': return styles.sm;
      case 'lg': return styles.lg;
      default: return styles.md;
    }
  };

  return (
    <TouchableOpacity 
      style={[
        styles.base, 
        getVariantStyle(), 
        getSizeStyle(), 
        (disabled || loading) && styles.disabled, 
        style
      ]}
      disabled={disabled || loading}
      activeOpacity={0.7}
      {...props}
    >
      {loading ? (
        <ActivityIndicator color={variant === 'outline' || variant === 'ghost' ? colors.primary : colors.textInverted} />
      ) : (
        <Text style={[styles.text, getTextStyle()]}>{children}</Text>
      )}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  base: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: borderRadius.md,
    ...shadows.sm,
  },
  primary: {
    backgroundColor: colors.primary,
  },
  secondary: {
    backgroundColor: colors.secondary,
  },
  outline: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: colors.primary,
  },
  ghost: {
    backgroundColor: 'transparent',
  },
  danger: {
    backgroundColor: colors.error,
  },
  disabled: {
    opacity: 0.5,
  },
  sm: {
    paddingVertical: spacing.xs,
    paddingHorizontal: spacing.sm,
  },
  md: {
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.md,
  },
  lg: {
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.lg,
  },
  text: {
    ...typography.bodyBold,
    textAlign: 'center',
  },
});
