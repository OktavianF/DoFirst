"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TaskController = void 0;
const task_service_1 = require("./task.service");
const taskService = new task_service_1.TaskService();
class TaskController {
    async create(req, res, next) {
        try {
            const { user } = req;
            const task = await taskService.createTask(user.id, req.body);
            res.status(201).json({
                success: true,
                data: task,
            });
        }
        catch (err) {
            next(err);
        }
    }
    async list(req, res, next) {
        try {
            const { user } = req;
            const tasks = await taskService.getTasksByUser(user.id);
            res.json({
                success: true,
                data: tasks,
                count: tasks.length,
            });
        }
        catch (err) {
            next(err);
        }
    }
    async getById(req, res, next) {
        try {
            const { user } = req;
            const task = await taskService.getTaskById(user.id, req.params.id);
            res.json({
                success: true,
                data: task,
            });
        }
        catch (err) {
            next(err);
        }
    }
    async complete(req, res, next) {
        try {
            const { user } = req;
            const result = await taskService.completeTask(user.id, req.params.id);
            res.json({
                success: true,
                data: result,
            });
        }
        catch (err) {
            next(err);
        }
    }
}
exports.TaskController = TaskController;
//# sourceMappingURL=task.controller.js.map