import winston from 'winston';
import { env } from '../config/env';

/**
 * Winston logger instance configured for the application.
 * Utilizes the console transport with structured formatting including
 * timestamp, colorization, and custom print format.
 */
export const logger = winston.createLogger({
  level: env.LOG_LEVEL,
  format: winston.format.combine(
    winston.format.colorize({ all: true }),
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.printf(({ timestamp, level, message, ...meta }) => {
      const metaStr = Object.keys(meta).length ? JSON.stringify(meta) : '';
      return `[${timestamp}] ${level}: ${message} ${metaStr}`;
    })
  ),
  transports: [
    new winston.transports.Console()
  ],
});
