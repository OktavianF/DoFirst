"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authMiddleware = authMiddleware;
const supabase_1 = require("../lib/supabase");
const AppError_1 = require("../lib/AppError");
/**
 * Middleware that verifies Supabase JWT from Authorization header.
 * Attaches the authenticated user to req.user.
 */
async function authMiddleware(req, _res, next) {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            throw AppError_1.AppError.unauthorized('Missing or invalid Authorization header');
        }
        const token = authHeader.split(' ')[1];
        const { data: { user }, error, } = await supabase_1.supabaseAdmin.auth.getUser(token);
        if (error || !user) {
            throw AppError_1.AppError.unauthorized('Invalid or expired token');
        }
        req.user = {
            id: user.id,
            email: user.email,
        };
        next();
    }
    catch (err) {
        next(err);
    }
}
//# sourceMappingURL=auth.js.map