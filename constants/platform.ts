// constants/platform.ts
import { Platform, Dimensions, StatusBar } from 'react-native';

const { width: windowWidth, height: windowHeight } = Dimensions.get('window');

export const isIOS = Platform.OS === 'ios';
export const isAndroid = Platform.OS === 'android';
export const isWeb = Platform.OS === 'web';

export const screenDimensions = {
  width: windowWidth,
  height: windowHeight,
};

export const platformSpacing = {
  statusBarHeight: StatusBar.currentHeight || (isIOS ? 44 : 0),
  headerHeight: isIOS ? 44 : 56,
  tabBarHeight: isIOS ? 83 : 64,
  safeBottomPadding: isIOS ? 34 : 0,
};

export const platformBehavior = {
  hasHaptics: !isWeb,
  hasCamera: !isWeb,
  hasBiometrics: !isWeb,
};
