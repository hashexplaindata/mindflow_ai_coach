// components/ui/Container.tsx
import React from 'react';
import { View, StyleSheet, ViewProps, SafeAreaView, Platform } from 'react-native';
import { colors, spacing } from '@/constants/design';

interface ContainerProps extends ViewProps {
  useSafeArea?: boolean;
}

export function Container({ children, style, useSafeArea = true, ...props }: ContainerProps) {
  const Wrapper = useSafeArea ? SafeAreaView : View;
  
  return (
    <Wrapper style={[styles.container, style]} {...props}>
      <View style={styles.inner}>
        {children}
      </View>
    </Wrapper>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  inner: {
    flex: 1,
    paddingHorizontal: spacing.md,
  },
});
