import { useState, useEffect } from 'react';

export const usePayments = () => {
  const [isPro, setIsPro] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Simulate checking entitlement
    const checkPro = async () => {
      // In a real RC web setup, you'd use their REST API or Web SDK
      // Here we simulate for the builder
      const isProUser = localStorage.getItem('mindflow_pro') === 'true';
      setIsPro(isProUser);
      setIsLoading(false);
    };
    checkPro();
  }, []);

  const upgrade = () => {
    localStorage.setItem('mindflow_pro', 'true');
    setIsPro(true);
  };

  return { isPro, isLoading, upgrade };
};
