import express, { type Express, type Request, type Response } from 'express';
import { storage } from './storage.js';
import { getUncachableStripeClient, getStripePublishableKey } from './stripeClient.js';

export function registerRoutes(app: Express) {
  app.get('/api/health', (req: Request, res: Response) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
  });

  app.get('/api/stripe/publishable-key', async (req: Request, res: Response) => {
    try {
      const publishableKey = await getStripePublishableKey();
      res.json({ publishableKey });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });

  app.get('/api/products', async (req: Request, res: Response) => {
    try {
      const rows = await storage.listProductsWithPrices();
      
      const productsMap = new Map();
      for (const row of rows as any[]) {
        if (!productsMap.has(row.product_id)) {
          productsMap.set(row.product_id, {
            id: row.product_id,
            name: row.product_name,
            description: row.product_description,
            active: row.product_active,
            metadata: row.product_metadata,
            prices: []
          });
        }
        if (row.price_id) {
          productsMap.get(row.product_id).prices.push({
            id: row.price_id,
            unit_amount: row.unit_amount,
            currency: row.currency,
            recurring: row.recurring,
            active: row.price_active,
            metadata: row.price_metadata,
          });
        }
      }

      res.json({ data: Array.from(productsMap.values()) });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/checkout', async (req: Request, res: Response) => {
    try {
      const { priceId, userId, email, successUrl, cancelUrl } = req.body;
      
      if (!priceId) {
        return res.status(400).json({ error: 'priceId is required' });
      }

      const stripe = await getUncachableStripeClient();
      
      let user = userId ? await storage.getUser(userId) : null;
      let customerId = user?.stripeCustomerId;

      if (!customerId && email) {
        const customer = await stripe.customers.create({
          email,
          metadata: { userId: userId || 'anonymous' },
        });
        customerId = customer.id;
        
        if (user) {
          await storage.updateUserStripeInfo(user.id, { stripeCustomerId: customerId });
        }
      }

      const sessionConfig: any = {
        payment_method_types: ['card'],
        line_items: [{ price: priceId, quantity: 1 }],
        mode: 'subscription',
        success_url: successUrl || `${req.protocol}://${req.get('host')}/checkout/success`,
        cancel_url: cancelUrl || `${req.protocol}://${req.get('host')}/checkout/cancel`,
      };

      if (customerId) {
        sessionConfig.customer = customerId;
      }

      const session = await stripe.checkout.sessions.create(sessionConfig);

      res.json({ url: session.url, sessionId: session.id });
    } catch (error: any) {
      console.error('Checkout error:', error);
      res.status(500).json({ error: error.message });
    }
  });

  app.get('/api/subscription', async (req: Request, res: Response) => {
    try {
      const userId = req.query.userId as string;
      
      if (!userId) {
        return res.json({ subscription: null });
      }

      const user = await storage.getUser(userId);
      if (!user?.stripeSubscriptionId) {
        return res.json({ subscription: null });
      }

      const subscription = await storage.getSubscription(user.stripeSubscriptionId);
      res.json({ subscription });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/sessions', async (req: Request, res: Response) => {
    try {
      const { userId, meditationId, durationSeconds } = req.body;
      
      if (!userId || !meditationId || typeof durationSeconds !== 'number') {
        return res.status(400).json({ 
          error: 'userId, meditationId, and durationSeconds are required' 
        });
      }

      const session = await storage.createMeditationSession({
        userId,
        meditationId,
        durationSeconds,
      });

      const progress = await storage.updateProgressAfterSession(userId, durationSeconds);

      res.json({ session, progress });
    } catch (error: any) {
      console.error('Session logging error:', error);
      res.status(500).json({ error: error.message });
    }
  });

  app.get('/api/progress/:userId', async (req: Request, res: Response) => {
    try {
      const { userId } = req.params;
      
      const progress = await storage.getUserProgress(userId);
      const sessions = await storage.getUserSessions(userId, 10);

      res.json({ 
        progress: progress || { 
          totalMinutes: 0, 
          currentStreak: 0, 
          longestStreak: 0,
          lastSessionDate: null 
        },
        recentSessions: sessions 
      });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/users', async (req: Request, res: Response) => {
    try {
      const { id, email } = req.body;
      
      if (!id || !email) {
        return res.status(400).json({ error: 'id and email are required' });
      }

      const existing = await storage.getUser(id);
      if (existing) {
        return res.json({ user: existing });
      }

      const user = await storage.createUser({ id, email });
      res.json({ user });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });
}
