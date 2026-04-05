"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.prisma = void 0;
const client_1 = require("@prisma/client");
const adapter_pg_1 = require("@prisma/adapter-pg");
// Use the direct URL (port 5432) for Prisma queries
const connectionString = process.env['DIRECT_URL'] || process.env['DATABASE_URL'] || '';
const adapter = new adapter_pg_1.PrismaPg({ connectionString });
const globalForPrisma = globalThis;
exports.prisma = globalForPrisma.prisma ??
    new client_1.PrismaClient({
        adapter,
    });
if (process.env['NODE_ENV'] !== 'production') {
    globalForPrisma.prisma = exports.prisma;
}
// Test connection on startup
exports.prisma.$connect()
    .then(() => console.log('✅ Database connected'))
    .catch((err) => console.error('❌ Database connection failed:', err.message));
//# sourceMappingURL=prisma.js.map