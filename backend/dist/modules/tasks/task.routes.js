"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.taskRoutes = void 0;
const express_1 = require("express");
const task_controller_1 = require("./task.controller");
const auth_1 = require("../../middleware/auth");
const router = (0, express_1.Router)();
exports.taskRoutes = router;
const controller = new task_controller_1.TaskController();
// All task routes require authentication
router.use(auth_1.authMiddleware);
router.post('/', controller.create);
router.get('/', controller.list);
router.get('/:id', controller.getById);
router.delete('/:id/complete', controller.complete);
//# sourceMappingURL=task.routes.js.map