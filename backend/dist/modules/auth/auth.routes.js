"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authRoutes = void 0;
const express_1 = require("express");
const auth_controller_1 = require("./auth.controller");
const auth_1 = require("../../middleware/auth");
const router = (0, express_1.Router)();
exports.authRoutes = router;
const controller = new auth_controller_1.AuthController();
router.post('/signup', controller.signup);
router.post('/login', controller.login);
router.post('/google', controller.googleSignIn);
router.get('/me', auth_1.authMiddleware, controller.me);
//# sourceMappingURL=auth.routes.js.map