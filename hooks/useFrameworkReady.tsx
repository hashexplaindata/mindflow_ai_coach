// hooks/useFrameworkReady.tsx
import { useEffect, useState } from 'react';

export function useFrameworkReady() {
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    // Simulate any initialization needed
    setIsReady(true);
  }, []);

  return isReady;
}
