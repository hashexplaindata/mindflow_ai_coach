// components/ui/Avatar.tsx
import React from 'react';
import { View, Text, Image, StyleSheet } from 'react-native';
import { colors, borderRadius, typography } from '@/constants/design';

interface AvatarProps {
  name: string;
  src?: string;
  size?: 'sm' | 'md' | 'lg' | 'xl';
}

export function Avatar({ name, src, size = 'md' }: AvatarProps) {
  const getInitials = (n: string) => n.split(' ').map(p => p[0]).join('').toUpperCase().slice(0, 2);
  
  const getSizeStyle = () => {
    switch (size) {
      case 'sm': return { width: 32, height: 32, borderRadius: 16 };
      case 'lg': return { width: 64, height: 64, borderRadius: 32 };
      case 'xl': return { width: 80, height: 80, borderRadius: 40 };
      default: return { width: 48, height: 48, borderRadius: 24 };
    }
  };

  const getFontSize = () => {
    switch (size) {
      case 'sm': return 12;
      case 'lg': return 24;
      case 'xl': return 32;
      default: return 18;
    }
  };

  if (src) {
    return <Image source={{ uri: src }} style={[styles.base, getSizeStyle()]} />;
  }

  return (
    <View style={[styles.base, styles.fallback, getSizeStyle()]}>
      <Text style={[styles.initials, { fontSize: getFontSize() }]}>{getInitials(name)}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  base: {
    backgroundColor: colors.surfaceVariant,
  },
  fallback: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  initials: {
    ...typography.bodyBold,
    color: colors.primary,
  },
});
