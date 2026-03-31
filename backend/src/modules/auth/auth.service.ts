import { supabaseAdmin } from '../../lib/supabase';
import { prisma } from '../../lib/prisma';
import { AppError } from '../../lib/AppError';

export class AuthService {
  /**
   * Register a new user via Supabase Auth and create a profile in our DB.
   */
  async signup(email: string, password: string, fullName: string) {
    // Use admin API to create user (auto-confirms email)
    const { data: createData, error: createError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { full_name: fullName },
    });

    if (createError) {
      throw AppError.badRequest(createError.message);
    }

    if (!createData.user) {
      throw AppError.badRequest('Signup failed');
    }

    // Create profile in our database
    const profile = await prisma.profile.create({
      data: {
        id: createData.user.id,
        fullName,
      },
    });

    // Sign in immediately to get session tokens
    const { data: loginData, error: loginError } = await supabaseAdmin.auth.signInWithPassword({
      email,
      password,
    });

    return {
      user: {
        id: createData.user.id,
        email: createData.user.email,
      },
      profile,
      session: loginError ? null : {
        accessToken: loginData.session.access_token,
        refreshToken: loginData.session.refresh_token,
        expiresAt: loginData.session.expires_at,
      },
    };
  }

  /**
   * Authenticate an existing user via Supabase Auth.
   */
  async login(email: string, password: string) {
    const { data, error } = await supabaseAdmin.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      throw AppError.unauthorized(error.message);
    }

    // Ensure profile exists (self-healing)
    let profile = await prisma.profile.findUnique({
      where: { id: data.user.id },
    });

    if (!profile) {
      profile = await prisma.profile.create({
        data: {
          id: data.user.id,
          fullName: data.user.user_metadata?.full_name || 'User',
        },
      });
    }

    return {
      user: {
        id: data.user.id,
        email: data.user.email,
      },
      profile,
      session: {
        accessToken: data.session.access_token,
        refreshToken: data.session.refresh_token,
        expiresAt: data.session.expires_at,
      },
    };
  }

  /**
   * Retrieve the profile for a given user ID.
   */
  async getProfile(userId: string) {
    const profile = await prisma.profile.findUnique({
      where: { id: userId },
    });

    if (!profile) {
      throw AppError.notFound('Profile not found');
    }

    return profile;
  }

  /**
   * Sign in with Google ID token.
   */
  async googleSignIn(idToken: string) {
    const { data, error } = await supabaseAdmin.auth.signInWithIdToken({
      provider: 'google',
      token: idToken,
    });

    if (error) {
      throw AppError.unauthorized(error.message);
    }

    // Ensure profile exists (self-healing)
    let profile = await prisma.profile.findUnique({
      where: { id: data.user.id },
    });

    if (!profile) {
      profile = await prisma.profile.create({
        data: {
          id: data.user.id,
          fullName: data.user.user_metadata?.full_name || data.user.user_metadata?.name || 'User',
          avatarUrl: data.user.user_metadata?.avatar_url || null,
        },
      });
    }

    return {
      user: {
        id: data.user.id,
        email: data.user.email,
      },
      profile,
      session: data.session ? {
        accessToken: data.session.access_token,
        refreshToken: data.session.refresh_token,
        expiresAt: data.session.expires_at,
      } : null,
    };
  }
}
