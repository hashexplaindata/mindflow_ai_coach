// lib/payments.ts
import { useState, useEffect } from 'react';
import { Platform } from 'react-native';
import Purchases, { PurchasesPackage, CustomerInfo } from 'react-native-purchases';

export const getApiKey = (): string | undefined => {
  if (__DEV__ && process.env.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY) {
    return process.env.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY;
  }
  
  return Platform.select({
    ios: process.env.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY,
    android: process.env.EXPO_PUBLIC_REVENUECAT_ANDROID_API_KEY,
    default: undefined,
  });
};

export const initializePayments = async (): Promise<boolean> => {
  if (Platform.OS === 'web') return false;
  
  const apiKey = getApiKey();
  if (!apiKey) return false;
  
  try {
    await Purchases.configure({ apiKey });
    return true;
  } catch (error) {
    console.error('[RevenueCat] Error:', error);
    return false;
  }
};

export const usePackages = () => {
  const [packages, setPackages] = useState<PurchasesPackage[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (Platform.OS === 'web') {
      setIsLoading(false);
      return;
    }
    
    const fetchPackages = async () => {
      try {
        const offerings = await Purchases.getOfferings();
        setPackages(offerings.current?.availablePackages ?? []);
      } catch (error) {
        console.error('Error fetching packages:', error);
      } finally {
        setIsLoading(false);
      }
    };
    fetchPackages();
  }, []);

  const purchasePackage = async (pkg: PurchasesPackage) => {
    return Purchases.purchasePackage(pkg);
  };

  return { packages, isLoading, purchasePackage };
};

export const useCustomerInfo = () => {
  const [customerInfo, setCustomerInfo] = useState<CustomerInfo | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (Platform.OS === 'web') {
      setIsLoading(false);
      return;
    }
    
    let listener: ((info: CustomerInfo) => void) | null = null;
    
    const setup = async () => {
      try {
        const info = await Purchases.getCustomerInfo();
        setCustomerInfo(info);
      } catch (error) {
        console.error('Error fetching customer info:', error);
      } finally {
        setIsLoading(false);
      }
      
      listener = (info: CustomerInfo) => setCustomerInfo(info);
      Purchases.addCustomerInfoUpdateListener(listener);
    };
    
    setup();
    
    return () => {
      if (listener) Purchases.removeCustomerInfoUpdateListener(listener);
    };
  }, []);

  const isPro = !!customerInfo?.entitlements.active['pro_access'];

  return { customerInfo, isLoading, isPro };
};
