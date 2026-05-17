import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { errorHandler } from './middleware/errorHandler';
import { authRoutes } from './modules/auth/auth.routes';
import { webAuthRoutes } from './modules/auth/web-auth.routes';
import { taskRoutes } from './modules/tasks/task.routes';
import { dashboardRoutes } from './modules/dashboard/dashboard.routes';
import { profileRoutes } from './modules/profile/profile.routes';
import { historyRoutes } from './modules/history/history.routes';
import { focusRoutes } from './modules/focus/focus.routes';
import { settingsRoutes } from './modules/settings/settings.routes';
import { notificationRoutes } from './modules/notifications/notification.routes';
import { uploadRoutes } from './modules/upload/upload.routes';

const app = express();

// ---------------------------------------------------------------------------
// Global Middleware
// ---------------------------------------------------------------------------
app.use(helmet({ contentSecurityPolicy: false }));
app.use(cors());
app.use(express.json());

// ---------------------------------------------------------------------------
// Health Check
// ---------------------------------------------------------------------------
app.get('/api/health', (_req, res) => {
  res.json({ status: 'i<3nad', timestamp: new Date().toISOString() });
});

// ---------------------------------------------------------------------------
// Web & API Routes
// ---------------------------------------------------------------------------
app.use('/auth', webAuthRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/history', historyRoutes);
app.use('/api/focus', focusRoutes);
app.use('/api/settings', settingsRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/upload', uploadRoutes);

// ---------------------------------------------------------------------------
// Error Handling
// ---------------------------------------------------------------------------
app.use(errorHandler);

export { app };
