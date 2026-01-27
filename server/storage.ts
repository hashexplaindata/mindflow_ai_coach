import { users, meditationSessions, userProgress } from '../shared/schema.js';
import { eq, sql, desc } from 'drizzle-orm';
import { db } from './db.js';

export class Storage {
  async getProduct(productId: string) {
    const result = await db.execute(
      sql`SELECT * FROM stripe.products WHERE id = ${productId}`
    );
    return result.rows[0] || null;
  }

  async listProducts(active = true, limit = 20, offset = 0) {
    const result = await db.execute(
      sql`SELECT * FROM stripe.products WHERE active = ${active} LIMIT ${limit} OFFSET ${offset}`
    );
    return result.rows;
  }

  async listProductsWithPrices(active = true, limit = 20, offset = 0) {
    const result = await db.execute(
      sql`
        WITH paginated_products AS (
          SELECT id, name, description, metadata, active
          FROM stripe.products
          WHERE active = ${active}
          ORDER BY id
          LIMIT ${limit} OFFSET ${offset}
        )
        SELECT 
          p.id as product_id,
          p.name as product_name,
          p.description as product_description,
          p.active as product_active,
          p.metadata as product_metadata,
          pr.id as price_id,
          pr.unit_amount,
          pr.currency,
          pr.recurring,
          pr.active as price_active,
          pr.metadata as price_metadata
        FROM paginated_products p
        LEFT JOIN stripe.prices pr ON pr.product = p.id AND pr.active = true
        ORDER BY p.id, pr.unit_amount
      `
    );
    return result.rows;
  }

  async getPrice(priceId: string) {
    const result = await db.execute(
      sql`SELECT * FROM stripe.prices WHERE id = ${priceId}`
    );
    return result.rows[0] || null;
  }

  async listPrices(active = true, limit = 20, offset = 0) {
    const result = await db.execute(
      sql`SELECT * FROM stripe.prices WHERE active = ${active} LIMIT ${limit} OFFSET ${offset}`
    );
    return result.rows;
  }

  async getPricesForProduct(productId: string) {
    const result = await db.execute(
      sql`SELECT * FROM stripe.prices WHERE product = ${productId} AND active = true`
    );
    return result.rows;
  }

  async getSubscription(subscriptionId: string) {
    const result = await db.execute(
      sql`SELECT * FROM stripe.subscriptions WHERE id = ${subscriptionId}`
    );
    return result.rows[0] || null;
  }

  async getUser(id: string) {
    const [user] = await db.select().from(users).where(eq(users.id, id));
    return user;
  }

  async getUserByEmail(email: string) {
    const [user] = await db.select().from(users).where(eq(users.email, email));
    return user;
  }

  async createUser(data: { id: string; email: string }) {
    const [user] = await db.insert(users).values(data).returning();
    return user;
  }

  async updateUserStripeInfo(userId: string, stripeInfo: {
    stripeCustomerId?: string;
    stripeSubscriptionId?: string;
  }) {
    const [user] = await db.update(users).set(stripeInfo).where(eq(users.id, userId)).returning();
    return user;
  }

  async createMeditationSession(data: {
    userId: string;
    meditationId: string;
    durationSeconds: number;
  }) {
    const [session] = await db.insert(meditationSessions).values(data).returning();
    return session;
  }

  async getUserSessions(userId: string, limit = 50) {
    return await db.select()
      .from(meditationSessions)
      .where(eq(meditationSessions.userId, userId))
      .orderBy(desc(meditationSessions.completedAt))
      .limit(limit);
  }

  async getUserProgress(userId: string) {
    const [progress] = await db.select()
      .from(userProgress)
      .where(eq(userProgress.userId, userId));
    return progress;
  }

  async upsertUserProgress(userId: string, data: {
    totalMinutes: number;
    currentStreak: number;
    longestStreak: number;
    lastSessionDate: Date;
  }) {
    const existing = await this.getUserProgress(userId);
    
    if (existing) {
      const [updated] = await db.update(userProgress)
        .set(data)
        .where(eq(userProgress.userId, userId))
        .returning();
      return updated;
    } else {
      const [created] = await db.insert(userProgress)
        .values({ userId, ...data })
        .returning();
      return created;
    }
  }

  async updateProgressAfterSession(userId: string, durationSeconds: number) {
    const progress = await this.getUserProgress(userId);
    const now = new Date();
    const additionalMinutes = Math.floor(durationSeconds / 60);
    
    if (!progress) {
      return await this.upsertUserProgress(userId, {
        totalMinutes: additionalMinutes,
        currentStreak: 1,
        longestStreak: 1,
        lastSessionDate: now,
      });
    }

    const lastDate = progress.lastSessionDate ? new Date(progress.lastSessionDate) : null;
    const isConsecutiveDay = lastDate && 
      (now.getTime() - lastDate.getTime()) < 48 * 60 * 60 * 1000 &&
      now.toDateString() !== lastDate.toDateString();
    
    const isSameDay = lastDate && now.toDateString() === lastDate.toDateString();
    
    let newStreak = progress.currentStreak;
    if (isConsecutiveDay) {
      newStreak = progress.currentStreak + 1;
    } else if (!isSameDay && !isConsecutiveDay) {
      newStreak = 1;
    }
    
    return await this.upsertUserProgress(userId, {
      totalMinutes: progress.totalMinutes + additionalMinutes,
      currentStreak: newStreak,
      longestStreak: Math.max(progress.longestStreak, newStreak),
      lastSessionDate: now,
    });
  }
}

export const storage = new Storage();
