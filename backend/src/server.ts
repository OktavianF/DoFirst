import { app } from './app';
import { env } from './config/env';
import './modules/tasks/task.notification';

const PORT = env.PORT;

app.listen(PORT, () => {
  console.log(`🚀 DoFirst API running on http://localhost:${PORT}`);
  console.log(`📋 Health check: http://localhost:${PORT}/api/health`);
  console.log(`🌍 Environment: ${env.NODE_ENV}`);
});
