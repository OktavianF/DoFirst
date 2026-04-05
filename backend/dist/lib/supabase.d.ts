/**
 * Supabase Admin client — uses the service_role key.
 * Use this for server-side operations (user management, bypassing RLS).
 */
export declare const supabaseAdmin: import("@supabase/supabase-js").SupabaseClient<any, "public", "public", any, any>;
/**
 * Creates a Supabase client scoped to a specific user's access token.
 * Use this when you need to perform operations as the authenticated user.
 */
export declare function createSupabaseClient(accessToken: string): import("@supabase/supabase-js").SupabaseClient<any, "public", "public", any, any>;
//# sourceMappingURL=supabase.d.ts.map