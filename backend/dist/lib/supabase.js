"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.supabaseAdmin = void 0;
exports.createSupabaseClient = createSupabaseClient;
const supabase_js_1 = require("@supabase/supabase-js");
const env_1 = require("../config/env");
/**
 * Supabase Admin client — uses the service_role key.
 * Use this for server-side operations (user management, bypassing RLS).
 */
exports.supabaseAdmin = (0, supabase_js_1.createClient)(env_1.env.SUPABASE_URL, env_1.env.SUPABASE_SERVICE_ROLE_KEY, {
    auth: {
        autoRefreshToken: false,
        persistSession: false,
    },
});
/**
 * Creates a Supabase client scoped to a specific user's access token.
 * Use this when you need to perform operations as the authenticated user.
 */
function createSupabaseClient(accessToken) {
    return (0, supabase_js_1.createClient)(env_1.env.SUPABASE_URL, env_1.env.SUPABASE_ANON_KEY, {
        global: {
            headers: {
                Authorization: `Bearer ${accessToken}`,
            },
        },
    });
}
//# sourceMappingURL=supabase.js.map