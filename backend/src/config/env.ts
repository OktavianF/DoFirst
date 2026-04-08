import dotenv from 'dotenv';
import path from 'path';

const isProd = process.env.NODE_ENV === 'production';
const envFile = isProd ? '.env.production' : '.env.development';

// Prioritaskan file env spesifik (.env.development / .env.production)
dotenv.config({ path: path.resolve(__dirname, `../../${envFile}`) });
// Opsional fallback ke .env biasa jika file di atas tidak ditemukan 
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

function requireEnv(key: string): string {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
}

export const env = {
  PORT: parseInt(process.env.PORT || '3000', 10),
  DATABASE_URL: requireEnv('DATABASE_URL'),
  DIRECT_URL: requireEnv('DIRECT_URL'),
  SUPABASE_URL: requireEnv('SUPABASE_URL'),
  SUPABASE_SERVICE_ROLE_KEY: requireEnv('SUPABASE_SERVICE_ROLE_KEY'),
  SUPABASE_ANON_KEY: requireEnv('SUPABASE_ANON_KEY'),
  NODE_ENV: process.env.NODE_ENV || 'development',
} as const;
