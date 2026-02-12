import { createClient } from '@blinkdotnew/sdk'

export const blink = createClient({
  projectId: import.meta.env.VITE_BLINK_PROJECT_ID || 'mindflow-ai-app-z9ziag67',
  publishableKey: import.meta.env.VITE_BLINK_PUBLISHABLE_KEY || 'blnk_pk_67nNH89fUOVlYFnRuAiDqkjmvLj1X2lw',
  auth: { mode: 'managed' },
})
