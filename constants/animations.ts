// constants/animations.ts
import { Easing } from 'react-native-reanimated';

export const animationDurations = {
  fast: 150,
  normal: 300,
  slow: 500,
  vSlow: 800,
};

export const animationEasing = {
  easeIn: Easing.in(Easing.ease),
  easeOut: Easing.out(Easing.ease),
  easeInOut: Easing.inOut(Easing.ease),
  bezier: Easing.bezier(0.25, 0.1, 0.25, 1),
};

export const animationTimings = {
  spring: {
    damping: 15,
    stiffness: 150,
    mass: 1,
  },
  bouncy: {
    damping: 10,
    stiffness: 100,
    mass: 1,
  },
};
