// lib/blink.ts
import { createClient, AsyncStorageAdapter } from '@blinkdotnew/sdk';
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as WebBrowser from 'expo-web-browser';

function getProjectId(): string {
  const envId = process.env.EXPO_PUBLIC_BLINK_PROJECT_ID;
  if (envId) return envId;
  return 'mindflow-ai-app-z9ziag67';
}

export const blink = createClient({
  projectId: getProjectId(),
  publishableKey: process.env.EXPO_PUBLIC_BLINK_PUBLISHABLE_KEY,
  auth: { 
    mode: 'headless',
    webBrowser: WebBrowser
  },
  storage: new AsyncStorageAdapter(AsyncStorage)
});
