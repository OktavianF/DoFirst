import { createClient } from '@supabase/supabase-js';
import { env } from '../config/env';

/**
 * Supabase Admin client — uses the service_role key.
 * Use this for server-side operations (user management, bypassing RLS).
 */
export const supabaseAdmin = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
});

/**
 * Creates a Supabase client scoped to a specific user's access token.
 * Use this when you need to perform operations as the authenticated user.
 */
export function createSupabaseClient(accessToken: string) {
  return createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY, {
    global: {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    },
  });
}
