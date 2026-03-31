import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';

// Use the direct URL (port 5432) for Prisma queries
const connectionString = process.env['DIRECT_URL'] || process.env['DATABASE_URL'] || '';

const adapter = new PrismaPg({ connectionString });

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    adapter,
  });

if (process.env['NODE_ENV'] !== 'production') {
  globalForPrisma.prisma = prisma;
}

// Test connection on startup
prisma.$connect()
  .then(() => console.log('✅ Database connected'))
  .catch((err: Error) => console.error('❌ Database connection failed:', err.message));
