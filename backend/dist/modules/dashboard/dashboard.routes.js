"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.dashboardRoutes = void 0;
const express_1 = require("express");
const dashboard_controller_1 = require("./dashboard.controller");
const auth_1 = require("../../middleware/auth");
const router = (0, express_1.Router)();
exports.dashboardRoutes = router;
const controller = new dashboard_controller_1.DashboardController();
router.get('/', auth_1.authMiddleware, controller.getDashboard);
//# sourceMappingURL=dashboard.routes.js.map