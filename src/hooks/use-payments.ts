import { useState, useEffect, useCallback } from 'react';

const PRO_STORAGE_KEY = 'mindflow_pro_access';

export const usePayments = () => {
  const [isPro, setIsPro] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const stored = localStorage.getItem(PRO_STORAGE_KEY);
    setIsPro(stored === 'true');
    setIsLoading(false);
  }, []);

  const upgrade = useCallback(() => {
    // On web, RevenueCat doesn't have a native SDK.
    // For the hackathon demo, we toggle Pro locally.
    // In production, this would call a RevenueCat REST API or redirect to a Stripe checkout.
    localStorage.setItem(PRO_STORAGE_KEY, 'true');
    setIsPro(true);
  }, []);

  const checkEntitlement = useCallback((entitlementId: string): boolean => {
    if (entitlementId === 'pro_access') return isPro;
    return false;
  }, [isPro]);

  return { isPro, isLoading, upgrade, checkEntitlement };
};
