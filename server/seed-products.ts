import { getUncachableStripeClient } from './stripeClient.js';

async function seedProducts() {
  console.log('Starting product seed...');
  
  const stripe = await getUncachableStripeClient();

  const existingProducts = await stripe.products.search({ 
    query: "metadata['app']:'mindflow'" 
  });
  
  if (existingProducts.data.length > 0) {
    console.log('Products already exist. Skipping seed.');
    console.log('Existing products:', existingProducts.data.map(p => p.name));
    return;
  }

  console.log('Creating Free tier...');
  const freeTier = await stripe.products.create({
    name: 'MindFlow Free',
    description: 'Access basic meditations and track your progress. Perfect for beginners starting their mindfulness journey.',
    metadata: {
      app: 'mindflow',
      tier: 'free',
      features: JSON.stringify([
        '5 guided meditations',
        'Basic progress tracking',
        'Daily reminders',
      ]),
    },
  });
  console.log(`Created: ${freeTier.name} (${freeTier.id})`);

  console.log('Creating Premium Monthly...');
  const premiumMonthly = await stripe.products.create({
    name: 'MindFlow Premium Monthly',
    description: 'Unlock the full MindFlow experience with unlimited meditations, personalized coaching, and advanced features.',
    metadata: {
      app: 'mindflow',
      tier: 'premium',
      billing: 'monthly',
      features: JSON.stringify([
        'Unlimited meditations',
        'AI-powered personalized coaching',
        'Advanced NLP profiling',
        'Sleep stories and soundscapes',
        'Offline access',
        'Priority support',
      ]),
    },
  });

  const monthlyPrice = await stripe.prices.create({
    product: premiumMonthly.id,
    unit_amount: 999,
    currency: 'usd',
    recurring: { interval: 'month' },
    metadata: {
      app: 'mindflow',
      display_name: '$9.99/month',
    },
  });
  console.log(`Created: ${premiumMonthly.name} (${premiumMonthly.id}) - Price: ${monthlyPrice.id}`);

  console.log('Creating Premium Annual...');
  const premiumAnnual = await stripe.products.create({
    name: 'MindFlow Premium Annual',
    description: 'Get the best value with annual billing. Save over 30% compared to monthly. Includes all premium features.',
    metadata: {
      app: 'mindflow',
      tier: 'premium',
      billing: 'annual',
      savings: '33%',
      features: JSON.stringify([
        'Everything in Premium Monthly',
        'Save 33% with annual billing',
        'Exclusive annual member content',
        'Early access to new features',
      ]),
    },
  });

  const annualPrice = await stripe.prices.create({
    product: premiumAnnual.id,
    unit_amount: 7999,
    currency: 'usd',
    recurring: { interval: 'year' },
    metadata: {
      app: 'mindflow',
      display_name: '$79.99/year',
      monthly_equivalent: '$6.67/month',
    },
  });
  console.log(`Created: ${premiumAnnual.name} (${premiumAnnual.id}) - Price: ${annualPrice.id}`);

  console.log('\n✅ Product seed completed successfully!');
  console.log('\nCreated products:');
  console.log(`  1. ${freeTier.name} (Free tier, no price)`);
  console.log(`  2. ${premiumMonthly.name} - $9.99/month`);
  console.log(`  3. ${premiumAnnual.name} - $79.99/year`);
}

seedProducts()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('Seed failed:', error);
    process.exit(1);
  });
