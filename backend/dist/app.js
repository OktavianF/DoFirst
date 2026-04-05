"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.app = void 0;
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const errorHandler_1 = require("./middleware/errorHandler");
const auth_routes_1 = require("./modules/auth/auth.routes");
const task_routes_1 = require("./modules/tasks/task.routes");
const dashboard_routes_1 = require("./modules/dashboard/dashboard.routes");
const app = (0, express_1.default)();
exports.app = app;
// ---------------------------------------------------------------------------
// Global Middleware
// ---------------------------------------------------------------------------
app.use((0, helmet_1.default)());
app.use((0, cors_1.default)());
app.use(express_1.default.json());
// ---------------------------------------------------------------------------
// Health Check
// ---------------------------------------------------------------------------
app.get('/api/health', (_req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
// ---------------------------------------------------------------------------
// API Routes
// ---------------------------------------------------------------------------
app.use('/api/auth', auth_routes_1.authRoutes);
app.use('/api/tasks', task_routes_1.taskRoutes);
app.use('/api/dashboard', dashboard_routes_1.dashboardRoutes);
// ---------------------------------------------------------------------------
// Error Handling
// ---------------------------------------------------------------------------
app.use(errorHandler_1.errorHandler);
//# sourceMappingURL=app.js.map