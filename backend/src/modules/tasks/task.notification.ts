import cron from 'node-cron';
import { TaskRepository } from './task.repository';

const taskRepository = new TaskRepository();

async function notifyUpcomingDeadlines() {
  try {
    const now = new Date();
    const nextHour = new Date(now.getTime() + 1000 * 60 * 60);

    const tasks = await taskRepository.findUpcomingDeadlineTasksToNotify(now, nextHour);

    for (const task of tasks) {
      console.log(`Reminder: Task ${task.title} akan segera deadline`);
      await taskRepository.markTaskNotified(task.id, task.userId);
    }
  } catch (error) {
    console.error('Task notification error:', error);
  }
}

cron.schedule('* * * * *', () => {
  notifyUpcomingDeadlines();
});
