import { Router } from 'express';
import path from 'path';
import fs from 'fs';

const router = Router();

/**
 * Serves the beautiful reset password page.
 */
router.get('/reset-password', (_req, res) => {
  // 1. Try production path (dist/views)
  const filePath = path.join(__dirname, '../../views/reset-password.html');
  if (fs.existsSync(filePath)) {
    return res.sendFile(filePath);
  }

  // 2. Try development path (src/views)
  const fallbackPath = path.join(__dirname, '../../views/reset-password.html');
  if (fs.existsSync(fallbackPath)) {
    return res.sendFile(fallbackPath);
  }

  // 3. Try process.cwd() fallback
  const cwdPath = path.join(process.cwd(), 'src', 'views', 'reset-password.html');
  if (fs.existsSync(cwdPath)) {
    return res.sendFile(cwdPath);
  }

  const workspacePath = path.join(process.cwd(), 'backend', 'src', 'views', 'reset-password.html');
  if (fs.existsSync(workspacePath)) {
    return res.sendFile(workspacePath);
  }

  res.status(404).send('Reset password page not found.');
});

export { router as webAuthRoutes };
