import express from 'express';
import cors from 'cors';
import { runMigrations } from 'stripe-replit-sync';
import { registerRoutes } from './routes.js';
import { getStripeSync } from './stripeClient.js';
import { WebhookHandlers } from './webhookHandlers.js';

const app = express();
const PORT = 3000;

app.use(cors({
  origin: [
    'http://localhost:5000',
    'http://127.0.0.1:5000',
    /https:\/\/.*\.replit\.dev$/,
    /https:\/\/.*\.repl\.co$/,
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

async function initStripe() {
  const databaseUrl = process.env.DATABASE_URL;

  if (!databaseUrl) {
    console.warn('DATABASE_URL not set - Stripe sync disabled');
    return;
  }

  try {
    console.log('Initializing Stripe schema...');
    await runMigrations({ 
      databaseUrl,
      schema: 'stripe'
    });
    console.log('Stripe schema ready');

    const stripeSync = await getStripeSync();

    console.log('Setting up managed webhook...');
    const domains = process.env.REPLIT_DOMAINS?.split(',') || [];
    if (domains.length > 0) {
      const webhookBaseUrl = `https://${domains[0]}`;
      try {
        const result = await stripeSync.findOrCreateManagedWebhook(
          `${webhookBaseUrl}/api/stripe/webhook`
        );
        if (result?.webhook?.url) {
          console.log(`Webhook configured: ${result.webhook.url}`);
        } else {
          console.log('Webhook setup returned empty result - Stripe may not be fully configured');
        }
      } catch (webhookError: any) {
        console.warn('Could not set up webhook:', webhookError.message);
      }
    } else {
      console.log('No REPLIT_DOMAINS found - skipping webhook setup');
    }

    console.log('Syncing Stripe data...');
    stripeSync.syncBackfill()
      .then(() => console.log('Stripe data synced'))
      .catch((err: Error) => console.error('Error syncing Stripe data:', err));
  } catch (error) {
    console.error('Failed to initialize Stripe:', error);
  }
}

app.post(
  '/api/stripe/webhook',
  express.raw({ type: 'application/json' }),
  async (req, res) => {
    const signature = req.headers['stripe-signature'];

    if (!signature) {
      return res.status(400).json({ error: 'Missing stripe-signature' });
    }

    try {
      const sig = Array.isArray(signature) ? signature[0] : signature;

      if (!Buffer.isBuffer(req.body)) {
        console.error('STRIPE WEBHOOK ERROR: req.body is not a Buffer');
        return res.status(500).json({ error: 'Webhook processing error' });
      }

      await WebhookHandlers.processWebhook(req.body as Buffer, sig);

      res.status(200).json({ received: true });
    } catch (error: any) {
      console.error('Webhook error:', error.message);
      res.status(400).json({ error: 'Webhook processing error' });
    }
  }
);

app.use(express.json());
app.use(express.urlencoded({ extended: false }));

registerRoutes(app);

async function startServer() {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`MindFlow API server running on http://0.0.0.0:${PORT}`);
  });

  initStripe().catch((err) => {
    console.error('Stripe initialization error (non-blocking):', err.message);
  });
}

startServer();
