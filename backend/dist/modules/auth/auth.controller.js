"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const auth_service_1 = require("./auth.service");
const authService = new auth_service_1.AuthService();
class AuthController {
    async signup(req, res, next) {
        try {
            const { email, password, fullName } = req.body;
            if (!email || !password || !fullName) {
                res.status(400).json({
                    success: false,
                    error: 'Email, password, and fullName are required',
                });
                return;
            }
            const result = await authService.signup(email, password, fullName);
            res.status(201).json({
                success: true,
                data: result,
            });
        }
        catch (err) {
            next(err);
        }
    }
    async login(req, res, next) {
        try {
            const { email, password } = req.body;
            if (!email || !password) {
                res.status(400).json({
                    success: false,
                    error: 'Email and password are required',
                });
                return;
            }
            const result = await authService.login(email, password);
            res.json({
                success: true,
                data: result,
            });
        }
        catch (err) {
            next(err);
        }
    }
    async me(req, res, next) {
        try {
            const { user } = req;
            const profile = await authService.getProfile(user.id);
            res.json({
                success: true,
                data: {
                    id: user.id,
                    email: user.email,
                    profile,
                },
            });
        }
        catch (err) {
            next(err);
        }
    }
    async googleSignIn(req, res, next) {
        try {
            const { idToken } = req.body;
            if (!idToken) {
                res.status(400).json({
                    success: false,
                    error: 'idToken is required',
                });
                return;
            }
            const result = await authService.googleSignIn(idToken);
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
exports.AuthController = AuthController;
//# sourceMappingURL=auth.controller.js.map