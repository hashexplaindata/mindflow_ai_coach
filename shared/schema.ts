import { pgTable, text, integer, timestamp, serial } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: text('id').primaryKey(),
  email: text('email').notNull(),
  stripeCustomerId: text('stripe_customer_id'),
  stripeSubscriptionId: text('stripe_subscription_id'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export const meditationSessions = pgTable('meditation_sessions', {
  id: serial('id').primaryKey(),
  userId: text('user_id').notNull().references(() => users.id),
  meditationId: text('meditation_id').notNull(),
  durationSeconds: integer('duration_seconds').notNull(),
  completedAt: timestamp('completed_at').defaultNow().notNull(),
});

export const userProgress = pgTable('user_progress', {
  id: serial('id').primaryKey(),
  userId: text('user_id').notNull().references(() => users.id).unique(),
  totalMinutes: integer('total_minutes').notNull().default(0),
  currentStreak: integer('current_streak').notNull().default(0),
  longestStreak: integer('longest_streak').notNull().default(0),
  lastSessionDate: timestamp('last_session_date'),
});

export type User = typeof users.$inferSelect;
export type InsertUser = typeof users.$inferInsert;
export type MeditationSession = typeof meditationSessions.$inferSelect;
export type InsertMeditationSession = typeof meditationSessions.$inferInsert;
export type UserProgress = typeof userProgress.$inferSelect;
export type InsertUserProgress = typeof userProgress.$inferInsert;
