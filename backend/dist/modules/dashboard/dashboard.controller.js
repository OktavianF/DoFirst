"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DashboardController = void 0;
const dashboard_service_1 = require("./dashboard.service");
const dashboardService = new dashboard_service_1.DashboardService();
class DashboardController {
    async getDashboard(req, res, next) {
        try {
            const { user } = req;
            const dashboard = await dashboardService.getDashboard(user.id);
            res.json({
                success: true,
                data: dashboard,
            });
        }
        catch (err) {
            next(err);
        }
    }
}
exports.DashboardController = DashboardController;
//# sourceMappingURL=dashboard.controller.js.map